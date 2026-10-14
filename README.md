# omarchy-tools

Small, keyboard- and terminal-first tools for an [Omarchy](https://omarchy.org) /
Hyprland desktop. One directory per tool, each self-contained with its own
script, installer, and README.

## Tools

| Tool | Description |
| --- | --- |
| [hypr-window-list](hypr-window-list/) | `fzf` picker to list and focus open Hyprland windows |

## Installing a tool

Each tool directory has an `install.sh` that copies its script into
`~/.local/bin` (make sure that is on your `PATH`):

```sh
git clone https://github.com/fuentej/omarchy-tools.git
cd omarchy-tools
./hypr-window-list/install.sh
```

## Requirements

Individual tools list their own dependencies. Most rely on `hyprctl` (Hyprland)
plus common CLI tools such as `fzf` and `jq`.

## Troubleshooting notes

Field notes on non-obvious desktop issues — input grabs, hibernation power-off,
Wi-Fi band flapping — live in [docs/troubleshooting.md](docs/troubleshooting.md).

## License

MIT - see [LICENSE](LICENSE).
