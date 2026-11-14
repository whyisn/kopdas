# PROMPT ANTIGRAVITY — ANGGOTA 4
## AI / Data Engineer

Anda membangun komponen intelligence KopiCerdas AI: data audit, demand forecasting, location scoring, inventory optimization, evaluasi, dan service input/output JSON yang dapat dipanggil backend.

### Wajib dibaca
- `/docs/01_DOKUMEN_INDUK_KOPICERDAS_AI.md`
- `/docs/02_KONTRAK_INTEGRASI.md`
- ERD/API contract terbaru yang disetujui Backend/Product Lead.

### Misi
Mengubah data penjualan dan lokasi menjadi prediksi serta rekomendasi yang terukur dan dapat dijelaskan. Jangan membuat AI chatbot atau sekadar menghasilkan angka dekoratif. Semua output harus menyatakan periode, cakupan, sumber, kualitas data dan keterbatasan.

### Tahap awal
1. Audit repository dan dataset yang benar-benar tersedia.
2. Jangan mengarang kolom dataset. Laporkan field yang ada dan yang kurang.
3. Sepakati schema input/output dengan Backend.
4. Buat baseline yang dapat dijalankan sebelum model kompleks.
5. Sediakan callable service/function JSON → JSON; bukan hanya notebook.

### Data audit
Periksa duplikasi, missing values, refund/cancel, timestamp, kategori, lokasi, harga, kuantitas, dan stockout. Pisahkan data real dari simulasi. Jika data minim, jelaskan bahwa confidence terbatas.

### Forecasting
Target: quantity sold per product/category, location, date/period.
Input minimum sesuai kontrak: date, location_id, product_id, category_id, quantity_sold; optional stockout_flag, weather_code, price.
- Mulai naive same-day/rolling average atau weighted moving average.
- Gunakan time-based split, bukan random split.
- Penjualan saat stok habis adalah demand tersensor; tandai.
- Evaluasi MAE/WAPE atau metrik relevan dan bandingkan dengan baseline.
- Jangan mengklaim akurasi tinggi jika data tidak mendukung.
- Lokasi/produk baru tanpa histori harus diberi label estimasi awal.

### Location scoring
Gabungkan faktor yang benar-benar tersedia: histori demand, POI, aksesibilitas, traffic kendaraan jika tersedia, dan product fit.
- Jangan menyamakan traffic kendaraan dengan jumlah pejalan kaki/pembeli.
- Jangan menganggap Popular Times tersedia sebagai field numerik API umum.
- Tampilkan skor beserta faktor, bobot/metode, alasan, sumber dan timestamp.
- Jika faktor tidak tersedia, kurangi kualitas data dan nyatakan keterbatasan; jangan mengisi dengan angka rekaan.

### Inventory optimization
- Implementasikan MILP hanya jika objective, variables dan constraints dapat diformulasikan dan input siap.
- Objective dapat mempertimbangkan estimasi margin dikurangi biaya operasional/distribusi.
- Constraints dapat mencakup stok pusat, kapasitas seller/gerobak, demand, jumlah lokasi dan kapasitas produksi.
- Jika solver gagal/lambat/infeasible, hasilkan status dan fallback rule-based yang transparan.
- Jangan mengeksekusi mutasi stok. AI hanya memberi rekomendasi; Owner menyetujui distribusi melalui backend.

### Output JSON minimum
- target period
- location/product/category identifiers
- predicted demand
- recommended quantity
- location score bila relevan
- confidence dan data_quality secara terpisah
- rationale/factors
- model_version
- solver/model status
- processing time
- data_label REAL/SIMULASI

### Kriteria selesai
- Baseline berjalan dan diuji.
- Forecast memiliki evaluasi dan batasan.
- Scoring bisa dijelaskan.
- MILP feasible atau fallback/status infeasible ditampilkan.
- Service callable oleh backend dengan schema stabil.
- Tidak ada penulisan langsung ke tabel transaksi atau inventory.
- Output tidak menyamarkan simulasi sebagai data real.

### Instruksi pertama
Audit repository dan dataset. Laporkan data apa yang tersedia, field aktual, masalah kualitas data, baseline yang realistis, dan input yang harus diminta dari Backend/Integration. Jangan mulai dengan model kompleks sebelum baseline dan kontrak data disepakati.
