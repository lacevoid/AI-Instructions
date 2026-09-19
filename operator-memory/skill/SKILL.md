---
name: operator-memory
description: Use when working on any task, discussing design decisions, receiving user feedback, or being asked to "ingat ini"/"catat"/"rekam"/"restore". All agents must read this skill to learn the operator's identity, preferences, communication style, and decision patterns. Also use when user says "ingat ini", "catat", "rekam", "restore", or gives corrections about their own behavior or preferences.
---

# Operator Memory — Identitas & Konteks Operator

Skill ini menyimpan **"potret diri" operator** (di **persona.md**) dan
**konteks pekerjaan terkini** (di **context.md**) yang terus diperbarui
seiring percakapan dan pekerjaan, plus **behavior-log.md** — catatan lengkap
SEMUA perilaku operator yang teramati (journal mentah di balik setiap pola).
**SEMUA agent** (orchestrator, subagent, tim authoring, tim dev, dan agent
lainnya) **WAJIB membaca persona.md + context.md** sebelum bekerja dan
menyesuaikan perilaku berdasarkan isinya.

- **persona.md** — *siapa operator* (stabil): identitas, gaya, preferensi,
  pola keputusan, filosofi, standar kualitas, pelajaran, hipotesis.
- **context.md** — *di mana kita sekarang* (dinamis): state saat ini
  (checkpoint), progres, dan Log entri bertanggal.
- **behavior-log.md** — *semua yang operator lakukan* (journal): entri
  bertanggal per perilaku teramati, termasuk yang belum jadi pola; sumber
  mentah untuk konsolidasi persona.

Tujuan: lama-kelamaan, perilaku agent **menyerupai operator** — gaya bicara,
pola keputusan, prioritas — sehingga seolah operator ikut berdiskusi dan
memimpin walau tidak di depan layar.

Mekanisme ini **dibawa oleh setiap salinan repository** yang memuatnya:
perangkat atau proyek mana pun yang memiliki salinan tersebut menjalankan
mekanisme yang sama dengan **operatornya masing-masing**. Identitas operator +
repo backup diinstansiasi lewat `operator-memory/bootstrap-operator-memory.sh`
(lihat bagian 6).

## Lokasi file

```
${XDG_CONFIG_HOME:-$HOME/.config}/opencode/skills/operator-memory/persona.md   ← persona live (global)
${XDG_CONFIG_HOME:-$HOME/.config}/opencode/skills/operator-memory/context.md   ← konteks live (global)
${XDG_CONFIG_HOME:-$HOME/.config}/opencode/skills/operator-memory/behavior-log.md  ← behavior-log live (global)
${XDG_CONFIG_HOME:-$HOME/.config}/operator-persona/config/skills/operator-memory/persona.md  ← salinan repo backup
${XDG_CONFIG_HOME:-$HOME/.config}/operator-persona/config/skills/operator-memory/context.md  ← salinan repo backup
${XDG_CONFIG_HOME:-$HOME/.config}/operator-persona/config/skills/operator-memory/behavior-log.md  ← salinan repo backup
```

Kedua file live otomatis di-sinkronkan ke repo privat
`{{GITHUB_HANDLE}}/{{BACKUP_REPO}}` (di GitHub) pada setiap checkpoint kerja —
lihat bagian 6.

## Protokol pembelajaran

### 1. Baca di awal kerja (WAJIB)

Sebelum eksekusi tugas apapun, **baca **persona.md** dan **context.md****
dan terapkan:

- Gaya komunikasi operator (persona)
- Pola keputusan dan risk tolerance (persona)
- Prioritas & preferensi (persona)
- Koreksi & pelajaran yang sudah direkam (persona)
- Jangan ulangi kesalahan lama (persona)
- State saat ini, progres, dan Log (context) — lanjutkan dari titik terakhir

Baca file utuh — bukan hanya bagian tertentu — karena konteks bisa muncul dari
bagian mana saja. Bila butuh dasar lebih dalam di balik pola (mis. "kenapa
operator dianggap begini"), baca **behavior-log.md** — detail perilaku
mentahnya ada di sana.

### 2. Rekam otomatis (tanpa izin dulu)

Di **checkpoint alami** — akhir langkah besar, akhir sesi, sebelum commit/merge
besar — lakukan langkah berikut:

1. **Ekstrak** dari percakapan: keputusan, preferensi baru, koreksi, pola perilaku
2. **Ekstrak ke kesalahan + perbaikan**: ini **kelas satu** — rekam sebagai
   bagian dari identitas, bukan buang. Kesalahan + cara operator bereaksi
   padanya = data paling berharga untuk memahami operator.
3. **Tulis ke file yang tepat**:
   - **persona.md** untuk hal stabil: preferensi, pola keputusan, filosofi,
     standar, koreksi & pelajaran, hipotesis.
   - **context.md** untuk hal dinamis: state saat ini, progres pekerjaan,
     dan entri baru di **Log** (bertanggal).
   - **behavior-log.md** untuk SEMUA perilaku teramati: journal mentah,
     termasuk yang belum jadi pola (lihat 2b).
4. **Laporkan** secara ringkas ke operator apa yang baru saja direkam (tanpa
   menunggu persetujuan untuk hal yang sudah jelas)
5. **Sinkronkan ke GitHub** — jalankan **backup.sh** (lihat bagian 6). Skrip
   ini melakukan sinkronisasi **dua arah**: tarik perubahan dari GitHub
   (perangkat lain yang menghasilkan data), gabungkan dengan file live, lalu
   commit + push. Tidak memerlukan tool/scheduler eksternal — cukup jalankan
   saat bekerja.

### 2b. Mencatat SEMUA perilaku (behavior-log.md)

Memory punya **dua tingkat**:

- **persona.md + context.md** = inti kurasi. Pola yang sudah terbukti konsisten
  (untuk dibaca cepat di awal kerja). Tetap ringkas.
- **behavior-log.md** = catatan lengkap SEMUA perilaku operator yang teramati,
  tingkat journal (mendekati transcript). Ini sumber mentah di balik setiap pola.

Wajib — setiap kali perilaku operator teramati saat bekerja (tidak hanya yang
"layak dikategorikan"):

1. Tulis ke **behavior-log.md**: `- [YYYY-MM-DD HH:MM] konteks → perilaku (tag)`.
   Tag: `#perintah`, `#keputusan`, `#reaksi-error`, `#reaksi-laporan`,
   `#gaya-bahasa`, `#kebiasaan`, `#preferensi`, `#koreksi`, `#humor`, `#diam`.
2. Catat yang mencolok saat kejadian; yang biasa di checkpoint alami.
   Jangan menyensor perilaku "kecil" — konsolidasi yang memilah, bukan pencatatan.
3. Saat konsolidasi (tiap ±10 entri): pola yang konsisten dipromosikan ke
   **persona.md**. Entri behavior-log TIDAK dihapus — jadi riwayat & bukti.
4. **behavior-log.md** ikut disinkronkan ke repo backup (lihat bagian 6).

### 3. Koreksi dari operator — dua kategori

Ketika operator mengoreksi perilaku agent atau menunjukkan pola baru:

**a. Koreksi ke perilaku agent** (mis. "jangan berasumsi X", "jangan ucap Y tanpa dasar"):
→ Langsung rekam ke **persona.md** sebagai `## Koreksi & pelajaran`. Laporkan
di akhir. Tidak perlu diskusi dulu — itu jelas milik agent untuk diperbaiki.

**b. Operator kontradiksi diri sendiri / koreksi atas kesalahan pribadi / blunder**:
→ Diskusikan dulu: *"ini kukira jadi pola kamu — simpan ke memori atau
dihapus?"* — hormati pilihan operator.

**c. Operator meminta restore** (mis. "sistem mati, apakah hasilnya masih ada?"):
→ **SELALU rekam.** Itu adalah bagian dari identitas: bagaimana operator
merespons krisis, apa yang diprioritaskan, cara recover.

### 4. Sharing lintas agent & proyek

- Skill ini bersifat **global** — berlaku di repo authoring DAN semua proyek konsumen
- **persona.md** dan **context.md** berada di lokasi tetap, dibaca oleh semua
  agent di semua proyek
- Ketika salah satu file diperbarui di proyek mana pun, perubahan berlaku untuk
  proyek berikutnya secara otomatis
- Semua subagent yang dipanggil lewat Task tool juga harus membaca **persona.md**
  dan **context.md** sebelum memberi laporan — sehingga seluruh tim menyesuaikan
  dengan operator

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
   `{{GITHUB_HANDLE}}/{{BACKUP_REPO}}`, memasang skill + **persona.md** +
   **context.md** starter di `${XDG_CONFIG_HOME:-$HOME/.config}/opencode/`,
   menautkan keduanya ke `opencode.jsonc`, dan menyiapkan **backup.sh** +
   **restore.sh** + **metrics.sh**.
2. Restart opencode — skill aktif; memori berkembang dari titik itu.
3. Bila memori lama (`memory.md` legacy) ditemukan, bootstrap **memigrasi** ke
   persona.md + context.md secara deterministik dan menyimpan file lamanya.

**Alur **backup.sh**** (setelah file memori di-update di checkpoint mana pun,
agent WAJIB menjalankannya):

1. **Tarik (pull)** — `git fetch origin` + `git merge --ff-only` terhadap branch
   aktif. Perubahan dari perangkat lain masuk ke salinan repo lokal dulu.
2. **Sinkron file demi file** (**persona.md**, **context.md**,
   **behavior-log.md**, **SKILL.md**, `opencode.jsonc`):
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
   backup versi lama `.bak.<timestamp>`; memory.md legacy ikut dipulihkan bila ada)
3. Restart opencode, lalu lanjut bekerja — memori berkembang dari titik terakhir
   dan tetap sinkron dua arah via **backup.sh**.

### 7. Metrik adaptasi

Untuk menilai seberapa cepat memori salinan ini berkembang, jalankan
**`operator-memory/metrics.sh`** (atau `~/.config/operator-persona/metrics.sh`):

- Ringkasan manusia: `operator-memory/metrics.sh`
- Data untuk agent: `operator-memory/metrics.sh --json`

Metrik yang dihitung: ukuran & bagian persona/context, entri Log, sinyal
pembelajaran (pelajaran/hipotesis), keseimbangan persona vs context,
pertumbuhan sejak sinkron terakhir, dan frekuensi sinkronisasi backup repo.
Metrik ini **lokal** — tidak ada telemetri ke pusat.

## Format persona.md

Gunakan struktur berikut (bisa disesuaikan seiring waktu):

```markdown
# Persona Operator — {{NAME}}

## Fakta permanen
- Identitas, kontak, repo backup, latar belakang

## Preferensi komunikasi
- Gaya bahasa, nada, panjang respon, bahasa yang digunakan

## Pola keputusan
- Bagaimana operator memilih, risk tolerance, threshold verifikasi

## Filosofi authoring
- Cara berpikir operator tentang instruksi/arsitektur/proyek

## Standar kualitas pribadi
- Standar yang operator tuntut dari agent (evidence, lint, honesty)

## Preferensi tooling & workflow
- Tool utama, konvensi git, cara kerja favorit

## Koreksi & pelajaran
- Koreksi dari operator terhadap perilaku agent
- Blunder operator + cara recover (penting untuk dipahami, bukan dihapus)

## Hipotesis
- Asumsi yang belum terkonfirmasi — tandai dengan "belum pasti"
- Hapus atau konfirmasi setelah ada bukti dari interaksi
```

## Format context.md

Gunakan struktur berikut (bagian dinamis, berubah tiap sesi):

```markdown
# Konteks Pekerjaan — {{NAME}}

## State saat ini (checkpoint — <tanggal>)
- Progres yang sedang berjalan, keputusan terakhir, hal yang wajib diingat

## Log
- [tanggal] Entri bertanggal untuk konteks yang berkembang secara spesifik
```

## Format behavior-log.md

Catatan SEMUA perilaku operator (journal mentah, di luar inti kurasi):

```markdown
# Behavior Log Operator — {{NAME}}

## Aturan penulisan
- Tiap entri singkat: `- [YYYY-MM-DD HH:MM] konteks → perilaku (tag)`
- Tag: #perintah, #keputusan, #reaksi-error, #reaksi-laporan, #gaya-bahasa,
  #kebiasaan, #preferensi, #koreksi, #humor, #diam

## Log
- [tanggal] Perilaku teramati — termasuk yang belum jadi pola
```

Detail aturan & tag lengkap ada di starter `skill/behavior-log.md.start`
atau file live `behavior-log.md` setelah bootstrap.

### Pruning & konsolidasi

- **Konsolidasi** setiap ~10 entri baru: gabungkan entri serupa, buang
  duplikasi, perbarui hipotesis; pola yang konsisten dipromosikan dari
  **behavior-log.md** ke **persona.md** (entri log tidak dihapus)
- **Operator boleh prune kapan saja**: hapus bagian yang tidak relevan
- **persona.md** (inti permanen) tetap kecil (1-2 layar): fakta, gaya, pola utama
- **context.md** (Log) boleh tumbuh, tapi jangan melebihi ~50 entri tanpa
  konsolidasi; usang dipindah ke state baru atau dipangkas
- **behavior-log.md** (journal) boleh tumbuh besar; konsolidasi mempromosikan
  pola ke persona.md, sisanya tetap jadi riwayat & bukti

## Contoh pemicu

- User memberi koreksi: "jangan berasumsi X" → rekam di persona + laporkan
- Selesai diskusi arsitektur besar → ekstrak pola keputusan → tulis di persona;
  keputusan & progres → tulis di context
- User berkata: "catat ini, aku tidak suka Y" → rekam di persona
- Sistem error, user tanya "masih ada?" → rekam pola recovery di persona
- User: "ingat ini" atau "rekam" → pastikan tercatat
- User: "harus mencatat semua perilaku saya" → tulis SEMUA perilaku teramati ke
  behavior-log.md, promosikan pola ke persona.md saat konsolidasi
- Akhir sesi kerja → perbarui State saat ini + tambahkan entri Log di context
