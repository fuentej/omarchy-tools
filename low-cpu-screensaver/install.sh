#!/usr/bin/env bash
#
# Install low-cpu-screensaver: the patch script into ~/.local/bin and the
# post-update hook into ~/.config/omarchy/hooks/post-update.d/.

set -euo pipefail

here=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
dest="${1:-$HOME/.local/bin}"
hooks="$HOME/.config/omarchy/hooks/post-update.d"

mkdir -p "$dest" "$hooks"
install -m 755 "$here/low-cpu-screensaver" "$dest/low-cpu-screensaver"
install -m 755 "$here/low-cpu-screensaver.hook" "$hooks/low-cpu-screensaver.hook"

echo "Installed to $dest/low-cpu-screensaver"
case ":$PATH:" in
  *":$dest:"*) ;;
  *) echo "Note: $dest is not on your PATH - add it to your shell profile." ;;
esac
echo "Installed post-update hook to $hooks/low-cpu-screensaver.hook"

echo
echo "Applying the patch now (may prompt for your sudo password):"
if "$dest/low-cpu-screensaver"; then
  :
else
  echo "Patch not applied - run low-cpu-screensaver whenever you are ready."
fi
