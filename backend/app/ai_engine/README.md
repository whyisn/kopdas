# Kopi Cerdas — Prototipe Mesin AI (forecast + optimasi stok & lokasi)

> **Semua data di folder ini SIMULASI.** Pola permintaan sengaja ditanam di `generate_data.py`.
> Hasil backtest menunjukkan *metode bekerja pada data yang polanya diketahui*, bukan bukti dampak di lapangan.

## Menjalankan

```bash
pip install pandas numpy scipy scikit-learn matplotlib   # scipy >= 1.9 (milp/HiGHS)
python generate_data.py --weeks 12 --seed 42   # -> data/*.csv
python backtest.py                              # -> results.json
python make_chart.py                            # -> chart_backtest.png
```

Total waktu < 10 detik di laptop biasa.

## Isi

| File | Fungsi |
|---|---|
| `generate_data.py` | Dataset 12 minggu: 4 lokasi Padang, 6 produk, 3 kategori, cuaca, libur, stockout, transaksi per cup (bisa jadi seed DB aplikasi). |
| `engine.py` | `DemandForecaster` (ML + koreksi data tersensor), `optimize_allocation` (MILP), `explain` (alasan teks). |
| `backtest.py` | Uji 3 minggu terakhir: Manual vs Rumus (+10%) vs AI; akurasi forecast vs baseline. |
| `make_chart.py` | Grafik perbandingan untuk slide/proposal. |

## Cara kerja AI (untuk pitch)

1. **Forecast permintaan** per lokasi × kategori × hari — `HistGradientBoostingRegressor` (loss Poisson),
   fitur: hari, akhir pekan, lokasi, kategori, hujan, curah hujan, suhu, libur.
2. **Koreksi permintaan tersensor** — saat stok habis, penjualan < permintaan asli. Model memakai EM sederhana:
   target hari stockout diganti E[D | D ≥ terjual], lalu dilatih ulang.
3. **Optimasi MILP** (scipy `milp`, solver HiGHS) — memilih lokasi yang dibuka (≤ jumlah pegawai) dan jumlah cup
   per kategori, memaksimalkan ekspektasi laba = harga·E[min(D,q)] − HPP·q − biaya lokasi,
   dengan kendala kapasitas gerobak dan kapasitas produksi pusat.
4. **Pengaman confidence** — lokasi dengan histori < 3 hari pada kondisi serupa tidak dibuka otomatis,
   melainkan ditandai *kandidat uji coba*. (Tanpa aturan ini, model sempat mengirim gerobak ke pantai pada
   hari kerja karena ekstrapolasi dari data akhir pekan — dan laba turun.)
5. **Rincian per produk** (`postprocess.split_cups`) — cup per kategori dibagi ke produk mengikuti porsi
   penjualan historis di lokasi itu (digabung dengan porsi global jika histori < 30 cup); total selalu tepat.
6. **Penugasan pegawai** (`postprocess.assign_sellers`) — assignment problem dengan algoritma Hungarian
   (`scipy.optimize.linear_sum_assignment`): biaya = jarak dari posisi terakhir − 0,1 km × hari pengalaman di lokasi (maks. 20).
7. **Penjelasan** — `explain()` menghasilkan alasan terstruktur; LLM opsional hanya memparafrasekan.

## Hasil backtest (data simulasi, 12 Okt – 1 Nov 2026)

| Kebijakan | Laba 3 minggu | Cup sisa | Permintaan tak terlayani |
|---|---|---|---|
| Manual (stok tetap, 3 lokasi tetap) | Rp13,26 jt | 1.251 (28%) | 344 |
| Rumus proposal (minggu lalu +10%) | Rp14,45 jt | 540 (16%) | 661 |
| **AI (forecast + MILP)** | **Rp17,53 jt** | 710 (17%) | 561 |

Akurasi forecast (MAE cup per lokasi-kategori-hari): hari sama minggu lalu 6,29 · rata-rata 4 hari sama 5,59 ·
model ML 5,42 (bias ≈ 0, baseline bias ≈ −3 karena belajar dari penjualan tersensor).

**Catatan jujur:** peningkatan akurasi forecast kecil. Sebagian besar keuntungan datang dari
(a) memindahkan gerobak ke lokasi yang tepat di akhir pekan dan (b) koreksi data stockout, bukan dari model yang
"lebih pintar". Ini justru poin pitch yang kuat dan bisa dipertahankan di depan juri.

## Integrasi ke backend FastAPI

```python
from engine import Config, DemandForecaster, optimize_allocation, explain, to_category_level
model = DemandForecaster(locations).fit(to_category_level(daily_sales_df), weather_df)
fc = model.predict("2026-11-14", weather_df)          # weather_df berisi prakiraan untuk tanggal target
plan = optimize_allocation(fc, Config(n_vendors=3))
return {"rencana": plan.to_dict("records"), "alasan": explain(plan, fc)}
```

Parameter bisnis (harga, HPP, kapasitas, biaya lokasi) ada di `engine.py` (`PRICE`, `HPP`, `Config`) — sesuaikan
dengan angka hasil wawancara pedagang.
