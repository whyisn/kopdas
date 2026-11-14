import 'package:flutter/material.dart';

const _ink = Color(0xFF14201B);

class CupArt extends StatelessWidget {
  final Color color;
  final double size;
  const CupArt(this.color, {super.key, this.size = 46});
  @override
  Widget build(BuildContext context) =>
      SizedBox(width: size, height: size, child: CustomPaint(painter: _CupPainter(color)));
}

class SnackArt extends StatelessWidget {
  final Color color;
  final double size;
  const SnackArt(this.color, {super.key, this.size = 46});
  @override
  Widget build(BuildContext context) =>
      SizedBox(width: size, height: size, child: CustomPaint(painter: _SnackPainter(color)));
}

class GerobakArt extends StatelessWidget {
  final double width;
  const GerobakArt({super.key, this.width = 120});
  @override
  Widget build(BuildContext context) => SizedBox(
        width: width,
        height: width * 92 / 120,
        child: const CustomPaint(painter: _GerobakPainter()),
      );
}

class _CupPainter extends CustomPainter {
  final Color color;
  _CupPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 48);
    canvas.drawLine(
      const Offset(27, 3),
      const Offset(24, 11),
      Paint()
        ..color = color
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round,
    );
    final body = Path()
      ..moveTo(11, 15)
      ..lineTo(37, 15)
      ..lineTo(34, 40.5)
      ..arcToPoint(const Offset(30.5, 44), radius: const Radius.circular(3.5))
      ..lineTo(17.5, 44)
      ..arcToPoint(const Offset(14, 40.5), radius: const Radius.circular(3.5))
      ..close();
    canvas.drawPath(body, Paint()..color = color);
    final shine = Path()
      ..moveTo(13.2, 25)
      ..lineTo(34.8, 25)
      ..lineTo(33.9, 33)
      ..lineTo(14.1, 33)
      ..close();
    canvas.drawPath(shine, Paint()..color = Colors.white.withValues(alpha: .22));
    canvas.drawRRect(
      RRect.fromLTRBR(9, 10.5, 39, 16, const Radius.circular(2.75)),
      Paint()..color = _ink,
    );
  }

  @override
  bool shouldRepaint(_CupPainter o) => o.color != color;
}

class _SnackPainter extends CustomPainter {
  final Color color;
  _SnackPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 48);
    canvas.drawRRect(
      RRect.fromLTRBAndCorners(8, 12, 40, 40,
          topLeft: const Radius.circular(8),
          topRight: const Radius.circular(8),
          bottomLeft: const Radius.circular(4),
          bottomRight: const Radius.circular(4)),
      Paint()..color = color,
    );
    final line = Paint()
      ..color = Colors.white.withValues(alpha: .4)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(15, 27), const Offset(33, 27), line);
    canvas.drawLine(const Offset(15, 33), const Offset(27, 33), line);
  }

  @override
  bool shouldRepaint(_SnackPainter o) => o.color != color;
}

class _GerobakPainter extends CustomPainter {
  const _GerobakPainter();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 120);
    const n = 6;
    const w = 92 / n;
    for (var i = 0; i < n; i++) {
      final x = 14.0 + i * w;
      final p = Path()
        ..moveTo(x, 14)
        ..relativeLineTo(w, 0)
        ..relativeLineTo(0, 12)
        ..arcToPoint(Offset(x, 26), radius: const Radius.elliptical(w / 2, 6))
        ..close();
      canvas.drawPath(
        p,
        Paint()..color = i.isOdd ? const Color(0xFFF5B73A) : Colors.white,
      );
    }
    final ink = Paint()..color = _ink;
    final stroke = Paint()
      ..color = _ink
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    canvas.drawRRect(RRect.fromLTRBR(12, 10, 108, 15, const Radius.circular(2.5)), ink);
    canvas.drawLine(const Offset(19, 30), const Offset(19, 48), stroke);
    canvas.drawLine(const Offset(101, 30), const Offset(101, 48), stroke);
    canvas.drawRRect(RRect.fromLTRBR(10, 46, 110, 52, const Radius.circular(3)), ink);
    canvas.drawRRect(RRect.fromLTRBR(14, 52, 106, 78, const Radius.circular(4)),
        Paint()..color = const Color(0xFF0E5A43));
    canvas.drawRRect(RRect.fromLTRBR(22, 58, 50, 70, const Radius.circular(3)),
        Paint()..color = const Color(0xFFF5B73A));
    final soft = Paint()
      ..color = Colors.white.withValues(alpha: .6)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(60, 59), const Offset(94, 59), soft);
    canvas.drawLine(const Offset(60, 65), const Offset(82, 65), soft);
    final cup = Path()
      ..moveTo(34, 40)
      ..lineTo(35.8, 34)
      ..lineTo(43.2, 34)
      ..lineTo(45, 40)
      ..close();
    canvas.drawPath(cup, Paint()..color = const Color(0xFFF5B73A));
    canvas.drawLine(const Offset(106, 66), const Offset(118, 76), stroke);
    for (final cx in [34.0, 88.0]) {
      canvas.drawCircle(Offset(cx, 80), 9, ink);
      canvas.drawCircle(Offset(cx, 80), 3, Paint()..color = const Color(0xFFCFD6D0));
    }
  }

  @override
  bool shouldRepaint(_GerobakPainter o) => false;
}
