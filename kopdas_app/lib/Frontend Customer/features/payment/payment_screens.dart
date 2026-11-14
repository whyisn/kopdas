import 'dart:async';
import '../../core/core.dart';

class ReserveScreen extends StatefulWidget {
  const ReserveScreen({super.key});
  @override
  State<ReserveScreen> createState() => _ReserveScreenState();
}

class _ReserveScreenState extends State<ReserveScreen> {
  Timer? _t;
  bool _gone = false;

  @override
  void initState() {
    super.initState();
    _t = Timer(const Duration(milliseconds: 2400), _next);
  }

  @override
  void dispose() {
    _t?.cancel();
    super.dispose();
  }

  void _next() {
    if (_gone || !mounted) return;
    _gone = true;
    context.read<OrderProvider>().startPayment();
    context.replace(Routes.bill);
  }

  @override
  Widget build(BuildContext context) {
    final o = context.watch<OrderProvider>();
    return AppScaffold(
      title: 'Pesanan diterima',
      canPop: false,
      footer: AppButton(label: 'Lanjut ke pembayaran', onPressed: _next),
      body: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        const StatusHeader(
          icon: Icons.check_rounded,
          kind: BadgeKind.ok,
          title: 'Gerobak menerima pesananmu',
          message:
              'Stok untuk pesananmu dicadangkan sementara. Selesaikan pembayaran sebelum waktu habis.',
        ),
        const SizedBox(height: 14),
        AppCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Nomor pesanan ${o.orderCode}',
                style: body(context, size: 13, w: FontWeight.w700)),
            Text('Menyiapkan tagihan…', style: mut(context, 13)),
          ]),
        ),
      ]),
    );
  }
}

enum _PayPhase { idle, checking, notYet }

class BillScreen extends StatefulWidget {
  const BillScreen({super.key});
  @override
  State<BillScreen> createState() => _BillScreenState();
}

class _BillScreenState extends State<BillScreen> {
  Timer? _tick, _check;
  _PayPhase _phase = _PayPhase.idle;
  bool _gone = false;

  @override
  void initState() {
    super.initState();
    _tick = Timer.periodic(const Duration(milliseconds: 500), (_) {
      if (!mounted) return;
      if (context.read<OrderProvider>().remainingSeconds <= 0) {
        _expire();
      } else {
        setState(() {}); // segarkan hitung mundur
      }
    });
  }

  @override
  void dispose() {
    _tick?.cancel();
    _check?.cancel();
    super.dispose();
  }

  void _expire() {
    if (_gone || !mounted) return;
    _gone = true;
    context.replace(Routes.expired);
  }

  void _payCheck() {
    if (_phase == _PayPhase.checking || _gone) return;
    setState(() => _phase = _PayPhase.checking);
    _check = Timer(const Duration(milliseconds: 1200), () {
      if (!mounted || _gone) return;
      if (context.read<OrderProvider>().paymentReceived) {
        _gone = true;
        context.replace(Routes.paid);
      } else {
        setState(() => _phase = _PayPhase.notYet);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final o = context.watch<OrderProvider>();
    const methods = [
      (PayMethod.qris, 'QRIS'),
      (PayMethod.wallet, 'Dompet digital'),
      (PayMethod.va, 'Virtual account'),
    ];

    Widget detail() {
      switch (o.payMethod) {
        case PayMethod.qris:
          return Column(spacing: 10, children: [
            QrBox('PAY${o.orderCode}'),
            Text('Pindai dengan aplikasi bank atau dompet digital apa pun.',
                textAlign: TextAlign.center, style: mut(context, 13)),
          ]);
        case PayMethod.wallet:
          return Text(
            'Kamu akan diarahkan ke aplikasi dompet digital untuk menyetujui pembayaran (simulasi).',
            style: mut(context, 13),
          );
        case PayMethod.va:
          final tail = o.orderCode.length > 3 ? o.orderCode.substring(3) : o.orderCode;
          return Column(crossAxisAlignment: CrossAxisAlignment.start, spacing: 6, children: [
            Text('Transfer ke nomor virtual account:', style: mut(context, 13)),
            Text('8801 0812 $tail 7731',
                style: dsp(context, 22).copyWith(letterSpacing: .9)),
          ]);
      }
    }

    return AppScaffold(
      title: 'Tagihan pembayaran',
      canPop: false,
      footer: AppButton(
        label: _phase == _PayPhase.checking ? 'Memeriksa pembayaran…' : 'Cek status pembayaran',
        onPressed: _phase == _PayPhase.checking ? null : _payCheck,
      ),
      body: Column(crossAxisAlignment: CrossAxisAlignment.stretch, spacing: 14, children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(color: p.sun, borderRadius: BorderRadius.circular(18)),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Sisa waktu bayar',
                  style: body(context, size: 13, w: FontWeight.w700, color: p.onSun)),
              Text('Stok dicadangkan · waktu demo dipercepat',
                  style: body(context, size: 12, color: p.onSun)),
            ]),
            Text(mmss(o.remainingSeconds), style: dsp(context, 30, color: p.onSun)),
          ]),
        ),
        AppCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, spacing: 6, children: [
            Text('${o.cart.name} · ${o.orderCode}', style: mut(context, 15)),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('Total tagihan', style: body(context, size: 20, w: FontWeight.w800)),
              Text(rp(o.total), style: body(context, size: 20, w: FontWeight.w800)),
            ]),
          ]),
        ),
        for (final m in methods)
          RadioTile(
            label: m.$2,
            selected: o.payMethod == m.$1,
            onTap: () => o.setPayMethod(m.$1),
          ),
        AppCard(child: Align(alignment: Alignment.center, child: detail())),
        if (_phase == _PayPhase.notYet)
          Row(crossAxisAlignment: CrossAxisAlignment.start, spacing: 6, children: [
            Icon(Icons.warning_amber_rounded, size: 18, color: p.bad),
            Expanded(
              child: Text('Pembayaran belum masuk. Selesaikan sebelum waktu habis, lalu cek lagi.',
                  style: body(context, size: 13, w: FontWeight.w600, color: p.bad)),
            ),
          ]),
        DemoBox(title: 'Simulasi bank', children: [
          Row(spacing: 8, children: [
            Expanded(
              child: AppButton(
                label: 'Pembayaran masuk',
                small: true,
                onPressed: () {
                  o.markPaid();
                  _payCheck();
                },
              ),
            ),
            Expanded(
              child: AppButton(
                  label: 'Waktu habis', small: true, kind: BtnKind.line, onPressed: _expire),
            ),
          ]),
        ]),
      ]),
    );
  }
}

class ExpiredScreen extends StatefulWidget {
  const ExpiredScreen({super.key});
  @override
  State<ExpiredScreen> createState() => _ExpiredScreenState();
}

class _ExpiredScreenState extends State<ExpiredScreen> {
  Timer? _t;
  bool _released = false;

  @override
  void initState() {
    super.initState();
    _t = Timer(const Duration(milliseconds: 1800), () {
      if (mounted) setState(() => _released = true);
    });
  }

  @override
  void dispose() {
    _t?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Pesanan kedaluwarsa',
      canPop: false,
      footer: AppButton(
        label: 'Kembali ke Explore Coffee Cart',
        onPressed: _released ? () => context.fromHome(Routes.explore) : null,
      ),
      body: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        const StatusHeader(
          icon: Icons.schedule_rounded,
          kind: BadgeKind.bad,
          title: 'Pesanan kedaluwarsa',
          message: 'Kamu belum membayar sampai batas waktu. Tidak ada biaya yang dipotong.',
        ),
        const SizedBox(height: 18),
        Timeline([
          const TrackRow(TrkState.bad, 'Waktu pembayaran habis', 'Pembayaran tidak diterima'),
          TrackRow(
            _released ? TrkState.done : TrkState.now,
            'Reservasi stok dilepas',
            _released
                ? 'Stok kembali tersedia untuk pembeli lain'
                : 'Melepas stok yang dicadangkan',
          ),
        ]),
        const SizedBox(height: 18),
        Text('Pesanan lamamu masih ada di keranjang kalau mau mencoba lagi.',
            style: mut(context, 13)),
      ]),
    );
  }
}

class PaidScreen extends StatefulWidget {
  const PaidScreen({super.key});
  @override
  State<PaidScreen> createState() => _PaidScreenState();
}

class _PaidScreenState extends State<PaidScreen> {
  Timer? _t;
  bool _gone = false;

  @override
  void initState() {
    super.initState();
    _t = Timer(const Duration(seconds: 3), _next);
  }

  @override
  void dispose() {
    _t?.cancel();
    super.dispose();
  }

  void _next() {
    if (_gone || !mounted) return;
    _gone = true;
    context.replace(Routes.making);
  }

  @override
  Widget build(BuildContext context) {
    final o = context.watch<OrderProvider>();
    return AppScaffold(
      title: 'Pesanan dibayar',
      canPop: false,
      footer: AppButton(label: 'Lihat status pesanan', onPressed: _next),
      body: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        const StatusHeader(
          icon: Icons.check_rounded,
          kind: BadgeKind.ok,
          title: 'Pembayaran berhasil',
          message: 'Gerobak mulai menyiapkan kopimu.',
        ),
        const SizedBox(height: 14),
        AppCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text(o.cart.name, style: body(context, w: FontWeight.w700)),
              Text(o.orderCode, style: mut(context, 13)),
            ]),
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
