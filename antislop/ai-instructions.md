# AI INSTRUCTION SYSTEM — antislop FILTER (CONSTITUTION)

> [!CRITICAL]
> antislop adalah **filter, bukan style guide**. Ia menghentikan "AI slop" generik
> pada UI, copywriting, dan kode yang dihasilkan AI — tanpa memaksakan warna, font,
> atau layout tertentu. Arah visual (keindahan) adalah tanggung jawab `DESIGN.md`
> milik proyek, bukan tanggung jawab antislop. Filter yang bekerja tanpa arah akan
> menghasilkan output monoton, bukan gagal (R-37).

## Apa yang dilakukan antislop

- **38 aturan wajib** (R-01 sampai R-38) dalam tiga tier: **Hard Gate** (mutlak),
  **Purpose-Gate** (teknik boleh dipakai, alasan wajib), **Quality Locks** (konsistensi).
- **Liveliness Toolkit**: tiga dial (ENERGY / RHYTHM / MOTION) + Design Read, supaya
  hasil terasa hidup dan spesifik — bukan sekadar "bersih".
- **Delivery Gate**: laporan wajib PASS/FAIL dalam empat blok, dijalankan sebelum
  apa pun dianggap selesai.
- **Skill aditif**, satu per concern — agent hanya memuat yang diperlukan tugas.

## Dua mode penggunaan

Di awal sesi, tanyakan ke user (dalam bahasa percakapan) kapan antislop berlaku:

1. **DURING** — aturan diterapkan saat menulis (mencegah slop sejak awal), diakhiri
   Delivery Gate. Dipakai saat membangun UI baru.
2. **AFTER** — audit hasil jadi: daftar temuan bernomor (mengutip R-XX + alasan),
   user memilih nomor mana yang diperbaiki, lalu laporan tindak lanjut.

Tiga langkah berjalan di KEDUA mode, apa pun yang memimpin sesi: selesaikan arah
sebelum membangun (R-37), tanya sebelum membuat aset (R-23), dan jalankan Delivery
Gate sebelum menyerahkan hasil.

## Teknik yang ditolak tanpa tujuan

Antislop menolak teknik yang tidak punya tujuan: gradient, ikon khusus, tipografi
dekoratif, glow/glassmorphism/shadow berlebihan, badge/eyebrow di atas headline,
animasi tanpa fungsi, testimoni dan angka palsu, FAQ yang mengulang halaman,
navigasi umum seperti "Modern | Clean | Next-Gen", dan klaim tanpa bukti.
Semua itu BOLEH jika ada alasan nyata — itulah gunanya Purpose-Gate.

## Aturan sumber (rules live in skills, bukan di sini)

Aturan lengkap R-01 sampai R-38, Liveliness Toolkit, Functional Patterns, dan
Delivery Gate ada di skill inti. Jangan menduplikasi aturan di file ini.

## Skill

| Skill | Memuat file | Untuk pekerjaan |
|---|---|---|
| inti | `.opencode/skills/antislop/SKILL.md` | selalu aktif — filter inti |
| UI | `.opencode/skills/antislop-ui/SKILL.md` | layout, warna, komponen, dekorasi, motion |
| Copywriting | `.opencode/skills/antislop-copywriting/SKILL.md` | headline, CTA, tone, angka palsu, markdown hygiene |
| Human | `.opencode/skills/antislop-human/SKILL.md` | contrast, keyboard, focus, states |
| Layout mobile | `.opencode/skills/antislop-layoutmobile/SKILL.md` | responsive reflow, breakpoints, tap targets |
| Code comments | `.opencode/skills/antislop-code/SKILL.md` | komentar kode: buang slop, jaga yang berharga |

Pilih sesuai pekerjaan: UI → `antislop-ui`; copy → `antislop-copywriting`;
orang → `antislop-human`; responsive → `antislop-layoutmobile`;
komentar kode → `antislop-code`. Lebih dari satu jenis pekerjaan → muat beberapa.
Tidak ada yang cocok → core saja sudah merupakan filter lengkap.

## Delivery Gate (wajib sebelum deliver)

Empat blok, masing-masing PASS/FAIL:

1. **Hard Gate** — tidak ada pelanggaran mutlak (R-02, R-03, R-17, R-18, R-23–R-28,
   R-32–R-38).
2. **Purpose-Gate** — setiap teknik terlarang yang dipakai punya alasan tertulis.
3. **Liveliness** — ENERGY / RHYTHM / MOTION diisi sadar, bukan default.
4. **Craftsmanship & Quality Locks** — konsistensi (R-05, R-11, R-15, R-16, R-20,
   R-21, R-29–R-31).

## Catatan jujur

antislop tidak mempercantik dirinya sendiri — `DESIGN.md` milik proyeklah tempat
keindahan dan arah berasal. Hasil yang monoton berarti arahnya hilang, bukan
filternya gagal. Jangan pernah mengarang konten contoh untuk `DESIGN.md`.

## Referensi cepat

- Sumber aturan: `.opencode/skills/antislop/SKILL.md` (core) + skill per concern.
- Mode: DURING / AFTER — tanya user dulu.
- Pra-kirim: Delivery Gate 4 blok.
- Arah: `DESIGN.md` milik proyek (tanya user bila tidak ada).
