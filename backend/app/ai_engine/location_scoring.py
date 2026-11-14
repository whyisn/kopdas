"""
Modul Skoring Lokasi (Location Intelligence)
PIC: AI / Data Engineer & Integration Engineer
Acuan: Dokumen Induk Bab 12 & Kontrak Integrasi
Catatan: Traffic kendaraan bukan hitungan calon pembeli pejalan kaki.
"""
from typing import Dict, Any, List

class LocationScorer:
    def __init__(self):
        pass

    def score_location(
        self,
        location_data: Dict[str, Any],
        historical_sales_count: int = 0,
        poi_count: int = 0,
        has_weather_signal: bool = False,
        data_label: str = "SIMULASI"
    ) -> Dict[str, Any]:
        """
        Menghasilkan skor kelayakan titik gerobak (0-100) beserta faktor penjelas transparan.
        """
        factors = []
        raw_score = 40.0  # Base viability score

        # 1. Faktor Histori Penjualan
        if historical_sales_count > 50:
            raw_score += 30.0
            factors.append(f"Histori penjualan kuat ({historical_sales_count} transaksi dicatat).")
        elif historical_sales_count > 10:
            raw_score += 15.0
            factors.append(f"Histori penjualan moderat ({historical_sales_count} transaksi).")
        else:
            factors.append("Lokasi baru/kandidat tanpa histori; skor mengandalkan POI (Estimasi Awal).")

        # 2. Faktor POI (Point of Interest di sekitar)
        poi_contribution = min(20.0, poi_count * 4.0)
        raw_score += poi_contribution
        if poi_count > 0:
            factors.append(f"Dikelilingi {poi_count} POI potensial (perkantoran/kampus/stasiun).")
        else:
            factors.append("POI di sekitar lokasi masih minim terdeteksi.")

        # 3. Faktor Mobilitas & Cuaca (Sinyal pendukung)
        if has_weather_signal:
            factors.append("Prakiraan cuaca mendukung aktivitas luar ruangan.")
            raw_score += 5.0

        final_score = min(98.0, max(20.0, raw_score))
        confidence = 0.85 if historical_sales_count > 20 else 0.55

        return {
            "location_id": location_data.get("id"),
            "location_name": location_data.get("name"),
            "score": round(final_score, 1),
            "confidence": confidence,
            "data_quality": "HIGH" if historical_sales_count > 20 else "LIMITED",
            "factors": factors,
            "data_label": data_label
        }

location_scorer = LocationScorer()
