# 10 — Quality Gates (Definisi "Selesai", Senior Self-Review, Verifikasi Akhir)

Modul ini adalah **definisi selesai** untuk semua peran. Tugas dianggap DONE
hanya bila seluruh gates lulus secara lokal (local parity) — bukan hanya
"tampak beres".

## 1. Senior Self-Review Rubric

Sebelum menyatakan selesai, baca diff sebagai **reviewer**, bukan sebagai
penulis. Untuk setiap perubahan:

- [ ] Apakah setiap hunk benar-benar perlu? (tidak ada perubahan tak terkait)
- [ ] Apakah kedua cabang kondisi ditelusuri (if/else, null, error path)?
- [ ] Apakah ada efek samping tak terlihat (mutasi, side effect, timeout)?
- [ ] Apakah nama & struktur mengikuti konvensi proyek?
- [ ] Apakah kode self-explanatory tanpa komentar chit-chat?
- [ ] Apakah ada data loss / integrity risiko?
- [ ] Apakah ada security exposure?

Bila salah satu jawaban "tidak jelas" → jangan menebak; periksa atau tanya
operator.

## 2. Gates wajib (perbarui sesuai proyek saat onboarding)

- [ ] Spec dibaca/dibuat (`MASTER_BUILD_SPECIFICATION.md`).
- [ ] Bekerja di branch yang benar; commit ringkas.
- [ ] Static analysis / lint lulus (0 error scope tersentuh).
- [ ] Test relevan lulus (bila diminta / berisiko).
- [ ] Tidak ada artefak build / rahasia ter-commit.
- [ ] Review tim untuk tugas berisiko (lihat `03-team-protocol.md`); veto
      diakomodasi / dieskalasi.
- [ ] Evidence-anchored: setiap file/method/signature yang dirujuk ada di kode
      nyata (`12-project-specific/canonical-snippets.md`).
- [ ] Edge probes dijalankan untuk code path yang disentuh (input kosong,
      null, batas, konflik, timeout).
- [ ] Keputusan & asumsi tercatat; hal yang TIDAK diverifikasi dinyatakan
      eksplisit.
- [ ] Perubahan ter-reproduksi: command yang diklaim dijalankan benar-benar
      dijalankan.
- [ ] Anti-AI-slop: output UI/copy/prosa bebas pola AI-slop — muat skill
      `.opencode/skills/antislop/SKILL.md` (+ skill concern: `antislop-copywriting`,
      `antislop-ui`, `antislop-code`) SEBELUM menulis; Delivery Gate dijalankan
      sebelum output final. Bila filter tidak terpasang, pasang via template
      `antislop` atau terapkan aturan Empty AI Vocabulary secara manual dan catat
      ketiadaannya di decision log.

## 3. Proses verifikasi akhir

1. Jalankan seluruh gates satu per satu, catat hasil (bukan hanya yang lulus).
2. Bila ada gates gagal: reproduce → isolate → hipotesis → fix minimal →
   **ulangi semua gates** (jangan hanya yang tadinya gagal).
3. Laporkan ke operator: apa yang dijalankan, apa yang TIDAK dijalankan, hasil.

## 4. Peran tim

- **Orchestrator menjalankan gates** dan melaporkan jujur bila ada yang TIDAK
  dijalankan. Bila subagent (`qa-engineer`, `code-reviewer`) tersedia, minta
  mereka memverifikasi dari perspektif masing-masing.
- Gates yang gagal TIDAK bisa "dianggap selesai" oleh orchestrator; hal itu
  memicu REVISI, dan bila diabaikan = veto (lihat `03-team-protocol.md`).

## 5. Record verifikasi

Simpan catatan verifikasi di laporan ke operator:

```
VERIFIKASI <tanggal>
- Gates dijalankan: <daftar + hasil>
- Gates TIDAK dijalankan: <daftar + alasan>
- Perintah reproduksi: <command>
```
