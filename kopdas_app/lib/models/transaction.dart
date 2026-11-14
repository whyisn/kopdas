class TransactionItemModel {
  final String id;
  final String productId;
  final String productName;
  final int quantity;
  final int unitPrice;
  final int subtotal;

  TransactionItemModel({
    required this.id,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.subtotal,
  });

  factory TransactionItemModel.fromJson(Map<String, dynamic> json) {
    return TransactionItemModel(
      id: json['id'] as String,
      productId: json['product_id'] as String,
      productName: json['product_name'] as String,
      quantity: json['quantity'] as int,
      unitPrice: json['unit_price'] as int,
      subtotal: json['subtotal'] as int,
    );
  }
}

class TransactionModel {
  final String id;
  final String sellerId;
  final String locationId;
  final int totalAmount;
  final String paymentMethod;
  final String paymentStatus;
  final String createdAt;
  final List<TransactionItemModel> items;

  TransactionModel({
    required this.id,
    required this.sellerId,
    required this.locationId,
    required this.totalAmount,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.createdAt,
    required this.items,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    var itemsList = (json['items'] as List<dynamic>? ?? [])
        .map((e) => TransactionItemModel.fromJson(e as Map<String, dynamic>))
        .toList();

    return TransactionModel(
      id: json['id'] as String,
      sellerId: json['seller_id'] as String,
      locationId: json['location_id'] as String,
      totalAmount: json['total_amount'] as int,
      paymentMethod: json['payment_method'] as String,
      paymentStatus: json['payment_status'] as String,
      createdAt: json['created_at'] as String,
      items: itemsList,
    );
  }
}
