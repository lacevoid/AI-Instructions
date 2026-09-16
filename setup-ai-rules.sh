#!/usr/bin/env bash
# ============================================================================
# AI Instructions Distribution Script
# ============================================================================
# Script ini mendistribusikan file instruksi AI ke direktori tempat script
# dieksekusi, sehingga semua AI coding assistant dapat membacanya.
#
# Penggunaan:
#   chmod +x setup-ai-rules.sh
#   ./setup-ai-rules.sh [framework]           # Distribusikan instruksi ke pwd
#   ./setup-ai-rules.sh reset [framework]     # Reset instruksi ke default template
#   ./setup-ai-rules.sh wipe [--force]        # Hapus SEMUA artefak instruksi dari pwd
#   ./setup-ai-rules.sh help                  # Tampilkan bantuan
#
# Contoh:
#   ./setup-ai-rules.sh laravel
#   ./setup-ai-rules.sh java
#   ./setup-ai-rules.sh          # Auto-detect dari direktori saat ini
#   ./setup-ai-rules.sh reset laravel   # Buang custom master, kembali ke default template
#   ./setup-ai-rules.sh wipe --force    # Hapus semua instruksi tanpa konfirmasi
#
# Framework yang didukung:
#   - laravel   → Laravel AI Instructions
#   - java      → Java AI Instructions (coming soon)
#   - react     → React AI Instructions (coming soon)
#
# AI tools yang didukung:
#   - Claude / Anthropic      → AGENTS.md, CLAUDE.md
#   - Google Gemini            → GEMINI.md
#   - GitHub Copilot           → .github/copilot-instructions.md
#   - Cursor                   → .cursor/rules/<framework>-directives.mdc, .cursorrules
#   - Windsurf                 → .windsurfrules
#   - Cline                    → .clinerules/<framework>-directives.md
#   - Aider                    → .aider.conf.yml
#   - Continue.dev             → .continuerules
#
# Workflow custom (menambahkan instruksi custom):
#   1. Jalankan script ini → dibuat master instruction yang bisa di-custom:
#        ai-instructions/master/ai-instructions.md   ← instruksi utama (EDIT DI SINI)
#        ai-instructions/master/ai-instructions/     ← modul instruksi (opsional, EDIT DI SINI)
#   2. Edit file master sesuai kebutuhan Anda.
#   3. Jalankan ulang script ini → versi custom didistribusikan ke semua file.
#   4. Untuk membuang custom dan kembali ke default template:
#        ./setup-ai-rules.sh reset <framework>
#   DILARANG mengedit file hasil distribusi (AGENTS.md, CLAUDE.md, ai-instructions/*.md, dll)
#   langsung, karena akan ditimpa setiap kali script dijalankan.
# ============================================================================

set -euo pipefail

# Direktori script berada (sumber instruksi) — symlink-aware agar bekerja
# saat dipanggil lewat vendor/bin (composer), .bin (npx), atau symlink lain.
SCRIPT_PATH="${BASH_SOURCE[0]}"
if command -v readlink >/dev/null 2>&1; then
    _ln=0
    while [ -L "$SCRIPT_PATH" ] && [ "$_ln" -lt 32 ]; do
        _TARGET="$(readlink "$SCRIPT_PATH")"
        case "$_TARGET" in
            /*) SCRIPT_PATH="$_TARGET" ;;
            *) SCRIPT_PATH="$(cd "$(dirname "$SCRIPT_PATH")" && pwd)/$_TARGET" ;;
        esac
        _ln=$((_ln + 1))
    done
fi
SCRIPT_DIR="$(cd "$(dirname "$SCRIPT_PATH")" && pwd)"

# Direktori target (tempat script dijalankan)
TARGET_DIR="$(pwd)"

# Framework yang akan didistribusikan (diatur oleh parsing subcommand di MAIN)
FRAMEWORK=""

# Fungsi: lowercase
to_lower() {
    echo "$1" | tr '[:upper:]' '[:lower:]'
}

# Warna output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# ============================================================================
# Fungsi: Tampilkan header
# ============================================================================
show_header() {
    echo -e "${BLUE}╔══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║  AI Instructions Distribution Script                    ║${NC}"
    echo -e "${BLUE}╚══════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

# ============================================================================
# Fungsi: Tampilkan available frameworks
# ============================================================================
show_frameworks() {
    echo -e "${YELLOW}📂 Available frameworks:${NC}"
    for dir in "${SCRIPT_DIR}"/*/; do
        if [ -d "$dir" ] && [ -f "$dir/ai-instructions.md" ]; then
            local name
            name="$(basename "$dir")"
            echo -e "   • ${GREEN}${name}${NC}"
        fi
    done
    echo ""
}

# ============================================================================
# Fungsi: Auto-detect framework
# ============================================================================
auto_detect_framework() {
    echo -e "${YELLOW}🔍 Auto-detecting framework...${NC}"

    # Check if there's only one framework available
    local frameworks=()
    for dir in "${SCRIPT_DIR}"/*/; do
        if [ -d "$dir" ] && [ -f "$dir/ai-instructions.md" ]; then
            frameworks+=("$(basename "$dir")")
        fi
    done

    if [ ${#frameworks[@]} -eq 1 ]; then
        FRAMEWORK="${frameworks[0]}"
        echo -e "   Found: ${GREEN}${FRAMEWORK}${NC}"
    elif [ ${#frameworks[@]} -gt 1 ]; then
        echo -e "${RED}❌ Multiple frameworks found. Please specify one:${NC}"
        for fw in "${frameworks[@]}"; do
            echo -e "   • ${fw}"
        done
        echo ""
        echo "Usage: $0 <framework>"
        exit 1
    else
        echo -e "${RED}❌ No frameworks found in ${SCRIPT_DIR}${NC}"
        exit 1
    fi
}

# ============================================================================
# Fungsi: Distribute file dengan header komentar
# ============================================================================
distribute() {
    local source="$1"
    local target="$2"
    local label="$3"
    local dir
    dir="$(dirname "$target")"

    # Buat direktori jika belum ada
    mkdir -p "$dir"

    # Copy file
    cp "$source" "$target"

    echo -e "  ${GREEN}✅${NC} ${label} → ${target}"
    count=$((count + 1))
}

# ============================================================================
# Fungsi: Distribute folder modul ai-instructions (01-11, 12-project-specific)
# ============================================================================
distribute_module_dir() {
    local source_dir="$1"
    local target_dir="$2"
    local label="$3"

    if [ ! -d "$source_dir" ]; then
        echo -e "  ${YELLOW}⚠️  ${label} tidak ditemukan, dilewati${NC}"
        return 0
    fi

    # Buat direktori target jika belum ada
    mkdir -p "$target_dir"

    # Hapus isi target yang lama (file modul) TANPA menghapus folder master/
    find "$target_dir" -mindepth 1 -maxdepth 1 ! -name "master" -exec rm -rf {} +

    # Copy seluruh isi (termasuk subdirektori 12-project-specific/)
    cp -r "$source_dir"/. "$target_dir"/

    echo -e "  ${GREEN}✅${NC} ${label} → ${target_dir}"
    count=$((count + 1))
}

# ============================================================================
# Fungsi: Sinkronkan Master Instruction (bisa di-custom)
# - Jika master belum ada, salin dari template framework.
# - Jika master sudah ada, JANGAN ditimpa (user berhak mengeditnya).
# ============================================================================
sync_master() {
    local framework_dir="$1"
    local master_dir="$2"

    mkdir -p "$master_dir"

    # Master konstitusi utama
    if [ -f "${master_dir}/ai-instructions.md" ]; then
        echo -e "  ${YELLOW}📝${NC} Master utama sudah ada, tidak ditimpa: ${master_dir}/ai-instructions.md"
    else
        cp "${framework_dir}/ai-instructions.md" "${master_dir}/ai-instructions.md"
        echo -e "  ${BLUE}🆕${NC} Master utama dibuat dari template: ${master_dir}/ai-instructions.md"
    fi

    # Master folder modul
    if [ -d "${master_dir}/ai-instructions" ]; then
        echo -e "  ${YELLOW}📝${NC} Master modul sudah ada, tidak ditimpa: ${master_dir}/ai-instructions/"
    elif [ -d "${framework_dir}/ai-instructions" ]; then
        cp -r "${framework_dir}/ai-instructions" "${master_dir}/ai-instructions"
        echo -e "  ${BLUE}🆕${NC} Master modul dibuat dari template: ${master_dir}/ai-instructions/"
    fi
}

# ============================================================================
# Fungsi: Tampilkan usage / bantuan
# ============================================================================
usage() {
    cat <<USAGE
Usage: $0 [<framework>]           Distribusikan instruksi ke proyek konsumen (pwd)
       $0 reset [<framework>]     Reset instruksi ke default template
                                  (hapus ai-instructions/master + distribusi ulang)
       $0 wipe [--force]          Hapus SEMUA artefak instruksi dari pwd
       $0 help                    Tampilkan bantuan ini

Commands:
  distribute   (default) Bentuk/sinkronkan master lalu distribusikan ke semua AI tools.
  reset        Hapus folder master yang di-custom, buat ulang dari template,
               lalu distribusikan ulang (kembali ke default template).
  wipe         Hapus semua file artefak hasil distribusi dari pwd:
               AGENTS.md, CLAUDE.md, GEMINI.md, .github/copilot-instructions.md,
               .cursorrules, .cursor/, .windsurfrules, .clinerules/,
               .continuerules, .aider.conf.yml, ai-instructions/ (termasuk master/).
               Tanpa --force, diminta konfirmasi.

Options:
  --force      Lewati konfirmasi pada perintah wipe (untuk automation/CI).

Examples:
  ./setup-ai-rules.sh laravel          Distribusikan framework laravel
  ./setup-ai-rules.sh reset laravel    Kembalikan ke default template lalu distribusikan
  ./setup-ai-rules.sh wipe --force     Hapus semua instruksi tanpa konfirmasi
USAGE
}

# ============================================================================
# Fungsi: Reset — hapus master hasil custom agar disinkronkan ulang dari template
# ============================================================================
reset_master() {
    local master_dir="${TARGET_DIR}/ai-instructions/master"
    if [ -d "$master_dir" ]; then
        echo -e "${YELLOW}♻️  Reset: menghapus master hasil custom: ${master_dir}${NC}"
        rm -rf "$master_dir"
    else
        echo -e "${YELLOW}♻️  Reset: master belum ada — akan dibuat dari template.${NC}"
    fi
}

# ============================================================================
# Fungsi: Wipe — hapus semua artefak instruksi dari direktori target (pwd)
# ============================================================================
wipe_instructions() {
    local force=0
    if [[ "${1:-}" == "--force" ]]; then
        force=1
    fi

    echo -e "${YELLOW}🧹 Wipe instruksi AI dari: ${TARGET_DIR}${NC}"
    echo -e "    Akan dihapus: AGENTS.md, CLAUDE.md, GEMINI.md,"
    echo -e "    .github/copilot-instructions.md, .cursorrules, .cursor/,"
    echo -e "    .windsurfrules, .clinerules/, .continuerules, .aider.conf.yml,"
    echo -e "    ai-instructions/ (termasuk master/ hasil custom)."
    echo ""

    if [[ $force -ne 1 ]]; then
        if [[ ! -t 0 ]]; then
            echo -e "${RED}❌ Terminal non-interaktif — jalankan dengan --force untuk mengeksekusi wipe.${NC}"
            exit 1
        fi
        read -r -p "Yakin ingin menghapus semua file di atas? [y/N] " ans
        if [[ ! "$ans" =~ ^[yY] ]]; then
            echo -e "${YELLOW}Wipe dibatalkan.${NC}"
            exit 0
        fi
    fi

    local count=0
    local item
    for item in \
        "AGENTS.md" \
        "CLAUDE.md" \
        "GEMINI.md" \
        ".github/copilot-instructions.md" \
        ".cursorrules" \
        ".windsurfrules" \
        ".continuerules" \
        ".aider.conf.yml"; do
        if [[ -e "${TARGET_DIR}/${item}" ]]; then
            rm -f "${TARGET_DIR}/${item}"
            echo -e "  ${RED}🗑️${NC} ${item}"
            count=$((count + 1))
        fi
    done

    for item in ".cursor" ".clinerules" "ai-instructions"; do
        if [[ -d "${TARGET_DIR}/${item}" ]]; then
            rm -rf "${TARGET_DIR:?}/${item}"
            echo -e "  ${RED}🗑️${NC} ${item}/"
            count=$((count + 1))
        fi
    done

    # Bersihkan direktori induk yang kini kosong (abaikan bila masih terpakai)
    for item in ".github" ".clinerules" ".cursor"; do
        if [[ -d "${TARGET_DIR}/${item}" ]]; then
            rmdir "${TARGET_DIR}/${item}" 2>/dev/null || true
        fi
    done

    echo ""
    echo -e "${GREEN}══════════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}✅ Wipe selesai! ${count} artefak dihapus.${NC}"
    echo -e "${GREEN}══════════════════════════════════════════════════════════${NC}"
    echo ""
    echo -e "${YELLOW}ℹ️  Untuk memasang kembali, jalankan: ./setup-ai-rules.sh <framework>${NC}"
}

# ============================================================================
# Fungsi: Buat file Cursor .mdc dengan frontmatter
# ============================================================================
distribute_cursor_mdc() {
    local source="$1"
    local target="$2"
    local framework_lower="$3"
    local dir
    dir="$(dirname "$target")"

    mkdir -p "$dir"

    # Cursor .mdc membutuhkan YAML frontmatter
    cat > "$target" << FRONTMATTER
---
description: "${framework_lower} AI Instructions — Directives for AI Agent"
globs: "**/*"
alwaysApply: true
---

FRONTMATTER

    # Append isi instruksi
    cat "$source" >> "$target"

    echo -e "  ${GREEN}✅${NC} Cursor (.mdc) → ${target}"
    count=$((count + 1))
}

# ============================================================================
# Fungsi: Buat .aider.conf.yml
# ============================================================================
create_aider_config() {
    local target="$1"
    local framework_dir="$2"

    cat > "$target" << EOF
# ${FRAMEWORK_NAME} — Aider Configuration
# File ini otomatis di-generate oleh setup-ai-rules.sh

read:
EOF

    # Tambahkan semua file instruksi
    for file in "${framework_dir}"*.md; do
        if [ -f "$file" ]; then
            local filename
            filename="$(basename "$file")"
            echo "  - ai-instructions/${filename}" >> "$target"
        fi
    done

    echo -e "  ${GREEN}✅${NC} Aider → .aider.conf.yml"
    count=$((count + 1))
}

# ============================================================================
# MAIN
# ============================================================================

show_header

# Parsing subcommand
COMMAND="$(to_lower "${1:-}")"
case "$COMMAND" in
    ""|distribute)
        FRAMEWORK="${2:-}"
        ;;
    reset)
        shift
        FRAMEWORK="${1:-}"
        reset_master
        echo ""
        ;;
    wipe)
        shift
        wipe_instructions "$@"
        exit 0
        ;;
    help|-h|--help)
        usage
        exit 0
        ;;
    *)
        FRAMEWORK="${1:-}"
        ;;
esac

# Auto-detect jika tidak ada framework yang ditentukan
if [ -z "$FRAMEWORK" ]; then
    auto_detect_framework
fi

# Validasi framework
FRAMEWORK_LOWER="$(to_lower "$FRAMEWORK")"

# Cari direktori framework (case-insensitive)
FRAMEWORK_DIR=""
for dir in "${SCRIPT_DIR}"/*/; do
    if [ -d "$dir" ] && [ "$(to_lower "$(basename "$dir")")" = "$FRAMEWORK_LOWER" ]; then
        FRAMEWORK_DIR="${dir%/}"
        break
    fi
done

if [ -z "$FRAMEWORK_DIR" ]; then
    echo -e "${RED}❌ Framework directory tidak ditemukan: ${FRAMEWORK}${NC}"
    echo ""
    show_frameworks
    exit 1
fi

FRAMEWORK_NAME="$(basename "$FRAMEWORK_DIR")"

SOURCE_FILE="${FRAMEWORK_DIR}/ai-instructions.md"

if [ ! -f "$SOURCE_FILE" ]; then
    echo -e "${RED}❌ File sumber tidak ditemukan: ${SOURCE_FILE}${NC}"
    exit 1
fi

echo -e "${YELLOW}📦 Framework: ${FRAMEWORK_NAME}${NC}"
echo -e "${YELLOW}📄 Template: ${SOURCE_FILE}${NC}"
echo -e "${YELLOW}🎯 Target: ${TARGET_DIR}${NC}"
echo ""

# Counter
count=0

# Master instruction (dapat di-custom) — dibuat dari template jika belum ada
MASTER_DIR="${TARGET_DIR}/ai-instructions/master"
MASTER_FILE="${MASTER_DIR}/ai-instructions.md"
MASTER_MODULE_DIR="${MASTER_DIR}/ai-instructions"

# ===========================================================================
# 0. Sinkronisasi Master Instruction
# ===========================================================================
echo -e "${BLUE}[0] Sinkronisasi Master Instruction${NC}"
sync_master "${FRAMEWORK_DIR}" "${MASTER_DIR}"
echo ""

# ===========================================================================
# 1. Claude / Anthropic → AGENTS.md
# ===========================================================================
echo -e "${BLUE}[1/9] Claude / Anthropic${NC}"
distribute "$MASTER_FILE" "${TARGET_DIR}/AGENTS.md" "AGENTS.md"
distribute "$MASTER_FILE" "${TARGET_DIR}/CLAUDE.md" "CLAUDE.md"

# ===========================================================================
# 2. Google Gemini → GEMINI.md
# ===========================================================================
echo -e "${BLUE}[2/9] Google Gemini${NC}"
distribute "$MASTER_FILE" "${TARGET_DIR}/GEMINI.md" "GEMINI.md"

# ===========================================================================
# 3. GitHub Copilot → .github/copilot-instructions.md
# ===========================================================================
echo -e "${BLUE}[3/9] GitHub Copilot${NC}"
distribute "$MASTER_FILE" "${TARGET_DIR}/.github/copilot-instructions.md" "Copilot Instructions"

# ===========================================================================
# 4. Cursor → .cursorrules + .cursor/rules/<framework>-directives.mdc
# ===========================================================================
echo -e "${BLUE}[4/9] Cursor${NC}"
distribute "$MASTER_FILE" "${TARGET_DIR}/.cursorrules" ".cursorrules"
distribute_cursor_mdc "$MASTER_FILE" "${TARGET_DIR}/.cursor/rules/${FRAMEWORK_NAME}-directives.mdc" "$FRAMEWORK_NAME"

# ===========================================================================
# 5. Windsurf → .windsurfrules
# ===========================================================================
echo -e "${BLUE}[5/9] Windsurf${NC}"
distribute "$MASTER_FILE" "${TARGET_DIR}/.windsurfrules" ".windsurfrules"

# ===========================================================================
# 6. Cline → .clinerules/<framework>-directives.md
# ===========================================================================
echo -e "${BLUE}[6/9] Cline${NC}"
distribute "$MASTER_FILE" "${TARGET_DIR}/.clinerules/${FRAMEWORK_NAME}-directives.md" "Cline Rules"

# ===========================================================================
# 7. Continue.dev → .continuerules
# ===========================================================================
echo -e "${BLUE}[7/9] Continue.dev${NC}"
distribute "$MASTER_FILE" "${TARGET_DIR}/.continuerules" ".continuerules"

# ===========================================================================
# 8. Aider → .aider.conf.yml
# ===========================================================================
echo -e "${BLUE}[8/9] Aider${NC}"
create_aider_config "${TARGET_DIR}/.aider.conf.yml" "${MASTER_MODULE_DIR}/"

# ===========================================================================
# 9. Modul ai-instructions/ (01-11 + 12-project-specific)
# ===========================================================================
echo -e "${BLUE}[9/9] Modul Instruksi${NC}"
distribute_module_dir "${MASTER_MODULE_DIR}" "${TARGET_DIR}/ai-instructions" "Modul Instruksi"

# ===========================================================================
# Selesai
# ===========================================================================
echo ""
echo -e "${GREEN}══════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}✅ Selesai! ${count} file berhasil didistribusikan.${NC}"
echo -e "${GREEN}══════════════════════════════════════════════════════════${NC}"
echo ""
echo -e "${YELLOW}📋 File yang di-generate:${NC}"
echo "   ├── ai-instructions/master/ai-instructions.md  (MASTER — edit di sini!)"
echo "   ├── ai-instructions/master/ai-instructions/    (Modul master — edit di sini, opsional)"
echo "   ├── AGENTS.md                                    (Claude/Anthropic)"
echo "   ├── CLAUDE.md                                    (Claude)"
echo "   ├── GEMINI.md                                    (Google Gemini)"
echo "   ├── .github/copilot-instructions.md              (GitHub Copilot)"
echo "   ├── .cursorrules                                 (Cursor - legacy)"
echo "   ├── .cursor/rules/${FRAMEWORK_NAME}-directives.mdc     (Cursor - modular)"
echo "   ├── .windsurfrules                               (Windsurf)"
echo "   ├── .clinerules/${FRAMEWORK_NAME}-directives.md        (Cline)"
echo "   ├── .continuerules                               (Continue.dev)"
echo "   ├── ai-instructions/                             (Modul 01-11 + project-specific)"
echo "   └── .aider.conf.yml                              (Aider)"
echo ""
echo -e "${YELLOW}💡 Tambah instruksi custom:${NC}"
echo "   1. Edit ai-instructions/master/ai-instructions.md (dan/atau ai-instructions/master/ai-instructions/)"
echo "   2. Jalankan ulang script untuk mendistribusikan ulang custom-nya:"
echo "      ./setup-ai-rules.sh ${FRAMEWORK_NAME}"
echo ""
echo -e "${YELLOW}💡 Tip:${NC} Untuk mengganti framework, jalankan:"
echo "   ./setup-ai-rules.sh <framework>"
echo ""
echo -e "${YELLOW}📂 Frameworks tersedia:${NC}"
show_frameworks
