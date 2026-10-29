# low-cpu-screensaver

Part of [omarchy-tools](../).

Tune the Omarchy screensaver: lower the animation frame rate and restrict which
`ttfx` effects may play. Stock `omarchy-screensaver` runs at **120fps in one
fullscreen terminal per connected monitor**, picking a random effect from
everything ttfx knows — on a multi-monitor desk that keeps several cores busy
for as long as the screensaver is up (idle auto-launch or `SUPER+CTRL+L`),
sometimes running effects like fireworks that are pure CPU confetti.

## What it changes

Two spots in a root-owned Omarchy script:

```
/usr/share/omarchy/bin/omarchy-screensaver:
  --frame-rate 120 → 8 (or whatever you pass)
  --random-effect → --random-effect --include-effects <your list>
```

`omarchy update` restores stock Omarchy files, which undoes both. The installer
therefore also drops a post-update hook that re-applies the patch automatically
(sudo is usually still cached right after an update) and notifies you with the
fix command when it isn't. The shipped hook restores 8fps with just `matrix` —
edit its `prefs` array to taste.

## Requirements

- Omarchy (`omarchy-screensaver` present in `/usr/share/omarchy/bin`)
- `ttfx` (effect names are validated against `ttfx --help`; a bad name would
  crash-loop the screensaver)
- sudo rights (the target file is root-owned)

## Install

```sh
git clone https://github.com/fuentej/omarchy-tools.git
cd omarchy-tools
./low-cpu-screensaver/install.sh 8 --effects matrix
```

`install.sh` copies the script to `~/.local/bin`, the hook to
`~/.config/omarchy/hooks/post-update.d/`, and applies the patch (prompts for
your sudo password once). Any arguments go straight through to the script.

## Usage

```sh
low-cpu-screensaver                             # 30fps, effects unchanged
low-cpu-screensaver 8                           # 8fps, effects unchanged
low-cpu-screensaver 15 --effects matrix rain    # restrict effect selection
low-cpu-screensaver --effects matrix            # effects only, keep frame rate
low-cpu-screensaver 120                         # restore a higher rate on purpose
```

`--effects` accepts anything `ttfx --help` lists (`matrix`, `binarypath`,
`rain`, ...). Names are validated before patching — a typo would make ttfx exit
instantly and the screensaver's loop respawn it forever.

Verify:

```sh
grep -oE -- '--frame-rate [0-9]+|--include-effects [a-z0-9 ]+' \
  /usr/share/omarchy/bin/omarchy-screensaver
```

Test with the real thing: `omarchy-launch-screensaver force`, or the default
`SUPER+CTRL+L` binding.

## Uninstall

```sh
sudo sed -i 's/--frame-rate 30/--frame-rate 120/' /usr/share/omarchy/bin/omarchy-screensaver
sudo sed -i -E 's/ --include-effects [a-z0-9 ]+//' /usr/share/omarchy/bin/omarchy-screensaver
rm ~/.config/omarchy/hooks/post-update.d/low-cpu-screensaver.hook
rm ~/.local/bin/low-cpu-screensaver
```

(Adjust the first `sed` if you patched to a custom rate.)
