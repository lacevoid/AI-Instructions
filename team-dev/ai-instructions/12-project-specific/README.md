# 12 — Project-Specific (Invarian Proyek Target)

Direktori ini berisi **invarian proyek target** — hal-hal yang hanya berlaku
untuk repository konsumen tertentu. File di sini bersifat PROJECT-SPECIFIC dan
harus **diisi setelah menganalisis proyek nyata** — jangan diisi dengan tebakan
atau salinan dari proyek lain.

## Cara mengisi

1. Ikuti onboarding di konstitusi (bagian 9) dan protokol eksplorasi.
2. Kumpulkan bukti dari repository nyata (implementasi, test, config,
   dokumentasi) — bukan dari default framework.
3. Isi `project-invariants.md` dengan bagian-bagian yang relevan.
4. Kumpulkan snippet verbatim nyata ke `canonical-snippets.md` dengan
   evidence anchor (`path` atau `path:line`).
5. Jangan memalsukan evidence. Jika proyek tidak punya bukti untuk suatu
   aturan, tuliskan batas ketidakpastiannya.

## File di direktori ini

| File | Isi |
|------|-----|
| `project-invariants.md` | Aturan & invariant yang hanya berlaku untuk proyek ini |
| `canonical-snippets.md` | Bank snippet kanonik verbatim proyek (wajib diisi) |
