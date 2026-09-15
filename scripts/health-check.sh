#!/usr/bin/env bash
#
# health-check.sh — Instruction Repository Integrity Check
#
# Verifies the AI-Instructions authoring repository stays consistent:
#   1. Every path token used in backticks across .md files resolves to an
#      existing file (no broken cross-references / "phantom" modules).
#   2. Every instruction module under laravel/ai-instructions/ is git-tracked
#      (a tracked file is not affected by .gitignore ignores and reaches PRs).
#   3. No generated distribution artifacts are present in the repo root.
#
# Usage: scripts/health-check.sh [--quiet]
# Exit code 0 = all checks pass; non-zero = violations found.

set -uo pipefail

QUIET=0
if [[ "${1:-}" == "--quiet" ]]; then
  QUIET=1
fi

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
FAILED=0
PASSED=0

say() {
  if [[ $QUIET -eq 0 ]]; then printf '%s\n' "$*"; fi
}

fail() {
  FAILED=$((FAILED + 1))
  printf '  [FAIL] %s\n' "$*" >&2
}

ok() {
  PASSED=$((PASSED + 1))
  say "  [ok] $*"
}

# Paths that exist only in consumer projects (referenced in instructions) or that
# name forbidden generated artifacts — never resolved against this repo.
SKIP_OR_EXTERNAL='^(app/|resources/|routes/|database/|config/|tests/|vendor/|public/|bootstrap/|node_modules/|stories/|\.github/|\.cursor/|\.clinerules/|CLAUDE\.md|GEMINI\.md|\.cursorrules|\.windsurfrules|\.continuerules|\.aider\.conf\.yml|AGENTS\.md|README\.md)'

cd "$ROOT"

say "== Referensi silang antar file instruksi =="

# Collect every backtick-coded path token from repo-root and laravel/ markdown files.
mapfile -t md_files < <(find . -maxdepth 1 -name '*.md'; find laravel -name '*.md')
TOKENS_TMP="$(mktemp)"
for f in "${md_files[@]}"; do
  grep -hoE '`[^`]+\.(md|sh)`' "$f" >> "$TOKENS_TMP" 2>/dev/null || true
done
sort -u "$TOKENS_TMP" -o "$TOKENS_TMP"
mapfile -t refs < <(sed -E 's/^`//; s/`$//' "$TOKENS_TMP")
rm -f "$TOKENS_TMP"

TOKEN_PATTERN='^[A-Za-z0-9._/-]+\.(md|sh)$'
for token in "${refs[@]}"; do
  # Skip external / non-file / forbidden-artifact references.
  [[ "$token" =~ $TOKEN_PATTERN ]] || continue
  [[ "$token" =~ http(s)?:// ]] && continue
  [[ "$token" == 'MASTER_BUILD_SPECIFICATION.md' ]] && continue
  [[ $token =~ $SKIP_OR_EXTERNAL ]] && continue

  # The constitution lives at laravel/ai-instructions.md but is referenced as a
  # bare filename from root-level docs.
  if [[ "$token" == 'ai-instructions.md' ]]; then
    ok "\`$token\` -> laravel/ai-instructions.md"
    continue
  fi

  resolved=""
  # ai-instructions/... tokens resolve relative to laravel/.
  if [[ "$token" == ai-instructions/* || "$token" == *'/ai-instructions/'* ]]; then
    if [[ -f "laravel/$token" ]]; then
      resolved="laravel/$token"
    fi
  fi
  # Resolve relative to the laravel instruction directory as fallback.
  if [[ -z "$resolved" && -f "laravel/ai-instructions/$token" ]]; then
    resolved="laravel/ai-instructions/$token"
  fi
  # Resolve relative to repo root as fallback (setup-ai-rules.sh, etc.).
  if [[ -z "$resolved" && -f "$token" ]]; then
    resolved="$token"
  fi
  # Basename fallback: bare filename that lives somewhere in laravel/ai-instructions/.
  if [[ -z "$resolved" ]]; then
    basename_match="$(find laravel/ai-instructions -type f -name "$token" 2>/dev/null | head -1)"
    if [[ -n "$basename_match" ]]; then
      resolved="$basename_match"
    fi
  fi

  if [[ -z "$resolved" ]]; then
    fail "referensi tdk ditemukan: \`$token\`"
  else
    ok "\`$token\` -> $resolved"
  fi
done

say ""
say "== Modul instruksi ter-track (bukan phantom) =="

while IFS= read -r file; do
  if git ls-files --error-unmatch "$file" >/dev/null 2>&1; then
    ok "tracked $file"
  else
    fail "TIDAK tracked (di-ignore .gitignore): $file"
  fi
done < <(find laravel/ai-instructions \( -name '*.md' -o -name '*.json' \) | sort)

say ""
say "== Artefak distribusi tidak boleh ada di root =="

while IFS= read -r artifact; do
  if [[ -e "$artifact" ]]; then
    fail "artefak distribusi ada di root: $artifact"
  else
    ok "tidak ada $artifact"
  fi
done < <(printf '%s\n' CLAUDE.md GEMINI.md .cursorrules .windsurfrules .continuerules .clinerules .cursor .aider.conf.yml .github/copilot-instructions.md)

say ""
if [[ $FAILED -gt 0 ]]; then
  printf 'health-check: %d GAGAL, %d lulus\n' "$FAILED" "$PASSED" >&2
  exit 1
fi
printf 'health-check: semua lulus (%d)\n' "$PASSED"
exit 0