class ServicePricing {
  final String service;
  final String price;

  const ServicePricing({
    required this.service,
    required this.price,
  });

  factory ServicePricing.fromMap(Map<String, dynamic> map) {
    return ServicePricing(
      service: map['service'] ?? '',
      price: map['price'] ?? '',
    );
  }
}

class SpaEntity {
  final String id;
  final String businessName;
  final String city;
  final String description;
  final String fullAddress;
  final List<String> services;
  final List<ServicePricing> pricing;
  final List<String> photos;
  final String status;
  final DateTime? publishedAt;
  final double? rating;

  const SpaEntity({
    required this.id,
    required this.businessName,
    required this.city,
    required this.description,
    required this.fullAddress,
    required this.services,
    required this.pricing,
    required this.photos,
    required this.status,
    this.publishedAt,
    this.rating,
  });

  factory SpaEntity.fromMap(String id, Map<String, dynamic> map) {
    return SpaEntity(
      id: id,
      businessName: map['businessName'] ?? '',
      city: map['city'] ?? '',
      description: map['description'] ?? '',
      fullAddress: map['fullAddress'] ?? '',
      services: List<String>.from((map['services'] as List?) ?? const []),
      pricing: ((map['pricing'] as List?) ?? const [])
          .map((e) => ServicePricing.fromMap(e as Map<String, dynamic>))
          .toList(),
      photos: List<String>.from((map['photos'] as List?) ?? const []),
      status: map['status'] ?? '',
      publishedAt: (map['publishedAt'] is DateTime)
          ? map['publishedAt'] as DateTime
          : (map['publishedAt'] != null &&
                map['publishedAt'].toString().isNotEmpty)
          ? DateTime.tryParse(map['publishedAt'].toString())
          : null,
      rating: _parseRating(map['rating']) ?? _parseRating(map['averageRating']),
    );
  }

  static double? _parseRating(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    final s = v.toString();
    return double.tryParse(s);
  }
}
