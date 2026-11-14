class OrderItemModel {
  final String id;
  final String productId;
  final String productName;
  final int quantity;
  final int unitPrice;
  final int subtotal;

  OrderItemModel({
    required this.id,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.subtotal,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      id: json['id'] as String? ?? '',
      productId: json['product_id'] as String? ?? '',
      productName: json['product_name'] as String? ?? (json['product_id'] as String? ?? ''),
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
      unitPrice: (json['unit_price'] as num?)?.toInt() ?? 0,
      subtotal: (json['subtotal'] as num?)?.toInt() ?? 0,
    );
  }
}

class OrderModel {
  final String id;
  final String orderNumber;
  final String? customerId;
  final String customerName;
  final String sellerId;
  final String? locationId;
  final int totalAmount;
  final String orderStatus;
  final String paymentMethod;
  final String paymentStatus;
  final String? qrisAssetUrl;
  final DateTime createdAt;
  final DateTime? expiresAt;
  final String dataLabel;
  final List<OrderItemModel> items;

  OrderModel({
    required this.id,
    required this.orderNumber,
    this.customerId,
    required this.customerName,
    required this.sellerId,
    this.locationId,
    required this.totalAmount,
    required this.orderStatus,
    required this.paymentMethod,
    required this.paymentStatus,
    this.qrisAssetUrl,
    required this.createdAt,
    this.expiresAt,
    this.dataLabel = 'REAL',
    this.items = const [],
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] as String? ?? '',
      orderNumber: json['order_number'] as String? ?? '',
      customerId: json['customer_id'] as String?,
      customerName: json['customer_name'] as String? ?? (json['customer_id'] as String? ?? 'Pelanggan'),
      sellerId: json['seller_id'] as String? ?? '',
      locationId: json['location_id'] as String?,
      totalAmount: (json['total_amount'] as num?)?.toInt() ?? (json['total'] as num?)?.toInt() ?? 0,
      orderStatus: json['order_status'] as String? ?? 'PENDING_PAYMENT',
      paymentMethod: json['payment_method'] as String? ?? 'QRIS_STATIC',
      paymentStatus: json['payment_status'] as String? ?? 'PENDING',
      qrisAssetUrl: json['qris_asset_url'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      expiresAt: json['expires_at'] != null
          ? DateTime.tryParse(json['expires_at'].toString())
          : null,
      dataLabel: json['data_label'] as String? ?? 'REAL',
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => OrderItemModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }
}
