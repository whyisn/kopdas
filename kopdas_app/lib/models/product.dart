class ProductOptionChoice {
  final String id;
  final String name;
  final int priceDelta;

  const ProductOptionChoice({
    required this.id,
    required this.name,
    this.priceDelta = 0,
  });

  factory ProductOptionChoice.fromJson(Map<String, dynamic> json) {
    return ProductOptionChoice(
      id: json['id'] as String,
      name: json['name'] as String,
      priceDelta: (json['price_delta'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'price_delta': priceDelta,
      };
}

class ProductOptionGroup {
  final String id;
  final String name;
  final bool multi;
  final List<ProductOptionChoice> choices;

  const ProductOptionGroup({
    required this.id,
    required this.name,
    this.multi = false,
    required this.choices,
  });

  factory ProductOptionGroup.fromJson(Map<String, dynamic> json) {
    return ProductOptionGroup(
      id: json['id'] as String,
      name: json['name'] as String,
      multi: json['multi'] as bool? ?? false,
      choices: (json['choices'] as List<dynamic>? ?? [])
          .map((e) => ProductOptionChoice.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'multi': multi,
        'choices': choices.map((c) => c.toJson()).toList(),
      };
}

class ProductModel {
  final String id;
  final String categoryId;
  final String name;
  final String? description;
  final int price;
  final int costPrice;
  final String status;
  final String? imageUrl;
  final String? categoryName;
  final List<ProductOptionGroup> options;

  ProductModel({
    required this.id,
    required this.categoryId,
    required this.name,
    this.description,
    required this.price,
    this.costPrice = 0,
    required this.status,
    this.imageUrl,
    this.categoryName,
    this.options = const [],
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as String,
      categoryId: json['category_id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      price: json['price'] as int,
      costPrice: json['cost_price'] as int? ?? 0,
      status: json['status'] as String? ?? 'ACTIVE',
      imageUrl: json['image_url'] as String?,
      categoryName: json['category_name'] as String?,
      options: (json['options'] as List<dynamic>? ?? [])
          .map((e) => ProductOptionGroup.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Opsi bawaan untuk tambah cepat: pilihan pertama tiap grup single-select.
  List<String> get defaultOptionIds => [
        for (final g in options)
          if (!g.multi && g.choices.isNotEmpty) g.choices.first.id,
      ];

  Iterable<ProductOptionChoice> _selectedChoices(List<String> optionIds) sync* {
    for (final g in options) {
      for (final c in g.choices) {
        if (optionIds.contains(c.id)) yield c;
      }
    }
  }

  int unitPriceFor(List<String> optionIds) =>
      price + _selectedChoices(optionIds).fold(0, (s, c) => s + c.priceDelta);

  String? variantLabelFor(List<String> optionIds) {
    final labels = _selectedChoices(optionIds).map((c) => c.name).toList();
    return labels.isEmpty ? null : labels.join(' · ');
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category_id': categoryId,
      'name': name,
      'description': description,
      'price': price,
      'cost_price': costPrice,
      'status': status,
      'image_url': imageUrl,
      'category_name': categoryName,
      'options': options.map((g) => g.toJson()).toList(),
    };
  }
}
