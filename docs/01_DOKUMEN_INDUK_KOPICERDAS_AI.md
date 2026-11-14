# KOPICERDAS AI — DOKUMEN INDUK PROYEK
**Smart Coffee Network | Hackathon 24 Jam | Versi 1.1**

## 1. Status dan otoritas dokumen
Dokumen ini adalah sumber acuan tunggal (*single source of truth*) untuk lima agen/anggota yang mengerjakan KopiCerdas AI menggunakan Antigravity. Semua prompt divisi wajib mengikuti dokumen ini. Jika instruksi lain bertentangan, dokumen induk dan keputusan Product Lead yang berlaku.

**Prinsip kerja:** satu repository, satu aplikasi web, satu database utama, satu kontrak API, satu definisi status bisnis, dan satu sumber kebenaran transaksi/stok.

## 2. Tujuan produk
KopiCerdas AI adalah sistem pengelolaan jaringan penjual kopi gerobakan yang membantu Owner mengelola produk, stok, distribusi, penjualan, dan keputusan operasional; membantu Seller menjalankan penjualan; serta membantu Customer menemukan seller dan melakukan pembelian langsung atau pemesanan terlebih dahulu.

Dua keluaran kecerdasan utama:
1. **Location Intelligence:** rekomendasi titik jualan berdasarkan data yang tersedia dan faktor yang dapat dijelaskan.
2. **Inventory Intelligence:** prediksi permintaan dan rekomendasi jumlah/alokasi stok berdasarkan histori penjualan, stok, kapasitas, dan batas operasional.

Bukan sekadar dashboard atau mockup. Fitur yang ditampilkan sebagai berfungsi harus terhubung ke backend dan database. Jika memakai data contoh, tampilkan label **SIMULASI** dengan jelas.

## 3. Keputusan produk yang sudah dikunci
- Target pengguna: **Owner, Seller, Customer**.
- Platform: **web app responsif** sebagai produk utama; struktur dapat disiapkan agar kelak bisa dipasang sebagai PWA. Jangan membuat aplikasi native terpisah.
- Customer dapat melakukan dua jenis pembelian:
  - **Walk-in/direct purchase:** datang ke seller, memilih produk, lalu membayar tunai atau QRIS statis.
  - **Online pre-order:** memilih seller dan produk di web, membuat pesanan lebih dahulu, lalu membayar QRIS statis.
- Pembayaran walk-in: `CASH` atau `QRIS_STATIC`.
- Pembayaran pre-order: `QRIS_STATIC`.
- QRIS yang dipakai adalah **QRIS statis**, bukan dynamic QRIS.
- Pembayaran QRIS statis online harus terintegrasi dengan PJP/acquirer yang menyediakan notifikasi transaksi real-time, webhook, API inquiry, atau API/ekspor transaksi yang dapat diproses otomatis. Jangan mengasumsikan semua penyedia menyediakan webhook; validasi kapabilitas provider yang dipilih. Tidak boleh ada verifikasi manual oleh Owner/Seller sebagai alur normal.
- Customer dapat melihat seller/lokasi, produk, harga, ketersediaan, dan status pesanan yang relevan.
- Seller hanya boleh melihat data dan stok miliknya sendiri.
- Owner memiliki akses pengelolaan menyeluruh.
- Tidak menggunakan CCTV, OpenCV, YOLO, computer vision, atau object tracking.
- Google Maps/Places/Routes dapat digunakan sesuai API, izin, kuota, dan ketersediaan. Traffic kendaraan bukan jumlah pejalan kaki atau calon pembeli.
- Weather hanya fitur pendukung jika tersedia; bukan ketergantungan core flow.
- Semua waktu disimpan konsisten (UTC atau ISO 8601 dengan offset yang disepakati) dan ditampilkan dalam zona `Asia/Jakarta`.
- Semua kunci API disimpan di environment/backend, tidak ditanam di frontend atau repository publik.

## 4. Batasan dan status fitur
### P0 — harus berfungsi end-to-end
1. Login dan role Owner/Seller; Customer dapat menjelajah dan melakukan alur order sesuai desain autentikasi yang dipilih.
2. Master produk, kategori, harga, dan status aktif.
3. Stok pusat, stok per seller, mutasi stok, dan distribusi.
4. Transaksi walk-in Seller: item, kuantitas, total, metode bayar CASH/QRIS_STATIC, dan pengurangan stok satu kali.
5. Customer discovery: daftar/peta seller, produk, harga, ketersediaan.
6. Pre-order: buat order, detail item, seller tujuan, status order, status pembayaran.
7. Owner sales analytics dasar.
8. Peta lokasi dan kandidat lokasi dengan sumber data yang jelas atau seed data berlabel simulasi.
9. Forecast baseline dan rekomendasi stok/lokasi yang dapat dijelaskan; fallback rule-based bila model/solver belum siap.
10. Proteksi role, validasi, error/loading/empty state, seed data dan demo yang dapat diulang.

### P1 — dikerjakan setelah P0 stabil
- Forecast model lebih lanjut dan backtest.
- MILP untuk optimasi alokasi bila variabel, objective, dan constraints tersedia.
- Weather API.
- Verifikasi pembayaran melalui provider resmi jika kredensial dan dukungan benar-benar tersedia.
- Notifikasi real-time, chat, loyalty, promo, dan fitur tambahan lainnya.

### P2 — tidak dikerjakan kecuali semua P0/P1 selesai
- Fitur tambahan yang tidak diperlukan untuk alur demo inti.
- Integrasi yang tidak punya akses API resmi atau tidak bisa diverifikasi.

Jangan mengorbankan konsistensi transaksi, stok, order, dan keamanan untuk mengejar banyak fitur.

## 5. Persona dan hak akses
### Owner
- Mengelola produk, kategori, harga, seller, lokasi, stok pusat, distribusi, dan konfigurasi QRIS statis.
- Melihat seluruh transaksi, order, pembayaran, analitik, dan mutasi.
- Memverifikasi pembayaran pre-order jika menggunakan prosedur manual.
- Melihat peta, forecast, rekomendasi lokasi, dan rekomendasi stok.
- Menyetujui rekomendasi sebagai rencana distribusi; rekomendasi AI tidak boleh mengubah stok otomatis tanpa aksi/aturan eksplisit.

### Seller
- Melihat profil dan lokasi jualannya sendiri.
- Melihat stok miliknya sendiri dan riwayat mutasi yang terkait.
- Mencatat penjualan walk-in dan metode pembayaran.
- Melihat dan memproses order yang ditujukan kepadanya.
- Tidak dapat mengakses stok, transaksi, order, atau data privat seller lain.
- Tidak boleh mengubah status pembayaran menjadi PAID tanpa otorisasi yang ditetapkan.

### Customer
- Menjelajah seller, lokasi, produk, harga, dan ketersediaan.
- Melakukan pembelian langsung dengan datang ke seller (informasi lokasi/jam/ketersediaan).
- Membuat pre-order, memilih seller, item dan kuantitas, melihat ringkasan dan instruksi pembayaran QRIS statis.
- Melihat status order miliknya sendiri.
- Tidak dapat melihat data internal seller, pelanggan lain, analitik Owner, atau rekomendasi AI internal.

## 6. Alur bisnis kanonis
### A. Owner
Kelola produk/kategori → kelola stok pusat → distribusikan stok ke seller → pantau transaksi dan order → lihat analitik → jalankan forecast/scoring/optimasi → tinjau alasan dan kualitas data → setujui rekomendasi distribusi.

### B. Seller — walk-in
Login → buka status jualan/lokasi → lihat stok sendiri → pilih produk dan kuantitas → pilih CASH atau QRIS_STATIC → konfirmasi transaksi → backend memvalidasi stok dan harga → transaksi tersimpan → stok berkurang tepat satu kali → laporan penjualan diperbarui.

### C. Customer — direct discovery
Buka web → cari/lihat seller pada peta/daftar → lihat detail seller, produk dan ketersediaan → datang ke lokasi → transaksi diselesaikan oleh Seller. Customer discovery tidak boleh mengurangi stok sebelum transaksi benar-benar dicatat.

### D. Customer — online pre-order
Buka web → pilih seller → pilih produk/kuantitas → backend memeriksa ketersediaan → buat order → sistem menahan/reservasi stok hanya jika mekanisme reservasi diaktifkan dan berhasil secara atomik → tampilkan total dan QRIS statis merchant/seller yang sesuai → status pembayaran `PENDING` → pelanggan melakukan pembayaran di aplikasi bank/e-wallet → pelanggan mengirim bukti jika prosedur manual digunakan → Owner/role berwenang memverifikasi → status pembayaran menjadi `PAID` hanya setelah bukti diverifikasi → order diproses seller → siap diambil → selesai.

**Penting:** bukti gambar/screenshot bukan bukti pembayaran otomatis. Jangan membuat auto-verification palsu. Jika tidak ada proses verifikasi yang siap, pertahankan `PENDING` dan tampilkan instruksi yang jujur. Order yang kedaluwarsa/dibatalkan harus melepas reservasi stok bila reservasi sempat dibuat.

## 7. Aturan QRIS statis dan pembayaran
- QRIS statis disimpan sebagai konfigurasi merchant/seller (misalnya image/file reference dan identitas merchant yang ditampilkan), bukan dibuat ulang per transaksi.
- Jangan mengubah nominal atau menambahkan order ID ke QRIS statis kecuali provider/format resmi memang mendukung dan sudah diverifikasi.
- Walk-in: CASH atau QRIS_STATIC; Seller mencatat metode yang dipakai. Untuk QRIS, status pembayaran hanya PAID jika Seller mengonfirmasi penerimaan sesuai prosedur operasional yang disepakati.
- Pre-order: QRIS_STATIC saja. Status awal `PENDING`; pembayaran perlu diverifikasi manual oleh role berwenang, kecuali kelak ada integrasi resmi yang benar-benar tersedia.
- Pisahkan `order_status` dan `payment_status`.
- Jangan menampilkan status `PAID`, `SUCCESS`, atau `LUNAS` berdasarkan klik tombol pelanggan, unggah gambar saja, atau respons frontend.
- Simpan `payment_method`, `payment_status`, `verified_by`, `verified_at`, `payment_reference` (opsional), dan `proof_asset_url` (opsional).
- Jangan simpan data sensitif kartu/rekening pelanggan.
- Jika QRIS merchant belum tersedia di environment, tampilkan status konfigurasi belum tersedia dan jangan mengganti dengan QR palsu.

Status minimum:
- `payment_status`: `PENDING`, `PAID`, `REJECTED`, `EXPIRED`, `REFUNDED` (gunakan subset yang benar-benar diimplementasikan).
- `order_status`: `PENDING_PAYMENT`, `CONFIRMED`, `PREPARING`, `READY_FOR_PICKUP`, `COMPLETED`, `CANCELLED`, `EXPIRED`.
- Definisikan transisi status di backend; frontend hanya menampilkan dan meminta aksi yang diizinkan.

### Integrasi pembayaran QRIS statis — aturan implementasi
- Gunakan QRIS MPM Statis yang tetap (open payment); pelanggan memasukkan nominal sesuai total order.
- Integrasi harus memakai kanal resmi PJP/acquirer: webhook/callback, API inquiry, API transaksi, atau mekanisme notifikasi/rekonsiliasi yang memang disediakan provider.
- Jangan menganggap setiap provider menyediakan webhook. Integration Engineer wajib menguji akses, format payload, autentikasi, signature, retry, settlement/transaction status, dan batasan API.
- Cocokkan transaksi menggunakan kombinasi data yang tersedia: merchant ID/NMID, nominal tepat, status sukses, waktu transaksi, transaction reference/RRN, dan metadata lain yang disediakan provider.
- QR statis umumnya tidak membawa order ID unik. Jika dua order memiliki merchant dan nominal sama dalam jendela waktu yang sama dan provider tidak memberi referensi yang cukup untuk membedakannya, jangan auto-assign secara spekulatif. Tandai sebagai `UNMATCHED/AMBIGUOUS` untuk rekonsiliasi sistem/penanganan exception, bukan verifikasi manual normal.
- Terapkan idempotency pada event provider; callback berulang tidak boleh menggandakan konfirmasi atau mengubah stok dua kali.
- Validasi signature/token, amount, merchant, currency, status transaksi, dan provider reference. Simpan raw event secara aman untuk audit tanpa menyimpan rahasia.
- Setelah cocok: `payment_status=PAID`; order otomatis `CONFIRMED` dan Seller menerima notifikasi/order baru. Jika tidak cocok/gagal: jangan konfirmasi.
- Buat job rekonsiliasi berkala jika provider menyediakan API transaksi/inquiry, agar notifikasi yang terlambat/terlewat dapat dipulihkan.
- Jika provider pilihan belum mendukung kanal integrasi, fitur auto-confirm belum dapat dinyatakan selesai. Jangan membuat polling ke aplikasi mobile merchant, membaca SMS pribadi, scraping dashboard, atau mengandalkan screenshot.

## 8. Arsitektur teknis acuan
Arsitektur logis:
- Web frontend responsif: Owner, Seller, Customer (role-based navigation).
- Backend API sebagai pusat aturan bisnis dan otorisasi.
- Database relasional sebagai sumber kebenaran.
- AI service/module yang dipanggil backend dan menghasilkan JSON terstruktur.
- External integration adapter untuk Maps/Places/Routes dan Weather jika dipakai.
- File storage untuk aset yang memang diperlukan (misalnya QRIS image dan bukti transfer) dengan kontrol akses.

Manual book mengusulkan **FastAPI** untuk backend. Gunakan FastAPI kecuali repository yang sudah ada menetapkan stack berbeda dan Product Lead menyetujuinya. Database relasional; pilih satu DB yang bisa dijalankan stabil di environment tim. Jangan mengganti stack secara sepihak. Frontend stack mengikuti repository yang sudah ada; jangan membuat dua frontend atau dua backend paralel.

### Prinsip integrasi
- Satu repository GitHub dan satu project board.
- Satu branch per fitur; commit kecil; review singkat.
- Backend/database adalah sumber kebenaran transaksi, harga, order, reservasi, dan stok.
- Frontend tidak menghitung ulang forecast, tidak mengubah stok lokal sebagai sumber kebenaran.
- AI tidak menulis langsung ke tabel transaksi atau inventory.
- Semua perubahan schema/API harus diumumkan dan disetujui sebelum merge.
- Setiap fitur memiliki PIC, dependency, acceptance criteria, status, dan evidence.

## 9. Model data minimum (nama final dikunci bersama Backend + Product Lead)
Entitas yang direkomendasikan:
- `users`: id, name, email/username, password_hash, role, status, created_at.
- `categories`: id, name, status.
- `products`: id, category_id, name, description, price, status.
- `locations`: id, seller_id (nullable untuk kandidat), name, latitude, longitude, address, source_type, is_active.
- `inventory`: id, product_id, owner_type/owner_id atau location/seller scope, quantity, reserved_quantity, updated_at.
- `stock_movements`: id, product_id, from_scope, to_scope, quantity, movement_type, reference_type, reference_id, actor_id, created_at, notes.
- `transactions`: id, seller_id, location_id, total, payment_method, payment_status, created_at, idempotency_key.
- `transaction_items`: id, transaction_id, product_id, quantity, unit_price, subtotal.
- `orders`: id, customer_id, seller_id, location_id, order_number, subtotal, total, order_status, payment_method, payment_status, expires_at, created_at, updated_at.
- `order_items`: id, order_id, product_id, quantity, unit_price, subtotal.
- `payment_events`: id, order_id/transaction_id, submitted_by, proof_asset_url, verification_status, verified_by, verified_at, notes.
- `ai_forecasts`/`ai_recommendations`: period, location/product/category references, predicted_demand, recommended_quantity, confidence/data_quality, rationale, model_version, data_label, created_at.
- `external_observations`: source, location/coordinates, observed_at, metric, value, unit, data_label.

Nama kolom dan normalisasi final harus ditetapkan sekali pada ERD/API contract sebelum implementasi paralel. Jangan membuat nama field berbeda antar divisi.

## 10. Kontrak API minimum
Backend wajib menerbitkan OpenAPI/Swagger dan contoh request/response. Endpoint berikut adalah target konseptual; sesuaikan prefix/versi dengan repository tetapi jangan mengubah semantik tanpa persetujuan.

- `POST /auth/login`
- `GET /auth/me`
- `GET/POST /products`; `PATCH /products/{id}`
- `GET/POST /categories`
- `GET /inventory`; `GET /inventory/movements`
- `POST /inventory/distributions`
- `POST /transactions`; `GET /transactions`
- `GET /analytics/sales`
- `GET /locations`; `POST /locations`; `GET /locations/candidates`
- `GET /customer/sellers`; `GET /customer/sellers/{id}/products`
- `POST /customer/orders`; `GET /customer/orders/{id}`
- `POST /orders/{id}/payment-proof` (jika upload bukti dipakai)
- `POST /webhooks/payments/{provider}` atau endpoint callback sesuai spesifikasi provider; endpoint internal untuk rekonsiliasi/inquiry bila provider mendukung.
- `PATCH /orders/{id}/status` (transisi tervalidasi)
- `POST /ai/forecast`; `POST /ai/optimize`; `GET /ai/recommendations`
- `GET /health`

Contoh payload transaksi walk-in:
```json
{
  "seller_id": "seller-001",
  "location_id": "loc-001",
  "payment_method": "CASH",
  "items": [{"product_id": "prod-001", "quantity": 2}]
}
```

Contoh payload pre-order:
```json
{
  "seller_id": "seller-001",
  "location_id": "loc-001",
  "payment_method": "QRIS_STATIC",
  "items": [{"product_id": "prod-001", "quantity": 2}]
}
```

Contoh response order:
```json
{
  "order_id": "ord-001",
  "order_status": "PENDING_PAYMENT",
  "payment_method": "QRIS_STATIC",
  "payment_status": "PENDING",
  "total": 36000,
  "qris_asset_url": "configured-merchant-qris-asset",
  "expires_at": null,
  "data_label": "REAL"
}
```
Nilai contoh di atas hanya contoh kontrak, bukan data transaksi nyata. Jangan hardcode URL QRIS atau menganggap `expires_at` harus null; tetapkan kebijakan setelah keputusan operasional.

## 11. Aturan stok dan konsistensi
- Semua mutasi stok dicatat sebagai stock movement.
- Distribusi stok: stok pusat turun dan stok seller naik dalam satu transaksi database atomik.
- Penjualan: validasi harga, kuantitas, kepemilikan seller, dan stok; simpan header/detail dan kurangi stok dalam satu transaksi database.
- Cegah double-submit dengan idempotency key atau mekanisme setara.
- Stok tidak boleh negatif.
- Transaksi gagal/batal tidak boleh mengurangi stok.
- Pre-order hanya mengurangi `available stock` melalui reservasi atomik bila fitur reservasi aktif. Jangan mengurangi stok dua kali saat order selesai.
- Pembatalan/kedaluwarsa harus melepaskan reservasi yang aktif.
- Jangan pernah mempercayai harga/total dari browser; hitung ulang di backend dari harga produk yang berlaku dan simpan snapshot `unit_price`.

## 12. AI dan Location Intelligence
### Forecasting
Target: kuantitas terjual per produk/kategori, lokasi, dan tanggal/periode target.
Input minimum: `date`, `location_id`, `product_id`, `category_id`, `quantity_sold`; opsional `stockout_flag`, `weather_code`, `price`.
- Audit duplikasi, data kosong, refund/cancel, timestamp, kategori, lokasi, dan stockout.
- Mulai dari baseline naive same-day/rolling average atau weighted moving average.
- Gunakan time-based split, bukan random split.
- Penjualan ketika stok habis adalah demand tersensor; tandai dan jangan dianggap sebagai permintaan penuh.
- Evaluasi MAE/WAPE atau metrik relevan dan bandingkan dengan baseline.
- Data minim harus menghasilkan confidence/kualitas data rendah dan penjelasan keterbatasan.

### Location scoring
Faktor dapat mencakup demand historis, POI, aksesibilitas, traffic kendaraan jika tersedia, dan kecocokan produk. Traffic kendaraan tidak sama dengan footfall. Jangan klaim jumlah calon pembeli dari data traffic kendaraan.
- Simpan sumber, waktu pengambilan, koordinat, dan nilai.
- Lokasi baru tanpa histori diberi label **ESTIMASI AWAL**.
- Skor wajib disertai faktor dan alasan, bukan angka tanpa penjelasan.

### Inventory optimization
- MILP hanya jika input, objective, dan constraints sudah jelas dan feasible.
- Objective dapat mempertimbangkan estimasi margin dikurangi biaya operasional/distribusi.
- Constraints dapat mencakup stok pusat, kapasitas seller/gerobak, demand, jumlah lokasi, dan kapasitas produksi.
- Jika solver tidak tersedia, lambat, atau infeasible, tampilkan status dan fallback rule-based yang transparan.
- AI menghasilkan rekomendasi; Owner menyetujui tindakan distribusi.

Output AI minimum: periode, lokasi, produk/kategori, prediksi demand, jumlah stok rekomendasi, skor lokasi, confidence/kualitas data, alasan/faktor, status model/solver, waktu proses, versi, label REAL/SIMULASI.

## 13. External integrations
- Integration Engineer memvalidasi endpoint, field, lisensi, kuota, dan biaya.
- Google Maps/Places/Routes hanya dipakai sesuai layanan yang benar-benar tersedia.
- Jangan menganggap Popular Times tersedia sebagai field numerik API umum.
- Weather opsional.
- API key berada di environment backend.
- Timeout, quota, invalid key, dan data kosong harus memiliki fallback yang tidak merusak aplikasi.
- Marker/POI seed yang disimulasikan harus diberi label SIMULASI.
- Jika integrasi gagal, jangan mengarang nilai seolah-olah live.

## 14. UI/UX dan kualitas produk
- Antarmuka profesional, konsisten, responsif, dan tidak tampak seperti template dashboard generik hasil AI.
- Gunakan komponen design system yang konsisten; hierarki informasi jelas; tabel/form/chart sesuai konteks.
- Sediakan loading, empty, error, success, validation, dan permission-denied states.
- Jangan menampilkan tombol yang tidak berfungsi atau angka dummy tanpa label.
- Customer flow dibuat sederhana: temukan seller → pilih produk → direct discovery atau pre-order → instruksi pembayaran → status order.
- Seller flow fokus pada penjualan cepat dan stok.
- Owner flow fokus pada kontrol operasional dan keputusan.
- Semua aksi harus benar-benar memanggil backend; jangan menyamarkan mock sebagai fitur live.

## 15. QA wajib
- Seller tidak dapat membaca data seller lain.
- Owner dapat mengelola data lintas seller.
- Transaksi valid mengurangi stok tepat satu kali.
- Double submit tidak menggandakan transaksi.
- Transaksi gagal/batal tidak mengurangi stok.
- Stok tidak pernah negatif.
- Distribusi mengurangi stok pusat dan menambah stok seller sesuai jumlah.
- Pre-order tidak membuat stok terjual dua kali; reservasi dilepas saat batal/expired.
- Customer hanya dapat melihat order miliknya.
- Pembayaran menjadi PAID otomatis hanya dari notifikasi/API transaksi resmi yang tervalidasi; upload bukti bukan sumber konfirmasi.
- Hanya backend payment integration yang dapat mengubah status ke PAID berdasarkan transaksi PJP/acquirer tervalidasi.
- Grafik analytics cocok dengan agregasi transaksi.
- Forecast mencantumkan periode, lokasi, label data dan kualitas data.
- Lokasi tanpa histori diberi label estimasi awal.
- MILP feasible atau fallback/status infeasible dijelaskan.
- API eksternal gagal tidak membuat aplikasi crash.
- Semua data simulasi diberi label SIMULASI.
- Demo dapat diulang menggunakan seed data yang sama.

## 16. Jadwal 24 jam dan checkpoint
Ikuti kerangka playbook:
- 00:00–00:30 kickoff, tujuan, role, aturan.
- 00:30–01:30 PRD ringkas, user flow, P0/P1.
- 01:30–02:30 ERD/API contract, wireframe, dataset schema, API inventory.
- 02:30–04:00 setup repository, environment, DB, frontend shell, sample data.
- 04:00–06:00 auth/role, master produk, desain inti, data cleaning.
- 06:00–08:00 inventory/stock movement, UI stok, baseline sales.
- 08:00–10:00 transaksi, analytics API/chart, Maps/marker/POI.
- 10:00–11:30 forecasting, location scoring, integrasi awal.
- 11:30–12:00 checkpoint dan blocker.
- 12:00–12:30 coffee break.
- 12:30–14:30 MILP, constraints, stock allocation UI/API.
- 14:30–16:00 weather/fallback dan integrasi eksternal.
- 16:00–18:00 integrasi end-to-end Owner/Seller dan transaksi-stok.
- 18:00–19:30 backtest dan validasi skor/hasil MILP.
- 19:30–21:00 bug fixing, role security, error/loading state.
- 21:00–22:00 deployment, seed data, akun demo, dokumentasi.
- 22:00–23:00 rehearsal demo dan pitch.
- 23:00–24:00 final QA dan feature freeze/serah terima.

Checkpoint CP1 jam 02; CP2 jam 04; CP3 jam 08; CP4 jam 12; CP5 jam 16; CP6 jam 19:30; feature freeze jam 21; final jam 24.

## 17. Demo story
1. Owner login dan melihat dashboard.
2. Owner memeriksa produk/kategori dan stok pusat.
3. Owner mendistribusikan stok ke Seller A dan Seller B.
4. Seller A membuka lokasi dan mencatat transaksi walk-in (tunai/QRIS statis).
5. Customer membuka web, menemukan seller, melihat produk dan membuat pre-order.
6. Customer melihat instruksi QRIS statis; pembayaran tetap PENDING sampai diverifikasi.
7. Role berwenang memverifikasi pembayaran; Seller memproses order sampai READY_FOR_PICKUP/COMPLETED.
8. Dashboard Owner memperlihatkan penjualan, order, dan perubahan stok.
9. Owner melihat Maps dan membandingkan kandidat lokasi.
10. Owner membuka sales analytics, forecast dan rekomendasi stok/lokasi.
11. Owner meninjau alasan, confidence, label real/simulasi, lalu menyetujui rencana distribusi.

## 18. Aturan kerja AI/Antigravity
Setiap agen wajib:
1. Membaca dokumen induk ini dan memeriksa repository sebelum mengubah file.
2. Tidak mengarang struktur folder, endpoint, tabel, environment variable, API key, atau layanan yang belum ada.
3. Mengidentifikasi file yang akan dibuat/diubah dan dependency sebelum coding.
4. Memakai kontrak bersama; jika ada field yang kurang, mengajukan usulan ke Product Lead/Backend sebelum mengimplementasikan versi sendiri.
5. Tidak mengubah file di luar area tanggung jawab tanpa koordinasi.
6. Tidak menghapus atau menimpa pekerjaan anggota lain.
7. Tidak membuat mock sebagai data live; semua mock/seed diberi label.
8. Menjalankan lint/test/build yang tersedia dan melaporkan hasil sebenarnya.
9. Menyampaikan status dengan format DONE / NEXT / BLOCKER / EVIDENCE.
10. Jika ada ketidakjelasan, berhenti pada keputusan yang belum disepakati dan ajukan satu pertanyaan terarah; jangan menebak.

**Format laporan akhir agen**
- Files created/modified
- Implemented behavior
- API/schema assumptions
- Commands/tests run and actual results
- Known limitations
- Integration notes for other roles
- DONE / NEXT / BLOCKER / EVIDENCE
