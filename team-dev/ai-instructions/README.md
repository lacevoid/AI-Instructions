# AI Instructions — Team Development Template (README Modul)

Ringkasan set instruksi template `team-dev` untuk proyek konsumen. Set ini
mengajarkan **tim AI multi-agent** (orchestrator + subagent) bekerja dan
berdiskusi saat mengerjakan proyek.

## File map

| File | Isi |
|------|-----|
| `ai-instructions.md` | Konstitusi (entry point) — prinsip, prioritas, gates, protokol spec |
| `01-governance.md` | Prioritas, resolusi konflik, scope aturan |
| `02-agent-workflow.md` | Workflow wajib 12 langkah + decision trees tim |
| `03-team-protocol.md` | **Peran tim, protokol diskusi, sintesis & kriteria veto** |
| `04-coding-standards.md` | Deteksi & kepatuhan gaya kode aktual proyek |
| `05-naming.md` | Deteksi & kepatuhan konvensi penamaan |
| `06-testing.md` | Strategi testing berbasis bukti proyek |
| `07-security.md` | Keamanan GLOBAL (area veto) |
| `08-git.md` | Branching, commit, klausa wajib |
| `09-tools.md` | Tooling proyek & penggunaannya |
| `10-quality-gates.md` | Definisi "selesai" + senior self-review |
| `11-forbidden-behavior.md` | Larangan eksplisit |
| `12-project-specific/` | Invarian + bank snippet kanonik (WAJIB diisi konsumen) |

## Cara pakai (konsumen)

1. Jalankan distribusi dari root proyek konsumen:
   `./setup-ai-rules.sh team-dev` (atau `ainstruct team-dev` / `npx @lace/ainstruct team-dev`).
2. Ikuti onboarding: buat `MASTER_BUILD_SPECIFICATION.md` (bila belum ada),
   analisis proyek, isi `ai-instructions/12-project-specific/*`.
3. Untuk tim opencode: template juga mendistribusikan `.opencode/agent/*` dan
   skill `team` ke proyek — lihat bagian berikut.
4. Saat bekerja, minta "tim" / "review" ke agent; protokol di `03-team-protocol.md`.

## Distribusi tim opencode (otomatis bila template dipakai)

Bila `setup-ai-rules.sh` mendistribusikan template `team-dev`, selain file
instruksi, ia juga menempatkan **role subagent** dan **skill diskusi** ke
`.opencode/` proyek konsumen:

- `.opencode/agent/team-lead.md` — orchestrator / pemimpin tim
- `.opencode/agent/code-reviewer.md` — review kode
- `.opencode/agent/qa-engineer.md` — review QA & edge case
- `.opencode/agent/security-reviewer.md` — review keamanan (veto)
- `.opencode/skills/team/SKILL.md` — skill yang memicu protokol diskusi

Sumber role/skill ada di folder `opencode/` di dalam template ini.

## Referensi

- Konstitusi: `ai-instructions.md`
- Protokol tim: `03-team-protocol.md`
- Definisi selesai: `10-quality-gates.md`
