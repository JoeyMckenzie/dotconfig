"""Scan a folder of screenshots and classify each one with a vision model."""

from __future__ import annotations

import argparse
import json
import shutil
import sys
from collections.abc import Iterable
from concurrent.futures import ThreadPoolExecutor
from pathlib import Path

from openai import OpenAI

from screenshot_classifier.classify import IMAGE_SUFFIXES, Result, classify
from screenshot_classifier.config import PROVIDERS, load_categories


def parse_args(argv: list[str] | None = None) -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        prog="screenshot-classifier",
        description="Classify a folder of screenshots with a local or hosted vision model.",
    )
    parser.add_argument("folder", type=Path, help="folder of screenshots to scan")
    parser.add_argument(
        "--provider",
        choices=sorted(PROVIDERS),
        default="lmstudio",
        help="where to send requests (default: lmstudio)",
    )
    parser.add_argument("--model", help="override the provider's default model")
    parser.add_argument("--base-url", help="override the provider's base URL")
    parser.add_argument("--api-key", help="override the key from the environment")
    parser.add_argument(
        "--categories", type=Path, help="path to a categories.toml (default: bundled)"
    )
    parser.add_argument(
        "-o",
        "--output",
        type=Path,
        help="JSONL report path (default: <folder>/results.jsonl)",
    )
    parser.add_argument("-r", "--recursive", action="store_true", help="descend into subfolders")
    parser.add_argument(
        "-j",
        "--concurrency",
        type=int,
        default=1,
        help="parallel requests; keep at 1 for a single local GPU (default: 1)",
    )
    parser.add_argument(
        "--max-edge",
        type=int,
        default=1536,
        help="downscale images to this longest edge before sending (default: 1536)",
    )
    parser.add_argument(
        "--timeout", type=float, default=120.0, help="per-request timeout in seconds"
    )
    parser.add_argument("--limit", type=int, help="stop after N images (useful for tuning)")
    parser.add_argument(
        "--overwrite",
        action="store_true",
        help="reclassify images already present in the report",
    )
    parser.add_argument(
        "--move",
        action="store_true",
        help="after classifying, move each image into <folder>/<category>/",
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="with --move, print the moves instead of performing them",
    )
    return parser.parse_args(argv)


def find_images(folder: Path, recursive: bool) -> list[Path]:
    walker = folder.rglob("*") if recursive else folder.glob("*")
    return sorted(p for p in walker if p.is_file() and p.suffix.lower() in IMAGE_SUFFIXES)


def load_report(path: Path) -> dict[str, dict[str, object]]:
    """Read an existing report so an interrupted run can pick up where it stopped."""
    if not path.is_file():
        return {}

    seen: dict[str, dict[str, object]] = {}
    for line in path.read_text().splitlines():
        line = line.strip()
        if not line:
            continue
        try:
            record = json.loads(line)
        except json.JSONDecodeError:
            continue
        if isinstance(record, dict) and isinstance(record.get("path"), str):
            seen[record["path"]] = record
    return seen


def run_moves(records: Iterable[dict[str, object]], folder: Path, dry_run: bool) -> tuple[int, int]:
    moved = skipped = 0
    for record in records:
        source = Path(str(record["path"]))
        if not source.is_file():
            skipped += 1
            continue

        target_dir = folder / str(record["category"])
        target = target_dir / source.name
        if target.resolve() == source.resolve():
            skipped += 1
            continue

        # Never clobber: park collisions under name-1.png, name-2.png, ...
        counter = 1
        while target.exists():
            target = target_dir / f"{source.stem}-{counter}{source.suffix}"
            counter += 1

        if dry_run:
            print(f"would move {source} -> {target}", file=sys.stderr)
        else:
            target_dir.mkdir(parents=True, exist_ok=True)
            shutil.move(str(source), str(target))
        moved += 1

    return moved, skipped


def main(argv: list[str] | None = None) -> int:
    args = parse_args(argv)

    folder = args.folder.expanduser().resolve()
    if not folder.is_dir():
        print(f"not a folder: {folder}", file=sys.stderr)
        return 1

    if args.dry_run and not args.move:
        print("--dry-run only applies to --move", file=sys.stderr)
        return 1

    categories = load_categories(args.categories)
    provider = PROVIDERS[args.provider]
    model = args.model or provider.default_model
    client = OpenAI(
        base_url=args.base_url or provider.base_url,
        api_key=args.api_key or provider.api_key(),
    )

    report_path = args.output or folder / "results.jsonl"
    existing = load_report(report_path)

    images = find_images(folder, args.recursive)
    pending = [p for p in images if args.overwrite or str(p) not in existing]
    if args.limit is not None:
        pending = pending[: args.limit]

    print(
        f"{len(images)} images, {len(pending)} to classify via {provider.name}:{model}",
        file=sys.stderr,
    )

    fresh: list[Result] = []
    if pending:
        with (
            report_path.open("a", encoding="utf-8") as report,
            ThreadPoolExecutor(max_workers=max(args.concurrency, 1)) as pool,
        ):
            futures = [
                pool.submit(classify, client, model, path, categories, args.max_edge, args.timeout)
                for path in pending
            ]
            for index, future in enumerate(futures, start=1):
                result = future.result()
                fresh.append(result)
                report.write(result.as_json() + "\n")
                report.flush()
                note = f" ({result.error})" if result.error else ""
                print(
                    f"[{index}/{len(pending)}] {result.category:<10} "
                    f"{Path(result.path).name}{note}",
                    file=sys.stderr,
                )

    failures = sum(1 for r in fresh if r.error)
    print(f"wrote {report_path} ({failures} errors)", file=sys.stderr)

    if args.move:
        # Move everything the report knows about, so a resumed run tidies up
        # images classified by an earlier invocation too.
        records = {**existing, **{r.path: json.loads(r.as_json()) for r in fresh}}
        moved, skipped = run_moves(records.values(), folder, args.dry_run)
        verb = "would move" if args.dry_run else "moved"
        print(f"{verb} {moved} files, skipped {skipped}", file=sys.stderr)

    return 1 if failures else 0


if __name__ == "__main__":
    raise SystemExit(main())
