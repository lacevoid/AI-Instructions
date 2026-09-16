# Operator Persona — Mekanisme yang Sama, Operator yang Berbeda

Setiap salinan repository AI-Instructions membawa **mekanisme yang sama**:
sebuah skill `operator-memory` yang membuat agent belajar meniru **operator
salinan tersebut** — identitas, gaya, preferensi, pola keputusan — dan
menyimpannya di `~/.config/opencode/skills/operator-memory/memory.md` yang
**di-sinkronkan dua arah** ke repo privat GitHub operator.

Mekanisme bersifat **per-salinan**: operator A di salinan A punya memori,
repo backup, dan GitHub sendiri; operator B di salinan B memulai dari kosong dan
membangun identitasnya sendiri. Tidak ada data operator yang saling menimpa —
`operator-memory/backup.sh` selalu menarik lalu menggabungkan.

```
operator-memory/
├── README.md                        ← file ini
├── bootstrap-operator-memory.sh     ← INSTALLER: personalisasi per operator
├── backup.sh                        ← sinkronisasi DUA ARAH (tarik → gabung → push)
├── restore.sh                       ← restore ke ~/.config/opencode/ di mesin baru
└── skill/
    ├── SKILL.md                     ← protokol belajar & rekam (template)
    └── memory.md.start              ← starter memori (template, ber-placeholder)
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
3. Memasang skill + `~/.config/opencode/skills/operator-memory/memory.md` ke
   `~/.config/opencode/skills/operator-memory/`
   (memori yang sudah ada TIDAK ditimpa).
4. Menautkan memori ke `~/.config/opencode/opencode.jsonc` (dibuat bila
   belum ada).
5. Menyalin config ke repo backup, commit + push awal.

**Setelah itu restart opencode.** Agent membuka sesi berikutnya sudah mengenal
operator: membaca `~/.config/opencode/skills/operator-memory/memory.md`,
merekam pembelajaran di checkpoint kerja, lalu menjalankan
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
2. **Sinkron file demi file** (memori, skill, `opencode.jsonc`) — file memori
   dan skill relatif ke `~/.config/opencode/skills/operator-memory/`:
   - hanya lokal berubah → commit + push
   - hanya remote berubah → **adopsi** ke file live lokal
   - keduanya berubah → **merge 3-arah** (`git merge-file`, base + lokal +
     remote); bila konflik, digabung aman tanpa kehilangan data dan ditandai
     `--- SINKRONISASI PERANGKAT LAIN — PERLU DIRAPIKAN MANUAL ---`
3. **Commit + push** hanya bila ada perubahan.

## Restore di mesin baru / fresh install

```bash
git clone git@github.com:<handle>/operator-persona.git ~/.config/operator-persona
~/.config/operator-persona/restore.sh   # salin ke ~/.config/opencode/ (.bak otomatis)
# restart opencode
```

## Syarat minimal

- `git`
- `gh` (untuk membuat repo privat otomatis; bisa dilewati dengan `--local-only`)
- opencode (memuat skill dari `~/.config/opencode/skills/`)
