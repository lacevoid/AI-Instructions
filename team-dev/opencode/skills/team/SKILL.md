---
name: team
description: Use when bekerja di proyek ini dan membutuhkan perspektif tim development — orchestrator harus memanggil subagent (team-lead, code-reviewer, qa-engineer, security-reviewer) untuk berdiskusi sebelum menetapkan keputusan. Trigger kata kunci: "tim", "team", "review", "second opinion", "diskusi", "bantu menilai", "code review", "qa review", "security review".
---

# Skill Team — Protokol Diskusi Tim Development

Saat skill ini terpicu, Anda (agent utama/orchestrator) menjalankan **diskusi
tim development** sebelum menetapkan keputusan. Protokol lengkap ada di
`ai-instructions/03-team-protocol.md` — ringkasannya di sini.

## Role subagent

| Role | Dipanggil saat | Frontmatter color |
|------|----------------|-------------------|
| `team-lead` | Desain arsitektur/struktur, alur fitur, penempatan kode | accent |
| `code-reviewer` | Kualitas & kebenaran kode, pola, scope, style | warning |
| `qa-engineer` | Kesesuaian spec, edge case, makna test | info |
| `security-reviewer` | Auth, secrets, validasi, data sensitif, boundary | error |

## Protokol (untuk orchestrator)

1. **Siapkan brief**: task, spec, file yang disentuh, pertanyaan spesifik.
2. **Paralel**: panggil subagent yang relevan dalam satu pesan (parallel),
   bukan berurutan, agar hemat waktu. Beri tahu mereka konteks yang sama.
3. **Sintesis**: kumpulkan laporan → kelompokkan kritikal vs minor → cari bukti
   (path/hasil test) bila bertentangan → putuskan.
4. **Veto** (dari kriteria di `03-team-protocol.md`): hallucination evidence,
   data loss/integrity, keamanan, gates gagal yang diabaikan, pelanggaran
   MUST. Veto MUST diakomodasi atau dieskalasi ke operator — TIDAK diabaikan.
5. **Eksekusi**: orchestrator yang mengedit; subagent hanya melapor.
6. **Maks 2 putaran**: setelah itu putuskan atau eskalasi ke operator.
7. **Catat keputusan**: ringkas ke operator (temuan, veto, keputusan, dan apa
   yang TIDAK diverifikasi).

## Aturan

- Paralel dulu, sintesis sesudah; subagent berbicara ke orchestrator.
- Evidence over opinion: klaim tanpa bukti = opini.
- Jangan panggil subagent untuk hal yang bisa dicek tools (lint/test).
- Scope-stop: tim tidak menambah pekerjaan di luar task.
- Git: semua perubahan mengikuti aturan git proyek (branch, bukan commit ke
  branch stabil).
