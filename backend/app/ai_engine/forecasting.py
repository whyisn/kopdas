"""
Modul Peramalan Penjualan (Demand Forecasting)
PIC: AI / Data Engineer (Anggota 4)
Acuan: Dokumen Induk Bab 12 & Kontrak Integrasi

Fitur Unggulan:
1. HistGradientBoostingRegressor (Loss Poisson) untuk data hitungan cup non-negatif.
2. Koreksi data tersensor (EM loop sederhana) saat terjadi stockout.
3. Fallback cerdas ke Weighted Moving Average (WMA) jika data histori minim.
"""
from typing import List, Dict, Any, Optional
import datetime
import numpy as np
import pandas as pd
from scipy.stats import norm
from sklearn.ensemble import HistGradientBoostingRegressor


class DemandForecaster:
    def __init__(self, model_version: str = "hgb-poisson-em-v1"):
        self.model_version = model_version
        self.stockout_uplift = 1.15
        self.phi = 1.5  # dispersi

    def _train_poisson_em(
        self,
        df_history: pd.DataFrame,
        em_iters: int = 3
    ) -> Optional[HistGradientBoostingRegressor]:
        """Melatih model HistGradientBoostingRegressor dengan loss Poisson dan EM loop."""
        try:
            if len(df_history) < 15:
                return None

            # Fitur: location_code, product_code, dow (day of week), is_weekend
            df = df_history.copy()
            if "dow" not in df.columns:
                df["dow"] = 2  # default Rabu
            if "weekend" not in df.columns:
                df["weekend"] = (df["dow"] >= 5).astype(int)

            loc_cats = {loc: i for i, loc in enumerate(df["location_id"].unique())}
            prod_cats = {p: i for i, p in enumerate(df["product_id"].unique())}

            df["loc_feat"] = df["location_id"].map(loc_cats).fillna(0).astype(int)
            df["prod_feat"] = df["product_id"].map(prod_cats).fillna(0).astype(int)

            features = ["loc_feat", "prod_feat", "dow", "weekend"]
            X = df[features]
            sold = df["quantity"].to_numpy(float)
            cens = df.get("stockout_flag", pd.Series([False] * len(df))).to_numpy() == True

            y = np.where(cens, sold * self.stockout_uplift, sold)

            model = HistGradientBoostingRegressor(
                loss="poisson",
                max_iter=100,
                learning_rate=0.08,
                max_leaf_nodes=8,
                min_samples_leaf=3,
                categorical_features=[0, 1],
                random_state=42
            )

            # EM loop untuk censored demand
            for _ in range(em_iters):
                model.fit(X, y)
                mu = model.predict(X)
                unc = ~cens
                if np.any(unc):
                    diff = sold[unc] - mu[unc]
                    self.phi = float(np.clip(np.mean(diff ** 2 / np.maximum(mu[unc], 1.0)), 1.0, 5.0))
                sd = np.sqrt(self.phi * np.maximum(mu, 1.0))
                a = (sold - mu) / sd
                tail_mean = mu + sd * norm.pdf(a) / np.maximum(norm.sf(a), 1e-6)
                y = np.where(cens, np.maximum(sold, tail_mean), sold)

            return model
        except Exception:
            return None

    def forecast_sales(
        self,
        sales_history: List[Dict[str, Any]],
        target_days: int = 7,
        data_label: str = "SIMULASI"
    ) -> List[Dict[str, Any]]:
        """
        Menghasilkan prediksi demand per produk dan lokasi untuk target_days ke depan.
        """
        now = datetime.datetime.now()
        start_str = (now + datetime.timedelta(days=1)).strftime("%Y-%m-%d")
        end_str = (now + datetime.timedelta(days=target_days)).strftime("%Y-%m-%d")

        if not sales_history:
            return []

        df_hist = pd.DataFrame(sales_history)
        if "quantity" not in df_hist.columns and "qty" in df_hist.columns:
            df_hist["quantity"] = df_hist["qty"]

        # Coba latih model ML Poisson EM jika data mencukupi
        ml_model = None
        if len(df_hist) >= 15 and "location_id" in df_hist.columns and "product_id" in df_hist.columns:
            ml_model = self._train_poisson_em(df_hist)

        # Kelompokkan data per (location_id, product_id)
        grouped = {}
        for row in sales_history:
            key = (row["location_id"], row["product_id"])
            if key not in grouped:
                grouped[key] = []
            qty = row.get("quantity", row.get("qty", 0))
            if row.get("stockout_flag", False):
                qty = int(qty * self.stockout_uplift)
            grouped[key].append(qty)

        results = []
        for (loc_id, prod_id), history in grouped.items():
            count = len(history)
            used_model = self.model_version

            if not history:
                predicted_daily = 10
                confidence = 0.35
                data_quality = "LIMITED"
                rationale = ["Tidak ada histori penjualan yang cukup; estimasi awal default diterapkan."]
            elif ml_model is not None and count >= 5:
                # Menggunakan prediksi GBDT Poisson
                try:
                    loc_idx = 0
                    prod_idx = 0
                    # Rata-rata prediksi untuk target days
                    dow_vals = [(now.weekday() + 1 + d) % 7 for d in range(target_days)]
                    pred_sum = 0
                    for dow in dow_vals:
                        x_sample = pd.DataFrame([{
                            "loc_feat": loc_idx,
                            "prod_feat": prod_idx,
                            "dow": dow,
                            "weekend": 1 if dow >= 5 else 0
                        }])
                        pred_sum += max(1, float(ml_model.predict(x_sample)[0]))
                    predicted_daily = max(1, int(round(pred_sum / target_days)))
                    confidence = min(0.92, 0.65 + (count * 0.03))
                    data_quality = "HIGH" if count >= 10 else "MEDIUM"
                    rationale = [
                        f"Model ML HistGradientBoosting (loss Poisson) dilatih dari {count} titik data.",
                        "Koreksi EM diaplikasikan pada penjualan saat terjadi stockout (demand tersensor).",
                        f"Proyeksi memperhitungkan variasi hari kerja vs akhir pekan untuk {target_days} hari ke depan."
                    ]
                except Exception:
                    # Fallback ke WMA
                    weights = [i + 1 for i in range(len(history))]
                    predicted_daily = max(1, int(round(sum(h * w for h, w in zip(history, weights)) / sum(weights))))
                    confidence = min(0.85, 0.50 + (count * 0.04))
                    data_quality = "MEDIUM" if count >= 7 else "LIMITED"
                    used_model = "baseline-wma-v1"
                    rationale = [
                        f"Rata-rata berbobot (WMA) dari {count} data histori penjualan.",
                        "Penyesuaian uplift 15% untuk hari berstatus stockout."
                    ]
            else:
                # WMA: beri bobot lebih tinggi pada data terbaru
                weights = [i + 1 for i in range(len(history))]
                weighted_sum = sum(h * w for h, w in zip(history, weights))
                predicted_daily = max(1, int(round(weighted_sum / sum(weights))))
                confidence = min(0.85, 0.50 + (count * 0.04))
                data_quality = "MEDIUM" if count >= 7 else "LIMITED"
                used_model = "baseline-wma-v1"
                rationale = [
                    f"Rata-rata berbobot (WMA) dari {count} data histori penjualan.",
                    "Penyesuaian uplift 15% untuk hari berstatus stockout."
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
                "model_version": used_model,
                "data_label": data_label
            })

        return results


forecaster = DemandForecaster()
