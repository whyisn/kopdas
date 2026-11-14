class CartItem {
  final String pid;
  final String name;
  int qty;
  int unit;

  CartItem({
    required this.pid,
    required this.name,
    required this.qty,
    required this.unit,
  });

  /// Kompatibilitas backward
  String get size => '';
  String get temp => '';
  String get sugar => '';
  String get note => '';
  List<String> get addons => const [];
  String get optText => '';

  /// Kunci penggabungan item identik di keranjang (per product id)
  String get key => pid;
}

class DraftItem {
  final String pid;
  int qty = 1;
  String size = '';
  String temp = '';
  String sugar = '';
  String note = '';
  final List<String> addons = [];
  DraftItem(this.pid);
}
