# 02 — Agent Workflow (Workflow Wajib Tim Multi-Agent)

Modul ini mendefinisikan alur kerja **wajib** bagi agent (orchestrator + subagent)
saat mengerjakan fitur/perubahan.

## 1. WORKFLOW WAJIB 12 LANGKAH

```
UNDERSTAND → SPEC → PLAN → TIM CHECKPOINT (bila perlu)
→ IMPLEMENT → STATIC ANALYSIS → TEST → TIM REVIEW (code+QA+security bila perlu)
→ DIFF REVIEW → STYLE REVIEW → FINALIZE
```

### Langkah 0 — Pahami tugas

Jika instruksi operator ambigu: mintalah klarifikasi mendetil, jangan menebak.

### Langkah 1 — Baca spec (WAJIB, bagian 12 konstitusi)

Baca `MASTER_BUILD_SPECIFICATION.md`. Jika tidak ada → STOP → tanya operator
mendetil → buat file spesifikasi → baru lanjut.

### Langkah 2 — Inspect & rencanakan

- Cari analogue implementasi di repository (jangan menciptakan pola baru tanpa
  dasar).
- Tentukan file yang akan diubah/dibuat; perkiraan dampak (change locality).
- Pecah menjadi fase berurutan bila besar; verifikasi tiap fase sebelum lanjut.

### Langkah 3 — TIM CHECKPOINT (SHOULD, wajib untuk tugas berisiko)

Panggil subagent bila salah satu berlaku:

- Tugas menyentuh arsitektur baru, data model, auth/secrets, atau API contract.
- Tugas besar (multi-file, >1 fase).
- Operator meminta "tim", "review", "second opinion", "diskusi".
Protokol pemanggilan: `03-team-protocol.md`. Untuk tugas kecil dan jelas,
langkah ini boleh dilewati (orchestrator memutuskan dan mencatat alasannya).

### Langkah 4 — Implement

- Ubah hanya file dalam scope (scope-stop).
- Ikuti pola repository: analoque-first, self-explanatory code.
- Commit kecil per unit logis; jangan dump raksasa.

### Langkah 5 — Static analysis

Jalankan linter/static analysis sesuai `09-tools.md`. 0 error wajib.

### Langkah 6 — Test (hanya bila diminta / berisiko)

Tulis/jalankan test relevan sesuai `06-testing.md`.

### Langkah 7 — TIM REVIEW (SHOULD bila berisiko)

- `code-reviewer` menilai kualitas & konsistensi kode.
- `qa-engineer` menilai kesesuaian dengan spec & skenario edge (bila ada test).
- `security-reviewer` menilai bila menyentuh auth, secrets, validasi, data
  sensitif.
Kumpulkan laporan, sintesis, putuskan; catat veto bila ada. Jangan menunggu
persetujuan subagent untuk perubahan trivial.

### Langkah 8 — DIFF REVIEW

Baca diff sebagai reviewer, bukan penulis: apakah setiap perubahan perlu?
Apakah ada efek samping tak terduga?

### Langkah 9 — STYLE REVIEW

Cocokkan style dengan file tetangga, naming convention (`05-naming.md`),
kebijakan komentar (`04-coding-standards.md`).

### Langkah 10 — FINALIZE

- Jalankan semua quality gates (`10-quality-gates.md`).
- Pastikan tidak ada file tak-terkait yang berubah.
- Catat decision log & asumsi; nyatakan yang TIDAK diverifikasi.

## 2. DECISION TREES

### Kapan memanggil tim?

```
Tugas menyentuh arsitektur/data/auth/API? ──YA──▶ TIM CHECKPOINT (L3)
Tugas > 1 fase / banyak file?            ──YA──▶ TIM CHECKPOINT (L3)
Operator minta tim/review/diskusi?        ──YA──▶ TIM CHECKPOINT (L3)
Tidak semua?                             ──TIDAK─▶ Implement langsung (L4)
```

### Kapan memanggil subagent mana?

| Kondisi | Subagent yang dipanggil |
|---------|-------------------------|
| Desain arsitektur / struktur file baru | `team-lead` (orchestrator tetap memutuskan) |
| Kode berisiko / perlu second opinion | `code-reviewer` |
| Fitur yang bisa diuji / perlu skenario edge | `qa-engineer` |
| Auth, secrets, validasi, data sensitif | `security-reviewer` |
| Konflik lint/style/naming | `code-reviewer` + `09-tools.md` |

## 3. CHECKLIST FITUR (pakaikan sebelum menyatakan selesai)

- [ ] Spec dibaca / dibuat (tidak menebak).
- [ ] Fase terencana (bila besar, fase per fase).
- [ ] Tim checkpoint dijalankan bila berisiko (atau dicatat dilewati, dengan alasan).
- [ ] Kode mengikuti analogue repository.
- [ ] Scope-stop terpenuhi.
- [ ] Static analysis lulus.
- [ ] Test relevan lulus (bila diminta).
- [ ] Review tim (bila dijalankan) disintesis; veto diakomodasi/eskalasi.
- [ ] Diff & style review bersih.
- [ ] Quality gates final lulus; yang tidak diverifikasi dinyatakan eksplisit.
