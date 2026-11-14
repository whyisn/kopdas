"""
Modul Optimasi Alokasi Stok (Inventory Intelligence - MILP & Rule-Based Fallback)
PIC: AI / Data Engineer (Anggota 4)
Acuan: Dokumen Induk Bab 12 & Kontrak Integrasi

Fitur Unggulan:
1. Mixed Integer Linear Programming (MILP) berbasis Scipy HiGHS solver.
2. Batasan riil: kapasitas stok gudang pusat, kapasitas fisik gerobak seller, dan batas permintaan.
3. Objective function: memaksimalkan total margin laba bersih.
4. Fallback otomatis dan transparan ke Rule-Based Fallback jika solver tidak konvergen.
"""
from typing import List, Dict, Any
import time
import numpy as np
from scipy.optimize import Bounds, LinearConstraint, milp


class InventoryOptimizer:
    def __init__(self):
        pass

    def optimize_allocation(
        self,
        central_inventory: Dict[str, int],       # {product_id: available_quantity}
        seller_capacities: Dict[str, int],       # {seller_id: max_cups_capacity}
        forecasts: List[Dict[str, Any]],         # output dari forecaster
        product_margins: Dict[str, int],         # {product_id: margin_rupiah}
        data_label: str = "REAL"
    ) -> Dict[str, Any]:
        """
        Menghitung alokasi stok optimal per gerobak penjual menggunakan solver MILP HiGHS.
        """
        start_time = time.time()
        solver_status = "OPTIMAL_MILP"
        recommendations = []

        if not forecasts:
            return {
                "recommendations": [],
                "total_recommended_cups": 0,
                "estimated_margin": 0,
                "solver_status": "NO_FORECASTS",
                "processing_time_ms": 0.0,
                "data_label": data_label
            }

        N = len(forecasts)
        try:
            # Objective: Memaksimalkan Margin = Meminimalkan Negatif Margin
            c = np.array([
                -float(product_margins.get(fc["product_id"], 5000))
                for fc in forecasts
            ])

            # Batas atas variabel keputusan: x_i <= predicted_demand_i
            uppers = np.array([
                max(0.0, float(fc.get("predicted_demand", 0)))
                for fc in forecasts
            ])

            # Matriks kendala linear
            constraint_rows = []
            lb_list = []
            ub_list = []

            # 1. Kendala Kapasitas Gudang Pusat per Produk (stok tidak tersedia = 0, tidak boleh mengalokasikan stok fiktif)
            products = list(set(fc["product_id"] for fc in forecasts))
            for p_id in products:
                row = np.zeros(N)
                for i, fc in enumerate(forecasts):
                    if fc["product_id"] == p_id:
                        row[i] = 1.0
                max_avail = float(central_inventory.get(p_id, 0.0))
                constraint_rows.append(row)
                lb_list.append(0.0)
                ub_list.append(max_avail)

            # 2. Kendala Kapasitas Bawa Fisik Gerobak per Seller / Lokasi
            locations = list(set(fc["location_id"] for fc in forecasts))
            for loc_id in locations:
                row = np.zeros(N)
                for i, fc in enumerate(forecasts):
                    if fc["location_id"] == loc_id:
                        row[i] = 1.0
                max_cap = float(seller_capacities.get(loc_id, 80))
                constraint_rows.append(row)
                lb_list.append(0.0)
                ub_list.append(max_cap)

            A = np.array(constraint_rows)
            lb = np.array(lb_list)
            ub = np.array(ub_list)
            integrality = np.ones(N)  # Semua variabel harus bernilai integer

            bounds = Bounds(0, uppers)
            constraints = LinearConstraint(A, lb, ub)

            # Eksekusi Solver HiGHS dengan batas waktu 5 detik
            res = milp(c=c, constraints=constraints, integrality=integrality, bounds=bounds, options={"time_limit": 5.0})

            if res.success:
                allocations = np.round(res.x).astype(int)
                for i, fc in enumerate(forecasts):
                    allocated = int(allocations[i])
                    s_id = fc["location_id"]
                    p_id = fc["product_id"]

                    rationale = list(fc.get("rationale", []))
                    rationale.append("Dioptimasi oleh solver MILP HiGHS (memaksimalkan margin dengan batas kapasitas gerobak & stok gudang).")

                    recommendations.append({
                        "period_start": fc["period_start"],
                        "period_end": fc["period_end"],
                        "location_id": s_id,
                        "location_name": fc.get("location_name", s_id),
                        "product_id": p_id,
                        "product_name": fc.get("product_name", p_id),
                        "predicted_demand": int(fc.get("predicted_demand", 0)),
                        "recommended_stock": allocated,
                        "recommended_quantity": allocated,  # Kompatibilitas UI Flutter
                        "confidence": float(fc.get("confidence", 0.75)),
                        "data_quality": fc.get("data_quality", "HIGH"),
                        "rationale": rationale,
                        "model_version": "milp-highs-v1",
                        "solver_status": solver_status,
                        "data_label": data_label
                    })
            else:
                solver_status = "RULE_BASED_FALLBACK"
                recommendations = self._rule_based_fallback(central_inventory, seller_capacities, forecasts, product_margins, data_label)

        except Exception as e:
            solver_status = "RULE_BASED_FALLBACK"
            recommendations = self._rule_based_fallback(central_inventory, seller_capacities, forecasts, product_margins, data_label)

        total_cups = sum(r["recommended_stock"] for r in recommendations)
        est_margin = sum(r["recommended_stock"] * product_margins.get(r["product_id"], 5000) for r in recommendations)
        processing_time = (time.time() - start_time) * 1000

        return {
            "recommendations": recommendations,
            "total_recommended_cups": total_cups,
            "estimated_margin": est_margin,
            "solver_status": solver_status,
            "processing_time_ms": round(processing_time, 2),
            "data_label": data_label
        }

    def _rule_based_fallback(
        self,
        central_inventory: Dict[str, int],
        seller_capacities: Dict[str, int],
        forecasts: List[Dict[str, Any]],
        product_margins: Dict[str, int],
        data_label: str
    ) -> List[Dict[str, Any]]:
        """
        Fallback algoritma proporsional bila MILP solver tidak aktif.
        Menjamin tidak ada alokasi jika stok gudang 0 dan total alokasi
        tidak pernah melampaui kapasitas fisik gerobak seller.
        """
        results = []
        allocated_per_seller: Dict[str, int] = {}
        remaining_warehouse: Dict[str, int] = {k: int(v) for k, v in central_inventory.items()}

        for fc in forecasts:
            s_id = fc["location_id"]
            p_id = fc["product_id"]
            dem = int(fc.get("predicted_demand", 0))
            avail = int(remaining_warehouse.get(p_id, 0))
            cap = int(seller_capacities.get(s_id, 80))

            already_allocated = allocated_per_seller.get(s_id, 0)
            remaining_cap = max(0, cap - already_allocated)

            # Batasi dengan demand, sisa stok gudang, dan sisa kapasitas fisik
            recommended = min(dem, avail, remaining_cap)
            recommended = max(0, recommended)

            allocated_per_seller[s_id] = already_allocated + recommended
            remaining_warehouse[p_id] = max(0, avail - recommended)

            rationale = list(fc.get("rationale", []))
            rationale.append("Dialokasikan melalui Rule-Based Fallback (dibatasi stok gudang aktual & sisa kapasitas gerobak).")

            results.append({
                "period_start": fc["period_start"],
                "period_end": fc["period_end"],
                "location_id": s_id,
                "location_name": fc.get("location_name", s_id),
                "product_id": p_id,
                "product_name": fc.get("product_name", p_id),
                "predicted_demand": dem,
                "recommended_stock": recommended,
                "recommended_quantity": recommended,  # Kompatibilitas UI Flutter
                "confidence": max(0.5, float(fc.get("confidence", 0.6)) - 0.1),
                "data_quality": "LIMITED",
                "rationale": rationale,
                "model_version": "rule-based-fallback-v1",
                "solver_status": "RULE_BASED_FALLBACK",
                "data_label": data_label
            })
        return results


optimizer = InventoryOptimizer()
