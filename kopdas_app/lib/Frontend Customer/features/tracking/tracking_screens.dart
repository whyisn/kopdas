import 'dart:async';
import '../../core/core.dart';

class MakingScreen extends StatefulWidget {
  const MakingScreen({super.key});
  @override
  State<MakingScreen> createState() => _MakingScreenState();
}

class _MakingScreenState extends State<MakingScreen> {
  Timer? _t;
  bool _gone = false;

  @override
  void initState() {
    super.initState();
    _t = Timer(const Duration(seconds: 7), _next);
  }

  @override
  void dispose() {
    _t?.cancel();
    super.dispose();
  }

  void _next() {
    if (_gone || !mounted) return;
    _gone = true;
    context.replace(Routes.ready);
  }

  @override
  Widget build(BuildContext context) {
    final o = context.watch<OrderProvider>();
    final c = o.cart;
    final eta = c.waitMinutes + o.count;
    return AppScaffold(
      title: 'Menyiapkan kopi',
      canPop: false,
      footer: AppButton(label: 'Percepat (demo)', kind: BtnKind.alt, onPressed: _next),
      body: Column(crossAxisAlignment: CrossAxisAlignment.stretch, spacing: 14, children: [
        Column(spacing: 8, children: [
          Text('Nomor pesanan', style: mut(context, 13)),
          Text(o.orderCode, style: dsp(context, 34).copyWith(letterSpacing: 2)),
        ]),
        Timeline([
          TrackRow(TrkState.done, 'Pesanan dibayar', '${c.name} menerima pembayaranmu'),
          TrackRow(TrkState.now, 'Gerobak menyiapkan kopi',
              'Barista membuat ${o.count} item · ± $eta menit'),
          const TrackRow(TrkState.todo, 'Siap diambil'),
        ]),
        const LoadingBar(seconds: 7),
        Text('Waktu pada demo ini dipercepat.', style: mut(context, 12)),
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
      title: 'Pesanan siap',
      canPop: false,
      footer: AppButton(label: 'Buka notifikasi', onPressed: () => context.replace(Routes.pickupCode)),
      body: Column(crossAxisAlignment: CrossAxisAlignment.stretch, spacing: 18, children: [
        const SizedBox(height: 6),
        NotifCard(
          cartName: o.cart.name,
          code: o.orderCode,
          onTap: () => context.replace(Routes.pickupCode),
        ),
        StatusHeader(
          icon: Icons.check_rounded,
          kind: BadgeKind.ok,
          title: 'Pesananmu siap diambil',
          message:
              'Barista ${o.cart.name} sudah menyiapkan kopimu. Ketuk notifikasi untuk membuka kode pickup.',
        ),
      ]),
    );
  }
}

class PickupCodeScreen extends StatelessWidget {
  const PickupCodeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final o = context.watch<OrderProvider>();
    return AppScaffold(
      title: 'Kode pickup',
      canPop: false,
      footer: AppButton(
        label: 'Menuju gerobak',
        icon: Icons.directions_walk_rounded,
        onPressed: () => context.replace(Routes.arrive),
      ),
      body: Column(crossAxisAlignment: CrossAxisAlignment.center, spacing: 14, children: [
        const SizedBox(height: 6),
        NotifCard(cartName: o.cart.name, code: o.orderCode),
        QrBox(o.orderCode),
        Text(o.orderCode, style: dsp(context, 44).copyWith(letterSpacing: 2.6)),
        Text('Simpan kode ini. Barista akan memintanya saat kamu tiba di gerobak.',
            textAlign: TextAlign.center, style: mut(context, 15)),
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
          borderRadius: BorderRadius.circular(20),
          child: Container(
            height: 200,
            decoration: BoxDecoration(
                border: Border.all(color: p.line), borderRadius: BorderRadius.circular(20)),
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
      title: 'Verifikasi kode',
      canPop: false,
      footer: AppButton(
        label: 'Simulasi: barista memverifikasi kode',
        kind: BtnKind.alt,
        onPressed: () {
          o.initReceived();
          context.replace(Routes.handover);
        },
      ),
      body: Column(crossAxisAlignment: CrossAxisAlignment.center, spacing: 14, children: [
        const SizedBox(height: 6),
        QrBox(o.orderCode),
        Text(o.orderCode, style: dsp(context, 44).copyWith(letterSpacing: 2.6)),
        Text('Tunjukkan layar ini ke barista ${o.cart.name} untuk diverifikasi.',
            textAlign: TextAlign.center, style: mut(context, 15)),
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
