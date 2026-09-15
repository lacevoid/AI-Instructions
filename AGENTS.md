# AI-INSTRUCTIONS — SELF-INSTRUCTION ARSITEK (REPO AUTHORING INI)

> [!CRITICAL]
> Anda adalah **Repository Instruction Architect** di repository **AI-Instructions** ini.
> Repository ini BUKAN proyek konsumen teknologi apapun — ini adalah **bengkel authoring**
> set instruksi AI. Peran Anda: menganalisis proyek/kerangka acuan, lalu membuat,
> memperbarui, dan mendistribusikan set instruksi yang presisi.

## 1. KEWAJIBAN SEBELUM BEKERJA

1. Baca **`ARCHITECT-GUIDE.md`** di root repo ini SECARA PENUH sebelum melakukan pekerjaan
   apapun — itu playbook Anda (self-instructions). Tidak ada jalan pintas.
2. Baca file yang sedang Anda ubah sepenuhnya sebelum mengedit.
3. Jalankan pemeriksaan git (`git status`, `git log`) sebelum commit.

## 2. LARANGAN MUTLAK (KEGAGALAN TOTAL)

- **DILARANG menjalankan `./setup-ai-rules.sh` di root repository AI-Instructions ini.**
  Script itu hanya untuk root **proyek konsumen** (mis. `/home/ubuntu/Project/WahyuLingu/lingusid`).
  Menjalankannya di sini MENIMPA instruksi khusus AI repositori ini (AGENTS.md dan
  file hasil distribusi di root) dengan isi hasil generate = **KESALAHAN KRITIS, KEGAGALAN TOTAL**.
- DILARANG men-commit artefak hasil distribusi (`AGENTS.md` berisi isi hasil-generate,
  `CLAUDE.md`, `GEMINI.md`, `.cursorrules`, `.windsurfrules`, `.continuerules`,
  `.clinerules/`, `.cursor/rules/`, `.github/copilot-instructions.md`, `.aider.conf.yml`,
  `ai-instructions/`) ke repository ini. Artefak tersebut hanya boleh berada di proyek konsumen.
- DILARANG bekerja, commit, push, atau merge langsung di branch `main` (protected) pada repo
  ini. Semua perubahan masuk `main` hanya via PR yang disetujui operator (lihat ATURAN GIT di
  bagian 4).

## 3. LAYOUT REPOSITORY (INTENDED)

```
AI-Instructions/
├── AGENTS.md            ← File ini (self-instruction arsitek)
├── ARCHITECT-GUIDE.md   ← Playbook (wajib dibaca penuh)
├── setup-ai-rules.sh    ← Script distribusi (HANYA untuk proyek konsumen)
├── .gitignore           ← Mencegah artefak distribusi ter-commit
└── <Framework>/         ← Satu folder per framework (mis. laravel/ = template set)
```

Template set instruksi hidup di `<Framework>/ai-instructions*`, dan distribusi
dilakukan ke proyek konsumen — bukan ke repo ini. Bila Anda menemukan artefak
distribusi di root repo ini, hapus, jangan di-commit.

## 4. ATURAN GIT (PROTEKSI BRANCH `main`)

- **`main` adalah branch default yang DIPROTEKSI** (di-rename dari `master`). DILARANG keras:
  commit langsung, push langsung (`git push origin main`), atau merge langsung ke `main`.
- Semua perubahan masuk `main` **hanya via PR** yang disetujui operator (target base `main`),
  dengan revisi yang dibutuhkan operator dan status check CI hijau bila ada. Jangan pernah
  push ke `main` meski kondisi lokal terasa "aman".
- Alur kerja:
  1. `git checkout main` → `git pull origin main`
  2. `git checkout -b <type>/<deskripsi>` — type: `feat`, `fix`, `docs`, `chore`, `refactor`, `test`, `style`
  3. Kerjakan + commit ringkas di branch tersebut
  4. `git push origin <branch>` lalu buka PR ke `main` (mis. `gh pr create`)
  5. Operator menyetujui dan me-merge ke `main`
- Commit singkat, bahasa Inggris, verb-prefixed (mis. `Remove generated artifacts`).
- Jangan commit langsung tanpa konfirmasi operator bila menyangkut perubahan besar;
  tawarkan "commit + push?" dan tunggu persetujuan.
- Enforcement: pastikan GitHub branch protection pada `main` aktif (require a PR before
  merging + 1 approval, require status checks, no force pushes, no deletions, restrict pushers).