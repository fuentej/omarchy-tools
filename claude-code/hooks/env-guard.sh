#!/usr/bin/env bash
# env-guard.sh - Claude Code PreToolUse hook for Read, Edit and Write.
#
# Blocks any file whose name starts with ".env" (case-insensitive), except the
# templates .env.example, .env.sample and .env.template (case-insensitive).
# Files whose names do not start with ".env" pass through untouched.
#
# Pure bash: no jq, node or python, and no external commands, so it starts
# fast and runs unchanged under Linux bash and Git Bash on Windows.
#
# Fails closed: if the input cannot be parsed, the call is blocked.
# Block = exit 2 with the reason on stderr (PreToolUse blocking error).

export LC_ALL=C

deny() {
  printf 'env-guard: %s\n' "$1" >&2
  exit 2
}

IFS= read -r -d '' input || true

key='"file_path"'
case $input in
  *"$key"*) ;;
  *) deny "no file_path in tool input" ;;
esac
rest=${input#*"$key"}
case $rest in
  *"$key"*) deny "more than one file_path in tool input" ;;
esac

# JSON string value: any run of non-quote/non-backslash chars or escape pairs.
re='^[[:space:]]*:[[:space:]]*"(([^"\\]|\\.)*)"'
[[ $rest =~ $re ]] || deny "file_path is not a JSON string"
path=${BASH_REMATCH[1]}
[ -n "$path" ] || deny "empty file_path"

# Base name. Backslash is a separator only for Windows paths (C:\..., \\server,
# \\?\...); on Linux it is a legal filename character. JSON escapes a backslash
# as two, so strip through the last escaped pair.
name=${path##*/}
if [[ $path =~ ^[A-Za-z]:[\\/] || $path == '\\\\'* ]]; then
  name=${name##*\\\\}
fi
lname=${name,,}

case $lname in
  .env.example|.env.sample|.env.template) exit 0 ;;
  .env*) deny "blocked secret env file '$name' (only .env.example, .env.sample, .env.template are allowed)" ;;
esac
exit 0
