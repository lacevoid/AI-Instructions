# 03 — Team Protocol (Peran Subagent, Protokol Diskusi, Sintesis & Konsensus)

Modul ini mendefinisikan **siapa timnya, kapan dipanggil, bagaimana mereka
berdiskusi, dan bagaimana keputusan diambil**. Ini jantung sistem "tim
development" — beberapa AI agent dengan perspektif berbeda bekerja bersama.

## 1. Peran dalam tim

| Peran | Deskripsi | Tanggung jawab inti |
|-------|-----------|---------------------|
| `team-lead` (orchestrator) | Agent utama yang menjalankan task | Memimpin, membagi pekerjaan, mensusintesis laporan, memutuskan, bertanggung jawab pada operator |
| `code-reviewer` | Subagent | Menilai kualitas kode, konsistensi, pola, style; mencari bug & pelanggaran scope |
| `qa-engineer` | Subagent | Menilai kesesuaian spesifikasi, skenario edge, test coverage, kriteria "selesai" |
| `security-reviewer` | Subagent | Menilai auth, authorization, validasi, secrets, data sensitif, injection, dll. |

> Bila tool AI yang dipakai tidak menyediakan mekanisme subagent, orchestrator
> tetap menjalankan "review perspektif" secara bergiliran (simulasi role) sesuai
> peran di atas — prinsip yang sama, mekanisme berbeda.

## 2. Kapan tim aktif

Tim **aktif** dan WAJIB dipanggil (bahkan untuk tugas kecil, minimal satu
perspektif lawan) ketika:

1. Tugas menyentuh **arsitektur baru** (struktur direktori, layer baru, pola baru).
2. Tugas menyentuh **data model / migrasi / API contract**.
3. Tugas menyentuh **auth / secrets / data sensitif**.
4. Tugas **besar** (multi-fase, >1 file inti).
5. Operator meminta "tim", "review", "second opinion", "diskusi", "bantu
   menilai".

Untuk perubahan trivial (typo, rename lokal, add field sederhana), orchestrator
boleh memutuskan tim tidak perlu diskusi penuh — tapi MUST menjalankan minimal
self-review dan mencatat keputusan tersebut.

## 3. Protokol diskusi (urutan wajib untuk orchestrator)

### Fase A — Siapkan konteks

1. Tulis **brief tugas**: apa yang dikerjakan, spec titik, file yang disentuh,
   pertanyaan spesifik untuk tim.
2. Beri tahu subagent yang dipanggil — jangan berasumsi mereka tahu konteks.
3. Sampaikan batasan dasar: jangan mengedit file; hanya lapor.

### Fase B — Paralel (sebisa mungkin)

- Panggil subagent **paralel** (dalam satu pesan) agar hemat waktu.
- Minta format laporan terstruktur. Contoh format laporan subagent:

```
REVIEW <role>
- Konteks yang dibaca: <file/spec>
- Temuan (prioritas tinggi → rendah):
  1. ...
- Verdict: SETUJU / REVISI / VETO (+ alasan)
```

### Fase C — Sintesis

1. Kumpulkan semua temuan. Kelompokkan: kritikal vs minor.
2. **Veto** (kriteria di bawah) tidak bisa diabaikan orchestrator.
3. Buat rencana: perbaiki temuan kritikal dulu; minor bila masuk scope.
4. Bila dua subagent bertentangan, cari bukti tertulis (path, hasil test);
   yang berbasis bukti menang. Bila tetap bertentangan → eskalasi ke operator.

### Fase D — Eksekusi & rekonsiliasi

1. Lakukan perbaikan yang disepakati (orchestrator yang edit).
2. Untuk perubahan penting, jalankan satu putaran konfirmasi singkat ke
   subagent yang mereview (bila perlu).
3. Catat keputusan di log (bagian 6).

## 4. Aturan diskusi

- **Paralel dulu, sintesis sesudah.** Subagent berbicara ke orchestrator, bukan
  satu sama lain; orchestrator yang menyatukan suara.
- **Evidence over opinion.** Klaim MUST menyertakan bukti (path, output,
  hasil test). Klaim tanpa bukti diperlakukan sebagai opini.
- **Putaran maks 2.** Untuk menghindari diskusi tak berujung, orchestrator boleh
  maksimal 2 putaran; setelah itu putuskan atau eskalasi ke operator.
- **Tidak ada "voting" gaya.** Perselisihan gaya diselesaikan oleh konvensi
  repository & aturan set instruksi — bukan jumlah suara.
- **Jangan memanggil subagent untuk hal yang bisa dicek sendiri** (lint, test).
  Gunakan tools langsung; subagent untuk penilaian, bukan eksekusi rutin.

## 5. Kriteria VETO (harus diakomodasi atau dieskalasi)

Subagent boleh mengajukan VETO hanya untuk:

- Referensi ke file/method/path yang **tidak ada** (hallucination evidence).
- Perubahan yang dapat **menghapus data / merusak integritas**.
- **Keamanan**: rahasia ter-expose, validasi input tidak ada, auth bocor.
- **Quality gates** yang diketahui gagal dan diabaikan.
- Pelanggaran MUST pada set instruksi ini (non-main, spec-first, dsb.).

Veto MUST disertai bukti minimal (path + alasan). Veto tanpa bukti = opini,
tidak mengikat.

## 6. Decision log

Catat di file atau bagian komunikasi dengan operator:

```
KEPUTUSAN TIM <tanggal>
- Tugas: ...
- Subagent yang dipanggil: ...
- Temuan kritikal: ...
- Veto: ...
- Keputusan akhir: ...
- Yang TIDAK diverifikasi: ...
```

Log ini bagian laporan akhir ke operator (dapat berupa ringkasan di pesan,
bukan file ter-commit kecuali diminta).

## 7. Integrasi dengan opencode

- Role diimplementasikan sebagai subagent opencode bila `setup-ai-rules.sh`
  menjalankan template `team-dev` (mendistribusikan `.opencode/agent/*` dan
  skill `team`). Lihat `ai-instructions/README.md`.
- Skill `team` memicu protokol ini saat user mengetik permintaan tim;
  orchestrator mengikuti Fase A–D di atas.
- `subagent_depth` di config opencode membatasi subagent memanggil subagent —
  default 1; tim ini cukup 1 tingkat (orchestrator → subagent).
