import 'dart:async';
import '../../core/core.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});
  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  bool _ask = false;
  Timer? _t;

  @override
  void initState() {
    super.initState();
    _t = Timer(const Duration(seconds: 1), () {
      if (mounted) setState(() => _ask = true);
    });
  }

  @override
  void dispose() {
    _t?.cancel();
    super.dispose();
  }

  void _gps() {
    final o = context.read<OrderProvider>();
    o.setGps();
    context.push(o.availableCarts.isEmpty ? Routes.noCart : Routes.cartList);
  }

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    return AppScaffold(
      title: 'Explore Coffee Cart',
      back: true,
      scroll: false,
      body: Stack(children: [
        const Positioned.fill(child: MapView(pins: [])),
        if (!_ask)
          Align(
            alignment: const Alignment(0, -.25),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
              decoration: BoxDecoration(
                color: p.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: p.line),
              ),
              child: Column(mainAxisSize: MainAxisSize.min, spacing: 12, children: [
                const Spin(),
                Text('Menyiapkan peta gerobak…', style: body(context, w: FontWeight.w600)),
              ]),
            ),
          )
        else
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 18),
              decoration: BoxDecoration(
                color: p.surface,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: .3), blurRadius: 40, offset: const Offset(0, -16))],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: 12,
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(color: p.surface2, borderRadius: BorderRadius.circular(16)),
                    child: Icon(Icons.place_outlined, size: 28, color: p.accent),
                  ),
                  Text('Cari gerobak dari mana?', style: dsp(context, 22)),
                  Text(
                    'Aktifkan lokasi supaya gerobak terdekat tampil otomatis, atau pilih area sendiri.',
                    style: mut(context, 13),
                  ),
                  AppButton(label: 'Aktifkan lokasi', onPressed: _gps),
                  AppButton(
                    label: 'Pilih lokasi manual',
                    kind: BtnKind.line,
                    onPressed: () => context.push(Routes.manual),
                  ),
                ],
              ),
            ),
          ),
      ]),
    );
  }
}

class ManualLocationScreen extends StatefulWidget {
  const ManualLocationScreen({super.key});
  @override
  State<ManualLocationScreen> createState() => _ManualLocationScreenState();
}

class _ManualLocationScreenState extends State<ManualLocationScreen> {
  final _q = TextEditingController();

  @override
  void dispose() {
    _q.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final q = _q.text.trim().toLowerCase();
    final areas = MockData.areas
        .where((a) => q.isEmpty || '${a.name} ${a.district}'.toLowerCase().contains(q))
        .toList();
    return AppScaffold(
      title: 'Pilih lokasi',
      back: true,
      body: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        AppField(
          label: 'Cari area atau jalan',
          controller: _q,
          hint: 'Contoh: Kemang',
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 8),
        for (final a in areas)
          InkWell(
            onTap: () {
              final o = context.read<OrderProvider>();
              o.setArea(a);
              context.replace(o.availableCarts.isEmpty ? Routes.noCart : Routes.cartList);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(border: Border(bottom: BorderSide(color: p.line))),
              child: Row(spacing: 12, children: [
                Icon(Icons.place_outlined, color: p.accent),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(a.name, style: body(context, w: FontWeight.w700)),
                  Text('${a.district}${a.empty ? ' · demo: belum ada gerobak' : ''}',
                      style: mut(context, 13)),
                ]),
              ]),
            ),
          ),
      ]),
    );
  }
}

class CartListScreen extends StatelessWidget {
  const CartListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final o = context.watch<OrderProvider>();
    final list = [...o.availableCarts]..sort((a, b) => o.distance(a).compareTo(o.distance(b)));
    void pick(CoffeeCart c) {
      o.selectCart(c.id);
      context.push(Routes.menu);
    }

    return AppScaffold(
      title: 'Gerobak sekitar',
      back: true,
      action: TextButton(
        onPressed: () => context.replace(Routes.manual),
        child: Text('Ubah lokasi',
            style: body(context, size: 13, w: FontWeight.w700, color: p.accent)),
      ),
      body: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(spacing: 6, children: [
          Icon(Icons.place_outlined, size: 18, color: p.muted),
          Text(o.locName, style: mut(context, 13)),
        ]),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Container(
            height: 184,
            decoration: BoxDecoration(border: Border.all(color: p.line), borderRadius: BorderRadius.circular(12)),
            child: MapView(pins: list, onPick: pick),
          ),
        ),
        SectionTitle('${list.length} gerobak buka dan online'),
        Column(spacing: 14, children: [
          for (var i = 0; i < list.length; i++)
            GestureDetector(
              onTap: () => pick(list[i]),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: p.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: p.line),
                ),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, spacing: 12, children: [
                  Container(
                    width: 34,
                    height: 34,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(color: p.accent, shape: BoxShape.circle),
                    child: Text('${i + 1}',
                        style: body(context, w: FontWeight.w800, color: p.onAccent)),
                  ),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(list[i].name, style: dsp(context, 16, w: FontWeight.w700)),
                      const SizedBox(height: 4),
                      Text(
                        '${fmtDist(o.distance(list[i]))}  ·  ★ ${ratingText(list[i].rating)} (${list[i].reviews})  ·  antre ± ${list[i].waitMinutes} mnt',
                        style: mut(context, 13),
                      ),
                      Text(list[i].tag, style: mut(context, 13)),
                    ]),
                  ),
                  const Pill('Buka'),
                ]),
              ),
            ),
        ]),
      ]),
    );
  }
}

class NoCartScreen extends StatelessWidget {
  const NoCartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final o = context.watch<OrderProvider>();
    return AppScaffold(
      title: 'Gerobak sekitar',
      back: true,
      body: StatusHeader(
        icon: Icons.place_outlined,
        kind: BadgeKind.warn,
        title: 'Belum ada gerobak yang buka',
        message:
            'Tidak ada gerobak buka dan online di ${o.locName} saat ini. Coba area lain atau cek lagi nanti.',
      ),
      footer: AppButton(
        label: 'Kembali ke Explore Coffee Cart',
        onPressed: () => context.fromHome(Routes.explore),
      ),
    );
  }
}
