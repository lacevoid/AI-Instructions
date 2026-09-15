#!/usr/bin/env bash
# install-hooks.sh — activate local git hooks for this repository.
# Sets {core.hooksPath} to .githooks so pre-commit runs health-check +
# markdown lint before every commit (scoped to this working tree).

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

chmod +x "$ROOT/.githooks/pre-commit"
git -C "$ROOT" config core.hooksPath .githooks

printf 'Git hooks aktif (core.hooksPath -> .githooks).\n'
printf 'pre-commit akan menjalankan scripts/health-check.sh + markdown lint.\n'