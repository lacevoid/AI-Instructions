#!/usr/bin/env bash
#
# bootstrap-operator-memory.sh — instansiasi mekanisme operator-memory
#
# Setiap salinan repository ini (fork/clone/distribusi) membawa mekanisme yang
# sama: skill global + memori operator + backup/sinkronisasi DUA ARAH ke repo
# privat GitHub. Script ini mem-personalisasi mekanisme tersebut untuk
# OPERATOR SALINAN ini — identitas, repo backup, dan memori masing-masing.
#
# Alur:
#   1. Identitas operator (nama, email, handle GitHub) — argumen atau interaktif.
#   2. Buat repo privat GitHub <handle>/<repo> (@gh) bila belum ada; clone ke
#      ${XDG_CONFIG_HOME:-$HOME/.config}/operator-persona.
#   3. Pasang skill + memori starter ke ~/.config/opencode/ (memori lama dijaga).
#   4. Tautkan memory.md ke opencode.jsonc (dibuat bila belum ada).
#   5. Sinkronkan config ke repo backup, commit + push.
#
# Setelah selesai: restart opencode. Agent selanjutnya membaca memory.md,
# memperbaruinya di checkpoint kerja, dan menjalankan backup.sh (dua arah).
# Restore di mesin lain: clone repo privat lalu jalankan restore.sh.
#
# Opsi non-interaktif / CI / pengujian:
#   --name NAME     --email EMAIL     --github HANDLE
#   --repo NAME     (default: operator-persona)
#   --dest DIR      (lokasi salinan repo backup; default ~/.config/operator-persona)
#   --remote-url URL (pakai remote ini alih-alih git@github.com:<handle>/<repo>.git
#                     — untuk pengujian/sandbox)
#   --local-only    (tanpa gh / tanpa remote — repo git lokal saja)
set -euo pipefail

usage() {
  cat <<'EOF'
Penggunaan: bootstrap-operator-memory.sh [opsi]

  --name NAME          Nama operator (prompt bila kosong)
  --email EMAIL        Email operator (prompt bila kosong)
  --github HANDLE      Handle GitHub (prompt bila kosong)
  --repo NAME          Nama repo backup privat (default: operator-persona)
  --dest DIR           Lokasi salinan repo backup (default: ~/.config/operator-persona)
  --remote-url URL     Remote untuk clone/push (untuk sandbox/pengujian)
  --local-only         Lewati gh & remote — repo git lokal saja
  -h, --help           Tampilkan bantuan ini
EOF
}

# --- Parsing argumen ---
NAME=""
EMAIL=""
GITHUB_HANDLE=""
BACKUP_REPO="operator-persona"
DEST=""
REMOTE_URL=""
LOCAL_ONLY=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --name) NAME="${2:-}"; shift 2 ;;
    --email) EMAIL="${2:-}"; shift 2 ;;
    --github) GITHUB_HANDLE="${2:-}"; shift 2 ;;
    --repo) BACKUP_REPO="${2:-}"; shift 2 ;;
    --dest) DEST="${2:-}"; shift 2 ;;
    --remote-url) REMOTE_URL="${2:-}"; shift 2 ;;
    --local-only) LOCAL_ONLY=1; shift ;;
    -h|--help) usage; exit 0 ;;
    *) echo "argumen tak dikenal: $1" >&2; usage; exit 1 ;;
  esac
done

TOOLKIT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CFG_BASE="${XDG_CONFIG_HOME:-$HOME/.config}"
OPENCODE_DIR="$CFG_BASE/opencode"
SKILL_DIR="$OPENCODE_DIR/skills/operator-memory"
DEST="${DEST:-$CFG_BASE/operator-persona}"
DATE_UTC="$(date -u '+%Y-%m-%d %H:%M UTC')"

log() { printf '[bootstrap] %s\n' "$*"; }

# --- Identitas operator ---
if [[ -z "$NAME" ]]; then
  read -rp "Nama operator: " NAME
fi
if [[ -z "$EMAIL" ]]; then
  read -rp "Email operator: " EMAIL
fi
if [[ -z "$GITHUB_HANDLE" && $LOCAL_ONLY -eq 0 ]]; then
  read -rp "Handle GitHub (mis. lacevoid): " GITHUB_HANDLE
fi

if [[ -z "$NAME" || -z "$EMAIL" ]]; then
  log "GAGAL: nama dan email wajib diisi." >&2
  exit 1
fi
if [[ $LOCAL_ONLY -eq 0 && -z "$GITHUB_HANDLE" ]]; then
  log "GAGAL: handle GitHub wajib diisi (atau gunakan --local-only)." >&2
  exit 1
fi

log "Identitas: $NAME <$EMAIL>"
log "Repo backup: ${GITHUB_HANDLE:-LOCAL}/$BACKUP_REPO"

# --- Repo GitHub privat (bila diminta) ---
if [[ $LOCAL_ONLY -eq 0 && -z "$REMOTE_URL" ]]; then
  if command -v gh >/dev/null 2>&1; then
    if gh repo view "$GITHUB_HANDLE/$BACKUP_REPO" >/dev/null 2>&1; then
      log "repo GitHub sudah ada: $GITHUB_HANDLE/$BACKUP_REPO (dipakai apa adanya)"
    else
      log "membuat repo privat: $GITHUB_HANDLE/$BACKUP_REPO ..."
      gh repo create "$GITHUB_HANDLE/$BACKUP_REPO" --private || {
        log "GAGAL membuat repo via gh." >&2; exit 1; }
      log "repo privat dibuat."
    fi
  else
    log "PERINGATAN: 'gh' tidak terpasang — repo GitHub tidak dibuat otomatis."
    log "           Buat repo privat https://github.com/new bernama $BACKUP_REPO"
    log "           lalu jalankan ulang dengan --remote-url git@github.com:$GITHUB_HANDLE/$BACKUP_REPO.git"
  fi
fi

REMOTE_URL="${REMOTE_URL:-git@github.com:${GITHUB_HANDLE:-x}/$BACKUP_REPO.git}"

# --- Clone / buat salinan lokal repo backup ---
if [[ -d "$DEST/.git" ]]; then
  log "salinan lokal sudah ada: $DEST"
  if [[ $LOCAL_ONLY -eq 0 ]] && git -C "$DEST" remote | grep -q '^origin$'; then
    ( cd "$DEST" && git pull --ff-only 2>&1 | tail -1 ) || log "PERINGATAN: pull gagal — lanjut dengan state lokal."
  fi
elif [[ -d "$DEST" ]]; then
  log "GAGAL: $DEST ada tapi bukan repo git." >&2
  exit 1
else
  if [[ $LOCAL_ONLY -eq 1 ]]; then
    git init "$DEST" >/dev/null 2>&1
    log "repo git lokal dibuat: $DEST"
  else
    log "clone: $REMOTE_URL -> $DEST"
    git clone "$REMOTE_URL" "$DEST" 2>&1 | tail -2 || {
      log "GAGAL clone — periksa remote/auth." >&2; exit 1; }
  fi
fi

mkdir -p "$SKILL_DIR"
mkdir -p "$DEST/config/skills/operator-memory"

# --- Pasang skill (mekanisme — selalu dari template) ---
if [[ -f "$TOOLKIT_DIR/skill/SKILL.md" ]]; then
  sed -e "s|{{NAME}}|$NAME|g" \
      -e "s|{{EMAIL}}|$EMAIL|g" \
      -e "s|{{GITHUB_HANDLE}}|$GITHUB_HANDLE|g" \
      -e "s|{{BACKUP_REPO}}|$BACKUP_REPO|g" \
      -e "s|{{DATE}}|$DATE_UTC|g" \
      "$TOOLKIT_DIR/skill/SKILL.md" > "$SKILL_DIR/SKILL.md"
  log "skill dipasang: $SKILL_DIR/SKILL.md"
else
  log "GAGAL: template skill tidak ditemukan di $TOOLKIT_DIR/skill/SKILL.md" >&2
  exit 1
fi

# --- Pasang memori: adopsi remote atau seed starter (jangan timpa memori live) ---
if [[ -f "$SKILL_DIR/memory.md" ]]; then
  log "memori live dipertahankan: $SKILL_DIR/memory.md"
elif [[ -f "$DEST/config/skills/operator-memory/memory.md" ]]; then
  cp "$DEST/config/skills/operator-memory/memory.md" "$SKILL_DIR/memory.md"
  log "memori diadopsi dari repo backup (perangkat lain)."
elif [[ -f "$TOOLKIT_DIR/skill/memory.md.start" ]]; then
  sed -e "s|{{NAME}}|$NAME|g" \
      -e "s|{{EMAIL}}|$EMAIL|g" \
      -e "s|{{GITHUB_HANDLE}}|$GITHUB_HANDLE|g" \
      -e "s|{{BACKUP_REPO}}|$BACKUP_REPO|g" \
      -e "s|{{DATE}}|$DATE_UTC|g" \
      "$TOOLKIT_DIR/skill/memory.md.start" > "$SKILL_DIR/memory.md"
  log "memori starter dibuat: $SKILL_DIR/memory.md"
else
  log "GAGAL: template memori tidak ditemukan." >&2
  exit 1
fi

# --- Tautkan memory.md ke opencode.jsonc global ---
CONFIG_FILE="$OPENCODE_DIR/opencode.jsonc"
# Rujukan portabel bila lokasi standar (~/.config/opencode), agar restore di
# mesin lain tetap menunjuk benar; path absolut bila XDG_CONFIG_HOME di-override.
if [[ "$OPENCODE_DIR" == "$HOME/.config/opencode" ]]; then
  MEM_REF="~/.config/opencode/skills/operator-memory/memory.md"
else
  MEM_REF="$SKILL_DIR/memory.md"
fi
if [[ ! -f "$CONFIG_FILE" ]]; then
  mkdir -p "$OPENCODE_DIR"
  cat > "$CONFIG_FILE" <<'EOF'
{
  "$schema": "https://opencode.ai/config.json",
  "instructions": [
    "__MEM_REF__"
  ]
}
EOF
  sed -i "s|__MEM_REF__|$MEM_REF|" "$CONFIG_FILE"
  log "opencode.jsonc dibuat: $CONFIG_FILE"
elif grep -q 'operator-memory/memory\.md' "$CONFIG_FILE"; then
  log "opencode.jsonc sudah memuat referensi memory.md (tidak diubah)."
else
  if command -v python3 >/dev/null 2>&1 \
     && python3 -c 'import json,sys; json.load(open(sys.argv[1]))' "$CONFIG_FILE" 2>/dev/null; then
    cp "$CONFIG_FILE" "$CONFIG_FILE.bak.$DATE_UTC"
    python3 - "$CONFIG_FILE" "$MEM_REF" <<'PYEOF'
import json, sys
path, ref = sys.argv[1], sys.argv[2]
cfg = json.load(open(path))
cfg.setdefault("instructions", [])
if ref not in cfg["instructions"]:
    cfg["instructions"].append(ref)
with open(path, "w") as f:
    json.dump(cfg, f, indent=2)
    f.write("\n")
PYEOF
    log "opencode.jsonc diperbarui (referensi memory.md ditambahkan)."
  else
    log "PERINGATAN: opencode.jsonc sudah ada dan bukan JSON murni —"
    log "           tambahkan manual baris ini ke daftar instructions:"
    log "           \"$MEM_REF\""
  fi
fi

# --- Sinkronkan config ke repo backup + commit/push ---
log "menyalin config ke repo backup..."
cp -f "$SKILL_DIR/SKILL.md"   "$DEST/config/skills/operator-memory/SKILL.md"
cp -f "$SKILL_DIR/memory.md"  "$DEST/config/skills/operator-memory/memory.md"
cp -f "$CONFIG_FILE"          "$DEST/config/opencode.jsonc" 2>/dev/null || true
cp -f "$TOOLKIT_DIR/backup.sh"  "$DEST/backup.sh"
cp -f "$TOOLKIT_DIR/restore.sh" "$DEST/restore.sh"
cp -f "$TOOLKIT_DIR/README.md"  "$DEST/README.md" 2>/dev/null || true
chmod +x "$DEST/backup.sh" "$DEST/restore.sh"

# identitas git disimpan ke config backup agar restore.sh bisa menerapkannya
# di mesin baru (clone fresh TIDAK membawa user.name/user.email git lokal).
printf '%s\n%s\n' "${NAME:-Operator}" "${EMAIL:-operator@localhost}" \
  > "$DEST/config/git-identity"

# identitas git lokal (repo backup) — tidak mengubah config global
git -C "$DEST" config user.name  "${NAME:-Operator}"
git -C "$DEST" config user.email "${EMAIL:-operator@localhost}"

git -C "$DEST" add -A
if ! git -C "$DEST" diff --cached --quiet; then
  git -C "$DEST" commit -m "Init: operator persona ($NAME, $DATE_UTC)"
  if [[ $LOCAL_ONLY -eq 0 ]]; then
    git -C "$DEST" push origin HEAD 2>&1 | tail -1 \
      && log "repo backup ter-push ke GitHub." \
      || log "PERINGATAN: push gagal — jalankan backup.sh nanti."
  else
    log "mode lokal: tanpa push."
  fi
else
  log "tidak ada perubahan untuk di-commit."
fi

# --- Ringkasan ---
cat <<EOF

══════════════════════════════════════════════════════════
✅ Operator memory siap untuk: $NAME <$EMAIL>
   Skill + memori : $SKILL_DIR
   Config global  : $CONFIG_FILE
   Repo backup    : $DEST
   Sinkronisasi   : dua arah (tarik → gabung → push) via backup.sh
══════════════════════════════════════════════════════════
Langkah berikut:
   1. RESTART opencode agar skill aktif.
   2. Saat mencatat kegiatan, agent memperbarui memory.md lalu
      menjalankan backup.sh (otomatis di checkpoint kerja).
   3. Mesin lain: clone repo privat lalu restore.sh.
EOF