# 05 — Naming (Konvensi Penamaan)

Naming harus konsisten dengan **konvensi aktual proyek target**. Modul ini
menetapkan proses deteksi + aturan umum + tanggung jawab tim.

## 1. Proses deteksi (wajib saat onboarding)

Untuk setiap jenis artifact, periksa 2–3 contoh nyata di repository lalu
catat polanya di `12-project-specific/project-invariants.md`:

- Class / interface / trait / enum / type
- Function / method / variable / constant
- File & direktori
- Tabel database & kolom (bila ada)
- Route / endpoint API (bila ada)
- Component / halaman frontend (bila ada)
- Test file & test method

Contoh template isian:

| Artifact | Pola proyek | Contoh nyata (path) |
|----------|-------------|---------------------|
| Class | PascalCase | `src/InvoiceService.php` |
| Method | camelCase | `getTotalAmount()` |
| ... | ... | ... |

## 2. Aturan umum (berlaku sampai konvensi proyek menyatakan lain)

- Nama harus **bermakna dan deskriptif** (self-explanatory).
- Hindari singkatan yang tidak lazim.
- Ikuti casing yang dominan di proyek untuk tiap jenis artifact.
- Jangan menciptakan gaya penamaan baru untuk satu fitur saja.
- Bila proyek punya dua gaya (mis. `snake_case` dan `camelCase` dalam
  konteks berbeda — mis. DB vs kode), patuhi pemisahan itu.

## 3. Anti-pola umum (MUST NOT kecuali proyek membuktikan sebaliknya)

- Singkatan menyesatkan (`usr` vs `user`).
- Nama generik tanpa konteks (`data`, `items`) untuk variabel yang bermakna.
- Overloading makna satu nama untuk dua konsep berbeda.
- Penamaan yang berbohong (nama bilang X, isi mengerjakan Y).

## 4. Peran tim

- `code-reviewer` memeriksa kepatuhan naming saat review diff.
- Found naming convention baru yang jelas lebih baik? JANGAN refactor massal;
  catat di `project-invariants.md` dan usulkan ke operator.

## 5. Canonical snippets

- Setiap pola penamaan didukung contoh nyata di
  `12-project-specific/canonical-snippets.md`.
