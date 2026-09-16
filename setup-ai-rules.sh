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
#   ./setup-ai-rules.sh template <cmd>        # Kelola template milik konsumen
#   ./setup-ai-rules.sh help                  # Tampilkan bantuan
#
# Contoh:
#   ./setup-ai-rules.sh laravel
#   ./setup-ai-rules.sh java
#   ./setup-ai-rules.sh          # Auto-detect dari direktori saat ini
#   ./setup-ai-rules.sh reset laravel   # Buang custom master, kembali ke default template
#   ./setup-ai-rules.sh wipe --force    # Hapus semua instruksi tanpa konfirmasi
#   ./setup-ai-rules.sh template clone mylaravel laravel   # customisasi built-in
#   ./setup-ai-rules.sh template create myfw              # buat template sendiri
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
#   - opencode                 → opencode.json + AGENTS.md (default AI untuk pekerjaan)
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

# Template milik konsumen (dapat dibuat/hapus/perbarui) vs built-in paket (terproteksi).
# Built-in hidup di SCRIPT_DIR; template konsumen hidup di AINSTRUCT_HOME/templates
# dan menang (shadow) atas built-in jika namanya sama.
AINSTRUCT_HOME_DIR="${AINSTRUCT_HOME:-${XDG_CONFIG_HOME:-$HOME/.config}/ainstruct}"
CONSUMER_TEMPLATES_DIR="${AINSTRUCT_HOME_DIR}/templates"

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
    echo -e "${YELLOW}📂 Frameworks tersedia:${NC}"
    echo -e "  ${BLUE}Built-in (terproteksi):${NC}"
    for dir in "${SCRIPT_DIR}"/*/; do
        if [ -d "$dir" ] && [ -f "$dir/ai-instructions.md" ]; then
            echo -e "   • ${GREEN}$(basename "$dir")${NC}"
        fi
    done
    echo -e "  ${YELLOW}Custom (milik konsumen — dapat diubah/hapus):${NC}"
    if [ -d "${CONSUMER_TEMPLATES_DIR}" ]; then
        for dir in "${CONSUMER_TEMPLATES_DIR}"/*/; do
            if [ -d "$dir" ] && [ -f "$dir/ai-instructions.md" ]; then
                echo -e "   • ${GREEN}$(basename "$dir")${NC}"
            fi
        done
    fi
    echo ""
}

# ============================================================================
# Fungsi: Auto-detect framework
# ============================================================================
auto_detect_framework() {
    echo -e "${YELLOW}🔍 Auto-detecting framework...${NC}"

    # Kumpulkan semua template (konsumen dulu), dedup nama (konsumen shadow built-in)
    local frameworks=()
    local unique=()
    if [ -d "${CONSUMER_TEMPLATES_DIR}" ]; then
        for dir in "${CONSUMER_TEMPLATES_DIR}"/*/; do
            if [ -d "$dir" ] && [ -f "$dir/ai-instructions.md" ]; then
                frameworks+=("$(basename "$dir")")
            fi
        done
    fi
    for dir in "${SCRIPT_DIR}"/*/; do
        if [ -d "$dir" ] && [ -f "$dir/ai-instructions.md" ]; then
            frameworks+=("$(basename "$dir")")
        fi
    done
    local fw u found
    for fw in "${frameworks[@]}"; do
        found=0
        for u in "${unique[@]}"; do
            if [ "$u" = "$fw" ]; then found=1; break; fi
        done
        if [ "$found" -eq 0 ]; then unique+=("$fw"); fi
    done
    frameworks=("${unique[@]}")

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
# Fungsi: Cari direktori template — konsumen (home) DIDAHULUKAN, lalu built-in
# ============================================================================
find_template_dir() {
    local name="$1"
    local lower
    lower="$(to_lower "$name")"
    local dir
    local result=""

    if [ -d "${CONSUMER_TEMPLATES_DIR}" ]; then
        for dir in "${CONSUMER_TEMPLATES_DIR}"/*/; do
            if [ -d "$dir" ] && [ "$(to_lower "$(basename "$dir")")" = "$lower" ] && [ -f "${dir}ai-instructions.md" ]; then
                result="${dir%/}"
                break
            fi
        done
    fi

    if [ -z "$result" ]; then
        for dir in "${SCRIPT_DIR}"/*/; do
            if [ -d "$dir" ] && [ "$(to_lower "$(basename "$dir")")" = "$lower" ] && [ -f "${dir}ai-instructions.md" ]; then
                result="${dir%/}"
                break
            fi
        done
    fi

    printf '%s' "$result"
}

# ============================================================================
# Template Manager — template milik konsumen (create/clone/update/delete/list/path)
# Built-in TERPROTEKSI: tidak dapat dihapus/diubah; customisasi via clone.
# ============================================================================
validate_template_name() {
    local name="$1"
    case "$name" in
        ""|*/*|.*|*[!A-Za-z0-9_-]*)
            echo -e "${RED}❌ Nama template tidak valid: '${name}'${NC}" >&2
            echo "   (hanya huruf/angka/-/_; tanpa '/'; tanpa diawali '.')" >&2
            exit 1
            ;;
    esac
}

is_builtin_template() {
    local name="$1"
    local lower
    lower="$(to_lower "$name")"
    local dir
    for dir in "${SCRIPT_DIR}"/*/; do
        if [ -d "$dir" ] && [ -f "$dir/ai-instructions.md" ] && [ "$(to_lower "$(basename "$dir")")" = "$lower" ]; then
            printf '%s' "${dir%/}"
            return 0
        fi
    done
    return 1
}

template_usage() {
    cat <<'TEMPLATE_USAGE'
Template manager — kelola template AI Instructions milik konsumen.
Built-in (dibuat repo authoring) TERPROTEKSI: tidak bisa dihapus/diubah; untuk
menyesuaikannya, clone sebagai template milik Anda lalu edit bebas.

Commands:
  template list                              Daftar semua template (built-in & custom)
  template create <name> [--force]           Buat template kosong (scaffold) milik konsumen
  template clone <name> <source> [--force]   Salin template (built-in/custom) sebagai milik konsumen
  template update <name> [--from <source>] [--force]  Perbarui template custom dari sumber
  template delete <name> [--force]           Hapus template custom (built-in DITOLAK: terproteksi)
  template path <name>                       Cetak lokasi direktori template (untuk diedit)

Examples:
  ainstruct template list
  ainstruct template clone mylaravel laravel     # customisasi built-in laravel sbg milik Anda
  ainstruct template update mylaravel --from laravel
  ainstruct template delete mylaravel --force
TEMPLATE_USAGE
}

template_list() {
    echo -e "${YELLOW}📚 Template AI Instructions${NC}"
    echo ""
    echo -e "  ${BLUE}Built-in (TERPROTEKSI):${NC}"
    local n=0 dir
    for dir in "${SCRIPT_DIR}"/*/; do
        if [ -f "$dir/ai-instructions.md" ]; then
            echo -e "    • ${GREEN}$(basename "$dir")${NC}"
            n=$((n + 1))
        fi
    done
    [ "$n" -eq 0 ] && echo "    (tidak ada)"
    echo ""
    echo -e "  ${GREEN}Custom (milik konsumen — dapat diubah/hapus):${NC}"
    n=0
    if [ -d "${CONSUMER_TEMPLATES_DIR}" ]; then
        for dir in "${CONSUMER_TEMPLATES_DIR}"/*/; do
            if [ -f "$dir/ai-instructions.md" ]; then
                echo -e "    • ${GREEN}$(basename "$dir")${NC}  (${dir%/})"
                n=$((n + 1))
            fi
        done
    fi
    [ "$n" -eq 0 ] && echo "    (belum ada — 'template create <nama>' atau 'template clone <nama> laravel')"
    echo ""
}

template_create() {
    local name="" force=0
    while [ "$#" -gt 0 ]; do
        case "$1" in
            --force) force=1; shift ;;
            *) if [ -z "$name" ]; then name="$1"; else echo "arg tak dikenal: $1" >&2; exit 1; fi; shift ;;
        esac
    done
    validate_template_name "$name"

    local target="${CONSUMER_TEMPLATES_DIR}/${name}"
    if [ -d "$target" ]; then
        echo -e "${RED}❌ Template custom sudah ada: ${target}${NC}" >&2
        exit 1
    fi
    local conflict
    conflict="$(find_template_dir "$name")"
    if [ -n "$conflict" ] && [ "$force" -ne 1 ]; then
        echo -e "${RED}❌ Nama '${name}' sudah dipakai oleh: ${conflict}${NC}" >&2
        echo -e "   Pakai nama lain, atau --force untuk mengambil alih nama (shadow built-in)." >&2
        exit 1
    fi

    mkdir -p "${target}/ai-instructions"
    cat > "${target}/ai-instructions.md" <<'SCAFFOLD'
# AI INSTRUCTION SYSTEM — CONSTITUTION

> [!CRITICAL]
> Template scaffold dibuat lewat `template create` — TERBUKA untuk diedit konsumen.
> Bangun set instruksi presisi di sini, lalu distribusikan dengan
> `ainstruct <nama-template>`.

# File Map

- `ai-instructions.md`  ← konstitusi (entry point). Tulis prinsip, priority system,
                          rule scope, workflow wajib, quality gates, referensi cepat.
- `ai-instructions/`    ← modul bernomor (`01-governance.md`, `02-agent-workflow.md`, …).
                          Referensikan setiap modul dari konstitusi.

# Workflow Wajib

1. Wajib baca `MASTER_BUILD_SPECIFICATION.md` di root proyek sebelum menulis kode.
2. Aturan ditulis MUST / MUST NOT yang actionable, spesifik, dan berdasar bukti proyek target.
3. Verifikasi sendiri sebelum "selesai": lint, health check, dan uji distribusi.
SCAFFOLD
    cat > "${target}/ai-instructions/README.md" <<'SCAFFOLD_MODULE'
# Modul Instruksi (scaffold)

Buat modul bernomor di direktori ini (contoh: `01-governance.md`, `02-agent-workflow.md`)
dan referensikan dari `ai-instructions.md` di atas.
SCAFFOLD_MODULE

    echo -e "${GREEN}✅ Template custom dibuat: ${target}${NC}"
    echo -e "${YELLOW}💡 Edit file di direktori tsb. Untuk salin dari template lain: 'template clone <nama> <sumber>'.${NC}"
}

template_clone() {
    local name="" source="" force=0
    while [ "$#" -gt 0 ]; do
        case "$1" in
            --force) force=1; shift ;;
            *) if [ -z "$name" ]; then name="$1"; elif [ -z "$source" ]; then source="$1"; else echo "arg tak dikenal: $1" >&2; exit 1; fi; shift ;;
        esac
    done
    validate_template_name "$name"
    if [ -z "$source" ]; then
        echo -e "${RED}❌ 'template clone' butuh <source> (contoh: 'template clone mylaravel laravel')${NC}" >&2
        template_usage
        exit 1
    fi

    local src
    src="$(find_template_dir "$source")"
    if [ -z "$src" ]; then
        echo -e "${RED}❌ Sumber template tidak ditemukan: '${source}'${NC}" >&2
        exit 1
    fi

    local conflict
    conflict="$(find_template_dir "$name")"
    if [ -n "$conflict" ] && [ "$force" -ne 1 ]; then
        echo -e "${RED}❌ Nama '${name}' sudah dipakai oleh: ${conflict}${NC}" >&2
        echo -e "   Gunakan --force untuk menimpa template custom / shadow built-in." >&2
        exit 1
    fi

    local target="${CONSUMER_TEMPLATES_DIR}/${name}"
    if [ -e "$target" ]; then
        rm -rf "$target"
    fi
    mkdir -p "${CONSUMER_TEMPLATES_DIR}"
    cp -r "$src" "$target"

    echo -e "${GREEN}✅ Template '${name}' di-clone dari '${source}': ${target}${NC}"
    echo -e "${YELLOW}💡 Built-in terproteksi; template klon ini milik Anda — bebas diubah/dihapus.${NC}"
}

template_update() {
    local name="" from="" force=0
    while [ "$#" -gt 0 ]; do
        case "$1" in
            --force) force=1; shift ;;
            --from) from="${2:-}"; shift 2 ;;
            *) if [ -z "$name" ]; then name="$1"; else echo "arg tak dikenal: $1" >&2; exit 1; fi; shift ;;
        esac
    done
    validate_template_name "$name"

    local target="${CONSUMER_TEMPLATES_DIR}/${name}"
    if [ ! -d "$target" ]; then
        local builtin_dir
        builtin_dir="$(is_builtin_template "$name" || true)"
        if [ -n "$builtin_dir" ]; then
            echo -e "${RED}❌ '${name}' adalah built-in TERPROTEKSI — tidak bisa diperbarui langsung.${NC}" >&2
            echo -e "   Customisasi lewat clone: 'template clone <nama> ${name}' lalu edit/update '${name}' milik Anda." >&2
        else
            echo -e "${RED}❌ Template custom tidak ditemukan: '${name}'${NC}" >&2
        fi
        exit 1
    fi

    local from_dir=""
    if [ -z "$from" ]; then
        from_dir="$(is_builtin_template "$name" || true)"
        if [ -z "$from_dir" ]; then
            echo -e "${RED}❌ Tidak ada built-in '$name' — berikan '--from <sumber>' (mis. template update ${name} --from laravel)${NC}" >&2
            exit 1
        fi
    else
        from_dir="$(find_template_dir "$from")"
        if [ -z "$from_dir" ]; then
            echo -e "${RED}❌ Sumber tidak ditemukan: '${from}'${NC}" >&2
            exit 1
        fi
    fi
    if [ "$from_dir" = "$target" ]; then
        echo -e "${RED}❌ Sumber dan target sama ('${name}'). Pakai '--from <sumber-lain>' atau '--from <built-in-nama-sama>'.${NC}" >&2
        exit 1
    fi

    if [ "$force" -ne 1 ]; then
        if [ ! -t 0 ]; then
            echo -e "${RED}❌ Terminal non-interaktif — berikan --force untuk mengeksekusi update.${NC}" >&2
            exit 1
        fi
        read -r -p "Timpa template custom '${name}' dari '${from_dir}' (menghapus edit Anda)? [y/N] " ans
        if [[ ! "$ans" =~ ^[yY] ]]; then
            echo -e "${YELLOW}Dibatalkan.${NC}"
            exit 0
        fi
    fi

    rm -rf "$target"
    cp -r "$from_dir" "$target"
    echo -e "${GREEN}✅ Template custom '${name}' diperbarui dari '${from_dir}'.${NC}"
}

template_delete() {
    local name="" force=0
    while [ "$#" -gt 0 ]; do
        case "$1" in
            --force) force=1; shift ;;
            *) if [ -z "$name" ]; then name="$1"; else echo "arg tak dikenal: $1" >&2; exit 1; fi; shift ;;
        esac
    done
    validate_template_name "$name"

    local target="${CONSUMER_TEMPLATES_DIR}/${name}"
    if [ -d "$target" ]; then
        if [ "$force" -ne 1 ]; then
            if [ ! -t 0 ]; then
                echo -e "${RED}❌ Terminal non-interaktif — berikan --force untuk mengeksekusi delete.${NC}" >&2
                exit 1
            fi
            read -r -p "Hapus template custom '${name}'? [y/N] " ans
            if [[ ! "$ans" =~ ^[yY] ]]; then
                echo -e "${YELLOW}Dibatalkan.${NC}"
                exit 0
            fi
        fi
        rm -rf "$target"
        echo -e "${GREEN}🗑️ Template custom '${name}' dihapus.${NC}"
        return 0
    fi

    local builtin_dir
    builtin_dir="$(is_builtin_template "$name" || true)"
    if [ -n "$builtin_dir" ]; then
        echo -e "${RED}❌ '${name}' adalah built-in TERPROTEKSI — tidak bisa dihapus.${NC}" >&2
        echo -e "   Clone sebagai milik Anda dulu: 'template clone <nama> ${name}', lalu hapus '<nama>'.${NC}" >&2
        exit 1
    fi
    echo -e "${RED}❌ Template tidak ditemukan: '${name}'${NC}" >&2
    exit 1
}

template_path() {
    local name="$1"
    if [ -z "$name" ]; then
        template_usage
        exit 1
    fi
    local dir
    dir="$(find_template_dir "$name")"
    if [ -z "$dir" ]; then
        echo -e "${RED}❌ Template tidak ditemukan: '${name}'${NC}" >&2
        exit 1
    fi
    case "$dir" in
        "${CONSUMER_TEMPLATES_DIR}"/*)
            printf '%s\n' "$dir"
            ;;
        *)
            echo -e "${YELLOW}⚠️  '${name}' = built-in TERPROTEKSI (jangan diedit langsung; clone dulu).${NC}" >&2
            printf '%s\n' "$dir"
            ;;
    esac
}

template_cmd() {
    local action="${1:-help}"
    shift || true
    case "$action" in
        list) template_list ;;
        create) template_create "$@" ;;
        clone) template_clone "$@" ;;
        update) template_update "$@" ;;
        delete) template_delete "$@" ;;
        path) template_path "${1:-}" ;;
        help|-h|--help) template_usage ;;
        *)
            echo -e "${RED}❌ 'template' aksi tak dikenal: ${action}${NC}" >&2
            template_usage
            exit 1
            ;;
    esac
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
# Fungsi: Distribusikan folder 'opencode/' milik template (agent + skill tim)
# ke .opencode/ proyek konsumen. Folder 'opencode/' di template bersifat
# OPTIONAL — tanpa folder ini tidak terjadi apa-apa (template lama tetap jalan).
# Isi yang sudah ada di .opencode/ konsumen TIDAK dihapus; hanya ditambah/ditimpa.
# ============================================================================
distribute_opencode_dir() {
    local source_dir="$1"
    local target_dir="$2"

    if [ ! -d "$source_dir" ]; then
        echo -e "  ${YELLOW}⚠️  Folder 'opencode/' template tidak ada — tim opencode dilewati${NC}"
        return 0
    fi

    mkdir -p "$target_dir"

    # Salin setiap subfolder/file di opencode/ ke .opencode/ (tanpa menghapus lain)
    for item in "${source_dir}"/*; do
        local name
        name="$(basename "$item")"
        if [ -d "$item" ]; then
            mkdir -p "${target_dir}/${name}"
            cp -r "${item}"/. "${target_dir}/${name}"/
        else
            cp "$item" "${target_dir}/${name}"
        fi
        echo -e "  ${GREEN}✅${NC} opencode/${name} → .opencode/${name}"
        count=$((count + 1))
    done

    echo -e "  ${YELLOW}ℹ️  Tim development opencode siap: .opencode/agent/* + .opencode/skills/${NC}"
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
       $0 template <cmd>          Kelola template AI Instructions (lihat 'template help')
       $0 help                    Tampilkan bantuan ini

Commands:
  distribute   (default) Bentuk/sinkronkan master lalu distribusikan ke semua AI tools.
               Bila template memiliki folder opencode/ (agent+skill tim), isinya
               disalin ke .opencode/ proyek konsumen (tanpa menghapus yang ada).
  reset        Hapus folder master yang di-custom, buat ulang dari template,
               lalu distribusikan ulang (kembali ke default template).
  wipe         Hapus semua file artefak hasil distribusi dari pwd:
               AGENTS.md, CLAUDE.md, GEMINI.md, .github/copilot-instructions.md,
               .cursorrules, .cursor/, .windsurfrules, .clinerules/,
               .continuerules, .aider.conf.yml, opencode.json, .opencode/,
               ai-instructions/ (termasuk master/).
               Tanpa --force, diminta konfirmasi.
  template     Kelola template milik konsumen (custom): list, create, clone, update,
               delete, path. Built-in TERPROTEKSI — customisasi lewat clone.

Options:
  --force      Lewati konfirmasi pada perintah wipe (untuk automation/CI).

Examples:
  ./setup-ai-rules.sh laravel          Distribusikan framework laravel
  ./setup-ai-rules.sh template list    Daftar template (built-in & custom)
  ./setup-ai-rules.sh template clone mylaravel laravel   # customisasi built-in
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
        ".aider.conf.yml" \
        "opencode.json"; do
        if [[ -e "${TARGET_DIR}/${item}" ]]; then
            rm -f "${TARGET_DIR}/${item}"
            echo -e "  ${RED}🗑️${NC} ${item}"
            count=$((count + 1))
        fi
    done

    for item in ".cursor" ".clinerules" ".opencode" "ai-instructions"; do
        if [[ -d "${TARGET_DIR}/${item}" ]]; then
            rm -rf "${TARGET_DIR:?}/${item}"
            echo -e "  ${RED}🗑️${NC} ${item}/"
            count=$((count + 1))
        fi
    done

    # Bersihkan direktori induk yang kini kosong (abaikan bila masih terpakai)
    for item in ".github" ".clinerules" ".cursor" ".opencode"; do
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
# Fungsi: Buat opencode.json — opencode sebagai default AI untuk pekerjaan
# ============================================================================
create_opencode_config() {
    local target="$1"

    if ! command -v opencode >/dev/null 2>&1; then
        echo -e "  ${YELLOW}⚠️${NC} opencode CLI tidak terpasang — pasang dengan:"
        echo -e "      curl -fsSL https://opencode.ai/install | bash"
    fi

    cat > "$target" << 'OP'
{
  "$schema": "https://opencode.ai/config.json",
  "instructions": ["AGENTS.md"],
  "default_agent": "build"
}
OP

    echo -e "  ${GREEN}✅${NC} opencode → ${target} (default AI untuk pekerjaan)"
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
    template)
        shift
        template_cmd "$@"
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

# Cari direktori template (case-insensitive): konsumen (home) dulu, lalu built-in
FRAMEWORK_DIR="$(find_template_dir "$FRAMEWORK")"

if [ -z "$FRAMEWORK_DIR" ]; then
    echo -e "${RED}❌ Framework/template directory tidak ditemukan: ${FRAMEWORK}${NC}"
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

# Marker sumber template — built-in terproteksi vs template milik konsumen
case "$FRAMEWORK_DIR" in
    "${CONSUMER_TEMPLATES_DIR}"/*)
        TEMPLATE_SOURCE_NOTE="${YELLOW}🧩 Template: custom konsumen (terbuka untuk diedit)${NC}"
        ;;
    *)
        TEMPLATE_SOURCE_NOTE="${YELLOW}🧩 Template: built-in (terproteksi — clone untuk customisasi)${NC}"
        ;;
esac

echo -e "${YELLOW}📦 Framework/Template: ${FRAMEWORK_NAME}${NC}"
echo -e "${TEMPLATE_SOURCE_NOTE}"
echo -e "${YELLOW}📄 Sumber: ${FRAMEWORK_DIR}${NC}"
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
echo -e "${BLUE}[1/10] Claude / Anthropic${NC}"
distribute "$MASTER_FILE" "${TARGET_DIR}/AGENTS.md" "AGENTS.md"
distribute "$MASTER_FILE" "${TARGET_DIR}/CLAUDE.md" "CLAUDE.md"

# ===========================================================================
# 2. Google Gemini → GEMINI.md
# ===========================================================================
echo -e "${BLUE}[2/10] Google Gemini${NC}"
distribute "$MASTER_FILE" "${TARGET_DIR}/GEMINI.md" "GEMINI.md"

# ===========================================================================
# 3. GitHub Copilot → .github/copilot-instructions.md
# ===========================================================================
echo -e "${BLUE}[3/10] GitHub Copilot${NC}"
distribute "$MASTER_FILE" "${TARGET_DIR}/.github/copilot-instructions.md" "Copilot Instructions"

# ===========================================================================
# 4. Cursor → .cursorrules + .cursor/rules/<framework>-directives.mdc
# ===========================================================================
echo -e "${BLUE}[4/10] Cursor${NC}"
distribute "$MASTER_FILE" "${TARGET_DIR}/.cursorrules" ".cursorrules"
distribute_cursor_mdc "$MASTER_FILE" "${TARGET_DIR}/.cursor/rules/${FRAMEWORK_NAME}-directives.mdc" "$FRAMEWORK_NAME"

# ===========================================================================
# 5. Windsurf → .windsurfrules
# ===========================================================================
echo -e "${BLUE}[5/10] Windsurf${NC}"
distribute "$MASTER_FILE" "${TARGET_DIR}/.windsurfrules" ".windsurfrules"

# ===========================================================================
# 6. Cline → .clinerules/<framework>-directives.md
# ===========================================================================
echo -e "${BLUE}[6/10] Cline${NC}"
distribute "$MASTER_FILE" "${TARGET_DIR}/.clinerules/${FRAMEWORK_NAME}-directives.md" "Cline Rules"

# ===========================================================================
# 7. Continue.dev → .continuerules
# ===========================================================================
echo -e "${BLUE}[7/10] Continue.dev${NC}"
distribute "$MASTER_FILE" "${TARGET_DIR}/.continuerules" ".continuerules"

# ===========================================================================
# 8. Aider → .aider.conf.yml
# ===========================================================================
echo -e "${BLUE}[8/10] Aider${NC}"
create_aider_config "${TARGET_DIR}/.aider.conf.yml" "${MASTER_MODULE_DIR}/"

# ===========================================================================
# 9. opencode → opencode.json (default AI untuk pekerjaan) + AGENTS.md (shared)
# ===========================================================================
echo -e "${BLUE}[9/10] opencode${NC}"
create_opencode_config "${TARGET_DIR}/opencode.json"

# ===========================================================================
# 10. Modul ai-instructions/ (01-11 + 12-project-specific)
# ===========================================================================
echo -e "${BLUE}[10/10] Modul Instruksi${NC}"
distribute_module_dir "${MASTER_MODULE_DIR}" "${TARGET_DIR}/ai-instructions" "Modul Instruksi"

# ===========================================================================
# 11. Tim opencode (opsional — template dengan folder opencode/agent|skills)
# ===========================================================================
echo -e "${BLUE}[11/11] Tim opencode (agent + skill)${NC}"
distribute_opencode_dir "${FRAMEWORK_DIR}/opencode" "${TARGET_DIR}/.opencode"

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
echo "   ├── AGENTS.md                                    (Claude/Anthropic + opencode)"
echo "   ├── CLAUDE.md                                    (Claude)"
echo "   ├── GEMINI.md                                    (Google Gemini)"
echo "   ├── .github/copilot-instructions.md              (GitHub Copilot)"
echo "   ├── .cursorrules                                 (Cursor - legacy)"
echo "   ├── .cursor/rules/${FRAMEWORK_NAME}-directives.mdc     (Cursor - modular)"
echo "   ├── .windsurfrules                               (Windsurf)"
echo "   ├── .clinerules/${FRAMEWORK_NAME}-directives.md        (Cline)"
echo "   ├── .continuerules                               (Continue.dev)"
echo "   ├── ai-instructions/                             (Modul 01-11 + project-specific)"
echo "   ├── .aider.conf.yml                              (Aider)"
echo "   ├── .opencode/agent|skills/                      (Tim opencode — bila template memilikinya)"
echo "   └── opencode.json                                (opencode — default AI untuk pekerjaan)"
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
