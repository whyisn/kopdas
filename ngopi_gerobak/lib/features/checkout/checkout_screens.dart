import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/core.dart';

class CheckoutScreen extends StatelessWidget {
  const CheckoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final o = context.watch<OrderProvider>();
    final c = o.cart;
    return AppScaffold(
      title: 'Checkout',
      back: true,
      footer: AppButton(
        label: 'Validasi dan lanjutkan',
        onPressed: () => context.push(Routes.validate),
      ),
      body: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        CartInfoCard(title: 'Ambil di ${c.name}', subtitle: '${c.spot} · ${fmtDist(o.distance(c))}'),
        const SectionTitle('Waktu ambil'),
        Wrap(spacing: 8, runSpacing: 8, children: [
          for (final t in MockData.pickupTimes)
            AppChip(label: t, selected: o.pickup == t, onTap: () => o.setPickup(t)),
        ]),
        const SectionTitle('Pesananmu'),
        OrderLines(o.items),
        PriceSummary(subtotal: o.subtotal, fee: OrderProvider.serviceFee, total: o.total),
        Text('Pembayaran dilakukan setelah gerobak menerima pesananmu.', style: mut(context, 12)),
        const SizedBox(height: 14),
        DemoBox(title: 'Simulasi validasi', children: [
          ChoiceTile(
            selected: o.simulateChange,
            onTap: o.toggleSim,
            label: Text('Ada perubahan harga atau stok',
                style: body(context, w: FontWeight.w600)),
          ),
        ]),
      ]),
    );
  }
}

/// Animasi validasi gerobak → harga → stok, lalu lanjut otomatis.
class ValidateScreen extends StatefulWidget {
  const ValidateScreen({super.key});
  @override
  State<ValidateScreen> createState() => _ValidateScreenState();
}

class _ValidateScreenState extends State<ValidateScreen> {
  final _timers = <Timer>[];
  int _step = 0;
  bool? _ok;

  void _later(int ms, VoidCallback f) =>
      _timers.add(Timer(Duration(milliseconds: ms), () {
        if (mounted) f();
      }));

  @override
  void initState() {
    super.initState();
    _later(700, () => setState(() => _step = 1));
    _later(1400, () => setState(() => _step = 2));
    _later(2100, () {
      final ok = context.read<OrderProvider>().applyValidation();
      setState(() {
        _step = 3;
        _ok = ok;
      });
    });
    _later(3000, () => context.replace(_ok == true ? Routes.request : Routes.changes));
  }

  @override
  void dispose() {
    for (final t in _timers) {
      t.cancel();
    }
    super.dispose();
  }

  TrkState _st(int n) => _step > n ? TrkState.done : (_step == n ? TrkState.now : TrkState.todo);

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final o = context.read<OrderProvider>();
    return AppScaffold(
      title: 'Validasi pesanan',
      canPop: false,
      body: Column(crossAxisAlignment: CrossAxisAlignment.stretch, spacing: 16, children: [
        const SizedBox(height: 8),
        Text('Memeriksa pesananmu',
            textAlign: TextAlign.center, style: dsp(context, 24)),
        Text('Gerobak, harga, dan stok dicocokkan dulu sebelum permintaan dikirim.',
            textAlign: TextAlign.center, style: mut(context, 15)),
        const SizedBox(height: 4),
        Timeline([
          TrackRow(_st(0), 'Gerobak buka dan online', o.cart.name),
          TrackRow(_st(1), 'Harga terbaru', 'Mencocokkan harga menu'),
          TrackRow(_st(2), 'Stok bahan', 'Memeriksa ketersediaan'),
        ]),
        if (_ok == true)
          Row(spacing: 6, children: [
            Icon(Icons.check_rounded, size: 18, color: p.ok),
            Text('Semua masih tersedia',
                style: body(context, size: 13, w: FontWeight.w600, color: p.ok)),
          ])
        else if (_ok == false)
          Row(spacing: 6, children: [
            Icon(Icons.warning_amber_rounded, size: 18, color: p.bad),
            Text('Ada perubahan pada pesananmu',
                style: body(context, size: 13, w: FontWeight.w600, color: p.bad)),
          ]),
      ]),
    );
  }
}

class ChangesScreen extends StatelessWidget {
  const ChangesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final o = context.watch<OrderProvider>();
    return AppScaffold(
      title: 'Ada perubahan',
      canPop: false,
      footer: AppButton(
        label: 'Lihat menu dan sesuaikan',
        onPressed: () => context.backTo(Routes.menu),
      ),
      body: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        const StatusHeader(
          icon: Icons.warning_amber_rounded,
          kind: BadgeKind.warn,
          title: 'Pesananmu perlu disesuaikan',
          titleSize: 24,
          message: 'Kondisi gerobak berubah sejak kamu menambahkan menu.',
        ),
        const SizedBox(height: 14),
        AppCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, spacing: 8, children: [
            for (final t in o.changes)
              Row(crossAxisAlignment: CrossAxisAlignment.start, spacing: 10, children: [
                Icon(Icons.warning_amber_rounded, size: 20, color: p.bad),
                Expanded(child: Text(t, style: body(context))),
              ]),
          ]),
        ),
        const SectionTitle('Pesanan sekarang'),
        OrderLines(o.items),
        PriceSummary(subtotal: o.subtotal, fee: OrderProvider.serviceFee, total: o.total),
      ]),
    );
  }
}

class RequestScreen extends StatelessWidget {
  const RequestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final o = context.watch<OrderProvider>();
    final c = o.cart;
    Widget kv(String k, String v, {bool big = false}) => Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(k, style: big ? body(context, size: 17, w: FontWeight.w800) : mut(context, 15)),
            Text(v, style: body(context, size: big ? 17 : 15, w: FontWeight.w800)),
          ],
        );
    return AppScaffold(
      title: 'Kirim permintaan',
      back: true,
      footer: AppButton(
        label: 'Kirim permintaan pesanan',
        onPressed: () => context.fromHome(Routes.waiting),
      ),
      body: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        CartInfoCard(title: c.name, subtitle: '${c.spot} · ${fmtDist(o.distance(c))}'),
        const SectionTitle('Pesananmu'),
        OrderLines(o.items),
        const SizedBox(height: 10),
        AppCard(
          child: Column(spacing: 8, children: [
            kv('Waktu ambil', o.pickup),
            kv('Total', rp(o.total), big: true),
          ]),
        ),
        const SizedBox(height: 12),
        Text('Ini permintaan, belum tagihan. Kamu baru membayar setelah gerobak menerima.',
            style: mut(context, 12)),
      ]),
    );
  }
}

class WaitingScreen extends StatefulWidget {
  const WaitingScreen({super.key});
  @override
  State<WaitingScreen> createState() => _WaitingScreenState();
}

class _WaitingScreenState extends State<WaitingScreen> {
  Timer? _t;
  bool _gone = false;

  @override
  void initState() {
    super.initState();
    _t = Timer(const Duration(seconds: 7), _accept);
  }

  @override
  void dispose() {
    _t?.cancel();
    super.dispose();
  }

  void _accept() {
    if (_gone || !mounted) return;
    _gone = true;
    context.read<OrderProvider>().acceptOrder();
    context.replace(Routes.reserve);
  }

  void _reject() {
    if (_gone || !mounted) return;
    _gone = true;
    context.read<OrderProvider>().rejectOrder();
    context.replace(Routes.rejected);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.read<OrderProvider>().cart;
    return AppScaffold(
      title: 'Menunggu konfirmasi',
      canPop: false,
      body: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        StatusHeader(
          badgeChild: const Spin(size: 42),
          title: 'Menunggu ${c.name}',
          message: 'Permintaanmu sudah terkirim. Gerobak sedang memeriksa stok dan antrean.',
        ),
        const SizedBox(height: 16),
        const LoadingBar(seconds: 7),
        const SizedBox(height: 16),
        DemoBox(
          title: 'Simulasi respons gerobak',
          hint: 'Tanpa memilih, gerobak akan menerima dalam 7 detik.',
          children: [
            Row(spacing: 8, children: [
              Expanded(child: AppButton(label: 'Gerobak menerima', small: true, onPressed: _accept)),
              Expanded(
                child: AppButton(
                    label: 'Gerobak menolak', small: true, kind: BtnKind.line, onPressed: _reject),
              ),
            ]),
          ],
        ),
      ]),
    );
  }
}

class RejectedScreen extends StatelessWidget {
  const RejectedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final o = context.watch<OrderProvider>();
    return AppScaffold(
      title: 'Pesanan ditolak',
      canPop: false,
      footer: AppButton(
        label: 'Pilih gerobak lain atau ubah pesanan',
        onPressed: () => context.replace(Routes.adjust),
      ),
      body: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        StatusHeader(
          icon: Icons.close_rounded,
          kind: BadgeKind.bad,
          title: '${o.cart.name} belum bisa menerima',
          message: o.rejectReason,
        ),
        const SizedBox(height: 14),
        AppCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Tidak ada biaya yang dipotong.', style: body(context, size: 13, w: FontWeight.w700)),
            Text('Stok belum dicadangkan dan pesananmu masih tersimpan.', style: mut(context, 13)),
          ]),
        ),
      ]),
    );
  }
}

class AdjustOrderScreen extends StatelessWidget {
  const AdjustOrderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final o = context.watch<OrderProvider>();
    return AppScaffold(
      title: 'Ubah pesanan',
      canPop: false,
      footer: AppButton(
        label: 'Cari gerobak lain',
        onPressed: () => context.fromHome(Routes.explore),
      ),
      body: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Text('Ubah jumlah atau hapus menu dulu, lalu cari gerobak lain.', style: mut(context, 15)),
        const SizedBox(height: 6),
        if (o.items.isEmpty)
          const StatusHeader(
              icon: Icons.shopping_bag_outlined, title: 'Keranjang kosong', titleSize: 22)
        else ...[
          const CartEditor(),
          PriceSummary(subtotal: o.subtotal, fee: OrderProvider.serviceFee, total: o.total),
        ],
      ]),
    );
  }
}
