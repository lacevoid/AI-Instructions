# AI-Instructions

<p align="center">
  <img src="assets/logo.svg" alt="AI-INSTRUCTIONS — Instruction Architecture" width="340">
</p>

**Repository Instruction Architect — bengkel authoring set instruksi AI.**

Repositori ini BUKAN proyek konsumen teknologi apa pun. Ini adalah bengkel untuk
**menganalisis set pembuatan instruksi**: repo ini menghasilkan, memperbarui, dan
mendistribusikan **set instruksi AI** yang presisi untuk digunakan oleh AI coding agent
di **proyek konsumen** (mis. LingSID).

Repositori ini BUKAN proyek konsumen teknologi apa pun. Ini adalah bengkel untuk
**menganalisis set pembuatan instruksi**: repo ini menghasilkan, memperbarui, dan
mendistribusikan **set instruksi AI** yang presisi untuk digunakan oleh AI coding agent
di **proyek konsumen** (mis. LingSID).

## Repo Ini Bukan Tempat Distribusi

`setup-ai-rules.sh` menjalankan distribusi ke **arah `pwd`** (direktori tempat script
dieksekusi). Menjalankannya di repo ini akan menimpa `AGENTS.md` (self-instruction arsitek)
dan memunculkan artefak distribusi (`CLAUDE.md`, `GEMINI.md`, `.cursorrules`, `ai-instructions/`,
dll.) di root dengan isi hasil-generate. **Itu KESALAHAN KRITIS — KEGAGALAN TOTAL.**
Script hanya dijalankan di root **proyek konsumen**.

## Layout Repository

```
AI-Instructions/
├── AGENTS.md            ← Self-instruction arsitek (peran, larangan, aturan git)
├── ARCHITECT-GUIDE.md   ← Playbook (wajib dibaca penuh sebelum bekerja)
├── setup-ai-rules.sh    ← Script distribusi (HANYA untuk root proyek konsumen)
├── .gitignore           ← Mencegah artefak distribusi ter-commit ke repo ini
└── laravel/             ← Template set instruksi (satu folder per framework/teknologi)
    ├── ai-instructions.md            ← Konstitusi (entry point)
    └── ai-instructions/
        ├── 01-…-21-*.md                          ← Modul universal (01–11 + skill 13–21)
        ├── 12-project-specific/                  ← Invarian per proyek
        │   ├── lingusid.md                       ← Invarian proyek LingSID
        │   └── canonical-snippets.md             ← Bank snippet verbatim + anchor
        └── README.md
```

## Cara Kerja

1. **Template set hidup di `<Framework>/`** (mis. `laravel/`) — ini sumber kebenaran untuk
   editing. Isinya dibangun dari analisis nyata sebuah proyek referensi:
   - `laravel/` berakar pada proyek **LingSID** (Laravel 12 + Inertia/Vue 3 + TypeScript):
     aturan arsitektur, coding standards, naming, testing, security, git, tools, quality gates
     semuanya berbukti dari kode nyata proyek.
   - `canonical-snippets.md` menampung potongan kode **verbatim** + `path:line` sebagai
     "DNA" format yang harus ditiru IDENTIK oleh agent masa depan, termasuk penandaan
     pola rusak/legacy (`// BAD`) yang dilarang ditiru.
2. **Distribusi dilakukan di proyek konsumen**, bukan di repo ini:

   ```bash
   # di root proyek konsumen (mis. /home/ubuntu/Project/WahyuLingu/lingusid)
   ./setup-ai-rules.sh laravel
   ```

   Script menyalin konstitusi ke `AGENTS.md`, `CLAUDE.md`, `GEMINI.md`,
   `.github/copilot-instructions.md`, `.cursorrules`, `.cursor/rules/laravel-directives.mdc`,
   `.windsurfrules`, `.clinerules/laravel-directives.md`, `.continuerules`,
   `.aider.conf.yml`, dan modul ke `ai-instructions/`.
3. **Master dapat di-custom**: script membuat `ai-instructions/master/` di proyek konsumen
   dan TIDAK menimpanya bila sudah ada — spesialisasi proyek dilakukan di sana, lalu script
   dijalankan ulang untuk mendistribusikan versi custom.
4. **Self-instruction arsitek mengadopsi aturan kualitas `laravel/`**: modul universal dari set
   `laravel/ai-instructions/` yang berlaku untuk kerja AI apa pun (evidence-anchored authoring,
   quality gates + senior self-review, edge probes authoring, change impact analysis, debug
   disipliner, agent discipline, reproduce-everywhere) diadopsi ke `AGENTS.md` bagian 5 dan
   di-enforce lewat pre-commit hook + CI (`scripts/health-check.sh`, markdownlint, smoke test).

## Reset & Wipe di Proyek Konsumen

`setup-ai-rules.sh` juga mendukung dua perintah untuk mengelola state instruksi **di
proyek konsumen** (dieksekusi dari root proyek konsumen, arah `pwd`):

- **Reset ke default** — buang seluruh custom di `ai-instructions/master/`, bangun ulang
  dari template framework, lalu distribusikan ulang. Sama dengan alur manual
  `rm -rf ai-instructions/master && ./setup-ai-rules.sh <framework>`:

  ```bash
  ./setup-ai-rules.sh reset laravel
  ```

- **Wipe** — hapus SEMUA artefak instruksi dari proyek konsumen: `AGENTS.md`, `CLAUDE.md`,
  `GEMINI.md`, `.github/copilot-instructions.md`, `.cursorrules`, `.cursor/`,
  `.windsurfrules`, `.clinerules/`, `.continuerules`, `.aider.conf.yml`, dan `ai-instructions/`
  (termasuk `master/` hasil custom):

  ```bash
  ./setup-ai-rules.sh wipe          # tanpa --force: diminta konfirmasi
  ./setup-ai-rules.sh wipe --force  # untuk automation/CI tanpa prompt
  ```

Keduanya dijalankan dari root proyek konsumen — **bukan** dari repo authoring ini.

## Adaptor: curl | sh, Composer, npm/npx

Repo ini menyediakan tiga adaptor agar `setup-ai-rules.sh` bisa dipakai langsung di
**proyek konsumen** (arah `pwd`) tanpa menyalin repo secara manual. Semua adapter
menjalankan fungsi yang sama: `distribute`, `reset`, `wipe`.

### 1. curl | sh (tanpa instalasi)

```bash
curl -fsSL https://raw.githubusercontent.com/lacevoid/AI-Instructions/main/install.sh | sh -s -- laravel
```

Unduhan tarball di-cache (`${XDG_CACHE_HOME:-$HOME/.cache}/ainstruct`), lalu
`setup-ai-rules.sh` dieksekusi dari cache terhadap direktori saat ini. Opsi:
`AINSTRUCT_SOURCE_URL` (sumber tarball), `AINSTRUCT_CACHE` (direktori cache),
`AINSTRUCT_UPDATE=1` (paksa unduh ulang).

### 2. Composer (binary global)

```bash
composer global require lace/ainstruct
ainstruct laravel          # distribusikan framework
ainstruct reset laravel    # kembali ke default template
ainstruct wipe --force     # hapus semua artefak instruksi
```

Paket `lace/ainstruct` memasang bin `ainstruct` (symlink `vendor/bin/ainstruct`
→ `bin/ainstruct`, yang me-resolve path akar paket lalu mendelegasikan ke
`setup-ai-rules.sh`).

### 3. npm / npx (scope `@lace`)

```bash
npx @lace/ainstruct laravel
npx @lace/ainstruct reset laravel
npx @lace/ainstruct wipe --force
```

Paket `@lace/ainstruct` (scope `@lace` bila tersedia) membungkus `bin/ainstruct`
yang sama dengan paket Composer.

## Membuat Set Instruksi Baru

Ikuti `ARCHITECT-GUIDE.md` secara penuh (ringkasannya):

1. Baca playbook `ARCHITECT-GUIDE.md`.
2. Eksplorasi repository target (protocol eksplorasi 7 fase, termasuk koleksi snippet kanonik).
3. Analisis (coding style, peletakan file, model fitur, testing, error handling, dll.).
4. Pelajari `laravel/` sebagai **reference bar** — target kualitas minimum (bagian 6D playbook).
5. Buat folder `<Framework>/` dengan struktur konstitusi + modul 01–11 + skill kualitas 13–21 +
   `12-project-specific/`.
6. Tulis dengan evidence anchors + snippet kanonik verbatim.
7. Verifikasi diri (bagian 9 playbook).
8. Jalankan distribusi dari **root proyek konsumen**.
9. Laporkan ringkasan ke operator.

## Klausa Wajib Set Hasil Generasi

Setiap set WAJIB memuat KLAUSA 1–5 (detail penuh di `ARCHITECT-GUIDE.md` bagian 6):

1. **Khusus proyek target** — tanpa hubungan/referensi ke repository contoh mana pun.
2. **Dilarang kerja langsung di branch `main`** — wajib branch baru.
3. **Commit message ringkas** mengikuti format standar proyek.
4. **Inisiasi git wajib** bila proyek baru belum repository git.
5. **Protokol `MASTER_BUILD_SPECIFICATION.md`** — wajib dibaca sebelum kode apa pun; jika
   tidak ada, agent wajib BERHENTI, bertanya ke operator secara mendetil, lalu membuatnya
   secara lengkap, detil, dan presisi sebelum menulis kode (LEVEL 2; pelanggaran =
   KEGAGALAN TOTAL).

## Larangan Mutlak (di Repo Ini)

- **DILARANG** menjalankan `./setup-ai-rules.sh` di root repo ini.
- **DILARANG** men-commit artefak distribusi (AGENTS.md isi hasil-generate, CLAUDE.md,
  GEMINI.md, .cursorrules, .windsurfrules, .continuerules, .clinerules/, .cursor/rules/,
  .github/, .aider.conf.yml, ai-instructions/) ke repo ini.
- **DILARANG** bekerja, commit, push, atau merge langsung di branch `main` (protected).
  Semua perubahan masuk `main` hanya via PR yang disetujui operator.

## Git Conventions

- **Proteksi `main`**: tidak ada push/commit/merge langsung ke `main`; kerja di branch
  pendek (`feat/…`, `fix/…`, `docs/…`, `chore/…`) dari `main`, lalu PR ke `main`.
- Commit ringkas dalam bahasa Inggris, verb-prefixed (mis. `Add canonical snippet bank`).
- Perubahan besar ditawarkan dulu ke operator ("commit + push?") dan menunggu persetujuan.
- Sebelum commit: cek `git status`, `git diff`, `git log --oneline -10`.

## Status Saat Ini

| Set | Status | Catatan |
|-----|--------|---------|
| `laravel/` | Aktif | Berakar pada LingSID; konstitusi + modul 01–21 + invariant proyek di `12-project-specific/lingusid.md` + bank snippet kanonik; memuat protokol MASTER_BUILD_SPECIFICATION. Self-instruction arsitek (`AGENTS.md` §5) mengadopsi aturan kualitas universal dari set ini. |
| `java/`, `react/` | Direncanakan | Didukung script (coming soon), folder belum dibuat |
