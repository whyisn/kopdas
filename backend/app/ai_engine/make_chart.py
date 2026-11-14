"""Membuat grafik perbandingan kebijakan dari results.json -> chart_backtest.png"""
import json
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt

r = json.load(open("results.json"))["kebijakan"]
names = list(r)
labels = ["Manual\n(kebiasaan)", "Rumus\n(minggu lalu +10%)", "Kopi Cerdas\n(forecast + MILP)"]
colors = ["#9AA5B1", "#9AA5B1", "#8B5A2B"]

fig, axes = plt.subplots(1, 3, figsize=(11, 3.6), dpi=200)
panels = [("Laba 3 minggu (juta Rp)", [r[n]["laba_rp"] / 1e6 for n in names], "{:.1f}"),
          ("Cup tersisa / terbuang", [r[n]["sisa_cup"] for n in names], "{:,.0f}"),
          ("Cup permintaan tak terlayani", [r[n]["hilang_cup"] for n in names], "{:,.0f}")]
for ax, (title, vals, fmt) in zip(axes, panels):
    bars = ax.bar(labels, vals, color=colors, width=0.6)
    ax.set_title(title, fontsize=10, loc="left", color="#222")
    for b, v in zip(bars, vals):
        ax.text(b.get_x() + b.get_width() / 2, v, fmt.format(v), ha="center", va="bottom", fontsize=9)
    ax.spines[["top", "right", "left"]].set_visible(False)
    ax.set_yticks([])
    ax.tick_params(axis="x", labelsize=7.5, length=0)
fig.suptitle("Backtest 3 minggu pada data SIMULASI (12 Okt - 1 Nov 2026)", fontsize=10, x=0.01, ha="left", color="#555")
fig.tight_layout()
fig.savefig("chart_backtest.png", bbox_inches="tight")
print("chart_backtest.png")
