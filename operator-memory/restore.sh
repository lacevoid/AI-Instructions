#!/usr/bin/env bash
# operator-persona — restore.sh
# Restore pengaturan opencode global dari repo backup ke ~/.config/opencode/.
# Jalankan dari dalam clone repo ini setelah git clone.
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CFG_BASE="${XDG_CONFIG_HOME:-$HOME/.config}"

echo "[restore] source: $REPO_DIR"
echo "[restore] target: $CFG_BASE/opencode/"

# -- Buat backup instan versi lama (jika ada) --
EXISTING="$CFG_BASE/opencode"
if [ -d "$EXISTING" ]; then
    BACKUP_TS="$(date '+%Y%m%d_%H%M%S')"
    echo "[restore] backup versi lama → $EXISTING.bak.$BACKUP_TS"
    cp -a "$EXISTING" "$EXISTING.bak.$BACKUP_TS"
fi

# -- Salin config --
mkdir -p "$CFG_BASE/opencode/skills/operator-memory"
cp "$REPO_DIR/config/opencode.jsonc"                  "$CFG_BASE/opencode/"
cp "$REPO_DIR/config/skills/operator-memory/SKILL.md" "$CFG_BASE/opencode/skills/operator-memory/"
cp "$REPO_DIR/config/skills/operator-memory/memory.md" "$CFG_BASE/opencode/skills/operator-memory/"

echo "[restore] restore selesai."
echo "[restore] restart opencode untuk mengaktifkan pengaturan."
