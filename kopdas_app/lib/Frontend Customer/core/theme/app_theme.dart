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
    bg: Color(0xFFF8FAFC),
    surface: Color(0xFFFFFFFF),
    surface2: Color(0xFFF1F5F9),
    ink: Color(0xFF111827),
    muted: Color(0xFF6B7280),
    line: Color(0xFFE5E7EB),
    accent: Color(0xFF1E3932),
    onAccent: Color(0xFFFFFFFF),
    sun: Color(0xFFF59E0B),
    onSun: Color(0xFF111827),
    ok: Color(0xFF059669),
    bad: Color(0xFFDC2626),
    you: Color(0xFF2563EB),
    map: Color(0xFFF1F5F9),
    road: Color(0xFFFFFFFF),
    park: Color(0xFFDCFCE7),
  );

  static const dark = AppPalette(
    bg: Color(0xFF0F172A),
    surface: Color(0xFF1E293B),
    surface2: Color(0xFF334155),
    ink: Color(0xFFF8FAFC),
    muted: Color(0xFF94A3B8),
    line: Color(0xFF334155),
    accent: Color(0xFF34D399),
    onAccent: Color(0xFF022C22),
    sun: Color(0xFFFBBF24),
    onSun: Color(0xFF1E293B),
    ok: Color(0xFF34D399),
    bad: Color(0xFFF87171),
    you: Color(0xFF60A5FA),
    map: Color(0xFF0F172A),
    road: Color(0xFF1E293B),
    park: Color(0xFF064E3B),
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
