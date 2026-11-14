class LocationModel {
  final String id;
  final String? sellerId;
  final String name;
  final double latitude;
  final double longitude;
  final String? address;
  final String sourceType;
  final bool isActive;
  final double? score;
  final String dataLabel;

  LocationModel({
    required this.id,
    this.sellerId,
    required this.name,
    required this.latitude,
    required this.longitude,
    this.address,
    required this.sourceType,
    required this.isActive,
    this.score,
    required this.dataLabel,
  });

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      id: json['id'] as String,
      sellerId: json['seller_id'] as String?,
      name: json['name'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      address: json['address'] as String?,
      sourceType: json['source_type'] as String,
      isActive: json['is_active'] as bool? ?? true,
      score: json['score'] != null ? (json['score'] as num).toDouble() : null,
      dataLabel: json['data_label'] as String? ?? 'SIMULASI',
    );
  }
}

class OrderModel {
  final String id;
  final String orderNumber;
  final String? customerId;
  final String sellerId;
  final String locationId;
  final int totalAmount;
  final String orderStatus;
  final String paymentMethod;
  final String paymentStatus;
  final String? qrisAssetUrl;
  final String createdAt;
  final String? expiresAt;
  final String dataLabel;

  OrderModel({
    required this.id,
    required this.orderNumber,
    this.customerId,
    required this.sellerId,
    required this.locationId,
    required this.totalAmount,
    required this.orderStatus,
    required this.paymentMethod,
    required this.paymentStatus,
    this.qrisAssetUrl,
    required this.createdAt,
    this.expiresAt,
    required this.dataLabel,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] as String,
      orderNumber: json['order_number'] as String,
      customerId: json['customer_id'] as String?,
      sellerId: json['seller_id'] as String,
      locationId: json['location_id'] as String,
      totalAmount: json['total_amount'] as int,
      orderStatus: json['order_status'] as String,
      paymentMethod: json['payment_method'] as String,
      paymentStatus: json['payment_status'] as String,
      qrisAssetUrl: json['qris_asset_url'] as String?,
      createdAt: json['created_at'] as String,
      expiresAt: json['expires_at'] as String?,
      dataLabel: json['data_label'] as String? ?? 'REAL',
    );
  }
}
