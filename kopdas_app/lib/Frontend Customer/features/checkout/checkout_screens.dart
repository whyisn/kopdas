import 'dart:async';
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
        label: 'Lanjut ke Pembayaran',
        onPressed: () => context.push(Routes.waiting),
      ),
      body: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        CartInfoCard(title: 'Ambil di ${c.name}', subtitle: '${c.spot} · ${fmtDist(o.distance(c))}'),
        const SectionTitle('Waktu Ambil'),
        Wrap(spacing: 8, runSpacing: 8, children: [
          for (final t in MockData.pickupTimes)
            AppChip(label: t, selected: o.pickup == t, onTap: () => o.setPickup(t)),
        ]),
        const SectionTitle('Rincian Pesanan'),
        OrderLines(o.items),
        PriceSummary(subtotal: o.subtotal, fee: OrderProvider.serviceFee, total: o.total),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              const Icon(Icons.check_circle_outline, size: 18, color: Color(0xFF1E3932)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Stok produk di gerobak ${c.name} akan langsung diverifikasi saat checkout.',
                  style: TextStyle(fontSize: 12.5, color: context.pal.muted),
                ),
              ),
            ],
          ),
        ),
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
    _startOrderProcess();
  }

  Future<void> _startOrderProcess() async {
    final orderProv = context.read<OrderProvider>();
    final success = await orderProv.createRealOrder();
    
    // Beri jeda halus agar transisi verifikasi stok terlihat natural
    _t = Timer(const Duration(milliseconds: 1500), () {
      if (_gone || !mounted) return;
      _gone = true;
      if (success) {
        context.replace(Routes.reserve);
      } else {
        context.replace(Routes.rejected);
      }
    });
  }

  @override
  void dispose() {
    _t?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.read<OrderProvider>().cart;
    final o = context.watch<OrderProvider>();
    return AppScaffold(
      title: 'Menghubungkan ke gerobak',
      canPop: false,
      body: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        StatusHeader(
          badgeChild: const Spin(size: 44),
          title: 'Memverifikasi dengan ${c.name}',
          message: 'Sistem sedang mencadangkan stok ${o.count} item di database gerobak dan menyiapkan jalur pembayaran Midtrans.',
        ),
        const SizedBox(height: 24),
        const LoadingBar(seconds: 2),
        const SizedBox(height: 20),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.shield_outlined, size: 18, color: Color(0xFF1E3932)),
                  const SizedBox(width: 8),
                  Text('Validasi Stok Real-Time', style: body(context, w: FontWeight.w700)),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Pesanan dikirimkan langsung ke antrean seller di titik ${c.name}.',
                style: mut(context, 13),
              ),
            ],
          ),
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
