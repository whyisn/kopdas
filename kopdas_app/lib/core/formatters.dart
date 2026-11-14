const List<String> _monthNames = [
  'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
  'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
];

String formatRupiah(num value) {
  final digits = value.round().abs().toString();
  final buf = StringBuffer(value < 0 ? '-' : '');
  for (int i = 0; i < digits.length; i++) {
    final remaining = digits.length - i;
    buf.write(digits[i]);
    if (remaining > 1 && remaining % 3 == 1) buf.write('.');
  }
  return 'Rp $buf';
}

// Backend mengirim timestamp naive UTC (tanpa suffix Z/offset).
DateTime? parseBackendDate(String? iso) {
  if (iso == null || iso.isEmpty) return null;
  final hasOffset =
      iso.endsWith('Z') || RegExp(r'[+-]\d{2}:?\d{2}$').hasMatch(iso);
  return DateTime.tryParse(hasOffset ? iso : '${iso}Z')?.toUtc();
}

DateTime toWib(DateTime utc) => utc.toUtc().add(const Duration(hours: 7));

String formatWib(DateTime utc, {bool withTime = true}) {
  final wib = toWib(utc);
  final date = '${wib.day} ${_monthNames[wib.month - 1]} ${wib.year}';
  if (!withTime) return date;
  final hh = wib.hour.toString().padLeft(2, '0');
  final mm = wib.minute.toString().padLeft(2, '0');
  return '$date, $hh:$mm WIB';
}

bool isTodayWib(DateTime utc) {
  final now = toWib(DateTime.now().toUtc());
  final wib = toWib(utc);
  return wib.year == now.year && wib.month == now.month && wib.day == now.day;
}