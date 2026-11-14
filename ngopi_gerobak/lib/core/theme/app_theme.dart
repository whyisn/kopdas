import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Palet warna kustom (light & dark) yang diakses lewat `context.pal`.
@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  final Color bg, surface, surface2, ink, muted, line;
  final Color accent, onAccent, sun, onSun, ok, bad, you, map, road, park;

  const AppPalette({
    required this.bg,
    required this.surface,
    required this.surface2,
    required this.ink,
    required this.muted,
    required this.line,
    required this.accent,
    required this.onAccent,
    required this.sun,
    required this.onSun,
    required this.ok,
    required this.bad,
    required this.you,
    required this.map,
    required this.road,
    required this.park,
  });

  static const light = AppPalette(
    bg: Color(0xFFF2F4F1),
    surface: Color(0xFFFFFFFF),
    surface2: Color(0xFFE7ECE6),
    ink: Color(0xFF14201B),
    muted: Color(0xFF5B6A62),
    line: Color(0xFFD6DDD7),
    accent: Color(0xFF0E5A43),
    onAccent: Color(0xFFFFFFFF),
    sun: Color(0xFFF5B73A),
    onSun: Color(0xFF241A00),
    ok: Color(0xFF1B7F45),
    bad: Color(0xFFBF3A30),
    you: Color(0xFF2B6CDF),
    map: Color(0xFFE3E9E1),
    road: Color(0xFFFBFCFA),
    park: Color(0xFFCFE3CD),
  );

  static const dark = AppPalette(
    bg: Color(0xFF0E1411),
    surface: Color(0xFF161E19),
    surface2: Color(0xFF202B25),
    ink: Color(0xFFEAF0EC),
    muted: Color(0xFF9AA89F),
    line: Color(0xFF2B372F),
    accent: Color(0xFF4BC99A),
    onAccent: Color(0xFF06251B),
    sun: Color(0xFFF5B73A),
    onSun: Color(0xFF2A1D00),
    ok: Color(0xFF5BD08B),
    bad: Color(0xFFFF8277),
    you: Color(0xFF6B9BFF),
    map: Color(0xFF18211C),
    road: Color(0xFF242F28),
    park: Color(0xFF1D3A2B),
  );

  @override
  AppPalette copyWith() => this;

  @override
  AppPalette lerp(ThemeExtension<AppPalette>? other, double t) {
    if (other is! AppPalette) return this;
    Color l(Color a, Color b) => Color.lerp(a, b, t)!;
    return AppPalette(
      bg: l(bg, other.bg),
      surface: l(surface, other.surface),
      surface2: l(surface2, other.surface2),
      ink: l(ink, other.ink),
      muted: l(muted, other.muted),
      line: l(line, other.line),
      accent: l(accent, other.accent),
      onAccent: l(onAccent, other.onAccent),
      sun: l(sun, other.sun),
      onSun: l(onSun, other.onSun),
      ok: l(ok, other.ok),
      bad: l(bad, other.bad),
      you: l(you, other.you),
      map: l(map, other.map),
      road: l(road, other.road),
      park: l(park, other.park),
    );
  }
}

extension PaletteX on BuildContext {
  AppPalette get pal => Theme.of(this).extension<AppPalette>()!;
}

/// Gaya teks display (mirip Bricolage Grotesque).
TextStyle dsp(BuildContext c, double size,
        {FontWeight w = FontWeight.w800, Color? color, double? h}) =>
    GoogleFonts.bricolageGrotesque(
      fontSize: size,
      fontWeight: w,
      color: color ?? c.pal.ink,
      height: h ?? 1.15,
      letterSpacing: -0.01 * size,
    );

/// Gaya teks body (Plus Jakarta Sans).
TextStyle body(BuildContext c,
        {double size = 15, FontWeight w = FontWeight.w400, Color? color, double? h}) =>
    GoogleFonts.plusJakartaSans(
      fontSize: size,
      fontWeight: w,
      color: color ?? c.pal.ink,
      height: h ?? 1.4,
    );

TextStyle mut(BuildContext c, [double size = 14]) =>
    body(c, size: size, color: c.pal.muted);

ThemeData buildTheme(Brightness b) {
  final p = b == Brightness.light ? AppPalette.light : AppPalette.dark;
  final base = ThemeData(
    brightness: b,
    useMaterial3: true,
    scaffoldBackgroundColor: p.bg,
    colorScheme: ColorScheme.fromSeed(seedColor: p.accent, brightness: b).copyWith(
      primary: p.accent,
      onPrimary: p.onAccent,
      surface: p.surface,
      onSurface: p.ink,
    ),
    extensions: [p],
  );
  return base.copyWith(
    textTheme: GoogleFonts.plusJakartaSansTextTheme(base.textTheme)
        .apply(bodyColor: p.ink, displayColor: p.ink),
    splashFactory: InkRipple.splashFactory,
  );
}
