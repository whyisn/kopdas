"""
Modul Optimasi Alokasi Stok (Inventory Intelligence - MILP & Rule-Based Fallback)
PIC: AI / Data Engineer (Anggota 4)
Acuan: Dokumen Induk Bab 12 & Kontrak Integrasi
"""
from typing import List, Dict, Any
import time

class InventoryOptimizer:
    def __init__(self):
        pass

    def optimize_allocation(
        self,
        central_inventory: Dict[str, int],       # {product_id: available_quantity}
        seller_capacities: Dict[str, int],       # {seller_id: max_cups_capacity}
        forecasts: List[Dict[str, Any]],         # output dari forecaster
        product_margins: Dict[str, int],         # {product_id: margin_rupiah}
        data_label: str = "SIMULASI"
    ) -> Dict[str, Any]:
        """
        Menghitung alokasi stok optimal per gerobak penjual.
        Mencoba memecahkan dengan MILP; jika tidak tersedia/timeout/infeasible,
        berpindah ke Rule-Based Fallback secara transparan.
        """
        start_time = time.time()
        solver_status = "OPTIMAL"
        recommendations = []

        try:
            import pulp
            # Formulasi MILP
            prob = pulp.LpProblem("KopiCerdas_Stock_Allocation", pulp.LpMaximize)

            # Variabel keputusan x[seller, product] = jumlah unit
            alloc_vars = {}
            for fc in forecasts:
                s_id = fc["location_id"] # Seller/location
                p_id = fc["product_id"]
                key = (s_id, p_id)
                # Maksimal alokasi tidak melebihi prediksi demand
                max_dem = fc.get("predicted_demand", 50)
                alloc_vars[key] = pulp.LpVariable(f"alloc_{s_id}_{p_id}", lowBound=0, upBound=max_dem, cat='Integer')

            # Objective: Maksimalkan Total Estimasi Margin Penjualan
            prob += pulp.lpSum([
                alloc_vars[(fc["location_id"], fc["product_id"])] * product_margins.get(fc["product_id"], 5000)
                for fc in forecasts
            ])

            # Constraint 1: Alokasi total produk tidak melebihi stok gudang pusat
            for p_id, max_stock in central_inventory.items():
                prob += pulp.lpSum([
                    alloc_vars[(fc["location_id"], fc["product_id"])]
                    for fc in forecasts if fc["product_id"] == p_id
                ]) <= max_stock

            # Constraint 2: Alokasi per seller tidak melebihi kapasitas fisik gerobak
            for s_id, max_cap in seller_capacities.items():
                prob += pulp.lpSum([
                    alloc_vars[(fc["location_id"], fc["product_id"])]
                    for fc in forecasts if fc["location_id"] == s_id
                ]) <= max_cap

            # Solve problem
            prob.solve(pulp.PULP_CBC_CMD(msg=0, timeLimit=2))

            if pulp.LpStatus[prob.status] == 'Optimal':
                solver_status = "OPTIMAL_MILP"
                for fc in forecasts:
                    s_id = fc["location_id"]
                    p_id = fc["product_id"]
                    allocated = int(alloc_vars[(s_id, p_id)].varValue or 0)
                    rationale = list(fc.get("rationale", []))
                    rationale.append("Dioptimasi oleh solver MILP dengan batasan kapasitas gerobak & stok gudang.")

                    recommendations.append({
                        "period_start": fc["period_start"],
                        "period_end": fc["period_end"],
                        "location_id": s_id,
                        "location_name": fc.get("location_name", s_id),
                        "product_id": p_id,
                        "product_name": fc.get("product_name", p_id),
                        "predicted_demand": fc.get("predicted_demand", 0),
                        "recommended_stock": allocated,
                        "confidence": fc.get("confidence", 0.7),
                        "data_quality": fc.get("data_quality", "MEDIUM"),
                        "rationale": rationale,
                        "model_version": "milp-pulp-v1",
                        "solver_status": solver_status,
                        "data_label": data_label
                    })
            else:
                solver_status = "RULE_BASED_FALLBACK"
                recommendations = self._rule_based_fallback(central_inventory, seller_capacities, forecasts, product_margins, data_label)

        except Exception:
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
        """
        results = []
        for fc in forecasts:
            s_id = fc["location_id"]
            p_id = fc["product_id"]
            dem = fc.get("predicted_demand", 20)
            avail = central_inventory.get(p_id, 100)
            cap = seller_capacities.get(s_id, 80)

            # Batasi dengan stok dan batas kapasitas
            recommended = min(dem, avail // max(1, len(seller_capacities)), cap // max(1, len(forecasts)))
            recommended = max(0, recommended)

            rationale = list(fc.get("rationale", []))
            rationale.append("Dialokasikan melalui Rule-Based Fallback (proporsional kapasitas).")

            results.append({
                "period_start": fc["period_start"],
                "period_end": fc["period_end"],
                "location_id": s_id,
                "location_name": fc.get("location_name", s_id),
                "product_id": p_id,
                "product_name": fc.get("product_name", p_id),
                "predicted_demand": dem,
                "recommended_stock": recommended,
                "confidence": max(0.5, fc.get("confidence", 0.6) - 0.1),
                "data_quality": "LIMITED",
                "rationale": rationale,
                "model_version": "rule-based-fallback-v1",
                "solver_status": "RULE_BASED_FALLBACK",
                "data_label": data_label
            })
        return results

optimizer = InventoryOptimizer()
