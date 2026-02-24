# Kanata Setup Notes

Kanata is auto-run at system startup via kanata-tray, which is managed by a systemd user service.

- Service file: `~/.config/systemd/user/kanata-tray.service`
- kanata-tray binary: `/home/linuxbrew/.linuxbrew/bin/kanata-tray`
- kanata-tray config: `~/.config/kanata-tray/kanata-tray.toml` (has `autorun = true` for the Default Preset)
- Kanata config: `/home/michael/src/kanata/linux.kbd`

Commands:
- `systemctl --user status kanata-tray` — check status
- `journalctl --user -u kanata-tray` — view logs
