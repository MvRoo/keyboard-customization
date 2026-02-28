# Zlaunch Launcher via Function Key
# Uses KDE native keybinding to launch zlaunch toggle

## Setup

Use **F15** (or any unused function key) to launch zlaunch through KDE shortcuts.

### Option 1: Manual KDE Setup

1. **System Settings** → **Shortcuts** → **Custom Shortcuts**
2. **Edit** → **New** → **Global Shortcut** → **Command/URL**
3. Configure:
   - **Name**: `zlaunch`
   - **Command**: `/home/michael/.local/bin/zlaunch toggle`
   - **Trigger**: Press **F15** (or any unused F-key like F14-F20)
4. **Apply**

### Option 2: Automatic Setup (requires logout)

The configuration below creates a KDE keybinding file. After applying:

```bash
# Update KDE configuration
cp ~/.config/khotkeysrc ~/.config/khotkeysrc.backup
```

Then **log out and log back in** for the keybinding to take effect.

## Function Keys Available

Your silakka54 keyboard has these extra function keys:
- **F22, F23** - Used by kanata for word deletion
- **F13-F20** - Available for custom shortcuts
- **F24** - Available if needed

## Testing

After setting up the shortcut:

```bash
# Test zlaunch works
~/.local/bin/zlaunch toggle

# Check kanata status (if needed)
systemctl --user status kanata-tray
```

## Notes

- KDE keybindings work independently of kanata
- You can disable kanata and still use zlaunch shortcut
- Function keys that pass through kanata (F13-F20) can be bound in KDE
- For better integration, you can also bind `Meta+Space` or `Alt+Space`