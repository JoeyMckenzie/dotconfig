# screenshot-classifier

Classify a folder of screenshots with a vision model — LM Studio locally by
default, OpenAI when you want the better model.

## Usage

```sh
cd scripts

# classify, write scripts-of-screenshots/results.jsonl, touch nothing else
uv run screenshot-classifier ~/Desktop/screenshots

# preview the sort, then do it
uv run screenshot-classifier ~/Desktop/screenshots --move --dry-run
uv run screenshot-classifier ~/Desktop/screenshots --move

# hosted model instead
OPENAI_API_KEY=... uv run screenshot-classifier ~/Desktop/screenshots --provider openai
```

Requires LM Studio running with its local server enabled (`http://localhost:1234`)
and a **vision-capable** model available. `google/gemma-4-e4b` is the default and
runs at roughly 5s per screenshot; LM Studio JIT-loads it on first request.

## How it works

Each image is downscaled to a 1536px longest edge and sent as a base64 JPEG —
untouched retina PNGs are an order of magnitude slower for no accuracy gain. The
category list from `categories.toml` goes into the prompt *and* into a
`json_schema` response format, so the model can only answer with a name you
defined. Replies are still parsed defensively and fall back to `other`.

Results append to `results.jsonl` (one record per line: path, category,
confidence, reason, error). A rerun skips paths already in the report, so an
interrupted run over a large folder resumes where it stopped. `--overwrite`
forces reclassification.

A request that fails — unreadable file, model not loaded, timeout — is recorded
as an `other` row with the error text rather than killing the run. The process
exits 1 if anything errored.

## Categories

Edit `categories.toml`. Names double as folder names under `--move`, and the
descriptions are the only guidance a small local model gets about where the
boundaries sit — vague descriptions are the main cause of bad classifications.

## Notes

- `--move` acts on every record in the report, including ones from earlier runs,
  and never overwrites: collisions become `name-1.png`. Files already moved are
  skipped, so rerunning is safe.
- After a `--move`, don't rerun with `--recursive` unless you want the sorted
  files reclassified at their new paths.
- `-j/--concurrency` defaults to 1. Raising it helps against OpenAI; against one
  local GPU the requests just queue.

## Development

```sh
uv run ruff format . && uv run ruff check . && uv run ty check
```
