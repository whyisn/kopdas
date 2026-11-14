class CategoryModel {
  final String id;
  final String name;
  final String status;

  CategoryModel({
    required this.id,
    required this.name,
    required this.status,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as String,
      name: json['name'] as String,
      status: json['status'] as String? ?? 'ACTIVE',
    );
  }
}