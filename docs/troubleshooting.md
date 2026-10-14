# Troubleshooting notes

Field notes from running Omarchy / Hyprland on a laptop. Mostly non-obvious
desktop issues and the thing that actually fixed them. Names, SSIDs, and
hardware identifiers are genericised.

## A single window ignores the keyboard/mouse, everything else works

**Symptom.** Keystrokes and clicks do nothing in one particular window (often a
browser), while other windows and terminals behave normally.

**Cause.** That window is holding a Wayland input grab — commonly a modal prompt,
a remote-desktop / RDP-over-browser session, or a stuck dialog. The compositor is
fine; input is being routed to the grab.

**Fix.** Close the window that holds the grab. If it's wedged and you can't click
it, switch virtual terminals to drop the grab and switch back — usually
`Ctrl+Alt+F2` then `Ctrl+Alt+F1`. Nothing is lost.

**Diagnosis tip.** If `hyprctl activewindow` reports the window you expect but
typing still does nothing "elsewhere", it's a grab, not a crash. A quick check
that the compositor is alive: `hyprctl monitors` should return immediately.

## Hibernate writes the image but the machine never powers off

**Symptom.** `systemctl hibernate` appears to work, but the laptop stays on
(and warm) instead of shutting down.

**Cause.** systemd's default power-off mode after hibernation is
`platform shutdown`, which asks the firmware to finish the power-off. On some
hardware that handoff hangs.

**Fix.** Force the plain power-off path in `/etc/systemd/sleep.conf`:

```ini
HibernateMode=shutdown
```

The hibernation image is still stored in swap; this only changes how the machine
powers off afterwards. Reboot (or restart `systemd-logind`) to apply, and roll
back with `platform shutdown` if restore ever misbehaves.

**Lesson.** "Hibernate hangs" is usually the power-off step, not the image write.

## External displays stay black after docking, only after a hibernate

**Symptom.** Resume from hibernation, then plug in a dock — external monitors
never come back. Windows are mapped but nothing renders.

**Cause.** DP-MST connector re-enumeration after resume leaves an output topology
the GPU refuses to modeset (repeated `atomic commit failed: Invalid argument`).
Config is not at fault; a reboot restores everything.

**Fix.** Hibernate with the dock attached, or reboot before docking again. Never
key anything to a connector name (`DP-1`, `HDMI-A-1`, ...) — they change across
dock cycles. Match outputs by hardware description instead.

## Wi-Fi keeps dropping / reconnecting

**Symptom.** Constant disconnects and DHCP renewals a minute or two apart.

**Cause.** The client sits on the 6 GHz band with weak signal and roams between
two access points whose 6 GHz radios are equally weak, so it ping-pongs. (Check
first that the driver itself is clean — no firmware errors in `journalctl -k`.)

**Fix.** Pin the connection to 5 GHz (NetworkManager 1.58 accepts `a`, `bg`, and
`6GHz`):

```sh
nmcli connection modify <SSID> 802-11-wireless.band a
nmcli connection up <SSID>
```

Revert with `802-11-wireless.band ""`.

**Lesson.** 6 GHz has far worse range and penetration than 5 GHz; if its coverage
isn't solid, preferring a lower band is more stable, not slower in practice.
