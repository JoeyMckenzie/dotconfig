"""Provider endpoints and the category taxonomy."""

from __future__ import annotations

import os
import tomllib
from dataclasses import dataclass
from pathlib import Path

DEFAULT_CATEGORIES_FILE = Path(__file__).resolve().parents[2] / "categories.toml"


@dataclass(frozen=True)
class Provider:
    """An OpenAI-compatible chat completions endpoint."""

    name: str
    base_url: str | None
    default_model: str
    api_key_env: str | None
    # Local servers ignore the key but the SDK still requires a non-empty string.
    api_key_fallback: str | None = None

    def api_key(self) -> str:
        key = os.environ.get(self.api_key_env or "", "")
        if key:
            return key
        if self.api_key_fallback is not None:
            return self.api_key_fallback
        raise SystemExit(
            f"{self.name}: set {self.api_key_env} or pass --api-key",
        )


PROVIDERS: dict[str, Provider] = {
    "lmstudio": Provider(
        name="lmstudio",
        base_url="http://localhost:1234/v1",
        # Naming the model explicitly lets LM Studio JIT-load it, and avoids
        # surprises when several models are loaded at once. Must be vision-capable.
        default_model="google/gemma-4-e4b",
        api_key_env="LMSTUDIO_API_KEY",
        api_key_fallback="lm-studio",
    ),
    "openai": Provider(
        name="openai",
        base_url=None,
        default_model="gpt-4o-mini",
        api_key_env="OPENAI_API_KEY",
    ),
}


def load_categories(path: Path | None = None) -> dict[str, str]:
    """Read the `[categories]` table as an ordered name -> description mapping."""
    source = path or DEFAULT_CATEGORIES_FILE
    if not source.is_file():
        raise SystemExit(f"categories file not found: {source}")

    with source.open("rb") as handle:
        data = tomllib.load(handle)

    categories = data.get("categories")
    if not isinstance(categories, dict) or not categories:
        raise SystemExit(f"{source}: expected a non-empty [categories] table")

    bad = [k for k, v in categories.items() if not isinstance(v, str)]
    if bad:
        raise SystemExit(f"{source}: descriptions must be strings ({', '.join(bad)})")

    return dict(categories)
