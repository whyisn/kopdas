class CartItem {
  final String pid;
  final String name;
  final String temp;
  final String sugar;
  final String note;
  int qty;
  int unit;

  CartItem({
    required this.pid,
    required this.name,
    this.temp = 'Dingin',
    this.sugar = 'Normal',
    this.note = '',
    required this.qty,
    required this.unit,
  });

  /// Kompatibilitas jika dipanggil
  String get size => '';
  List<String> get addons => const [];

  /// Kunci penggabungan item identik di keranjang.
  String get key => [pid, temp, sugar, note].join('|');

  String get optText =>
      [temp, sugar, if (note.isNotEmpty) 'Catatan: $note'].where((e) => e.isNotEmpty).join(' · ');
}

/// Draf produk yang sedang ditentukan jumlah dan catatannya.
class DraftItem {
  final String pid;
  String size = '';
  String temp = 'Dingin';
  String sugar = 'Normal';
  final List<String> addons = [];
  String note = '';
  int qty = 1;
  DraftItem(this.pid);
}
