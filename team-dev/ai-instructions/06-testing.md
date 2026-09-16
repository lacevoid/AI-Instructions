# 06 — Testing (Strategi, Pola, Konvensi)

Modul ini mengatur strategi testing untuk proyek target. Sama seperti modul
lain, aturan konvensi test harus **berbasis bukti proyek** — bukan template
default framework.

## 1. Prinsip

- Test ada untuk melindungi **perilaku yang bisa diverifikasi**: business logic,
  kontrak API, edge case penting, regresi.
- Jangan menulis test yang hanya menaikkan angka coverage tanpa memverifikasi
  perilaku.
- Test harus **reproducible** dan memberi signal yang jelas saat gagal.

## 2. Deteksi konvensi test proyek (saat onboarding)

Catat di `12-project-specific/project-invariants.md`:

- Framework & runner test (mis. pest / phpunit / vitest / jest).
- Lokasi file test & pola penamaan.
- Pola fixture/factory, mock, assertion style.
- Apa yang dianggap "test bermakna" di proyek ini (dari contoh nyata).
- Konvensi menjalankan subset test untuk perubahan tertentu.

## 3. Aturan umum

- **MUST mengikuti pola test yang sudah ada** (analogue-first) — jangan
  menciptakan struktur test baru tanpa dasar.
- **Test relevan saja**: jalankan minimal test yang menyentuh kode yang diubah;
  untuk perubahan berisiko, jalankan suite terkait.
- **MUST NOT** menghapus/mengubah test hanya agar lolos tanpa memahami
  perilaku aslinya.
- Test yang menutup bug: tambahkan test yang mereproduksi bug terlebih dahulu,
  lalu perbaiki (test-to-break).
- Bila proyek belum punya test untuk area yang disentuh, dan operator meminta
  test: ikuti pola test terdekat; bila tidak ada sama sekali, buat pola minimal
  dan catat sebagai keputusan authoring di `project-invariants.md`.

## 4. Kapan QA engineer aktif

- Fitur dengan banyak edge case / alur bisnis kompleks → panggil `qa-engineer`
  sebelum "selesai".
- `qa-engineer` menilai: apakah skenario penting sudah diuji? Apakah test
  benar-benar memverifikasi perilaku, bukan sekadar mengeksekusi?
- Temuan `qa-engineer` tentang **test yang menyesatkan / coverage palsu** =
  REVISI (bisa veto bila menyentuh data/security; lihat `03-team-protocol.md`).

## 5. Canonical snippets

- Contoh utuh tiap pola test yang khas (unit, integration, feature/route)
  dikumpulkan verbatim di `12-project-specific/canonical-snippets.md`.
