import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../data/models/cart_item.dart';
import '../../data/models/product.dart';
import '../../providers/order_provider.dart';
import '../theme/app_theme.dart';
import '../utils/format.dart';
import 'illustrations.dart';

// ───────────────────────── Kerangka layar ─────────────────────────

class AppScaffold extends StatelessWidget {
  final String? title;
  final bool back;
  final Widget? action;
  final Widget body;
  final Widget? footer;
  final bool scroll;
  final bool canPop;

  const AppScaffold({
    super.key,
    this.title,
    this.back = false,
    this.action,
    required this.body,
    this.footer,
    this.scroll = true,
    this.canPop = true,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    return PopScope(
      canPop: canPop,
      child: Scaffold(
        backgroundColor: p.bg,
        body: SafeArea(
          child: Column(children: [
            if (title != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                decoration: BoxDecoration(
                  color: p.surface,
                  border: Border(bottom: BorderSide(color: p.line)),
                ),
                child: SizedBox(
                  height: 44,
                  child: Row(children: [
                    if (back) ...[
                      IconBtn(
                        icon: Icons.arrow_back_ios_new_rounded,
                        label: 'Kembali',
                        onTap: () => Navigator.of(context).maybePop(),
                      ),
                      const SizedBox(width: 12),
                    ],
                    Expanded(
                      child: Text(title!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: dsp(context, 18, w: FontWeight.w800, color: p.ink)),
                    ),
                    ?action,
                  ]),
                ),
              ),
            Expanded(
              child: scroll
                  ? SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 6, 20, 24),
                      child: body,
                    )
                  : body,
            ),
            if (footer != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 14),
                decoration: BoxDecoration(
                  color: p.surface,
                  border: Border(top: BorderSide(color: p.line)),
                ),
                child: footer,
              ),
          ]),
        ),
      ),
    );
  }
}

// ───────────────────────── Kontrol dasar ─────────────────────────

class IconBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const IconBtn({super.key, required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    return Semantics(
      button: true,
      label: label,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: p.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: p.line),
          ),
          child: Icon(icon, size: 18, color: p.ink),
        ),
      ),
    );
  }
}

enum BtnKind { primary, alt, sun, line }

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final BtnKind kind;
  final bool small;
  final IconData? icon;
  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.kind = BtnKind.primary,
    this.small = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    late Color bg, fg;
    BorderSide? side;
    switch (kind) {
      case BtnKind.primary:
        bg = p.accent;
        fg = p.onAccent;
      case BtnKind.alt:
        bg = p.surface2;
        fg = p.ink;
      case BtnKind.sun:
        bg = p.sun;
        fg = p.onSun;
      case BtnKind.line:
        bg = Colors.transparent;
        fg = p.ink;
        side = BorderSide(color: p.line, width: 1.5);
    }
    return SizedBox(
      width: double.infinity,
      height: small ? 42 : 52,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: bg,
          foregroundColor: fg,
          disabledBackgroundColor: bg.withValues(alpha: .4),
          disabledForegroundColor: fg.withValues(alpha: .4),
          side: side,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          if (icon != null) ...[Icon(icon, size: 20), const SizedBox(width: 8)],
          Flexible(
            child: Text(label,
                textAlign: TextAlign.center,
                style: body(context,
                    size: small ? 14 : 15,
                    w: FontWeight.w700,
                    color: onPressed == null ? fg.withValues(alpha: .4) : fg)),
          ),
        ]),
      ),
    );
  }
}

class AppField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String? hint;
  final bool obscure;
  final int maxLines;
  final ValueChanged<String>? onChanged;
  final TextInputType? keyboardType;
  const AppField({
    super.key,
    required this.label,
    required this.controller,
    this.hint,
    this.obscure = false,
    this.maxLines = 1,
    this.onChanged,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    OutlineInputBorder border(Color c) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: c, width: 1.5),
        );
    return Column(crossAxisAlignment: CrossAxisAlignment.start, spacing: 6, children: [
      Text(label, style: body(context, size: 13, w: FontWeight.w600, color: p.muted)),
      TextField(
        controller: controller,
        obscureText: obscure,
        maxLines: maxLines,
        minLines: maxLines,
        onChanged: onChanged,
        keyboardType: keyboardType,
        style: body(context),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: body(context, color: p.muted.withValues(alpha: .7)),
          filled: true,
          fillColor: p.surface,
          contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: maxLines > 1 ? 12 : 15),
          enabledBorder: border(p.line),
          focusedBorder: border(p.accent),
        ),
      ),
    ]);
  }
}

class AppChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const AppChip({super.key, required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    return Semantics(
      button: true,
      selected: selected,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 15),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? p.accent : p.surface,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: selected ? p.accent : p.line, width: 1.5),
          ),
          child: Text(label,
              style: body(context,
                  size: 14, w: FontWeight.w600, color: selected ? p.onAccent : p.ink)),
        ),
      ),
    );
  }
}

class Pill extends StatelessWidget {
  final String text;
  final bool ok;
  const Pill(this.text, {super.key, this.ok = true});

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: ok ? const Color(0xFFECFDF5) : p.surface2,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: ok ? const Color(0xFFA7F3D0) : p.line),
      ),
      child: Text(text,
          style: body(context,
              size: 11.5,
              w: FontWeight.w700,
              color: ok ? const Color(0xFF065F46) : p.muted)),
    );
  }
}

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  const AppCard({super.key, required this.child, this.padding = const EdgeInsets.all(14)});

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: p.line),
      ),
      child: child,
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String text;
  const SectionTitle(this.text, {super.key});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 22, bottom: 10),
        child: Text(text.toUpperCase(),
            style: body(context, size: 13, w: FontWeight.w700, color: context.pal.muted)
                .copyWith(letterSpacing: .9)),
      );
}

class QtyStepper extends StatelessWidget {
  final int value;
  final VoidCallback onMinus, onPlus;
  const QtyStepper({super.key, required this.value, required this.onMinus, required this.onPlus});

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    Widget sq(IconData i, String label, VoidCallback f) => Semantics(
          button: true,
          label: label,
          child: GestureDetector(
            onTap: f,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(color: p.surface, borderRadius: BorderRadius.circular(9)),
              child: Icon(i, size: 18, color: p.ink),
            ),
          ),
        );
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(color: p.surface2, borderRadius: BorderRadius.circular(12)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        sq(Icons.remove, 'Kurangi', onMinus),
        SizedBox(
          width: 32,
          child: Text('$value',
              textAlign: TextAlign.center, style: body(context, w: FontWeight.w800)),
        ),
        sq(Icons.add, 'Tambah', onPlus),
      ]),
    );
  }
}

/// Baris pilihan bergaya checkbox (add-on, centang serah terima).
class ChoiceTile extends StatelessWidget {
  final Widget label;
  final Widget? trailing;
  final bool selected;
  final VoidCallback onTap;
  final bool round;
  final Color? activeColor;
  const ChoiceTile({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.trailing,
    this.round = false,
    this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final active = activeColor ?? p.accent;
    return Semantics(
      checked: selected,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 48),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: selected ? Color.alphaBlend(active.withValues(alpha: .10), p.surface) : p.surface,
            borderRadius: BorderRadius.circular(round ? 14 : 12),
            border: Border.all(color: selected ? active : p.line, width: 1.5),
          ),
          child: Row(children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: selected ? active : Colors.transparent,
                borderRadius: BorderRadius.circular(round ? 11 : 7),
                border: Border.all(color: selected ? active : p.line, width: 2),
              ),
              child: selected
                  ? Icon(Icons.check_rounded, size: 14, color: p.onAccent)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(child: label),
            ?trailing,
          ]),
        ),
      ),
    );
  }
}

class RadioTile extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const RadioTile({super.key, required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          color: selected ? Color.alphaBlend(p.accent.withValues(alpha: .10), p.surface) : p.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: selected ? p.accent : p.line, width: 1.5),
        ),
        child: Row(children: [
          Container(
            width: 20,
            height: 20,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: selected ? p.accent : p.line, width: 2),
            ),
            child: selected
                ? Container(width: 10, height: 10,
                    decoration: BoxDecoration(color: p.accent, shape: BoxShape.circle))
                : null,
          ),
          const SizedBox(width: 12),
          Text(label, style: body(context, w: FontWeight.w700)),
        ]),
      ),
    );
  }
}

// ───────────────────────── Status & info ─────────────────────────

enum BadgeKind { neutral, ok, bad, warn }

class BadgeIcon extends StatelessWidget {
  final IconData? icon;
  final Widget? child;
  final BadgeKind kind;
  const BadgeIcon({super.key, this.icon, this.child, this.kind = BadgeKind.neutral});

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    late Color bg, fg;
    switch (kind) {
      case BadgeKind.ok:
        bg = p.ok.withValues(alpha: .16);
        fg = p.ok;
      case BadgeKind.bad:
        bg = p.bad.withValues(alpha: .14);
        fg = p.bad;
      case BadgeKind.warn:
        bg = p.sun.withValues(alpha: .24);
        fg = p.ink;
      case BadgeKind.neutral:
        bg = p.surface2;
        fg = p.ink;
    }
    return Container(
      width: 96,
      height: 96,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(30)),
      child: child ?? Icon(icon, size: 46, color: fg),
    );
  }
}

/// Kepala status: badge ikon + judul + teks, rata tengah.
class StatusHeader extends StatelessWidget {
  final IconData? icon;
  final Widget? badgeChild;
  final BadgeKind kind;
  final String title;
  final String? message;
  final double titleSize;
  const StatusHeader({
    super.key,
    this.icon,
    this.badgeChild,
    this.kind = BadgeKind.neutral,
    required this.title,
    this.message,
    this.titleSize = 28,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 18),
      child: Column(spacing: 14, children: [
        BadgeIcon(icon: icon, kind: kind, child: badgeChild),
        Text(title, textAlign: TextAlign.center, style: dsp(context, titleSize)),
        if (message != null)
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 340),
            child: Text(message!, textAlign: TextAlign.center, style: mut(context, 15)),
          ),
      ]),
    );
  }
}

class Spin extends StatelessWidget {
  final double size;
  final Color? color;
  const Spin({super.key, this.size = 28, this.color});

  @override
  Widget build(BuildContext context) => SizedBox(
        width: size,
        height: size,
        child: CircularProgressIndicator(
          strokeWidth: size > 24 ? 3.5 : 3,
          color: color ?? context.pal.accent,
          backgroundColor: context.pal.surface2,
        ),
      );
}

/// Bar progres yang terisi dalam [seconds] detik.
class LoadingBar extends StatelessWidget {
  final int seconds;
  const LoadingBar({super.key, required this.seconds});

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(seconds: seconds),
      builder: (_, v, _) => ClipRRect(
        borderRadius: BorderRadius.circular(99),
        child: LinearProgressIndicator(
          value: v,
          minHeight: 8,
          color: p.accent,
          backgroundColor: p.surface2,
        ),
      ),
    );
  }
}

class DemoBox extends StatelessWidget {
  final String title;
  final String? hint;
  final List<Widget> children;
  const DemoBox({super.key, required this.title, this.hint, required this.children});

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: p.line, width: 1.5),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, spacing: 10, children: [
        Text(title, style: body(context, size: 13, w: FontWeight.w700)),
        if (hint != null) Text(hint!, style: mut(context, 12)),
        ...children,
      ]),
    );
  }
}

// ───────────────────────── Timeline ─────────────────────────

enum TrkState { todo, now, done, bad }

class TrackRow {
  final TrkState state;
  final String title;
  final String? sub;
  const TrackRow(this.state, this.title, [this.sub]);
}

class Timeline extends StatelessWidget {
  final List<TrackRow> rows;
  const Timeline(this.rows, {super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    Widget dot(TrkState s) {
      late Color bg;
      late Widget child;
      switch (s) {
        case TrkState.done:
          bg = p.ok;
          child = const Icon(Icons.check_rounded, size: 16, color: Colors.white);
        case TrkState.now:
          bg = p.sun;
          child = SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color: p.onSun,
              backgroundColor: Colors.black.withValues(alpha: .15),
            ),
          );
        case TrkState.bad:
          bg = p.bad;
          child = const Icon(Icons.close_rounded, size: 16, color: Colors.white);
        case TrkState.todo:
          bg = p.surface2;
          child = Icon(Icons.schedule_rounded, size: 15, color: p.muted);
      }
      return Container(
        width: 28,
        height: 28,
        alignment: Alignment.center,
        decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
        child: child,
      );
    }

    return Column(children: [
      for (var i = 0; i < rows.length; i++)
        IntrinsicHeight(
          child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            SizedBox(
              width: 28,
              child: Column(children: [
                dot(rows[i].state),
                if (i < rows.length - 1)
                  Expanded(child: Container(width: 2, color: p.line)),
              ]),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(bottom: i < rows.length - 1 ? 22 : 0),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(rows[i].title,
                      style: body(context,
                          w: FontWeight.w700,
                          color: rows[i].state == TrkState.todo ? p.muted : p.ink)),
                  if (rows[i].sub != null && rows[i].sub!.isNotEmpty)
                    Text(rows[i].sub!, style: mut(context, 13)),
                ]),
              ),
            ),
          ]),
        ),
    ]);
  }
}

// ───────────────────────── Pesanan ─────────────────────────

class ProductThumb extends StatelessWidget {
  final Product product;
  final double box, icon;
  const ProductThumb(this.product, {super.key, this.box = 64, this.icon = 46});

  @override
  Widget build(BuildContext context) => Container(
        width: box,
        height: box,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: context.pal.surface2,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: context.pal.line),
        ),
        child: product.isDrink
            ? CupArt(product.color, size: icon)
            : SnackArt(product.color, size: icon),
      );
}

class OrderLines extends StatelessWidget {
  final List<CartItem> items;
  const OrderLines(this.items, {super.key});

  @override
  Widget build(BuildContext context) => Column(children: [
        for (final i in items)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('${i.qty}× ${i.name}', style: dsp(context, 16, w: FontWeight.w700)),
                  Text(
                    '${i.optText}${i.note.isNotEmpty ? ' · “${i.note}”' : ''}',
                    style: mut(context, 13),
                  ),
                ]),
              ),
              const SizedBox(width: 12),
              Text(rp(i.unit * i.qty), style: body(context, w: FontWeight.w800)),
            ]),
          ),
      ]);
}

class PriceSummary extends StatelessWidget {
  final int subtotal, fee, total;
  final String totalLabel;
  const PriceSummary({
    super.key,
    required this.subtotal,
    required this.fee,
    required this.total,
    this.totalLabel = 'Total',
  });

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    Widget row(String l, String v, {bool bold = false}) => Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(l, style: body(context, size: bold ? 17 : 15, w: bold ? FontWeight.w800 : FontWeight.w400, color: bold ? p.ink : p.muted)),
            Text(v, style: body(context, size: bold ? 17 : 15, w: bold ? FontWeight.w800 : FontWeight.w400)),
          ],
        );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Column(spacing: 8, children: [
        row('Subtotal', rp(subtotal)),
        row('Biaya layanan', rp(fee)),
        Divider(color: p.line, height: 12),
        row(totalLabel, rp(total), bold: true),
      ]),
    );
  }
}

/// Daftar item keranjang yang bisa diubah jumlahnya / dihapus.
class CartEditor extends StatelessWidget {
  const CartEditor({super.key});

  @override
  Widget build(BuildContext context) {
    final o = context.watch<OrderProvider>();
    final p = context.pal;
    return Column(children: [
      for (var x = 0; x < o.items.length; x++)
        Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(border: Border(bottom: BorderSide(color: p.line))),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            ProductThumb(o.productOf(o.items[x].pid), box: 52, icon: 36),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(o.items[x].name, style: dsp(context, 16, w: FontWeight.w700)),
                Text(
                  '${o.items[x].optText}${o.items[x].note.isNotEmpty ? ' · “${o.items[x].note}”' : ''}',
                  style: mut(context, 13),
                ),
                const SizedBox(height: 10),
                Row(children: [
                  QtyStepper(
                    value: o.items[x].qty,
                    onMinus: () => o.changeQty(x, -1),
                    onPlus: () => o.changeQty(x, 1),
                  ),
                  const Spacer(),
                  Text(rp(o.items[x].unit * o.items[x].qty),
                      style: body(context, w: FontWeight.w800)),
                  IconButton(
                    tooltip: 'Hapus ${o.items[x].name}',
                    onPressed: () => o.removeAt(x),
                    icon: Icon(Icons.delete_outline_rounded, color: p.bad),
                  ),
                ]),
              ]),
            ),
          ]),
        ),
    ]);
  }
}

class QrBox extends StatelessWidget {
  final String data;
  final double size;
  const QrBox(this.data, {super.key, this.size = 208});

  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: context.pal.line),
        ),
        child: QrImageView(
          data: data,
          version: QrVersions.auto,
          backgroundColor: Colors.white,
          padding: EdgeInsets.zero,
        ),
      );
}

/// Kartu notifikasi "Kopimu sudah siap".
class NotifCard extends StatelessWidget {
  final String cartName, code;
  final VoidCallback? onTap;
  const NotifCard({super.key, required this.cartName, required this.code, this.onTap});

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: p.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: p.line),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: .06), blurRadius: 16, offset: const Offset(0, 4))],
        ),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: 36,
            height: 36,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(color: p.accent, borderRadius: BorderRadius.circular(10)),
            child: const FittedBox(child: GerobakArt(width: 60)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Kopimu sudah siap!', style: body(context, size: 14, w: FontWeight.w700)),
              Text('$cartName menunggu di gerobak. Kode pickup $code.', style: mut(context, 13)),
            ]),
          ),
          const SizedBox(width: 8),
          Text('sekarang', style: mut(context, 12)),
        ]),
      ),
    );
  }
}

class BrandBlock extends StatelessWidget {
  const BrandBlock({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, spacing: 14, children: [
      Container(
        width: 132,
        padding: const EdgeInsets.fromLTRB(10, 12, 10, 6),
        decoration: BoxDecoration(color: p.surface2, borderRadius: BorderRadius.circular(28)),
        child: const GerobakArt(width: 112),
      ),
      Text('Kopi\nCerdas', style: dsp(context, 34, h: 1.05)),
      Text('Pesan dari gerobak kopi terdekat, ambil tanpa antre.', style: mut(context, 15)),
    ]);
  }
}

/// Baris info gerobak (nama + lokasi + jarak) dengan ikon pin.
class CartInfoCard extends StatelessWidget {
  final String title, subtitle;
  const CartInfoCard({super.key, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) => AppCard(
        child: Row(spacing: 10, children: [
          Icon(Icons.place_outlined, color: context.pal.accent),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: body(context, w: FontWeight.w700)),
              Text(subtitle, style: mut(context, 13)),
            ]),
          ),
        ]),
      );
}
