# 01 — Governance (Prioritas, Konflik, Scope Aturan)

Modul ini mengatur aturan meta: sumber kebenaran, klasifikasi aturan, resolusi
konflik, dan aturan untuk **tim multi-agent** (bagaimana tim berdiskusi tanpa
mengorbankan kepastian keputusan).

## 1. Sumber Kebenaran (urutan hierarki)

Saat bekerja, gunakan hierarki ini:

1. **Instruksi eksplisit operator** pada task saat ini (LEVEL 1).
2. **`MASTER_BUILD_SPECIFICATION.md`** di root proyek — spesifikasi build (bagian
   12 konstitusi). Bila tidak ada, buat dulu via diskusi dengan operator.
3. **Konstitusi `ai-instructions.md`** — prinsip, prioritas, gates.
4. **Modul set instruksi ini** (01–11, 12-project-specific).
5. **Arsitektur & konvensi nyata repository** (bukti implementasi).
6. **Best practice generik framework** (paling rendah).

## 2. Klasifikasi Keyakinan

Untuk setiap aturan yang diangkat ke instruksi, klasifikasikan:

| Label | Makna | Perlakuan |
|-------|-------|-----------|
| CONFIRMED RULE | Diulang di banyak tempat / terdokumentasi eksplisit | Tulis sebagai MUST |
| STRONG INFERENCE | Didukung beberapa contoh, tak terdokumentasi | Tulis sebagai MUST/SHOULD ber-anchor |
| WEAK INFERENCE | Bukti terbatas | Jangan jadikan aturan absolut; if needed: tulis batas ketidakpastian |
| UNKNOWN | Bukti tidak cukup | Jangan mengarang; perintahkan inspeksi tetangga sebelum pola baru |

Jangan mengubah WEAK/UNKNOWN menjadi instruksi absolut. Bila perlu tulis:
> «Evidence insufficient — inspect neighboring implementations before introducing a new pattern.»

## 3. Kapan aturan menjadi global vs project-specific

- **GLOBAL** — berlaku di semua proyek/tugas: keamanan dasar, disiplin git,
  quality gates, larangan eksplisit, protokol tim.
- **UNIVERSAL + PROJECT** — pola engineering yang berlaku umum tapi harus
  diverifikasi terhadap proyek target (mis. penempatan logika bisnis).
- **PROJECT-SPECIFIC** — hanya bila repository memang punya bukti
  (mis. invariant `12-project-specific/project-invariants.md`).

Jangan memaksakan aturan project-specific sebagai aturan global. Jangan
menyalin konvensi dari proyek lain tanpa bukti di proyek target.

## 4. Resolusi Konflik

Urutan resolusi (tertinggi menang):

```
1. Prioritas lebih tinggi menang (LEVEL 0 > LEVEL 6).
2. Aturan lebih spesifik mengalahkan yang lebih umum.
3. Scope lebih sempit mengalahkan scope lebih luas.
4. Aturan eksplisit yang menyebut aturan lain menang.
5. Perlindungan: DATA INTEGRITY > FINANCIAL CORRECTNESS > SECURITY >
   AUDITABILITY > UX > VISUAL POLISH.
6. Jika masih belum tuntas: BERHENTI dan tanya operator. Dilarang memilih arbitrer.
```

**Dalam konteks tim**: temuan subagent yang menyentuh poin 5 (data, keuangan,
security, audit) bersifat **veto** — orchestrator MUST menampungnya dan
mengakomodasi atau mengeskalasi ke operator. Lihat `03-team-protocol.md`.

## 5. Rule Scope & Semantic Strength

Lihat bagian 5 dan 6 konstitusi. Jangan eskalasi SHOULD → MUST; jangan
deeskalasi MUST → SHOULD. Konsisten memakai kata imperatif:
MUST / MUST NOT / SHOULD / PREFER / MAY.

## 6. Invariant & keputusan authoring

- Setiap keputusan penting yang diambil saat onboarding (stack, arsitektur,
  convention output) dicatat di `12-project-specific/project-invariants.md`
  dengan tanggal dan alasan.
- Bila ada 2 gaya yang valid di repository (mis. dua variasi idiom), dokumentasikan
  keduanya, tandai mana kanonik (berdasar kelaziman/prevalensi), dan catat di
  `project-invariants.md`.

## 7. Tim & governance

- Subagent TIDAK memiliki otoritas untuk mengubah instruksi atau commit.
  Mereka memberi laporan ke orchestrator; orchestrator memutuskan.
- Veto subagent hanya berlaku untuk temuan kritikal (data/keamanan/gates),
  bukan preferensi gaya; preferensi disintesis dengan pertimbangan konteks.
- Semua keputusan tim yang mengikat (mis. arsitektur alternatif dipilih) dicatat
  di decision log operator, bukan hanya di percakapan.
