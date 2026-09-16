# 09 — Tools (Linter, Formatter, Static Analysis, Test Runner)

Modul ini mendefinisikan tooling yang wajib dipakai. Tooling proyek dideteksi
saat onboarding dan dicatat di `12-project-specific/project-invariants.md`.

## 1. Peta tooling proyek (isi saat onboarding)

| Jenis | Tool & versi | Command | Lokasi config |
|-------|-------------|---------|---------------|
| Package manager | ... | ... | ... |
| Linter | ... | ... | ... |
| Formatter | ... | ... | ... |
| Static analysis | ... | ... | ... |
| Test runner | ... | ... | ... |
| Type checker (bila ada) | ... | ... | ... |

- Dari manifest (composer.json / package.json / go.mod / requirements.txt /
  dll.) dan config yang ada — jangan menebak.
- Catat versi yang sebenarnya dipakai (lockfile), bukan sekadar rentang.

## 2. Aturan penggunaan (MUST)

- Jalankan linter/static analysis sebelum menyatakan selesai. 0 error pada
  scope yang disentuh.
- Jangan menonaktifkan rule tanpa alasan tertulis (catat di decision log).
- Format sesuai formatter proyek; jangan perang gaya antara file lama vs baru.
- Update lockfile saat menambah dependensi; jangan `-y`/`--latest` tanpa alasan.
- Bila proyek tidak punya tool tertentu, jangan pasang tool baru tanpa
  persetujuan operator — catat di `project-invariants.md`.

## 3. Peran tim

- `quality-gate-runner` (bila tersedia) / orchestrator menjalankan gates.
- `code-reviewer` memeriksa bahwa diff sudah lolos tooling (tidak ada file
  yang "kebetulan" lolos karena lint di-skip).

## 4. Canonical snippets

- Contoh command atau config tool yang khas proyek bisa dikumpulkan di
  `12-project-specific/canonical-snippets.md` bila relevan.
