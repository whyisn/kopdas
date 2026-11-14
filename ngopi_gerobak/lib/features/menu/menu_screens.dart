import 'package:flutter/material.dart';
import '../../core/core.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final o = context.watch<OrderProvider>();
    final c = o.cart;
    return AppScaffold(
      title: c.name,
      back: true,
      footer: o.count > 0
          ? AppButton(
              icon: Icons.shopping_bag_outlined,
              label: 'Lihat keranjang · ${o.count} item · ${rp(o.subtotal)}',
              onPressed: () => context.push(Routes.cart),
            )
          : null,
      body: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(spacing: 12, children: [
          Container(
            width: 56,
            padding: const EdgeInsets.fromLTRB(4, 6, 4, 2),
            decoration: BoxDecoration(color: p.surface2, borderRadius: BorderRadius.circular(14)),
            child: const GerobakArt(width: 48),
          ),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(c.spot, style: mut(context, 13)),
              Text(
                '${fmtDist(o.distance(c))} dari kamu · ★ ${ratingText(c.rating)} · antre ± ${c.waitMinutes} mnt',
                style: body(context, size: 13, w: FontWeight.w600),
              ),
            ]),
          ),
        ]),
        const SizedBox(height: 8),
        Row(spacing: 8, children: [
          const Pill('Buka'),
          const Pill('Online'),
          Text(c.hours, style: mut(context, 13)),
        ]),
        const SizedBox(height: 14),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(spacing: 8, children: [
            for (final k in MockData.categories)
              AppChip(label: k, selected: o.category == k, onTap: () => o.setCategory(k)),
          ]),
        ),
        const SizedBox(height: 6),
        for (final pr in o.filteredMenu)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(border: Border(bottom: BorderSide(color: p.line))),
            child: Row(spacing: 12, children: [
              ProductThumb(pr),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(pr.name, style: dsp(context, 16, w: FontWeight.w700)),
                  Text(pr.description, style: mut(context, 13)),
                  const SizedBox(height: 3),
                  Text(rp(pr.price), style: body(context, w: FontWeight.w700)),
                ]),
              ),
              Semantics(
                button: true,
                label: 'Pilih ${pr.name}',
                child: GestureDetector(
                  onTap: () {
                    o.startDraft(pr.id);
                    context.push(Routes.customize);
                  },
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(color: p.accent, shape: BoxShape.circle),
                    child: Icon(Icons.add, color: p.onAccent),
                  ),
                ),
              ),
            ]),
          ),
      ]),
    );
  }
}

class CustomizeScreen extends StatefulWidget {
  const CustomizeScreen({super.key});
  @override
  State<CustomizeScreen> createState() => _CustomizeScreenState();
}

class _CustomizeScreenState extends State<CustomizeScreen> {
  late final TextEditingController _note;

  @override
  void initState() {
    super.initState();
    _note = TextEditingController(text: context.read<OrderProvider>().draft?.note ?? '');
  }

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  Widget _group(BuildContext context, String title, List<Widget> chips) => Padding(
        padding: const EdgeInsets.only(top: 20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, spacing: 10, children: [
          Text(title, style: body(context, size: 14, w: FontWeight.w700)),
          Wrap(spacing: 8, runSpacing: 8, children: chips),
        ]),
      );

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final o = context.watch<OrderProvider>();
    final d = o.draft;
    if (d == null) return const SizedBox.shrink();
    final prod = o.productOf(d.pid);

    return AppScaffold(
      title: 'Atur variasi dan jumlah',
      back: true,
      footer: Row(spacing: 12, children: [
        QtyStepper(value: d.qty, onMinus: () => o.draftQty(-1), onPlus: () => o.draftQty(1)),
        Expanded(
          child: AppButton(
            label: 'Tambah ke keranjang · ${rp(o.draftUnit(d) * d.qty)}',
            onPressed: () {
              d.note = _note.text;
              o.addDraftToCart();
              context.replace(Routes.cart);
            },
          ),
        ),
      ]),
      body: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(spacing: 14, children: [
          ProductThumb(prod, box: 84, icon: 56),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(prod.name, style: dsp(context, 24)),
              Text(prod.description, style: mut(context, 13)),
              const SizedBox(height: 4),
              Text(rp(prod.price), style: body(context, w: FontWeight.w800)),
            ]),
          ),
        ]),
        if (prod.isDrink) ...[
          _group(context, 'Ukuran', [
            for (final s in MockData.sizes)
              AppChip(
                label: s.extra > 0 ? '${s.name} +${rp(s.extra)}' : s.name,
                selected: d.size == s.name,
                onTap: () => o.setSize(s.name),
              ),
          ]),
          _group(context, 'Suhu', [
            for (final t in MockData.temps)
              AppChip(label: t, selected: d.temp == t, onTap: () => o.setTemp(t)),
          ]),
          _group(context, 'Tingkat manis', [
            for (final s in MockData.sugars)
              AppChip(label: s, selected: d.sugar == s, onTap: () => o.setSugar(s)),
          ]),
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, spacing: 10, children: [
              Text('Tambahan', style: body(context, size: 14, w: FontWeight.w700)),
              for (final a in MockData.addons)
                ChoiceTile(
                  selected: d.addons.contains(a.name),
                  onTap: () => o.toggleAddon(a.name),
                  label: Text(a.name, style: body(context, w: FontWeight.w600)),
                  trailing: Text('+${rp(a.extra)}', style: mut(context, 13)),
                ),
            ]),
          ),
        ],
        Padding(
          padding: const EdgeInsets.only(top: 20),
          child: AppField(
            label: 'Catatan untuk barista',
            controller: _note,
            hint: 'Contoh: es batunya sedikit',
            maxLines: 3,
          ),
        ),
        SizedBox(height: 4, child: Container(color: p.bg)),
      ]),
    );
  }
}

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final o = context.watch<OrderProvider>();
    final c = o.cart;

    if (o.items.isEmpty) {
      return AppScaffold(
        title: 'Keranjang',
        back: true,
        body: StatusHeader(
          icon: Icons.shopping_bag_outlined,
          title: 'Keranjang kosong',
          message: 'Pilih menu dari ${c.name} untuk mulai memesan.',
        ),
        footer: AppButton(label: 'Lihat menu', onPressed: () => context.backTo(Routes.menu)),
      );
    }

    return AppScaffold(
      title: 'Keranjang',
      back: true,
      footer: Row(spacing: 10, children: [
        Expanded(
          child: AppButton(
            label: 'Ya, tambah',
            kind: BtnKind.alt,
            onPressed: () => context.backTo(Routes.menu),
          ),
        ),
        Expanded(
          child: AppButton(label: 'Tidak, checkout', onPressed: () => context.push(Routes.checkout)),
        ),
      ]),
      body: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(spacing: 6, children: [
          Icon(Icons.check_rounded, size: 18, color: p.ok),
          Text('Ditambahkan ke keranjang',
              style: body(context, size: 13, w: FontWeight.w600, color: p.ok)),
        ]),
        const SizedBox(height: 10),
        CartInfoCard(title: c.name, subtitle: '${c.spot} · ${fmtDist(o.distance(c))}'),
        const CartEditor(),
        PriceSummary(subtotal: o.subtotal, fee: OrderProvider.serviceFee, total: o.total),
        AppCard(
          child: Column(spacing: 4, children: [
            Text('Tambah produk lagi?', style: dsp(context, 18, w: FontWeight.w700)),
            Text('Pilih Ya untuk kembali ke menu, atau Tidak untuk lanjut ke checkout.',
                textAlign: TextAlign.center, style: mut(context, 13)),
          ]),
        ),
      ]),
    );
  }
}
