# Operator Persona — Mekanisme yang Sama, Operator yang Berbeda

Setiap salinan repository AI-Instructions membawa **mekanisme yang sama**:
sebuah skill `operator-memory` yang membuat agent belajar meniru **operator
salinan tersebut** — identitas, gaya, preferensi, pola keputusan — lewat dua
file memori yang **di-sinkronkan dua arah** ke repo privat GitHub operator:

- **persona.md** — *siapa operator* (stabil): identitas, gaya, pola keputusan,
  filosofi, standar, pelajaran, hipotesis.
- **context.md** — *di mana kita sekarang* (dinamis): state saat ini
  (checkpoint), progres, dan Log bertanggal.

Mekanisme bersifat **per-salinan**: operator A di salinan A punya memori,
repo backup, dan GitHub sendiri; operator B di salinan B memulai dari kosong
dan membangun identitasnya sendiri. Tidak ada data operator yang saling
menimpa — `operator-memory/backup.sh` selalu menarik lalu menggabungkan.

```
operator-memory/
├── README.md                        ← file ini
├── bootstrap-operator-memory.sh     ← INSTALLER: personalisasi per operator
├── backup.sh                        ← sinkronisasi DUA ARAH (tarik → gabung → push)
├── restore.sh                       ← restore ke ~/.config/opencode/ di mesin baru
├── metrics.sh                       ← METRIK adaptasi memori per salinan (manusia + --json)
└── skill/
    ├── SKILL.md                     ← protokol belajar & rekam (template)
    ├── persona.md.start             ← starter persona (template, ber-placeholder)
    └── context.md.start             ← starter konteks (template, ber-placeholder)
```

## Cara pakai (untuk operator salinan ini)

```bash
./operator-memory/bootstrap-operator-memory.sh
# atau non-interaktif:
./operator-memory/bootstrap-operator-memory.sh --name "Nama" --email "x@y.id" --github handle
```

Script akan:

1. Minta identitas operator (nama, email, handle GitHub).
2. Membuat repo privat GitHub `operator-persona` (via `gh`), lalu clone ke
   `${XDG_CONFIG_HOME:-$HOME/.config}/operator-persona`.
3. Memasang skill + `persona.md` + `context.md` starter ke
   `~/.config/opencode/skills/operator-memory/`
   (memori yang sudah ada TIDAK ditimpa; `memory.md` legacy dimigrasi ke dua
   file baru dan disimpan utuh).
4. Menautkan kedua file ke `~/.config/opencode/opencode.jsonc` (dibuat bila
   belum ada; referensi memory.md legacy diganti).
5. Menyalin config ke repo backup, commit + push awal.

**Setelah itu restart opencode.** Agent membuka sesi berikutnya sudah mengenal
operator: membaca `~/.config/opencode/skills/operator-memory/persona.md` dan
`context.md`, merekam pembelajaran di checkpoint kerja, lalu menjalankan
`operator-memory/backup.sh`.

> Tanpa `gh` / ingin uji coba offline:
> `./operator-memory/bootstrap-operator-memory.sh --name ... --email ... --local-only`

## Backup dua arah (saat bekerja, tanpa scheduler)

`operator-memory/backup.sh` dijalankan oleh agent setiap kali memori diperbarui
menyentuh checkpoint kerja (akhir langkah besar, akhir sesi, sebelum commit
besar). Tidak ada cron/systemd — cukup jalan saat bekerja, idempotent bila tidak
ada perubahan.

1. **Tarik** — `git fetch` + `git merge --ff-only` branch aktif; perubahan dari
   perangkat lain masuk duluan.
2. **Sinkron file demi file** (persona.md, context.md, SKILL.md,
   `opencode.jsonc`) — file memori relatif ke
   `~/.config/opencode/skills/operator-memory/`:
   - hanya lokal berubah → commit + push
   - hanya remote berubah → **adopsi** ke file live lokal
   - keduanya berubah → **merge 3-arah** (`git merge-file`, base + lokal +
     remote); bila konflik, digabung aman tanpa kehilangan data dan ditandai
     `--- SINKRONISASI PERANGKAT LAIN — PERLU DIRAPIKAN MANUAL ---`
3. **Commit + push** hanya bila ada perubahan.

## Metrik adaptasi (per salinan, lokal)

`operator-memory/metrics.sh` menjawab *"seberapa cepat memori salinan ini
berkembang?"* — untuk operator (ringkasan satu layar) dan untuk agent
(`--json`).

- `./operator-memory/metrics.sh` — ringkasan manusia
- `./operator-memory/metrics.sh --json` — data terstruktur untuk agent

Metrik: ukuran & bagian persona/context, entri Log, sinyal pembelajaran
(pelajaran/hipotesis), keseimbangan persona vs context, pertumbuhan sejak
sinkron terakhir, dan frekuensi sinkronisasi repo backup. Semua **lokal** —
tidak ada telemetri terpusat.

## Restore di mesin baru / fresh install

```bash
git clone git@github.com:<handle>/operator-persona.git ~/.config/operator-persona
~/.config/operator-persona/restore.sh   # salin ke ~/.config/opencode/ (.bak otomatis)
# restart opencode
```

Backup lama yang masih berisi `memory.md` legacy juga dipulihkan (file lama
tidak hilang); otoritas selanjutnya adalah persona.md + context.md.

## Syarat minimal

- `git`
- `gh` (untuk membuat repo privat otomatis; bisa dilewati dengan `--local-only`)
- opencode (memuat skill dari `~/.config/opencode/skills/`)
