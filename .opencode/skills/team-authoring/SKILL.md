---
name: team-authoring
description: Use when merancang/mereview set instruksi di repository authoring ini dan ingin tim AI berdiskusi: architecture review, evidence check, quality gates, dan scope consistency. Juga use when user meminta "tim", "review tim", "diskusi", "second opinion", "cross-check", atau "semua role menilai".
---

# Team Authoring — Protokol Diskusi Tim

Skill ini mengaktifkan **tim authoring** untuk pekerjaan merancang/mereview set
instruksi di repository authoring AI-Instructions ini. Saat skill dipicu, Anda
(build/default agent) bertindak sebagai **orchestrator** dari tim beranggotakan
subagent berikut:

| Role subagent | Tanggung jawab inti |
|---------------|---------------------|
| `architect-reviewer` | Kelayakan arsitektur & kelengkapan set (REFERENCE BAR, Klausa wajib 1-5) |
| `evidence-checker` | Verifikasi setiap backtick `.md`/`.sh` & evidence anchor benar-benar ada |
| `quality-gate-runner` | Menjalankan & melaporkan quality gates (health-check, markdownlint, bash -n, shellcheck, smoke test) |
| `scope-consistency-reviewer` | Change impact (stale reference), konsistensi penomoran, scope-stop |

## Protokol diskusi (wajib diikuti orchestrator)

### Fase 0 — Persiapan (orchestrator)

1. Baca `ARCHITECT-GUIDE.md` penuh bila belum dibaca sesi ini (self-instruction).
2. Tentukan **scope review** yang diminta user: set baru, modul tertentu, atau
   seluruh perubahan yang belum di-commit (`git status`/`git diff`).
3. Pastikan daftar file yang direview jelas — sampaikan ke subagent.

### Fase 1 — Paralel (kirim subagent sekaligus dalam satu pesan)

Bertindaklah sebagai orchestrator: **panggil subagent berikut secara paralel**
melalui Task tool, dengan prompt laporan yang meminta format output dari masing-masing:

1. `architect-reviewer` — tanya: arsitektur/kelengkapan set yang direview.
2. `evidence-checker` — tanya: semua referensi resolve? phantom/stale?
3. `scope-consistency-reviewer` — tanya: konsistensi penomoran + change impact.
4. `quality-gate-runner` — tanya: gates mana yang lulus / gagal / tidak dijalankan.

Kirim keempatnya dalam pesan yang sama (parallel tool calls), jangan berurutan.
Beri tahu mereka file/scope yang sama agar laporan bisa dibandingkan.

### Fase 2 — Sintesis (orchestrator)

1. Kumpulkan semua laporan. Bandingkan temuan lintas role.
2. Buat **ringkasan keputusan**: SETUJU / REVISI / TOLAK dengan alasan per role.
3. Prioritaskan temuan: kritis (hallucination, referensi putus, klausa hilang,
   gates gagal) vs minor (gaya, phrasing).
4. Rencana aksi: apa yang harus diperbaiki, oleh siapa, urutan (perbaiki
   hallucination/referensi dulu, lalu konten, lalu jalankan gates ulang).

### Fase 3 — Eksekusi & rekonsiliasi

1. Lakukan perbaikan yang disepakati (atau ajukan ke user bila di luar scope).
2. Jalankan ulang `quality-gate-runner` untuk verifikasi akhir (local parity).
3. Laporkan ke user: keputusan tim, daftar temuan, apa yang diubah, dan apa yang
   TIDAK dijalankan (honesty).

## Aturan diskusi

- **Paralel dulu, sintesis sesudah**: subagent berbicara ke orchestrator, bukan
  satu sama lain; orchestrator menyatukan suara.
- **Putaran maks 2**: bila temuan bertentangan setelah putaran pertama, jalankan
  putaran kedua hanya untuk role yang berselisih, lalu putuskan. Jangan looping.
- **Pelanggaran kritikal = veto**: referensi phantom/stale, gates gagal, atau
  klausa wajib hilang = REVISI, bukan sekadar catatan.
- **Honesty**: sampaikan ke user apa yang tidak diverifikasi (mis. markdownlint
  tidak terpasang) — jangan hanya daftar yang lulus.
- **Scope-stop**: tim tidak memperbaiki modul di luar tugas walau "hampir sama".
- **Git**: semua perubahan authoring mengikuti aturan git repo ini (branch +
  PR ke `main`, bukan commit langsung).

## Contoh pemicu

- "tim, review set instruksi baru untuk proyek X"
- "jalankan tim untuk memeriksa referensi dua modul terakhir"
- "cross-check draft konstitusi ini dengan semua role"
