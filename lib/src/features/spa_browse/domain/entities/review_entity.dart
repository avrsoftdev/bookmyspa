class ReviewEntity {
  final String id;
  final String userId;
  final String userName;
  final double rating;
  final String text;
  final DateTime createdAt;
  const ReviewEntity({
    required this.id,
    required this.userId,
    required this.userName,
    required this.rating,
    required this.text,
    required this.createdAt,
  });
  factory ReviewEntity.fromDoc(String id, Map<String, dynamic> map) {
    final r = map['rating'];
    final created = map['createdAt'];
    DateTime createdAt = DateTime.now();
    if (created is DateTime) {
      createdAt = created;
    } else if (created != null) {
      final parsed = DateTime.tryParse(created.toString());
      if (parsed != null) createdAt = parsed;
    }
    final rating = r is num ? r.toDouble() : double.tryParse(r?.toString() ?? '') ?? 0.0;
    return ReviewEntity(
      id: id,
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      rating: rating,
      text: map['text'] ?? '',
      createdAt: createdAt,
    );
  }
}
