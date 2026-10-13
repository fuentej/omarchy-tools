# hypr-window-list

Pick from a list of open [Hyprland](https://hypr.land) windows and focus the one
you choose. A tiny `fzf` picker for a keyboard-driven workflow.

```
ws  app       title
1   foot      ~/src
2   chromium  Round trip to Chicago | Google Flights
4   chromium  (5) Chat | Review Discovery and Design Doc
```

Type to filter, Enter to jump to the window, Esc to cancel. Shows one row per
window, grouped by workspace, with the window class and title.

## Requirements

- `hyprctl` (i.e. a running Hyprland session)
- [`jq`](https://jqlang.github.io/jq/)
- [`fzf`](https://github.com/junegunn/fzf)
- A terminal to run in (the picker is a TUI)

## Install

```sh
git clone https://github.com/fuentej/hypr-window-list.git
cd hypr-window-list
./install.sh
```

`install.sh` copies the script to `~/.local/bin` (make sure that is on your
`PATH`). Or just copy the file there yourself:

```sh
install -Dm755 hypr-window-list ~/.local/bin/hypr-window-list
```

## Keybinding

The cleanest setup launches the picker in a floating terminal. Pick whatever key
is free on your system.

### Hyprland Lua config

```lua
-- Launch in a floating terminal. With Omarchy's helpers this is a one-liner:
o.bind("SUPER + grave", "Window list", { tui = "hypr-window-list" })

-- Float and size the popup.
o.window("org.omarchy.hypr-window-list", { tag = "+floating-window" })
```

### Legacy `hyprland.conf`

```conf
# Run in a floating terminal. Adjust the terminal to taste.
bind = SUPER, grave, exec, foot -a window-list -e hypr-window-list

windowrulev2 = float, class:^(window-list)$
windowrulev2 = size 875 600, class:^(window-list)$
windowrulev2 = center, class:^(window-list)$
```

## How it works

It asks `hyprctl clients -j` for every mapped window, formats each as
`workspace <TAB> class <TAB> title <TAB> address`, and feeds that to `fzf`. When
you pick a row it focuses the matching window by its unique address:

```sh
hyprctl dispatch "hl.dsp.focus({ window = \"address:$address\" })"
```

No state is stored; the window list is read fresh every time.

## License

MIT - see [LICENSE](LICENSE).
