import 'dart:async';
import '../../core/core.dart';

class MakingScreen extends StatefulWidget {
  const MakingScreen({super.key});
  @override
  State<MakingScreen> createState() => _MakingScreenState();
}

class _MakingScreenState extends State<MakingScreen> {
  Timer? _poll;
  bool _gone = false;

  @override
  void initState() {
    super.initState();
    // Realtime polling ke database backend untuk mendengarkan perubahan status dari Seller
    _poll = Timer.periodic(const Duration(seconds: 2), (_) async {
      if (!mounted || _gone) return;
      final o = context.read<OrderProvider>();
      await o.checkOrderStatus();
      if (o.orderStatus == 'READY_FOR_PICKUP') {
        _goToPickup();
      } else if (o.orderStatus == 'COMPLETED') {
        _goToDone();
      }
    });
  }

  @override
  void dispose() {
    _poll?.cancel();
    super.dispose();
  }

  void _goToPickup() {
    if (_gone || !mounted) return;
    _gone = true;
    context.replace(Routes.pickupCode);
  }

  void _goToDone() {
    if (_gone || !mounted) return;
    _gone = true;
    context.replace(Routes.done);
  }

  @override
  Widget build(BuildContext context) {
    final o = context.watch<OrderProvider>();
    final c = o.cart;
    final isPreparing = o.orderStatus == 'PREPARING';

    return AppScaffold(
      title: 'Status Pesanan',
      canPop: false,
      footer: AppButton(
        label: 'Lihat Barcode Pengambilan',
        icon: Icons.qr_code_scanner_rounded,
        onPressed: _goToPickup,
      ),
      body: Column(crossAxisAlignment: CrossAxisAlignment.stretch, spacing: 14, children: [
        Column(spacing: 6, children: [
          Text('Nomor Pesanan Anda', style: mut(context, 13)),
          Text(o.orderCode, style: dsp(context, 30).copyWith(letterSpacing: 2, fontWeight: FontWeight.w800)),
        ]),
        Timeline([
          TrackRow(TrkState.done, 'Pembayaran Terkonfirmasi', '${c.name} telah menerima order'),
          TrackRow(
            isPreparing ? TrkState.now : TrkState.todo,
            'Barista Menyiapkan Kopi',
            isPreparing ? 'Kopi sedang diracik barista' : 'Menunggu antrean barista',
          ),
          const TrackRow(TrkState.todo, 'Siap Diambil di Gerobak', 'Tunjukkan barcode ke seller'),
        ]),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Spin(size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  isPreparing
                      ? 'Barista sedang membuat pesananmu. Layar akan beralih otomatis saat siap.'
                      : 'Menunggu konfirmasi pembuatan dari barista gerobak...',
                  style: body(context, size: 13, w: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
        AppCard(child: OrderLines(o.items)),
      ]),
    );
  }
}

class ReadyScreen extends StatelessWidget {
  const ReadyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final o = context.watch<OrderProvider>();
    return AppScaffold(
      title: 'Pesanan Siap',
      canPop: false,
      footer: AppButton(
        label: 'Buka Barcode Pengambilan',
        icon: Icons.qr_code_2_rounded,
        onPressed: () => context.replace(Routes.pickupCode),
      ),
      body: Column(crossAxisAlignment: CrossAxisAlignment.stretch, spacing: 18, children: [
        const SizedBox(height: 6),
        NotifCard(
          cartName: o.cart.name,
          code: o.orderCode,
          onTap: () => context.replace(Routes.pickupCode),
        ),
        StatusHeader(
          icon: Icons.check_circle_rounded,
          kind: BadgeKind.ok,
          title: 'Pesananmu Siap Diambil!',
          message:
              'Barista ${o.cart.name} sudah selesai membuat pesananmu. Ketuk tombol di bawah untuk menampilkan barcode pengambilan barang.',
        ),
      ]),
    );
  }
}

class PickupCodeScreen extends StatefulWidget {
  const PickupCodeScreen({super.key});

  @override
  State<PickupCodeScreen> createState() => _PickupCodeScreenState();
}

class _PickupCodeScreenState extends State<PickupCodeScreen> {
  Timer? _poll;
  bool _gone = false;

  @override
  void initState() {
    super.initState();
    // Auto-poll mendengarkan seller mengklik "Serahkan ke Pelanggan (COMPLETED)"
    _poll = Timer.periodic(const Duration(seconds: 2), (_) async {
      if (!mounted || _gone) return;
      final o = context.read<OrderProvider>();
      await o.checkOrderStatus();
      if (o.orderStatus == 'COMPLETED') {
        _finish();
      }
    });
  }

  @override
  void dispose() {
    _poll?.cancel();
    super.dispose();
  }

  void _finish() {
    if (_gone || !mounted) return;
    _gone = true;
    context.replace(Routes.done);
  }

  @override
  Widget build(BuildContext context) {
    final o = context.watch<OrderProvider>();
    final c = o.cart;

    return AppScaffold(
      title: 'Barcode Pengambilan Barang',
      canPop: false,
      footer: AppButton(
        label: 'Pesanan Sudah Saya Terima',
        icon: Icons.check_circle_outline,
        onPressed: _finish,
      ),
      body: Column(crossAxisAlignment: CrossAxisAlignment.stretch, spacing: 14, children: [
        StatusHeader(
          icon: Icons.qr_code_scanner_rounded,
          kind: BadgeKind.ok,
          title: 'Barcode Pengambilan Barang',
          message: 'Tunjukkan Barcode atau QR code berikut kepada barista ${c.name} saat mengambil minuman.',
        ),
        Center(child: BarcodeBox(o.orderCode)),
        const SizedBox(height: 4),
        Center(child: QrBox(o.orderCode, size: 170)),
        const SizedBox(height: 6),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.location_on, size: 18, color: Color(0xFF1E3932)),
                  const SizedBox(width: 6),
                  Text(c.name, style: body(context, w: FontWeight.w700)),
                ],
              ),
              const SizedBox(height: 2),
              Text(c.spot, style: mut(context, 12)),
              const Divider(height: 16),
              OrderLines(o.items),
            ],
          ),
        ),
      ]),
    );
  }
}

class ArriveScreen extends StatelessWidget {
  const ArriveScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final o = context.watch<OrderProvider>();
    final c = o.cart;
    return AppScaffold(
      title: 'Datang ke gerobak',
      canPop: false,
      footer: AppButton(
        label: 'Saya sudah tiba di gerobak',
        onPressed: () => context.replace(Routes.verify),
      ),
      body: Column(crossAxisAlignment: CrossAxisAlignment.stretch, spacing: 14, children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Container(
            height: 200,
            decoration: BoxDecoration(
                border: Border.all(color: p.line), borderRadius: BorderRadius.circular(12)),
            child: MapView(pins: [c]),
          ),
        ),
        AppCard(
          child: Row(spacing: 12, children: [
            Icon(Icons.directions_walk_rounded, color: p.accent),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(c.name, style: body(context, w: FontWeight.w700)),
                Text('${c.spot} · ${fmtDist(o.distance(c))} dari lokasimu', style: mut(context, 13)),
              ]),
            ),
          ]),
        ),
        Text('Jalan ke gerobak, lalu beri tahu barista bahwa kamu sudah tiba.',
            style: mut(context, 15)),
      ]),
    );
  }
}

class VerifyScreen extends StatelessWidget {
  const VerifyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final o = context.watch<OrderProvider>();
    return AppScaffold(
      title: 'Verifikasi Kode',
      canPop: false,
      footer: AppButton(
        label: 'Pesanan Selesai Diterima',
        icon: Icons.check_circle_outline,
        onPressed: () {
          o.initReceived();
          context.replace(Routes.done);
        },
      ),
      body: Column(crossAxisAlignment: CrossAxisAlignment.center, spacing: 14, children: [
        const SizedBox(height: 6),
        BarcodeBox(o.orderCode),
        const SizedBox(height: 4),
        QrBox(o.orderCode, size: 170),
        Text('Tunjukkan Barcode atau Kode Pesanan ini ke barista ${o.cart.name}.',
            textAlign: TextAlign.center, style: mut(context, 14)),
        AppCard(child: OrderLines(o.items)),
      ]),
    );
  }
}

class HandoverScreen extends StatelessWidget {
  const HandoverScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final o = context.watch<OrderProvider>();
    final all = o.items.isNotEmpty &&
        o.received.length == o.items.length &&
        o.received.every((e) => e);
    return AppScaffold(
      title: 'Pesanan diserahkan',
      canPop: false,
      footer: AppButton(
        label: 'Kopi sudah saya terima',
        onPressed: all ? () => context.replace(Routes.done) : null,
      ),
      body: Column(crossAxisAlignment: CrossAxisAlignment.stretch, spacing: 10, children: [
        const StatusHeader(
          icon: Icons.check_rounded,
          kind: BadgeKind.ok,
          title: 'Kode terverifikasi',
          message: 'Barista menyerahkan pesananmu. Periksa setiap item sebelum pergi.',
        ),
        const SizedBox(height: 8),
        for (var i = 0; i < o.items.length; i++)
          ChoiceTile(
            round: true,
            activeColor: context.pal.ok,
            selected: i < o.received.length && o.received[i],
            onTap: () => o.toggleReceived(i),
            label: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('${o.items[i].qty}× ${o.items[i].name}',
                  style: body(context, w: FontWeight.w700)),
              Text(o.items[i].optText, style: mut(context, 13)),
            ]),
          ),
      ]),
    );
  }
}

class DoneScreen extends StatelessWidget {
  const DoneScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final o = context.watch<OrderProvider>();
    return AppScaffold(
      title: 'Pesanan selesai',
      canPop: false,
      footer: AppButton(label: 'Beri rating dan review', onPressed: () => context.replace(Routes.review)),
      body: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        const StatusHeader(
          icon: Icons.check_rounded,
          kind: BadgeKind.ok,
          title: 'Pesanan selesai',
          message: 'Selamat menikmati. Terima kasih sudah membeli dari gerobak.',
        ),
        const SizedBox(height: 14),
        AppCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text(o.cart.name, style: body(context, w: FontWeight.w700)),
              Text(clockText(), style: mut(context, 13)),
            ]),
            Text('Nomor ${o.orderCode}', style: mut(context, 13)),
            OrderLines(o.items),
            Divider(color: context.pal.line),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('Total dibayar', style: body(context, size: 17, w: FontWeight.w800)),
              Text(rp(o.total), style: body(context, size: 17, w: FontWeight.w800)),
            ]),
          ]),
        ),
      ]),
    );
  }
}
