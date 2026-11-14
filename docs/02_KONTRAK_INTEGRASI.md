# KOPICERDAS AI — KONTRAK KERJA BERSAMA
Dokumen pendamping Dokumen Induk v1.1.

## Aturan integrasi yang tidak boleh dilanggar
1. Satu repository dan satu database.
2. Backend adalah sumber kebenaran untuk harga, transaksi, order, pembayaran, reservasi, dan stok.
3. Frontend memanggil API; AI menerima input terstruktur dan mengembalikan output JSON; Integration menyediakan adapter data eksternal.
4. Nama ID stabil: `user_id`, `product_id`, `category_id`, `location_id`, `transaction_id`, `order_id`, `forecast_id`.
5. Tanggal/waktu ISO 8601; tampilan `Asia/Jakarta`.
6. Data real dan simulasi harus dapat dibedakan.
7. Jangan mengubah kontrak tanpa persetujuan Product Lead dan pemberitahuan ke divisi terdampak.

## Definisi transaksi
Walk-in: `payment_method = CASH | QRIS_STATIC`.
Pre-order: `payment_method = QRIS_STATIC`.
Frontend tidak boleh mengirim `total` sebagai nilai final yang dipercaya backend. Backend menghitung dari harga produk yang berlaku.

## Status
`payment_status`: `PENDING | PAID | REJECTED | EXPIRED | REFUNDED`.
`order_status`: `PENDING_PAYMENT | CONFIRMED | PREPARING | READY_FOR_PICKUP | COMPLETED | CANCELLED | EXPIRED`.
Backend menentukan transisi yang sah. Screenshot bukti bayar tidak mengubah status menjadi PAID secara otomatis.

## Aturan stok
- Semua mutasi melalui stock movement.
- Distribusi dan transaksi harus atomik.
- Gunakan idempotency untuk mencegah duplikasi.
- Stok tersedia = stok fisik - stok yang direservasi aktif (jika reservasi diaktifkan).
- Batalkan/expire order harus melepas reservasi.
- Tidak boleh ada stok negatif.

## Contoh payload
### Walk-in
```json
{
  "seller_id": "seller-001",
  "location_id": "loc-001",
  "payment_method": "CASH",
  "items": [{"product_id": "prod-001", "quantity": 2}]
}
```
### Pre-order
```json
{
  "seller_id": "seller-001",
  "location_id": "loc-001",
  "payment_method": "QRIS_STATIC",
  "items": [{"product_id": "prod-001", "quantity": 2}]
}
```
### Forecast request (konseptual)
```json
{
  "target_period": {"start": "2026-11-15", "end": "2026-11-21"},
  "location_ids": ["loc-001"],
  "product_ids": ["prod-001"],
  "data_label": "REAL"
}
```
### AI recommendation (konseptual)
```json
{
  "period": {"start": "2026-11-15", "end": "2026-11-21"},
  "location_id": "loc-001",
  "product_id": "prod-001",
  "predicted_demand": 42,
  "recommended_quantity": 36,
  "confidence": 0.62,
  "data_quality": "LIMITED",
  "rationale": ["Rolling average dari histori tersedia", "Dibatasi stok pusat"],
  "model_version": "baseline-v1",
  "solver_status": "RULE_BASED_FALLBACK",
  "data_label": "SIMULASI"
}
```
Contoh adalah kontrak ilustratif, bukan angka/hasil nyata.

## RACI ringkas
- Product Lead/QA: scope, prioritas, acceptance criteria, kontrak final, QA, demo.
- UI/UX & Frontend: halaman dan interaksi web, konsumsi API, visualisasi.
- Backend: ERD, DB, auth/RBAC, business rules, API, transaksi, stok, order.
- AI/Data: audit data, baseline/forecast, scoring, optimization, backtest, AI JSON.
- Integration: Maps/Places/Routes/Weather adapter, secrets, fallback, deployment.

## Definition of Done bersama
Fitur selesai hanya jika:
- kriteria penerimaan lulus;
- data tidak palsu atau diberi label simulasi;
- otorisasi dan validasi backend berjalan;
- loading/error/empty state ditangani;
- pengujian dijalankan dan hasil dilaporkan;
- dampak kontrak ke divisi lain didokumentasikan.
