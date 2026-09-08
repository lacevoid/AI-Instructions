# AI-Instructions

**Repository Instruction Architect — bengkel authoring set instruksi AI.**

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
        ├── 01-governance.md … 11-forbidden-behavior.md   ← Modul universal
        ├── 12-project-specific/                          ← Invarian per proyek
        │   ├── lingusid.md                               ← Invarian proyek LingSID
        │   └── canonical-snippets.md                     ← Bank snippet verbatim + anchor
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

## Membuat Set Instruksi Baru

Ikuti `ARCHITECT-GUIDE.md` secara penuh (ringkasannya):

1. Baca playbook `ARCHITECT-GUIDE.md`.
2. Eksplorasi repository target (protocol eksplorasi 7 fase, termasuk koleksi snippet kanonik).
3. Analisis (coding style, peletakan file, model fitur, testing, error handling, dll.).
4. Pelajari `laravel/` sebagai **reference bar** — target kualitas minimum (bagian 6D playbook).
5. Buat folder `<Framework>/` dengan struktur konstitusi + modul 01–11 + `12-project-specific/`.
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
- **DILARANG** bekerja di luar branch `master` tanpa instruksi eksplisit.

## Git Conventions

- Commit ringkas dalam bahasa Inggris, verb-prefixed (mis. `Add canonical snippet bank`).
- Perubahan besar ditawarkan dulu ke operator ("commit + push?") dan menunggu persetujuan.
- Sebelum commit: cek `git status`, `git diff`, `git log --oneline -10`.

## Status Saat Ini

| Set | Status | Catatan |
|-----|--------|---------|
| `laravel/` | Aktif | Berakar pada LingSID; konstitusi + 11 modul + invariant proyek di `12-project-specific/lingusid.md` + bank snippet kanonik; memuat protokol MASTER_BUILD_SPECIFICATION |
| `java/`, `react/` | Direncanakan | Didukung script (coming soon), folder belum dibuat |