# 08 — Git (Branching, Commit, Version Control)

Aturan git bersifat GLOBAL dan wajib diikuti semua peran. Pelanggaran non-main /
commit langsung ke branch stabil = kegagalan total.

## 1. Klausa wajib (MUST — tanpa pengecualian)

- **DILARANG bekerja, mengedit, atau commit langsung di branch `main` (atau
  branch stabil proyek).**
- Sebelum mengerjakan apa pun, agent WAJIB membuat **branch baru** sesuai
  standar penamaan proyek (tentukan & tulis di bawah).
- **Commit message ringkas** (summary), jelas, mengikuti format standar proyek.
- Bila proyek baru belum repository git, WAJIB `git init` pada langkah pertama
  sebelum pekerjaan/branching/commit.

## 2. Standar penamaan branch (sesuaikan dengan proyek; default di bawah)

```
<type>/<deskripsi-singkat>
```

Tipe yang diizinkan:

```
feat/      fitur baru
fix/       perbaikan bug
chore/     pemeliharaan
docs/      dokumentasi
refactor/  refactor tanpa perubahan perilaku
test/      perubahan test
style/     formatting/style
```

Contoh: `feat/add-invoice-export`, `fix/validate-email-uniqueness`.

> Bila proyek target memakai konvensi lain (mis. `feature/...`, atau branch
> dari `develop`), tulis konvensi aktual di `12-project-specific/project-invariants.md`
> dan patuhi itu. Klausa "dilarang di main/branch stabil" TETAP berlaku.

## 3. Commit message

Format dasar (ikuti konvensi proyek; default Conventional Commits):

```
<type>: <ringkasan imperatif>
```

- Ringkas, satu kalimat fokus, bahasa proyek (default English).
- Jangan commit file tak-terkait / artefak build / rahasia.
- Satu fitur boleh beberapa commit logis; jangan satu commit raksasa berisi
  semuanya.

## 4. Alur kerja

1. `git status` + `git diff` sebelum commit.
2. Kerjakan di branch (bukan branch stabil).
3. Commit ringkas di branch.
4. Push branch + buka PR/MR ke branch target yang disetujui operator.
5. Jangan merge tanpa persetujuan operator / tanpa CI hijau (bila ada).

## 5. Peran tim

- Orchestrator bertanggung jawab atas branch & commit.
- Subagent TIDAK commit; mereka hanya melapor.
- `code-reviewer` menilai diff sebelum PR bila diminta.
