class SpaEntity {
  final String id;
  final String businessName;
  final String city;
  final List<String> services;
  final List<String> photos;
  final String status;
  final DateTime? publishedAt;

  const SpaEntity({
    required this.id,
    required this.businessName,
    required this.city,
    required this.services,
    required this.photos,
    required this.status,
    this.publishedAt,
  });

  factory SpaEntity.fromMap(String id, Map<String, dynamic> map) {
    return SpaEntity(
      id: id,
      businessName: map['businessName'] ?? '',
      city: map['city'] ?? '',
      services: List<String>.from((map['services'] as List?) ?? const []),
      photos: List<String>.from((map['photos'] as List?) ?? const []),
      status: map['status'] ?? '',
      publishedAt: (map['publishedAt'] is DateTime)
          ? map['publishedAt'] as DateTime
          : (map['publishedAt'] != null &&
                map['publishedAt'].toString().isNotEmpty)
          ? DateTime.tryParse(map['publishedAt'].toString())
          : null,
    );
  }
}
