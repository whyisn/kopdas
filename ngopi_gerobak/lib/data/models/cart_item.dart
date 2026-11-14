class CartItem {
  final String pid, name, size, temp, sugar, note;
  final List<String> addons;
  int qty;
  int unit;

  CartItem({
    required this.pid,
    required this.name,
    required this.size,
    required this.temp,
    required this.sugar,
    required this.addons,
    required this.note,
    required this.qty,
    required this.unit,
  });

  /// Kunci penggabungan item identik di keranjang.
  String get key => [pid, size, temp, sugar, addons.join(','), note].join('|');

  String get optText =>
      [size, temp, sugar, ...addons].where((e) => e.isNotEmpty).join(' · ');
}

/// Draf produk yang sedang dikustomisasi.
class DraftItem {
  final String pid;
  String size = 'Reguler';
  String temp = 'Dingin';
  String sugar = 'Normal';
  final List<String> addons = [];
  String note = '';
  int qty = 1;
  DraftItem(this.pid);
}
