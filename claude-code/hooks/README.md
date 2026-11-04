# env-guard

A Claude Code `PreToolUse` hook that keeps secret `.env` files away from the
Read, Edit and Write tools while still allowing env templates.

## What it blocks

| File name (case-insensitive) | Result |
| --- | --- |
| `.env.example`, `.env.sample`, `.env.template` | allowed |
| Any other name starting with `.env` (`.env`, `.env.local`, `.env.production`, `.env.example.bak`, `.env.`, `.env.~x`, ...) | blocked |
| Names not starting with `.env` | the hook does not run |

Blocking uses exit code 2, so Claude sees the reason and the call does not run.
The script fails closed: input it cannot parse is blocked, and `onFailure:
"block"` blocks the call if the script cannot start, crashes or times out.

## Why bash

The script is pure bash with no external commands (no `jq`, `node` or
`python`). It starts in a few milliseconds, and bash is available wherever
Claude Code runs shell-form hooks: `sh`/`bash` on Linux and macOS, and Git Bash
on Windows. It handles both `/` and Windows `\` path separators.

## Install

Copy `env-guard.sh` to `~/.claude/hooks/env-guard.sh`, then add three handlers
to `~/.claude/settings.json`. The same JSON works on Linux and on Windows.

```json
{
  "hooks": {
    "PreToolUse": [
      { "matcher": "Read",  "hooks": [{ "type": "command", "command": "bash \"$HOME/.claude/hooks/env-guard.sh\"", "if": "Read(//**/.env*)",  "timeout": 10, "onFailure": "block" }] },
      { "matcher": "Edit",  "hooks": [{ "type": "command", "command": "bash \"$HOME/.claude/hooks/env-guard.sh\"", "if": "Edit(//**/.env*)",  "timeout": 10, "onFailure": "block" }] },
      { "matcher": "Write", "hooks": [{ "type": "command", "command": "bash \"$HOME/.claude/hooks/env-guard.sh\"", "if": "Write(//**/.env*)", "timeout": 10, "onFailure": "block" }] }
    ]
  }
}
```

- Each `if` names its own tool. An `Edit(...)` condition does not fire for
  Write calls.
- **Windows:** install Git for Windows so Claude Code runs hooks in Git Bash,
  which sets `$HOME`. Without Git Bash, hooks run in PowerShell, the `bash`
  command is missing, and `onFailure: "block"` then blocks every matching call.
- Requires Claude Code v2.1.295 or later for `onFailure`.

If you replace a `Read(//**/.env.*)` deny rule with this hook, keep the exact
`Read(//**/.env)` deny rule and any Bash rules as a second layer.

## Limits

- The hook covers only Read, Edit and Write. A `Read(...)` deny rule also
  covers Grep and Glob as best effort; this hook does not.
- On case-sensitive file systems the `if` glob may not match upper-case names
  such as `.ENV.local`, and then the hook does not run for them.
