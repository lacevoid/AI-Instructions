# 04 — Coding Standards (Style & Formatting, Komentar)

Modul ini mendefinisikan standar gaya kode. Karena template ini ditujukan untuk
**proyek target apa pun**, aturan di sini adalah proses untuk **mendeteksi dan
mengunci** konvensi aktual proyek — lalu mematuhinya — bukan memaksakan gaya
dari luar tanpa bukti.

## 1. Prinsip utama

- **Repository consistency > isolated elegance.** Jika proyek konsisten
  melakukan X meski best practice umum menyarankan Y, ikuti X (kecuali ada bukti
  kuat X kecelakaan atau usang).
- **JANGAN "memperbaiki" konvensi yang ada** hanya karena gaya lain terlihat
  lebih bersih.
- **Urai legacy vs canonical**: bedakan pola kanonik / legacy / transisi.
  Jangan ajari agent mereproduksi pola yang jelas usang.

## 2. Deteksi konvensi aktual (Wajib sebelum menulis kode)

Saat onboarding (konstitusi bagian 9), dokumentasikan di
`12-project-specific/project-invariants.md`:

- **Formatting**: indentasi (spasi/tab), panjang baris, brace style, import
  ordering, blank line, chaining.
- **Gaya pemrograman**: functional vs imperative, early return/guard clause,
  null handling, exception handling, typing strictness, abstraction density.
- **Kebijakan komentar**: kapan komentar dipakai, apa yang dijelaskan, apa yang
  sengaja tidak dijelaskan.
- **Dua gaya bila keduanya ada** (mis. dua idiom) — tandai mana kanonik
  (berdasar prevalensi), sertakan keduanya di bank snippet.

## 3. Aturan umum (berlaku sampai konvensi proyek menyatakan lain)

- **MUST self-explanatory**: nama variabel/method/fungsi yang bermakna; fungsi
  kecil satu tanggung jawab; alur linear.
- **MUST NOT** menambah komentar yang mengulang isi kode (chit-chat).
  Komentar hanya untuk: invariant bisnis non-obvious (`why`), rationale
  keputusan, dan anotasi tipe untuk tooling.
- **Kode yang butuh komentar agar dimengerti** HARUS diperbaiki
  (rename/extract/simplify), bukan dikomentari.
- Prefer guard clause / early return untuk menghindari nesting dalam.
- Hindari duplikasi yang tidak beralasan; ikuti reuse policy proyek
  (lihat `05-naming.md` dan `11-forbidden-behavior.md`).

## 4. Tooling wajib

- Gunakan linter/formatter proyek yang sudah dikonfigurasi (`09-tools.md`).
  Jangan nonaktifkan rule tanpa alasan tertulis.
- Hasil `static analysis` dianggap bagian dari definisi "selesai"
  (`10-quality-gates.md`).

## 5. Peran tim

- `code-reviewer` menilai kode terhadap standar ini + konvensi aktual proyek;
  temuan bisa berupa REVISI tapi bukan veto kecuali menyentuh aturan MUST.
- Orchestrator memutuskan; konflik gaya diselesaikan oleh konvensi repository,
  bukan voting.

## 6. Canonical snippets

- Semua contoh gaya & idiom nyata dikumpulkan verbatim di
  `12-project-specific/canonical-snippets.md` (dengan evidence anchor `path:line`).
- Snippet mengalahkan deskripsi teks bila konflik (snippet = bukti terkuat).
- Potongan yang disingkat ditandai eksplisit (`…` / `// …`).
