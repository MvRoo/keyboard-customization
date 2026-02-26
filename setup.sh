#!/usr/bin/env bash
# Sets up kanata + kanata-tray for the Squalius-cephalus silakka54 keyboard.
# Run from the repo directory: bash setup.sh
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
KBD_CONFIG="$SCRIPT_DIR/linux.kbd"

info()  { echo "[INFO]  $*"; }
warn()  { echo "[WARN]  $*"; }
error() { echo "[ERROR] $*" >&2; exit 1; }

[[ -f "$KBD_CONFIG" ]] || error "linux.kbd not found in $SCRIPT_DIR"

# ── 1. Homebrew ──────────────────────────────────────────────────────────────

if ! command -v brew &>/dev/null; then
    info "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
else
    info "Homebrew already installed."
fi

# ── 2. kanata + kanata-tray ──────────────────────────────────────────────────

info "Installing kanata and kanata-tray..."
brew install kanata kanata-tray

BREW_PREFIX="$(brew --prefix)"
KANATA_BIN="$BREW_PREFIX/bin/kanata"
KANATA_TRAY_BIN="$(command -v kanata-tray)"
[[ -x "$KANATA_BIN" ]] || error "kanata binary not found at $KANATA_BIN"
info "kanata-tray: $KANATA_TRAY_BIN"
info "kanata: $KANATA_BIN"

# ── 3. udev rule (grants seat-user access to the keyboard interface) ───────────

UDEV_RULE="/etc/udev/rules.d/99-kanata-silakka54.rules"
info "Installing udev rule at $UDEV_RULE (requires sudo)..."
sudo tee "$UDEV_RULE" > /dev/null << 'EOF'
# Grant the logged-in seat user access to the Squalius-cephalus silakka54
# keyboard interface that emits undo/redo media keys.
SUBSYSTEM=="input", KERNEL=="event*", ATTRS{name}=="Squalius-cephalus silakka54", MODE="0660", GROUP="input", TAG+="uaccess"
EOF

sudo udevadm control --reload-rules

DEVICE_EVENT=$(grep -rl "Squalius-cephalus silakka54$" \
    /sys/class/input/*/device/name 2>/dev/null \
    | sed 's|/sys/class/input/\(event[0-9]*\)/device/name|\1|' \
    | head -1)

if [[ -n "$DEVICE_EVENT" ]]; then
    KANATA_INPUT_DEV="/dev/input/$DEVICE_EVENT"
    # Keep linux.kbd in sync with the currently detected input event node.
    sed -i "s|^[[:space:]]*linux-dev .*|  linux-dev $KANATA_INPUT_DEV|" "$KBD_CONFIG"
    info "Set linux-dev in $KBD_CONFIG to $KANATA_INPUT_DEV."

    sudo udevadm trigger --action=add "/dev/input/$DEVICE_EVENT"
    if [[ -r "$KANATA_INPUT_DEV" && -w "$KANATA_INPUT_DEV" ]]; then
        info "Access verified on $KANATA_INPUT_DEV."
    else
        warn "No read/write access to $KANATA_INPUT_DEV as $USER."
        warn "Run: sudo usermod -aG input $USER"
        warn "Then log out and log back in before starting kanata-tray."
    fi
else
    warn "Keyboard not detected — udev rule will apply automatically when plugged in."
fi

# ── 4. kanata-tray config ────────────────────────────────────────────────────

TRAY_CFG_DIR="$HOME/.config/kanata-tray"
TRAY_CFG="$TRAY_CFG_DIR/kanata-tray.toml"
mkdir -p "$TRAY_CFG_DIR"
info "Writing kanata-tray config to $TRAY_CFG..."

cat > "$TRAY_CFG" << EOF
# For help with configuration see https://github.com/rszyma/kanata-tray/blob/main/README.md#configuration
"\$schema" = "https://raw.githubusercontent.com/rszyma/kanata-tray/main/doc/config_schema.json"

[general]
allow_concurrent_presets = false
control_server_enable = false
control_server_port = 8100

[defaults]
tcp_port = 5829
autorestart_on_crash = false

[defaults.hooks]

[defaults.layer_icons]

[presets.'Default Preset']
kanata_config = '$KBD_CONFIG'
autorun = true
EOF

# ── 5. systemd user service ──────────────────────────────────────────────────

SERVICE_DIR="$HOME/.config/systemd/user"
SERVICE_FILE="$SERVICE_DIR/kanata-tray.service"
mkdir -p "$SERVICE_DIR"
info "Installing systemd user service at $SERVICE_FILE..."

cat > "$SERVICE_FILE" << EOF
[Unit]
Description=kanata-tray keyboard remapper
After=graphical-session.target

[Service]
Type=simple
Environment=PATH=$BREW_PREFIX/bin:$BREW_PREFIX/sbin:/usr/local/bin:/usr/bin:/bin
ExecStart=$KANATA_TRAY_BIN
Restart=on-failure
RestartSec=5

[Install]
WantedBy=default.target
EOF

systemctl --user daemon-reload
systemctl --user enable kanata-tray
systemctl --user restart kanata-tray

info "Done. kanata-tray is running with config: $KBD_CONFIG"
