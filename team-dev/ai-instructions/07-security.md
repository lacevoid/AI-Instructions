# 07 — Security (Keamanan)

Aturan keamanan bersifat **GLOBAL** dan menjadi area **veto** subagent. Prinsip:
tidak pernah mempercayai input tanpa validasi, tidak pernah menyimpan rahasia di
tempat ter-expose, dan selalu mempertimbangkan siapa yang boleh melakukan apa.

## 1. Aturan dasar (MUST)

- **Validasi input WAJIB server-side** — tidak pernah mempercayai input
  pengguna tanpa validasi (type, format, range, whitelist).
- **Tidak ada password/secret plaintext** di kode, config file yang ter-commit,
  atau log.
- **Autentikasi & otorisasi**: setiap akses ke sumber daya yang terproteksi
  MUST memverifikasi identitas (auth) dan hak akses (authorization) terhadap
  resource tersebut — jangan hanya pada satu layer.
- **Jangan pernah log rahasia/token/query param sensitif**.
- **Escape/sanitize output** untuk mencegah injection sesuai konteks (SQL,
  HTML/JS, command).
- Upload file: validasi tipe, ukuran, dan simpan di luar area publik yang bisa
  dieksekusi (bila berlaku).
- Dependency: jangan tambah package tanpa alasan; audit yang sudah ada
  (`09-tools.md`).

## 2. Area yang selalu memicu security-reviewer

Panggil `security-reviewer` (atau lakukan review keamanan penuh) bila perubahan
menyentuh:

- Auth, session, token, API key, credentials.
- Validasi input baru / perubahan rules validasi.
- Data sensitif: PII, finansial, data kesehatan, data akses.
- Upload/export/import, serialization, deserialization.
- Error handling yang menampilkan jejak internal ke user.
- Perubahan pada boundary sistem (webhook, public API, queue input).

## 3. Error handling & informasi bocor

- MUST NOT menampilkan stack trace / detail internal ke user.
- Gunakan pesan error user-friendly; log detail teknis di sisi server.
- Jangan membedakan respons "user tidak ada" vs "password salah" bila proyek
  memang menghindari user enumeration (ikuti konvensi proyek).

## 4. Peran tim & veto

- Temuan `security-reviewer` bertema di atas bersifat **VETO** (lihat
  `03-team-protocol.md` bagian 5): orchestrator MUST mengakomodasi atau
  mengeskalasi ke operator.
- Orchestrator TIDAK boleh mengesampingkan veto keamanan dengan alasan
  "nanti dulu" tanpa persetujuan operator.

## 5. Canonical snippets

- Pola keamanan nyata proyek (validasi, guard, policy, csrf, auth)
  dikumpulkan verbatim di `12-project-specific/canonical-snippets.md`.
