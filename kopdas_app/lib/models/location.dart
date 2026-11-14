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

