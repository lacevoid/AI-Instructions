# Canonical Snippets — Bank Snippet verbaatim Proyek Target (WAJIB DIISI)

> [!IMPORTANT]
> File ini adalah **bank "DNA" repository**: potongan kode nyata yang harus
> ditiru IDENTIK oleh agent masa depan. Semua snippet WAJIB **verbatim** dari
> repository target + **evidence anchor** (`path` atau `path:line`).
> DILARANG menyalin dari proyek/framework lain, dan DILARANG memparafrase.

## Aturan penulisan

- Salin verbatim — jangan "diperbaiki" atau ditebak bila kabur.
- Cantumkan anchor: `path` atau `path:line`.
- Yang disingkat ditandai eksplisit: `…` / `// …` + keterangan.
- Bila 2 variasi ada, tampilkan keduanya & tandai mana kanonik (prevalensi).
- Snippet mengalahkan deskripsi teks bila konflik.

## Kategori yang wajib dikumpulkan (centang saat terisi)

- [ ] Abstraksi dasar & kontrak (base/abstract class, interface, contract)
- [ ] Signature & gaya deklarasi (constructor, return type, modifiers)
- [ ] Idiom berulang (guard clause, null handling, validasi, query pattern)
- [ ] Contoh file per layer (controller/service/repository/model)
- [ ] Test: unit + integration/feature (1–2 pola utuh)
- [ ] Frontend (bila ada): komponen, typing, composable, util style
- [ ] Pola rusak/legacy yang DILARANG ditiru — tandai `// BAD`

## Template isian

### Abstraksi dasar

```php
// path: app/... (isi path nyata)
// (tempel verbatim kode di sini)
```

### Idiom

```php
// path: app/... (isi path nyata)
// (tempel verbatim kode di sini)
```

### Test

```php
// path: tests/... (isi path nyata)
// (tempel verbatim kode di sini)
```

### BAD pattern (jangan ditiru)

```php
// BAD — jangan tiru (ditemukan di <path>:line). Canonical: <kode yang benar>.
// (tempel verbatim pola rusaknya)
```

> Setelah analisis proyek selesai, hapus kalimat instruksi di atas dan isi
> seluruh kategori dengan bukti nyata.
