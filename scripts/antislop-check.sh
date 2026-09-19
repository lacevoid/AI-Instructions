#!/usr/bin/env bash
#
# antislop-check.sh — Anti-AI-slop pattern gate untuk dokumen authoring repo ini.
#
# Menscan seluruh .md ter-track (root + <Framework>/) terhadap pola marketing /
# AI-slop dari skill antislop (upstream miqdadbadjuber/anti-slop, MIT) — khususnya
# "Empty AI Vocabulary" (unlock, elevate, empower, delve, showcase, testament,
# game-changer, next-level, seamless, cutting-edge, revolutionary) dan klaim tanpa
# bukti. Tujuan: output authoring repo ini dibersihkan dari "nuansa AI-slop" dengan
# severity yang sama dengan gate lain (0 toleransi, evidence-based).
#
# Konten vendor dan deskripsi filter DIKECUALIKAN, karena mereka adalah sumber/
# pembahasan pola, bukan output authoring:
#   - `.opencode/`            — skill anti-slop untuk agent repo ini (self-use)
#   - `<Framework>/opencode/` — skill anti-slop dalam template (vendor)
#
# Usage: scripts/antislop-check.sh [--quiet]
# Exit code 0 = bersih; non-zero = pola AI-slop ditemukan.
#
# CATATAN: daftar ini sengaja KONSERVATIF (hanya pola yang hampir pasti slop dalam
# konteks dokumen instruksi). Kata yang sah di konteks teknis (robust, journey,
# landscape, leverage, streamline) TIDAK di-scan untuk menghindari false positive.

set -uo pipefail

QUIET=0
if [[ "${1:-}" == "--quiet" ]]; then
  QUIET=1
fi

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT" || exit 1

FAILED=0
FILES_SCANNED=0

# Pola regex (case-insensitive). Urutan: buzzword yang paling khas dulu.
PATTERNS=(
  'delve'
  'seamless'
  'cutting[- ]edge'
  'state-of-the-art'
  'game[- ]changer'
  'next[- ]generation'
  'next[- ]level'
  'next[- ]gen'
  'revolutionar'
  'supercharge'
  'elevate'
  'empower'
  'unlock the (potential|power|full)'
  'showcase'
  'testament to'
  "in today's fast-paced"
  'world-class'
  'best-in-class'
  'industry-leading'
  'groundbreaking'
  'paradigm shift'
  'harness the'
  'trusted by'
  'AI[- ]powered'
  '10K\+'
  '500M\+'
  '99\.9%'
)

# Seluruh .md ter-track, kecuali konten vendor (lihat header).
mapfile -t md_files < <(
  git ls-files '*.md' 2>/dev/null \
    | grep -vE '(^|/)\.opencode/|(^|/)opencode/' || true
)

for f in "${md_files[@]}"; do
  FILES_SCANNED=$((FILES_SCANNED + 1))
  while IFS=: read -r lineno match; do
    FAILED=$((FAILED + 1))
    if [[ $QUIET -eq 0 ]]; then
      printf '  [FAIL] %s:%s: pola AI-slop: %s\n' "$f" "$lineno" "$match"
    fi
  done < <(grep -niE "$(IFS='|'; printf '%s' "${PATTERNS[*]}")" "$f" 2>/dev/null || true)
done

if [[ $FAILED -gt 0 ]]; then
  printf 'antislop-check: %d pola AI-slop ditemukan (dari %d file di-scan) — muat skill antislop lalu perbaiki, jangan di-allowlist diam-diam.\n' \
    "$FAILED" "$FILES_SCANNED" >&2
  exit 1
fi

if [[ $QUIET -eq 0 ]]; then
  printf 'antislop-check: bersih (%d file di-scan)\n' "$FILES_SCANNED"
fi
exit 0