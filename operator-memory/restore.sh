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
cp "$REPO_DIR/config/skills/operator-memory/persona.md" "$CFG_BASE/opencode/skills/operator-memory/"
cp "$REPO_DIR/config/skills/operator-memory/context.md" "$CFG_BASE/opencode/skills/operator-memory/"
if [ -f "$REPO_DIR/config/skills/operator-memory/behavior-log.md" ]; then
    cp "$REPO_DIR/config/skills/operator-memory/behavior-log.md" "$CFG_BASE/opencode/skills/operator-memory/"
    echo "[restore] behavior-log.md ikut dipulihkan."
fi
# Legacy memory.md dari backup lama (bila masih ada) ikut dipulihkan agar
# tidak ada data yang hilang; file baru (persona/context) adalah otoritasnya.
if [ -f "$REPO_DIR/config/skills/operator-memory/memory.md" ]; then
    cp "$REPO_DIR/config/skills/operator-memory/memory.md" "$CFG_BASE/opencode/skills/operator-memory/"
    echo "[restore] memory.md legacy ikut dipulihkan (sudah tidak disinkronkan)."
fi

# -- Terapkan identitas git lokal ke repo backup hasil clone --
# Clone fresh tidak membawa user.name/user.email; tanpa ini backup.sh pertama
# akan gagal dengan "Author identity unknown".
if [ -f "$REPO_DIR/config/git-identity" ]; then
    IFS= read -r GIT_NAME < "$REPO_DIR/config/git-identity"
    GIT_EMAIL="$(sed -n '2p' "$REPO_DIR/config/git-identity")"
    if [ -n "$GIT_NAME" ] && [ -n "$GIT_EMAIL" ]; then
        git -C "$REPO_DIR" config user.name  "$GIT_NAME"
        git -C "$REPO_DIR" config user.email "$GIT_EMAIL"
        echo "[restore] identitas git diterapkan: $GIT_NAME <$GIT_EMAIL>"
    fi
fi

echo "[restore] restore selesai."
echo "[restore] restart opencode untuk mengaktifkan pengaturan."
