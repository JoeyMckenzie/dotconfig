/**
 * Project Quality extension
 *
 * Detects PHP/Laravel, TypeScript/React, and Neovim projects, then exposes
 * the repository's existing quality commands to Pi. Project scripts are only run
 * after Pi trusts the project, because a script can have side effects.
 */

import { spawn } from "node:child_process";
import { access, readFile, stat } from "node:fs/promises";
import { dirname, join, relative, resolve } from "node:path";
import { Type } from "typebox";
import {
  DEFAULT_MAX_BYTES,
  DEFAULT_MAX_LINES,
  truncateTail,
  type ExtensionAPI,
} from "@earendil-works/pi-coding-agent";

type CheckKind =
  | "validation"
  | "lint"
  | "types"
  | "tests"
  | "analysis"
  | "format";

interface Check {
  id: string;
  label: string;
  kind: CheckKind;
  command: string;
  args: string[];
}

interface StackProfile {
  root: string;
  stacks: string[];
  checks: Check[];
  notes: string[];
}

interface CommandResult {
  check: Check;
  code: number | null;
  output: string;
  outputTruncated: boolean;
  killed: boolean;
}

// Leave room for truncation notices in Pi's 50KB tool-output budget.
const MAX_CAPTURE_BYTES = DEFAULT_MAX_BYTES - 1024;
// At most 33 discovered checks can run (Composer validation + 16 Composer and 16 Node scripts).
const MAX_CHECK_RESULT_BYTES = 1024;

const QUALITY_SCRIPT_NAMES: Record<string, CheckKind> = {
  lint: "lint",
  "lint:js": "lint",
  "lint:ts": "lint",
  check: "validation",
  typecheck: "types",
  "type-check": "types",
  "check-types": "types",
  "test:types": "types",
  test: "tests",
  "test:unit": "tests",
  "test:feature": "tests",
  analyse: "analysis",
  analyze: "analysis",
  phpstan: "analysis",
  pint: "format",
  "format:check": "format",
};

async function exists(path: string): Promise<boolean> {
  try {
    await access(path);
    return true;
  } catch {
    return false;
  }
}

async function isDirectory(path: string): Promise<boolean> {
  try {
    const metadata = await stat(path);
    return metadata.isDirectory();
  } catch {
    return false;
  }
}

async function readJson(
  path: string,
): Promise<Record<string, unknown> | undefined> {
  try {
    const value = JSON.parse(await readFile(path, "utf8")) as unknown;
    return value !== null && typeof value === "object" && !Array.isArray(value)
      ? (value as Record<string, unknown>)
      : undefined;
  } catch {
    return undefined;
  }
}

async function findProjectRoot(cwd: string): Promise<string> {
  let current = resolve(cwd);
  while (true) {
    if (
      (await exists(join(current, ".git"))) ||
      (await exists(join(current, "composer.json"))) ||
      (await exists(join(current, "package.json")))
    ) {
      return current;
    }

    const parent = dirname(current);
    if (parent === current) return resolve(cwd);
    current = parent;
  }
}

async function packageManager(
  root: string,
): Promise<"npm" | "pnpm" | "yarn" | "bun"> {
  if (await exists(join(root, "pnpm-lock.yaml"))) return "pnpm";
  if (
    (await exists(join(root, "yarn.lock"))) ||
    (await exists(join(root, ".yarnrc.yml")))
  )
    return "yarn";
  if (
    (await exists(join(root, "bun.lock"))) ||
    (await exists(join(root, "bun.lockb")))
  )
    return "bun";
  return "npm";
}

function nodeScriptCommand(
  manager: "npm" | "pnpm" | "yarn" | "bun",
  script: string,
): Pick<Check, "command" | "args"> {
  if (manager === "yarn") return { command: "yarn", args: [script] };
  return { command: manager, args: ["run", script] };
}

function commandText(check: Check): string {
  return [check.command, ...check.args].join(" ");
}

function resultStatus(result: CommandResult): "PASS" | "FAIL" | "CANCELLED" {
  if (result.code === 0 && !result.killed) return "PASS";
  return result.killed ? "CANCELLED" : "FAIL";
}

function formatOutput(value: string, wasCapped: boolean): string {
  const trimmed = value.trim();
  if (!trimmed) return "(no output)";
  const truncated = truncateTail(trimmed, {
    maxBytes: DEFAULT_MAX_BYTES,
    maxLines: DEFAULT_MAX_LINES,
  });
  let output = truncated.content;
  if (wasCapped) output += "\n\n[Output was capped or summarized; only its final portion is shown.]";
  if (truncated.truncated) output += "\n\n[Output truncated to Pi's tool-output limit.]";
  return output;
}

function compactResult(result: CommandResult): CommandResult {
  const truncated = truncateTail(result.output, { maxBytes: MAX_CHECK_RESULT_BYTES, maxLines: DEFAULT_MAX_LINES });
  return {
    ...result,
    output: truncated.content,
    outputTruncated: result.outputTruncated || truncated.truncated,
  };
}

function retainTail(current: string, chunk: string): { value: string; truncated: boolean } {
  const combined = current + chunk;
  if (Buffer.byteLength(combined, "utf8") <= MAX_CAPTURE_BYTES) {
    return { value: combined, truncated: false };
  }
  return {
    value: Buffer.from(combined, "utf8").subarray(-MAX_CAPTURE_BYTES).toString("utf8"),
    truncated: true,
  };
}

/** Run a project command with bounded output. Project scripts are arbitrary code. */
async function runBoundedCommand(check: Check, cwd: string, signal: AbortSignal | undefined): Promise<CommandResult> {
  return new Promise((resolveResult) => {
    let output = "";
    let outputTruncated = false;
    let timedOut = false;
    let aborted = signal?.aborted ?? false;
    let spawnError: string | undefined;
    let settled = false;

    let child;
    try {
      child = spawn(check.command, check.args, { cwd, shell: false, stdio: ["ignore", "pipe", "pipe"] });
    } catch (error) {
      resolveResult({
        check,
        code: null,
        output: error instanceof Error ? error.message : String(error),
        outputTruncated: false,
        killed: false,
      });
      return;
    }
    const append = (chunk: Buffer) => {
      const retained = retainTail(output, chunk.toString("utf8"));
      output = retained.value;
      outputTruncated ||= retained.truncated;
    };
    child.stdout.on("data", append);
    child.stderr.on("data", append);

    const stop = () => child.kill("SIGTERM");
    const timeout = setTimeout(() => {
      timedOut = true;
      stop();
    }, 120_000);
    const onAbort = () => {
      aborted = true;
      stop();
    };
    signal?.addEventListener("abort", onAbort, { once: true });

    const finish = (code: number | null) => {
      if (settled) return;
      settled = true;
      clearTimeout(timeout);
      signal?.removeEventListener("abort", onAbort);
      if (spawnError) output = `${output}\n${spawnError}`;
      if (timedOut) output = `${output}\n[Command timed out after 120 seconds.]`;
      resolveResult({
        check,
        code,
        output,
        outputTruncated,
        killed: child.killed || timedOut || aborted,
      });
    };

    child.on("error", (error) => {
      spawnError = error.message;
      finish(null);
    });
    child.on("close", (code) => finish(code));
  });
}

async function detectProfile(cwd: string): Promise<StackProfile> {
  const root = await findProjectRoot(cwd);
  const stacks: string[] = [];
  const checks: Check[] = [];
  const notes: string[] = [];
  const composer = await readJson(join(root, "composer.json"));
  const packageJson = await readJson(join(root, "package.json"));

  if (composer) {
    const require = (composer.require ?? {}) as Record<string, unknown>;
    const requireDev = (composer["require-dev"] ?? {}) as Record<
      string,
      unknown
    >;
    const dependencies = { ...require, ...requireDev };
    const isLaravel =
      "laravel/framework" in dependencies ||
      (await exists(join(root, "artisan")));
    stacks.push(isLaravel ? "Laravel / PHP" : "PHP / Composer");
    checks.push({
      id: "composer:validate",
      label: "Validate composer.json",
      kind: "validation",
      command: "composer",
      args: ["validate", "--no-check-publish"],
    });

    const rawScripts = composer.scripts;
    const scripts = rawScripts !== null && typeof rawScripts === "object" && !Array.isArray(rawScripts)
      ? (rawScripts as Record<string, unknown>)
      : {};
    for (const [name, kind] of Object.entries(QUALITY_SCRIPT_NAMES)) {
      if (name in scripts) {
        checks.push({
          id: `composer:${name}`,
          label: `Composer script: ${name}`,
          kind,
          command: "composer",
          args: ["run-script", name],
        });
      }
    }
  }

  if (packageJson) {
    const dependencies = {
      ...((packageJson.dependencies ?? {}) as Record<string, unknown>),
      ...((packageJson.devDependencies ?? {}) as Record<string, unknown>),
    };
    const hasReact =
      "react" in dependencies ||
      "next" in dependencies ||
      "@vitejs/plugin-react" in dependencies;
    const hasTypescript =
      "typescript" in dependencies ||
      (await exists(join(root, "tsconfig.json")));
    if (hasReact && hasTypescript) stacks.push("React / TypeScript");
    else if (hasReact) stacks.push("React");
    else if (hasTypescript) stacks.push("TypeScript");
    else stacks.push("Node.js");

    const manager = await packageManager(root);
    const rawScripts = packageJson.scripts;
    const scripts = rawScripts !== null && typeof rawScripts === "object" && !Array.isArray(rawScripts)
      ? (rawScripts as Record<string, unknown>)
      : {};
    for (const [name, kind] of Object.entries(QUALITY_SCRIPT_NAMES)) {
      if (name in scripts) {
        const invocation = nodeScriptCommand(manager, name);
        checks.push({
          id: `node:${name}`,
          label: `${manager} script: ${name}`,
          kind,
          ...invocation,
        });
      }
    }
  }

  const isNvimConfig =
    (await exists(join(root, "init.lua"))) &&
    (await isDirectory(join(root, "lua")));
  const isNvimPlugin =
    (await isDirectory(join(root, "plugin"))) &&
    (await isDirectory(join(root, "lua")));
  if (isNvimConfig || isNvimPlugin) {
    stacks.push(isNvimPlugin ? "Neovim plugin" : "Neovim configuration");
    notes.push(
      "Neovim was detected. Use its repository scripts for automated checks; do not start the interactive editor from this tool.",
    );
  }

  if (checks.length === 0) {
    notes.push(
      "No supported repository quality scripts were found. Add Composer or package.json scripts to make checks discoverable.",
    );
  }

  return { root, stacks, checks, notes };
}

function selectChecks(
  profile: StackProfile,
  requested: string[] | undefined,
): Check[] {
  const selections = requested?.map((item) => item.trim()).filter(Boolean) ?? [
    "quick",
  ];
  const wanted = new Set(selections);
  const byId = new Map(profile.checks.map((check) => [check.id, check]));
  const selected: Check[] = [];

  const add = (check: Check | undefined) => {
    if (check && !selected.some((item) => item.id === check.id))
      selected.push(check);
  };

  if (wanted.has("all")) {
    for (const check of profile.checks) add(check);
  }
  if (wanted.has("quick")) {
    for (const check of profile.checks) {
      // Formatters such as Laravel Pint can rewrite files, so they are opt-in.
      if (check.kind !== "tests" && check.kind !== "format") add(check);
    }
  }
  for (const id of wanted) add(byId.get(id));

  return selected;
}

function profileText(profile: StackProfile, cwd: string): string {
  const root = relative(cwd, profile.root) || ".";
  const lines = [
    "## Project quality profile",
    `- Root: ${root}`,
    `- Detected: ${profile.stacks.join(", ") || "no recognized stack"}`,
  ];

  if (profile.checks.length > 0) {
    lines.push("", "### Available checks");
    for (const check of profile.checks) {
      lines.push(
        `- \`${check.id}\` (${check.kind}): \`${commandText(check)}\``,
      );
    }
    lines.push(
      "",
      "Run `quick` (default) for validation, lint, type, and analysis checks; `all` includes tests and formatters. Explicit check IDs are also supported.",
      "Project scripts are repository-controlled commands and can have side effects. Running them requires Pi to trust the project.",
    );
  }
  if (profile.notes.length > 0)
    lines.push("", ...profile.notes.map((note) => `- ${note}`));
  return lines.join("\n");
}

async function runChecks(
  profile: StackProfile,
  requested: string[] | undefined,
  signal: AbortSignal | undefined,
  cwd: string,
): Promise<{ text: string; results: CommandResult[] }> {
  const selected = selectChecks(profile, requested);
  if (selected.length === 0) {
    return {
      text: `${profileText(profile, cwd)}\n\nNo matching checks were selected.`,
      results: [],
    };
  }

  const results: CommandResult[] = [];
  for (const check of selected) {
    if (signal?.aborted) {
      return {
        text: `## Quality checks cancelled\n\nCancelled before \`${check.id}\` started.`,
        results,
      };
    }
    results.push(compactResult(await runBoundedCommand(check, profile.root, signal)));
  }

  const summary = results.map((result) => {
    const status = resultStatus(result);
    return `### ${status}: ${result.check.id}\n\n\`${commandText(result.check)}\`\n\n${formatOutput(result.output, result.outputTruncated)}`;
  });
  const passed = results.filter(
    (result) => result.code === 0 && !result.killed,
  ).length;
  return {
    text: [
      `## Quality checks: ${passed}/${results.length} passed`,
      ...summary,
    ].join("\n\n"),
    results,
  };
}

export default function projectQualityExtension(pi: ExtensionAPI) {
  pi.registerTool({
    name: "project_quality",
    label: "Project Quality",
    description:
      "Discover and, in trusted projects, run existing PHP/Laravel, TypeScript/React, or Neovim repository quality commands with bounded output.",
    promptSnippet:
      "Discover or run the repository's existing PHP/Laravel, TypeScript/React, and Neovim quality checks",
    promptGuidelines: [
      "Use project_quality with action discover before choosing unfamiliar project validation commands.",
      "Use project_quality with action run after changes to run the relevant existing checks; use quick by default and all only when appropriate.",
    ],
    parameters: Type.Object({
      action: Type.Optional(
        Type.String({ description: 'Either "discover" (default) or "run".' }),
      ),
      checks: Type.Optional(
        Type.Array(Type.String(), {
          description:
            'For action "run": "quick" (default), "all", or discovered check IDs such as "composer:test" and "node:typecheck".',
        }),
      ),
    }),
    async execute(_toolCallId, params, signal, onUpdate, ctx) {
      const profile = await detectProfile(ctx.cwd);
      const action = params.action ?? "discover";
      if (action === "discover") {
        return {
          content: [{ type: "text", text: profileText(profile, ctx.cwd) }],
          details: profile,
        };
      }
      if (action !== "run") throw new Error('action must be "discover" or "run".');
      if (!ctx.isProjectTrusted()) {
        throw new Error("Refusing to run repository scripts because this project is not trusted.");
      }

      onUpdate?.({
        content: [
          { type: "text", text: "Running repository quality checks..." },
        ],
        details: { profile },
      });
      const output = await runChecks(profile, params.checks, signal, ctx.cwd);
      return {
        content: [{ type: "text", text: output.text }],
        details: { profile, results: output.results },
      };
    },
  });

  pi.registerCommand("project-quality", {
    description:
      "Discover or run repository quality checks: /project-quality [quick|all|check-id...]",
    handler: async (args, ctx) => {
      const profile = await detectProfile(ctx.cwd);
      const requested = args.trim() ? args.trim().split(/\s+/) : undefined;
      if (!requested) {
        ctx.ui.notify(profileText(profile, ctx.cwd), "info");
        return;
      }

      if (!ctx.isProjectTrusted()) {
        ctx.ui.notify("Refusing to run repository scripts because this project is not trusted.", "warning");
        return;
      }

      const output = await runChecks(profile, requested, undefined, ctx.cwd);
      const failures = output.results.filter(
        (result) => result.code !== 0 || result.killed,
      ).length;
      if (ctx.mode === "tui") {
        await ctx.ui.editor("Project quality output", output.text);
      }
      ctx.ui.notify(
        failures === 0
          ? `Project quality: ${output.results.length}/${output.results.length} passed.`
          : `Project quality: ${failures} check(s) failed.`,
        failures === 0 ? "info" : "warning",
      );
    },
  });
}
