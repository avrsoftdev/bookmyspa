class ServicePricing {
  final String service;
  final String price;

  const ServicePricing({required this.service, required this.price});

  factory ServicePricing.fromMap(Map<String, dynamic> map) {
    return ServicePricing(
      service: map['service'] ?? '',
      price: map['price'] ?? '',
    );
  }
}

class ServiceDetail {
  final List<String> subcategories;
  final List<String> addons;

  const ServiceDetail({required this.subcategories, required this.addons});

  factory ServiceDetail.fromMap(Map<String, dynamic> map) {
    return ServiceDetail(
      subcategories: List<String>.from(
        (map['subcategories'] as List?) ?? const [],
      ),
      addons: List<String>.from((map['addons'] as List?) ?? const []),
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
  final Map<String, ServiceDetail> serviceDetails;

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
    this.serviceDetails = const {},
  });

  factory SpaEntity.fromMap(String id, Map<String, dynamic> map) {
    final rawDetails =
        (map['serviceDetails'] as Map?)?.cast<String, dynamic>() ??
        const <String, dynamic>{};
    final parsedDetails = <String, ServiceDetail>{};
    for (final entry in rawDetails.entries) {
      final v =
          (entry.value as Map?)?.cast<String, dynamic>() ??
          const <String, dynamic>{};
      parsedDetails[entry.key] = ServiceDetail.fromMap(v);
    }
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
      serviceDetails: parsedDetails,
    );
  }

  static double? _parseRating(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    final s = v.toString();
    return double.tryParse(s);
  }
}
