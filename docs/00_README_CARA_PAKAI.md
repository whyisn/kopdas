# Paket Antigravity KopiCerdas AI

## Isi paket
1. `01_DOKUMEN_INDUK_KOPICERDAS_AI.md` — acuan tunggal proyek.
2. `02_KONTRAK_INTEGRASI.md` — aturan data, API, status dan stok.
3. `PROMPT_1_PRODUCT_LEAD_QA.md`
4. `PROMPT_2_UI_UX_FRONTEND.md`
5. `PROMPT_3_BACKEND_DEVELOPER.md`
6. `PROMPT_4_AI_DATA_ENGINEER.md`
7. `PROMPT_5_INTEGRATION_ENGINEER.md`

## Cara memasukkan ke Antigravity
1. Buat satu repository GitHub bersama.
2. Letakkan dokumen induk dan kontrak integrasi di root repository, misalnya folder `/docs`.
3. Pastikan kelima anggota menggunakan repository dan versi dokumen yang sama.
4. Setiap anggota membuka Antigravity pada repository yang sama.
5. Tempel prompt sesuai peran masing-masing. Lampirkan/rujuk dua dokumen bersama.
6. Minta agen membaca dokumen dan melakukan audit repository dahulu. Jangan izinkan semua agen langsung membuat struktur proyek masing-masing.
7. Product Lead menetapkan kontrak final setelah Backend mengusulkan ERD/API awal. Semua divisi menyetujui sebelum implementasi paralel.
8. Gunakan branch terpisah dan pull request; jangan mengedit file yang sama tanpa koordinasi.

## Pembagian lima orang
- Anggota 1: Product Lead / QA
- Anggota 2: UI/UX & Frontend
- Anggota 3: Backend Developer
- Anggota 4: AI / Data Engineer
- Anggota 5: Integration Engineer

## Penting
Prompt bukan pengganti keputusan manusia. Jika repository yang ada berbeda dari asumsi prompt, agen wajib melaporkan perbedaan dan meminta keputusan, bukan membuat proyek kedua. Jangan menaruh API key, password, token, atau QRIS merchant privat ke prompt publik/repository.


## Koreksi pembayaran QRIS statis (v1.2)
Kebutuhan produk: tidak ada verifikasi manual. Backend harus mengonfirmasi pembayaran otomatis dari notifikasi/API transaksi resmi PJP/acquirer. QRIS statis tetap satu QR yang digunakan berulang; customer memasukkan nominal. Karena QR statis tidak selalu membawa order ID, pencocokan harus memakai merchant ID, nominal, waktu, transaction reference/RRN dan data provider yang tersedia. Transaksi ambigu tidak boleh dipasangkan secara spekulatif.

Sebelum coding integrasi, Product Lead dan Integration Engineer wajib memastikan provider QRIS yang akan digunakan dan akses API/notifikasinya. Jangan mengklaim auto-confirm jika akses provider belum tersedia.
