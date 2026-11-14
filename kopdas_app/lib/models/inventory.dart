class InventoryModel {
  final String id;
  final String productId;
  final String? productName;
  final String scopeType;
  final String scopeId;
  final int quantity;
  final int reservedQuantity;
  final int availableQuantity;
  final String updatedAt;

  InventoryModel({
    required this.id,
    required this.productId,
    this.productName,
    required this.scopeType,
    required this.scopeId,
    required this.quantity,
    required this.reservedQuantity,
    required this.availableQuantity,
    required this.updatedAt,
  });

  factory InventoryModel.fromJson(Map<String, dynamic> json) {
    return InventoryModel(
      id: json['id'] as String,
      productId: json['product_id'] as String,
      productName: json['product_name'] as String?,
      scopeType: json['scope_type'] as String,
      scopeId: json['scope_id'] as String,
      quantity: json['quantity'] as int,
      reservedQuantity: json['reserved_quantity'] as int? ?? 0,
      availableQuantity: json['available_quantity'] as int? ?? 0,
      updatedAt: json['updated_at'] as String,
    );
  }
}
