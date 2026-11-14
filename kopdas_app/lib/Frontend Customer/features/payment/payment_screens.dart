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
  Timer? _tick, _poll;
  _PayPhase _phase = _PayPhase.idle;
  bool _gone = false;

  @override
  void initState() {
    super.initState();
    // Inisialisasi QRIS Midtrans asli jika belum termuat
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final o = context.read<OrderProvider>();
      if (o.midtransQrString == null && o.backendOrderId.isNotEmpty) {
        o.initMidtransCharge('qris');
      }
    });

    // 1. Timer hitung mundur batas waktu pembayaran
    _tick = Timer.periodic(const Duration(milliseconds: 500), (_) {
      if (!mounted) return;
      if (context.read<OrderProvider>().remainingSeconds <= 0) {
        _expire();
      } else {
        setState(() {});
      }
    });

    // 2. Auto-poll status pembayaran dari backend secara realtime
    _poll = Timer.periodic(const Duration(seconds: 3), (_) async {
      if (!mounted || _gone) return;
      final o = context.read<OrderProvider>();
      final paid = await o.checkOrderStatus();
      if (paid && !_gone && mounted) {
        _gone = true;
        context.replace(Routes.paid);
      }
    });
  }

  @override
  void dispose() {
    _tick?.cancel();
    _poll?.cancel();
    super.dispose();
  }

  void _expire() {
    if (_gone || !mounted) return;
    _gone = true;
    context.replace(Routes.expired);
  }

  Future<void> _payCheck() async {
    if (_phase == _PayPhase.checking || _gone) return;
    setState(() => _phase = _PayPhase.checking);
    final o = context.read<OrderProvider>();
    final isPaid = await o.checkOrderStatus();

    if (!mounted || _gone) return;
    if (isPaid || o.paymentReceived) {
      _gone = true;
      context.replace(Routes.paid);
    } else {
      setState(() => _phase = _PayPhase.notYet);
    }
  }

  void _showSnapDialog(BuildContext context, OrderProvider o) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.payment, color: Color(0xFF1E3932)),
            SizedBox(width: 8),
            Text('Midtrans Snap Checkout', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Transaksi Midtrans Sandbox telah dibuat untuk pesanan ini:',
              style: TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Order ID: ${o.backendOrderId}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('Token Snap: ${o.midtransSnapToken ?? "Menyiapkan..."}', style: const TextStyle(fontSize: 11, color: Colors.black87)),
                  const SizedBox(height: 4),
                  Text('Client Key: ${o.midtransClientKey}', style: const TextStyle(fontSize: 11, color: Colors.black54)),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Pilih salah satu:',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            const Text(
              '1. Buka Redirect URL di tab browser baru untuk membayar via Sandbox Midtrans.\n2. Atau gunakan tombol simulasi settlement di bawah untuk konfirmasi instan.',
              style: TextStyle(fontSize: 12, color: Colors.black54, height: 1.4),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Tutup'),
          ),
          FilledButton.icon(
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFF1E3932)),
            onPressed: () async {
              Navigator.pop(ctx);
              await o.triggerMidtransLocalSimulation();
              await _payCheck();
            },
            icon: const Icon(Icons.check_circle_outline, size: 18),
            label: const Text('Simulasi Bayar Sukses'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final o = context.watch<OrderProvider>();
    const methods = [
      (PayMethod.qris, 'QRIS Resmi (Midtrans)'),
      (PayMethod.wallet, 'Midtrans Snap (GoPay / E-Wallet)'),
      (PayMethod.va, 'Virtual Account (Midtrans)'),
    ];

    Widget detail() {
      switch (o.payMethod) {
        case PayMethod.qris:
          final qrData = o.midtransQrString?.isNotEmpty == true
              ? o.midtransQrString!
              : '';
          final hasRealQr = qrData.isNotEmpty;

          return Column(spacing: 10, children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFECFDF5),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: const Color(0xFFA7F3D0)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.verified, size: 14, color: Color(0xFF065F46)),
                  const SizedBox(width: 4),
                  Text(
                    hasRealQr ? 'MIDTRANS CORE API QRIS (LIVE SANDBOX)' : 'MEMUAT QRIS DARI MIDTRANS…',
                    style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Color(0xFF065F46)),
                  ),
                ],
              ),
            ),
            if (hasRealQr)
              QrBox(qrData, size: 210)
            else
              Container(
                height: 200,
                width: 200,
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                alignment: Alignment.center,
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Spin(size: 32),
                    SizedBox(height: 12),
                    Text('Menghubungkan ke Midtrans…', style: TextStyle(fontSize: 12, color: Colors.black54)),
                  ],
                ),
              ),
            Text(
              'Pindai QRIS ini dengan BCA Mobile, GoPay, ShopeePay, OVO, Dana, atau mobile banking lainnya.',
              textAlign: TextAlign.center,
              style: mut(context, 12.5),
            ),
          ]);
        case PayMethod.wallet:
          return Column(
            children: [
              Text(
                'Pembayaran multi-channel didukung oleh Midtrans Payment Gateway.',
                textAlign: TextAlign.center,
                style: mut(context, 13),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () => _showSnapDialog(context, o),
                  icon: const Icon(Icons.open_in_new, size: 18),
                  label: const Text('Buka Antarmuka Midtrans Snap'),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF1E3932),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],
          );
        case PayMethod.va:
          final tail = o.orderCode.length > 3 ? o.orderCode.substring(3) : o.orderCode;
          return Column(crossAxisAlignment: CrossAxisAlignment.start, spacing: 6, children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: const Color(0xFFBFDBFE)),
              ),
              child: const Text(
                'MIDTRANS VIRTUAL ACCOUNT',
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF1D4ED8)),
              ),
            ),
            const SizedBox(height: 4),
            Text('Transfer ke nomor virtual account BCA/Mandiri/BRI:', style: mut(context, 13)),
            Text('8801 0812 $tail 7731',
                style: dsp(context, 22).copyWith(letterSpacing: .9)),
            Text('Nama Merchant: KopiCerdas Padang', style: mut(context, 12)),
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
          decoration: BoxDecoration(color: p.sun, borderRadius: BorderRadius.circular(12)),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Sisa waktu bayar',
                  style: body(context, size: 13, w: FontWeight.w700, color: p.onSun)),
              Text('Stok dicadangkan di database',
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
            if (o.backendOrderId.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text('ID Database: ${o.backendOrderId}', style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280))),
            ],
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
        DemoBox(title: 'Pengujian Webhook Midtrans (Notifikasi Lokal)', children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Endpoint Notifikasi Midtrans:\n${o.midtransNotificationUrl}',
                style: const TextStyle(fontSize: 10.5, color: Color(0xFF6B7280))),
            const SizedBox(height: 8),
            Row(spacing: 8, children: [
              Expanded(
                child: AppButton(
                  label: 'Kirim Webhook Settlement (Bayar Sukses)',
                  small: true,
                  onPressed: () async {
                    await o.triggerMidtransLocalSimulation();
                    await _payCheck();
                  },
                ),
              ),
              Expanded(
                child: AppButton(
                    label: 'Kedaluwarsa', small: true, kind: BtnKind.line, onPressed: _expire),
              ),
            ]),
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
