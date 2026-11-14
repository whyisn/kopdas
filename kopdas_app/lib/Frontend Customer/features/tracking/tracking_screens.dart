import 'dart:async';
import '../../core/core.dart';

/// Layar Pemantauan Status Pesanan Real-Time yang terhubung langsung ke Backend SQLite & Seller
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
    // Real-time polling ke backend SQLite setiap 2 detik untuk memeriksa status dari Seller
    _poll = Timer.periodic(const Duration(seconds: 2), (_) async {
      if (!mounted || _gone) return;
      final o = context.read<OrderProvider>();
      await o.checkOrderStatus();
      if (o.orderStatus == 'COMPLETED') {
        _finish();
      } else if (mounted) {
        setState(() {});
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
    final st = o.orderStatus;
    final isPreparing = st == 'PREPARING';
    final isReady = st == 'READY_FOR_PICKUP';

    String statusTitle;
    String statusSubtitle;
    IconData statusIcon;
    Color statusColor;

    if (isReady) {
      statusTitle = 'Pesanan Siap Diambil!';
      statusSubtitle = 'Silakan ambil minumanmu di gerobak ${c.name}.';
      statusIcon = Icons.check_circle_rounded;
      statusColor = const Color(0xFF059669);
    } else if (isPreparing) {
      statusTitle = 'Barista Sedang Menyiapkan Minuman';
      statusSubtitle = 'Minumanmu sedang diracik segar oleh barista di gerobak.';
      statusIcon = Icons.coffee_maker_rounded;
      statusColor = const Color(0xFFD97706);
    } else {
      statusTitle = 'Pesanan Diterima';
      statusSubtitle = 'Pembayaran terverifikasi. Menunggu antrean barista di gerobak.';
      statusIcon = Icons.receipt_long_rounded;
      statusColor = const Color(0xFF1E3932);
    }

    return AppScaffold(
      title: 'Status Pesanan',
      canPop: false,
      footer: isReady
          ? AppButton(
              label: 'Pesanan Sudah Saya Terima',
              icon: Icons.check_circle_outline,
              onPressed: _finish,
            )
          : null,
      body: Column(crossAxisAlignment: CrossAxisAlignment.stretch, spacing: 14, children: [
        // Header Nomor Pesanan
        Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: context.pal.line),
          ),
          child: Column(spacing: 6, children: [
            Text('NOMOR PESANAN RESMI',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: context.pal.muted, letterSpacing: 1.2)),
            Text(o.orderCode,
                style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: Color(0xFF1E3932), letterSpacing: 2)),
            Text('Tunjukkan nomor pesanan ini ke barista saat mengambil minuman.',
                textAlign: TextAlign.center, style: TextStyle(fontSize: 12.5, color: context.pal.muted)),
          ]),
        ),

        // Kartu Status Lifecycle
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: statusColor.withValues(alpha: 0.3)),
          ),
          child: Row(children: [
            Icon(statusIcon, size: 36, color: statusColor),
            const SizedBox(width: 14),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, spacing: 3, children: [
                Text(statusTitle, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: statusColor)),
                Text(statusSubtitle, style: TextStyle(fontSize: 12.5, color: Colors.black87)),
              ]),
            ),
          ]),
        ),

        // Timeline Tahapan Pesanan
        Timeline([
          TrackRow(TrkState.done, 'Pembayaran Terverifikasi', 'Lunas via Midtrans QRIS'),
          TrackRow(
            isPreparing || isReady ? (isReady ? TrkState.done : TrkState.now) : TrkState.todo,
            'Barista Menyiapkan Minuman',
            isPreparing ? 'Kopi sedang diracik barista' : (isReady ? 'Selesai dibuat' : 'Menunggu antrean'),
          ),
          TrackRow(
            isReady ? TrkState.now : TrkState.todo,
            'Siap Diambil di Gerobak',
            c.spot,
          ),
        ]),

        // Info Gerobak & Pesanan
        AppCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, spacing: 4, children: [
            Row(children: [
              const Icon(Icons.storefront_rounded, size: 18, color: Color(0xFF1E3932)),
              const SizedBox(width: 6),
              Text(c.name, style: body(context, w: FontWeight.w700)),
            ]),
            Text(c.spot, style: mut(context, 12.5)),
            const Divider(height: 18),
            OrderLines(o.items),
          ]),
        ),
      ]),
    );
  }
}

/// Redirect helper untuk kompatibilitas route
class ReadyScreen extends StatelessWidget {
  const ReadyScreen({super.key});
  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) => context.replace(Routes.making));
    return const Scaffold(body: Center(child: Spin()));
  }
}

class PickupCodeScreen extends StatelessWidget {
  const PickupCodeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) => context.replace(Routes.making));
    return const Scaffold(body: Center(child: Spin()));
  }
}

class ArriveScreen extends StatelessWidget {
  const ArriveScreen({super.key});
  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) => context.replace(Routes.making));
    return const Scaffold(body: Center(child: Spin()));
  }
}

class VerifyScreen extends StatelessWidget {
  const VerifyScreen({super.key});
  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) => context.replace(Routes.making));
    return const Scaffold(body: Center(child: Spin()));
  }
}

class HandoverScreen extends StatelessWidget {
  const HandoverScreen({super.key});
  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) => context.replace(Routes.making));
    return const Scaffold(body: Center(child: Spin()));
  }
}

class DoneScreen extends StatelessWidget {
  const DoneScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final o = context.watch<OrderProvider>();
    return AppScaffold(
      title: 'Pesanan Selesai',
      canPop: false,
      footer: AppButton(
        label: 'Beri Rating & Review',
        onPressed: () => context.replace(Routes.review),
      ),
      body: Column(crossAxisAlignment: CrossAxisAlignment.stretch, spacing: 14, children: [
        const StatusHeader(
          icon: Icons.check_circle_rounded,
          kind: BadgeKind.ok,
          title: 'Pesanan Telah Diterima!',
          message: 'Minumanmu telah diserahkan oleh barista. Selamat menikmati!',
        ),
        AppCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, spacing: 6, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text(o.cart.name, style: body(context, w: FontWeight.w700)),
              Text(clockText(), style: mut(context, 13)),
            ]),
            Text('Nomor Pesanan: ${o.orderCode}', style: mut(context, 13)),
            const Divider(height: 16),
            OrderLines(o.items),
            const Divider(height: 16),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('Total Lunas', style: body(context, size: 16, w: FontWeight.w800)),
              Text(rp(o.total), style: body(context, size: 16, w: FontWeight.w800, color: const Color(0xFF1E3932))),
            ]),
          ]),
        ),
      ]),
    );
  }
}
