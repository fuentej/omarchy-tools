#!/usr/bin/env bash
#
# Install hypr-window-list into ~/.local/bin.

set -euo pipefail

here=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
dest="${1:-$HOME/.local/bin}"

mkdir -p "$dest"
install -m 755 "$here/hypr-window-list" "$dest/hypr-window-list"

echo "Installed to $dest/hypr-window-list"
case ":$PATH:" in
  *":$dest:"*) ;;
  *) echo "Note: $dest is not on your PATH - add it to your shell profile." ;;
esac
