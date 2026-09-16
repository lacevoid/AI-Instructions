---
name: operator-memory
description: Use when working on any task, discussing design decisions, receiving user feedback, or being asked to "ingat ini"/"catat"/"rekam"/"restore". All agents must read this skill to learn the operator's identity, preferences, communication style, and decision patterns. Also use when user says "ingat ini", "catat", "rekam", "restore", or gives corrections about their own behavior or preferences.
---

# Operator Memory — Identitas & Pembelajaran Operator

Skill ini menyimpan **"potret diri" operator** yang terus diperbarui seiring
percakapan dan pekerjaan. **SEMUA agent** (orchestrator, subagent, tim authoring,
tim dev, dan agent lainnya) **WAJIB membaca **memory.md**** sebelum bekerja dan
menyesuaikan perilaku berdasarkan isinya.

Tujuan: lama-kelamaan, perilaku agent **menyerupai operator** — gaya bicara,
pola keputusan, prioritas — sehingga seolah operator ikut berdiskusi dan memimpin
walau tidak di depan layar.

Mekanisme ini **dibawa oleh setiap salinan repository** yang memuatnya: perangkat
atau proyek mana pun yang memiliki salinan tersebut menjalankan mekanisme yang
sama dengan **operatornya masing-masing**. Identitas operator + repo backup
diinstansiasi lewat `operator-memory/bootstrap-operator-memory.sh` (lihat bagian 6).

## Lokasi file

```
${XDG_CONFIG_HOME:-$HOME/.config}/opencode/skills/operator-memory/memory.md    ← file memori live (global)
${XDG_CONFIG_HOME:-$HOME/.config}/operator-persona/config/skills/operator-memory/memory.md  ← salinan repo backup (GitHub)
```

File memori live otomatis di-sinkronkan ke repo privat
`{{GITHUB_HANDLE}}/{{BACKUP_REPO}}` (di GitHub) pada setiap checkpoint kerja —
lihat bagian 6.

## Protokol pembelajaran

### 1. Baca di awal kerja (WAJIB)

Sebelum eksekusi tugas apapun, **baca **memory.md**** dan terapkan:

- Gaya komunikasi operator
- Pola keputusan dan risk tolerance
- Prioritas & preferensi (teknis, workflow, UI)
- Koreksi & pelajaran yang sudah direkam
- Jangan ulangi kesalahan lama

Baca file utuh — bukan hanya bagian tertentu — karena konteks bisa muncul dari
bagian mana saja.

### 2. Rekam otomatis (tanpa izin dulu)

Di **checkpoint alami** — akhir langkah besar, akhir sesi, sebelum commit/merge
besar — lakukan langkah berikut:

1. **Ekstrak** dari percakapan: keputusan, preferensi baru, koreksi, pola perilaku
2. **Ekstrak ke kesalahan + perbaikan**: ini **kelas satu** — rekam sebagai
   bagian dari identitas, bukan buang. Kesalahan + cara operator bereaksi padanya
   = data paling berharga untuk memahami operator.
3. **Tulis** ke **memory.md** sebagai entri terstruktur bertanggal
4. **Laporkan** secara ringkas ke operator apa yang baru saja direkam (tanpa
   menunggu persetujuan untuk hal yang sudah jelas)
5. **Sinkronkan ke GitHub** — jalankan **backup.sh** (lihat bagian 6). Skrip ini
   melakukan sinkronisasi **dua arah**: tarik perubahan dari GitHub (perangkat
   lain yang menghasilkan data), gabungkan dengan memori live, lalu commit + push.
   Tidak memerlukan tool/scheduler eksternal — cukup jalankan saat bekerja.

### 3. Koreksi dari operator — dua kategori

Ketika operator mengoreksi perilaku agent atau menunjukkan pola baru:

**a. Koreksi ke perilaku agent** (mis. "jangan berasumsi X", "jangan ucap Y tanpa dasar"):
→ Langsung rekam ke **memory.md** sebagai `## Koreksi & pelajaran`. Laporkan
di akhir. Tidak perlu diskusi dulu — itu jelas milik agent untuk diperbaiki.

**b. Operator kontradiksi diri sendiri / koreksi atas kesalahan pribadi / blunder**:
→ Diskusikan dulu: *"ini kukira jadi pola kamu — simpan ke memori atau
dihapus?"* — hormati pilihan operator.

**c. Operator meminta restore** (mis. "sistem mati, apakah hasilnya masih ada?"):
→ **SELALU rekam.** Itu adalah bagian dari identitas: bagaimana operator
merespons krisis, apa yang diprioritaskan, cara recover.

### 4. Sharing lintas agent & proyek

- Skill ini bersifat **global** — berlaku di repo authoring DAN semua proyek konsumen
- **memory.md** berada di lokasi tetap, dibaca oleh semua agent di semua proyek
- Ketika **memory.md** diperbarui di proyek mana pun, perubahan berlaku untuk
  proyek berikutnya secara otomatis
- Semua subagent yang dipanggil lewat Task tool juga harus membaca **memory.md**
  sebelum memberi laporan — sehingga seluruh tim menyesuaikan dengan operator

### 5. Batasan & honesty

- Memori ini membuat perilaku agent **menyerupai** operator, bukan menggantikan
  intent — untuk keputusan besar yang belum pernah dibahas, tetap tanyakan
- File memori **bukan transcript** — berisi ekstraksi terstruktur, bukan salin
  mentah percakapan
- Operator **boleh prune** kapan saja — hapus entri yang tidak relevan lagi
- Agent harus **jujur** tentang apa yang TIDAK diingat (memori dimulai dari
  kosong saat pertama kali dijalankan, atau dikurasi ulang)

### 6. Backup & restore ke GitHub (otomatis saat bekerja, DUA ARAH)

Memori dicadangkan ke repo privat `{{GITHUB_HANDLE}}/{{BACKUP_REPO}}` **hanya
saat kita bekerja** — tidak ada scheduler/cron/systemd. Sinkronisasi bersifat
**dua arah**: perangkat lain yang menjalankan distribusi agent ini juga bisa
menghasilkan data memori; **backup.sh** tidak pernah menimpa, selalu menggabungkan.

**Instansiasi di salinan baru (`operator-memory/bootstrap-operator-memory.sh`):**

1. Operator menjalankan `operator-memory/bootstrap-operator-memory.sh` → memasukkan identitas
   (nama, email, handle GitHub) → script membuat repo privat
   `{{GITHUB_HANDLE}}/{{BACKUP_REPO}}`, memasang skill + **memory.md** starter di
   `${XDG_CONFIG_HOME:-$HOME/.config}/opencode/`, menautkan `opencode.jsonc`, dan
   menyiapkan **backup.sh** + **restore.sh**.
2. Restart opencode — skill aktif; memori berkembang dari titik itu.

**Alur **backup.sh**** (setelah **memory.md** di-update di checkpoint mana pun,
agent WAJIB menjalankannya):

1. **Tarik (pull)** — `git fetch origin` + `git merge --ff-only` terhadap branch
   aktif. Perubahan dari perangkat lain masuk ke salinan repo lokal dulu.
2. **Sinkron file demi file** (**memory.md**, **SKILL.md**, `opencode.jsonc`):
   - Hanya lokal berubah → dorong ke repo (commit + push)
   - Hanya remote berubah → **adopsi** ke file live lokal (memori dari perangkat
     lain langsung terpakai)
   - Keduanya berubah → **merge 3-arah** (`git merge-file`: base + lokal + remote).
     Bila bersih, hasilnya dipakai di live DAN repo; bila konflik, keduanya
     digabung aman tanpa kehilangan data dan ditandai
     `--- SINKRONISASI PERANGKAT LAIN — PERLU DIRAPIKAN MANUAL ---`.
3. **Commit + push** hanya bila ada perubahan (idempotent bila tidak ada).

**Restore di mesin baru / fresh install:**

1. `git clone git@github.com:{{GITHUB_HANDLE}}/{{BACKUP_REPO}}.git ${XDG_CONFIG_HOME:-$HOME/.config}/operator-persona`
2. `${XDG_CONFIG_HOME:-$HOME/.config}/operator-persona/restore.sh` — menyalin
   config ke `${XDG_CONFIG_HOME:-$HOME/.config}/opencode/` (otomatis membuat
   backup versi lama `.bak.<timestamp>`)
3. Restart opencode, lalu lanjut bekerja — memori berkembang dari titik terakhir
   dan tetap sinkron dua arah via **backup.sh**.

## Format memory.md

Gunakan struktur berikut (bisa disesuaikan seiring waktu):

```markdown
# Memori Operator

## Fakta permanen
- Identitas, latar belakang, preferensi mendasar

## Preferensi komunikasi
- Gaya bahasa, nada, panjang respon, bahasa yang digunakan

## Pola keputusan
- Bagaimana operator memilih, risk tolerance, threshold verifikasi

## Koreksi & pelajaran
- Koreksi dari operator terhadap perilaku agent
- Blunder operator + cara recover (penting untuk dipahami, bukan dihapus)

## Hipotesis
- Asumsi yang belum terkonfirmasi — tandai dengan "belum pasti"
- Hapus atau konfirmasi setelah ada bukti dari interaksi

## Log
- Entri ber-tanggal untuk konteks yang berkembang secara spesifik
```

### Pruning & konsolidasi

- **Konsolidasi** setiap ~10 entri baru: gabungkan entri serupa, buang
  duplikasi, perbarui hipotesis
- **Operator boleh prune kapan saja**: hapus bagian yang tidak relevan
- **Inti permanen** tetap kecil (1-2 layar): fakta, gaya, pola utama
- **Log** boleh tumbuh, tapi jangan melebihi ~50 entri tanpa konsolidasi

## Contoh pemicu

- User memberi koreksi: "jangan berasumsi X" → rekam + laporkan
- Selesai diskusi arsitektur besar → ekstrak pola keputusan → tulis
- User berkata: "catat ini, aku tidak suka Y" → rekam langsung
- Sistem error, user tanya "masih ada?" → rekam pola recovery
- User: "ingat ini" atau "rekam" → pastikan tercatat
