import 'package:flutter/material.dart';
import '../../core/core.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final name = context.watch<AuthProvider>().userName;
    final favorites =
        MockData.favoriteIds.map((id) => MockData.menu.firstWhere((m) => m.id == id)).toList();

    Widget step(int n, String t, String s) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, spacing: 12, children: [
            Container(
              width: 28,
              height: 28,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: p.surface2, shape: BoxShape.circle),
              child: Text('$n', style: body(context, size: 13, w: FontWeight.w800)),
            ),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(t, style: body(context, w: FontWeight.w700)),
                Text(s, style: mut(context, 13)),
              ]),
            ),
          ]),
        );

    return AppScaffold(
      body: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        const SizedBox(height: 6),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('${greeting()},', style: mut(context, 13)),
            Text(name, style: dsp(context, 28)),
          ]),
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: p.sun, shape: BoxShape.circle),
            child: Text(greetingInitial(name), style: dsp(context, 18, color: p.onSun)),
          ),
        ]),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: p.accent, borderRadius: BorderRadius.circular(24)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, spacing: 14, children: [
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 230),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('Kopi dari gerobak, tanpa antre.',
                    style: dsp(context, 26, color: p.onAccent)),
              ),
            ),
            const Align(alignment: Alignment.centerRight, child: GerobakArt(width: 110)),
            AppButton(
              label: 'Explore Coffee Cart',
              kind: BtnKind.sun,
              icon: Icons.place_outlined,
              onPressed: () => context.push(Routes.explore),
            ),
          ]),
        ),
        const SectionTitle('Favorit minggu ini'),
        SizedBox(
          height: 162,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: favorites.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (_, i) {
              final f = favorites[i];
              return GestureDetector(
                onTap: () => context.push(Routes.explore),
                child: Container(
                  width: 128,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: p.surface,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: p.line),
                  ),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, spacing: 8, children: [
                    Container(
                      width: double.infinity,
                      height: 76,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          color: p.surface2, borderRadius: BorderRadius.circular(16)),
                      child: f.isDrink ? CupArt(f.color, size: 44) : SnackArt(f.color, size: 44),
                    ),
                    Text(f.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: body(context, size: 14, w: FontWeight.w700)),
                    Text(rp(f.price), style: mut(context, 13)),
                  ]),
                ),
              );
            },
          ),
        ),
        const SectionTitle('Cara kerja'),
        step(1, 'Cari gerobak yang buka dan online', 'Pakai lokasimu atau pilih area sendiri.'),
        Divider(color: p.line, height: 1),
        step(2, 'Kirim pesanan, bayar setelah diterima',
            'Stokmu dicadangkan selama waktu pembayaran.'),
        Divider(color: p.line, height: 1),
        step(3, 'Datang, tunjukkan kode, ambil kopi',
            'Barista memverifikasi kode sebelum menyerahkan.'),
      ]),
    );
  }
}
