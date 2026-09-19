# 11 — Forbidden Behavior (Larangan Eksplisit)

Modul ini adalah **single source of truth** untuk larangan. Setiap larangan
ditulis eksplisit dengan MUST NOT, berdasarkan bukti risiko universal atau pola
nyata di proyek target. Pelanggaran = kegagalan total / REVISI wajib.

## 1. Larangan GLOBAL (MUST NOT)

- Bekerja, commit, push, atau merge langsung di branch `main`/branch stabil.
- Menulis kode sebelum `MASTER_BUILD_SPECIFICATION.md` dibaca/dibuat.
- Menebak spesifikasi (fitur, entitas, konvensi) tanpa bertanya ke operator.
- Menyimpan rahasia/password/token dalam file ter-commit atau log.
- Mempercayai input tanpa validasi server-side.
- Menampilkan stack trace / detail internal ke pengguna.
- Menghapus/mengubah test hanya agar lolos tanpa memahami perilaku aslinya.
- Menambahkan komentar yang mengulang isi kode (chit-chat) tanpa diminta.
- Refactor kode yang berfungsi di luar scope tugas.
- Menyalin konvensi/pola dari proyek lain tanpa bukti di proyek target.
- Menciptakan arsitektur/layer baru tanpa dasar bukti repository.
- Mengabaikan veto subagent (lihat `03-team-protocol.md`).
- Menggunakan `dump()`/`dd()`/debug print pada kode ter-commit (bila berlaku
  stack proyek; sesuaikan dengan proyek).
- Membuat output teks/copy UI/prosa dengan pola AI-slop (buzzword marketing dari
  Empty AI Vocabulary, klaim tanpa bukti, frasa generik) padahal filter anti-slop
  tersedia (`.opencode/skills/antislop/SKILL.md` + skill concern); Delivery
  Gate-nya WAJIB dijalankan sebelum output final (`10-quality-gates.md`).

## 2. Larangan proses

- Menulis set instruksi/konvensi baru tanpa analisis repository target.
- Menyebut "best practice" generik sebagai konvensi proyek tanpa evidence.
- Mengklaim "sudah diverifikasi" tanpa menjalankan command-nya (honesty).
- Mengubah lebih dari satu area dalam satu PR tanpa alasan dan pemisahan.

## 3. Larangan tim

- Subagent mengedit file / commit sendiri (mereka melapor ke orchestrator).
- Diskusi tanpa keputusan (looping tanpa batas; max 2 putaran — lihat
  `03-team-protocol.md`).
- Orchestrator mengabaikan temuan kritikal subagent.

## 4. Menambah larangan baru

Bila ditemukan pola buruk nyata di proyek (dengan bukti), tulis di sini dengan
anchor. Jangan menambahkan larangan tanpa bukti penggunaan/risiko.
