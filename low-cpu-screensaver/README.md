# low-cpu-screensaver

Part of [omarchy-tools](../).

Cut the CPU load of the Omarchy screensaver. Stock `omarchy-screensaver` runs
the `ttfx` animation at **120fps in one fullscreen terminal per connected
monitor** — on a multi-monitor desk that keeps several cores busy for as long
as the screensaver is up (idle auto-launch or `SUPER+CTRL+L`). This rewrites
the animation to 30fps, which looks the same for a slow screensaver but uses a
fraction of the CPU.

## What it changes

One line in a root-owned Omarchy script:

```
/usr/share/omarchy/bin/omarchy-screensaver:  --frame-rate 120  →  --frame-rate 30
```

`omarchy update` restores stock Omarchy files, which brings the 120fps back.
The installer therefore also drops a post-update hook that re-applies the
patch automatically (sudo is usually still cached right after an update) and
notifies you with the fix command when it isn't.

## Requirements

- Omarchy (`omarchy-screensaver` present in `/usr/share/omarchy/bin`)
- sudo rights (the target file is root-owned)

## Install

```sh
git clone https://github.com/fuentej/omarchy-tools.git
cd omarchy-tools
./low-cpu-screensaver/install.sh
```

`install.sh` copies the script to `~/.local/bin`, the hook to
`~/.config/omarchy/hooks/post-update.d/`, and applies the patch (prompts for
your sudo password once).

## Usage

```sh
low-cpu-screensaver        # patch to 30fps (default)
low-cpu-screensaver 15     # even quieter, for very large canvases
low-cpu-screensaver 120    # restore a higher rate on purpose
```

Verify:

```sh
grep -o -- '--frame-rate [0-9]*' /usr/share/omarchy/bin/omarchy-screensaver
```

Test with the real thing: `omarchy-launch-screensaver force`, or the default
`SUPER+CTRL+L` binding.

## Uninstall

```sh
sudo sed -i 's/--frame-rate 30/--frame-rate 120/' /usr/share/omarchy/bin/omarchy-screensaver
rm ~/.config/omarchy/hooks/post-update.d/low-cpu-screensaver.hook
rm ~/.local/bin/low-cpu-screensaver
```

(Adjust the first `sed` if you patched to a custom rate.)
