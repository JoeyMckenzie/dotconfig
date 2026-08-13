"""Turn a single image file into a validated classification."""

from __future__ import annotations

import base64
import io
import json
from dataclasses import dataclass
from pathlib import Path
from typing import Any

from openai import OpenAI
from PIL import Image

IMAGE_SUFFIXES = frozenset({".png", ".jpg", ".jpeg", ".webp", ".gif", ".bmp", ".tiff"})

SYSTEM_PROMPT = (
    "You classify screenshots into exactly one category. Answer with JSON only, no prose."
)


@dataclass(frozen=True)
class Result:
    path: str
    category: str
    confidence: float
    reason: str
    error: str | None = None

    def as_json(self) -> str:
        return json.dumps(
            {
                "path": self.path,
                "category": self.category,
                "confidence": self.confidence,
                "reason": self.reason,
                "error": self.error,
            }
        )


def encode_image(path: Path, max_edge: int) -> str:
    """Downscale to `max_edge` and return a base64 JPEG data URL payload.

    Retina screenshots are routinely 6000px wide; sending them untouched is the
    difference between a few seconds and a minute per image on a local model.
    """
    with Image.open(path) as image:
        image = image.convert("RGB")
        if max(image.size) > max_edge:
            image.thumbnail((max_edge, max_edge), Image.Resampling.LANCZOS)
        buffer = io.BytesIO()
        image.save(buffer, format="JPEG", quality=80)

    return base64.b64encode(buffer.getvalue()).decode("ascii")


def build_prompt(categories: dict[str, str]) -> str:
    lines = [f"- {name}: {description}" for name, description in categories.items()]
    return (
        "Classify this screenshot into one of these categories:\n"
        + "\n".join(lines)
        + "\n\nRespond with JSON: "
        '{"category": "<one of the names above>", '
        '"confidence": <0.0-1.0>, '
        '"reason": "<at most 12 words>"}'
    )


def response_schema(categories: dict[str, str]) -> dict[str, Any]:
    return {
        "type": "json_schema",
        "json_schema": {
            "name": "classification",
            "strict": True,
            "schema": {
                "type": "object",
                "properties": {
                    "category": {"type": "string", "enum": list(categories)},
                    "confidence": {"type": "number"},
                    "reason": {"type": "string"},
                },
                "required": ["category", "confidence", "reason"],
                "additionalProperties": False,
            },
        },
    }


def classify(
    client: OpenAI,
    model: str,
    path: Path,
    categories: dict[str, str],
    max_edge: int,
    timeout: float,
) -> Result:
    """Classify one image, returning an `other` result rather than raising."""
    try:
        encoded = encode_image(path, max_edge)
    except OSError as exc:
        return Result(str(path), "other", 0.0, "", f"unreadable image: {exc}")

    try:
        response = client.chat.completions.create(
            model=model,
            timeout=timeout,
            temperature=0,
            max_tokens=200,
            response_format=response_schema(categories),  # ty: ignore[invalid-argument-type]
            messages=[
                {"role": "system", "content": SYSTEM_PROMPT},
                {
                    "role": "user",
                    "content": [
                        {"type": "text", "text": build_prompt(categories)},
                        {
                            "type": "image_url",
                            "image_url": {"url": f"data:image/jpeg;base64,{encoded}"},
                        },
                    ],
                },
            ],
        )
    except Exception as exc:  # noqa: BLE001 - one bad image must not kill the run
        return Result(str(path), "other", 0.0, "", f"{type(exc).__name__}: {exc}")

    content = response.choices[0].message.content or ""
    return parse_result(path, content, categories)


def parse_result(path: Path, content: str, categories: dict[str, str]) -> Result:
    """Parse the model's reply, tolerating fenced or chatty output."""
    text = content.strip().removeprefix("```json").removeprefix("```").removesuffix("```")
    start, end = text.find("{"), text.rfind("}")
    if start == -1 or end == -1:
        return Result(str(path), "other", 0.0, "", f"no JSON in response: {content[:120]}")

    try:
        payload = json.loads(text[start : end + 1])
    except json.JSONDecodeError as exc:
        return Result(str(path), "other", 0.0, "", f"bad JSON: {exc}")

    category = str(payload.get("category", "")).strip().lower()
    if category not in categories:
        return Result(str(path), "other", 0.0, "", f"unknown category: {category!r}")

    try:
        confidence = float(payload.get("confidence", 0.0))
    except (TypeError, ValueError):
        confidence = 0.0

    reason = str(payload.get("reason", "")).strip()
    return Result(str(path), category, round(min(max(confidence, 0.0), 1.0), 3), reason)
