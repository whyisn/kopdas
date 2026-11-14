"""
Modul Peramalan Penjualan (Demand Forecasting)
PIC: AI / Data Engineer (Anggota 4)
Acuan: Dokumen Induk Bab 12 & Kontrak Integrasi
"""
from typing import List, Dict, Any
import datetime

class DemandForecaster:
    def __init__(self, model_version: str = "baseline-wma-v1"):
        self.model_version = model_version

    def forecast_sales(
        self,
        sales_history: List[Dict[str, Any]],
        target_days: int = 7,
        data_label: str = "SIMULASI"
    ) -> List[Dict[str, Any]]:
        """
        Menghitung prediksi demand harian berbasis Weighted Moving Average (WMA)
        dengan penanganan demand tersensor saat stockout.
        """
        # Agregasi histori per produk dan lokasi
        grouped = {}
        for row in sales_history:
            key = (row["location_id"], row["product_id"])
            if key not in grouped:
                grouped[key] = []
            
            qty = row.get("quantity", 0)
            # Jika ada flag stockout, demand sebenarnya kemungkinan lebih tinggi dari unit terjual
            if row.get("stockout_flag", False):
                qty = int(qty * 1.25) # Koreksi sensor demand
            grouped[key].append(qty)

        results = []
        now = datetime.datetime.now()
        start_str = (now + datetime.timedelta(days=1)).strftime("%Y-%m-%d")
        end_str = (now + datetime.timedelta(days=target_days)).strftime("%Y-%m-%d")

        for (loc_id, prod_id), history in grouped.items():
            if not history:
                predicted_daily = 10
                confidence = 0.35
                data_quality = "LIMITED"
                rationale = ["Tidak ada histori penjualan yang cukup; estimasi awal default diterapkan."]
            else:
                # WMA: beri bobot lebih tinggi pada data terbaru
                weights = [i + 1 for i in range(len(history))]
                weighted_sum = sum(h * w for h, w in zip(history, weights))
                predicted_daily = max(1, int(round(weighted_sum / sum(weights))))
                
                # Confidence score
                count = len(history)
                confidence = min(0.90, 0.50 + (count * 0.05))
                data_quality = "HIGH" if count >= 7 else "MEDIUM"
                rationale = [
                    f"Rata-rata berbobot dari {count} titik data histori penjualan.",
                    "Penyesuaian sensor demand untuk hari berstatus stockout."
                ]

            total_predicted = predicted_daily * target_days

            results.append({
                "period_start": start_str,
                "period_end": end_str,
                "location_id": loc_id,
                "product_id": prod_id,
                "predicted_daily": predicted_daily,
                "predicted_demand": total_predicted,
                "confidence": round(confidence, 2),
                "data_quality": data_quality,
                "rationale": rationale,
                "model_version": self.model_version,
                "data_label": data_label
            })

        return results

forecaster = DemandForecaster()
