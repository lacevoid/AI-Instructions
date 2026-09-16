# Project Invariants (Isi Setelah Analisis Proyek Target)

> [!IMPORTANT]
> File ini TIDAK boleh diisi dengan asumsi atau salinan dari proyek lain.
> Setiap baris harus didukung bukti nyata dari repository target.

## 1. Identitas proyek

- Nama proyek: _(isi)_
- Domain & tujuan: _(isi)_
- Stack & versi aktual (dari lockfile/manifest): _(isi)_
- Tanggal analisis: _(isi)_

## 2. Technology & tooling

| Area | Keputusan proyek (bukti) | Evidence path |
|------|--------------------------|---------------|
| Bahasa/framework | | |
| Database | | |
| Frontend (bila ada) | | |
| Package manager | | |
| Linter/formatter/static analysis | | |
| Test runner | | |

## 3. Arsitektur & penempatan kode

- Pola direktori kanonik: _(isi + path bukti)_
- Tempat business logic: _(isi)_
- Arah dependensi yang ditegakkan: _(isi)_
- Pola yang JANGAN ditiru (legacy/defect): _(isi + anchor `path:line`)_

## 4. Konvensi penamaan

| Artifact | Pola | Contoh nyata (path) |
|----------|------|---------------------|
| Class | | |
| Method | | |
| Variabel/constant | | |
| File/direktori | | |
| DB tabel/kolom | | |
| Route/API | | |
| Component (bila ada) | | |

## 5. Alur fitur kanonik

Gambarkan alur nyata sebuah fitur melewati repository (controller → action →
repo → model → response, dst.) sesuai bukti kode.

## 6. Testing konvensi

- Framework & lokasi test: _(isi)_
- Pola test yang khas: _(isi + path bukti)_
- Apa yang dianggap "test bermakna": _(isi)_

## 7. Invariant project-specific (MUST)

- _(tulis aturan MUST yang hanya berlaku proyek ini + evidence path)_
- _(contoh: "Payment status hanya boleh diubah Action X — lihat app/Actions/...")_

## 8. Decision log keputusan authoring

| Tanggal | Keputusan | Alasan | Evidence |
|---------|-----------|--------|----------|
| | | | |
