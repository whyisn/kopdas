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
    );
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
    };
  }
}
