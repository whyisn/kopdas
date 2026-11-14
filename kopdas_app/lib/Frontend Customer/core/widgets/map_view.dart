import 'dart:math';
import 'package:flutter/material.dart';
import '../../data/models/coffee_cart.dart';
import '../theme/app_theme.dart';

/// Peta simulasi (kanvas 340x200, mode "cover") dengan pin gerobak
/// dan titik lokasi pengguna yang berdenyut.
class MapView extends StatefulWidget {
  final List<CoffeeCart> pins;
  final ValueChanged<CoffeeCart>? onPick;
  const MapView({super.key, required this.pins, this.onPick});

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 2200))
        ..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    return Semantics(
      label: 'Peta gerobak di sekitarmu',
      child: LayoutBuilder(builder: (context, box) {
        final w = box.maxWidth, h = box.maxHeight;
        final sc = max(w / 340, h / 200);
        final ox = (w - 340 * sc) / 2, oy = (h - 200 * sc) / 2;
        return ClipRect(
          child: Stack(children: [
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _c,
                builder: (_, _) => CustomPaint(painter: _MapPainter(p, sc, ox, oy, _c.value)),
              ),
            ),
            for (var i = 0; i < widget.pins.length; i++)
              Positioned(
                left: ox + widget.pins[i].pos.dx * sc - 15,
                top: oy + widget.pins[i].pos.dy * sc - 36,
                width: 30,
                height: 36,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: widget.onPick == null ? null : () => widget.onPick!(widget.pins[i]),
                  child: _Pin(i + 1),
                ),
              ),
          ]),
        );
      }),
    );
  }
}

class _Pin extends StatelessWidget {
  final int n;
  const _Pin(this.n);

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    return Stack(alignment: Alignment.topCenter, children: [
      CustomPaint(size: const Size(30, 36), painter: _DropPainter(p.accent, p.surface)),
      Padding(
        padding: const EdgeInsets.only(top: 7),
        child: Text('$n',
            style: const TextStyle(
                color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800)),
      ),
    ]);
  }
}

class _DropPainter extends CustomPainter {
  final Color fill, edge;
  _DropPainter(this.fill, this.edge);

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..addOval(Rect.fromCircle(center: const Offset(15, 14), radius: 12))
      ..moveTo(6, 21)
      ..lineTo(24, 21)
      ..lineTo(15, 36)
      ..close();
    canvas.drawPath(
      path,
      Paint()
        ..color = edge
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
    canvas.drawPath(path, Paint()..color = fill);
  }

  @override
  bool shouldRepaint(_DropPainter o) => o.fill != fill || o.edge != edge;
}

class _MapPainter extends CustomPainter {
  final AppPalette p;
  final double sc, ox, oy, t;
  _MapPainter(this.p, this.sc, this.ox, this.oy, this.t);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = p.map);
    canvas.save();
    canvas.translate(ox, oy);
    canvas.scale(sc);
    canvas.drawRRect(
      RRect.fromLTRBR(160, 56, 222, 96, const Radius.circular(8)),
      Paint()..color = p.park,
    );
    final road = Paint()
      ..color = p.road
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 11;
    for (final y in [48.0, 118.0, 176.0]) {
      canvas.drawLine(Offset(-10, y), Offset(350, y), road);
    }
    for (final x in [70.0, 150.0, 244.0, 306.0]) {
      canvas.drawLine(Offset(x, -10), Offset(x, 210), road);
    }
    canvas.drawLine(const Offset(-10, 200), const Offset(350, 14), road..strokeWidth = 7);
    // cincin berdenyut
    final r = 16 * (0.4 + 1.1 * t);
    canvas.drawCircle(const Offset(170, 108), r,
        Paint()..color = p.you.withValues(alpha: .5 * (1 - t)));
    canvas.drawCircle(const Offset(170, 108), 7, Paint()..color = Colors.white);
    canvas.drawCircle(const Offset(170, 108), 5.5, Paint()..color = p.you);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_MapPainter o) => true;
}
