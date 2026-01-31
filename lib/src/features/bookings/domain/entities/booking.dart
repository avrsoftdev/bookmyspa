class Booking {
  final String id;
  final String transactionId;
  final String spaId;
  final String serviceId;
  final String serviceName;
  final int quantity;
  final double unitPrice;
  final double totalPrice;
  final DateTime scheduledAt;
  final DateTime createdAt;

  // Customer Details
  final String userId;
  final String userName;
  final String? userEmail;
  final String? userPhone;

  const Booking({
    required this.id,
    required this.transactionId,
    required this.spaId,
    required this.serviceId,
    required this.serviceName,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    required this.scheduledAt,
    required this.createdAt,
    required this.userId,
    required this.userName,
    this.userEmail,
    this.userPhone,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'transactionId': transactionId,
      'spaId': spaId,
      'serviceId': serviceId,
      'serviceName': serviceName,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'totalPrice': totalPrice,
      'scheduledAt': scheduledAt.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'userId': userId,
      'userName': userName,
      'userEmail': userEmail,
      'userPhone': userPhone,
    };
  }

  factory Booking.fromMap(Map<String, dynamic> map) {
    return Booking(
      id: map['id'] ?? '',
      transactionId: map['transactionId'] ?? '',
      spaId: map['spaId'] ?? '',
      serviceId: map['serviceId'] ?? '',
      serviceName: map['serviceName'] ?? '',
      quantity: (map['quantity'] as num?)?.toInt() ?? 0,
      unitPrice: (map['unitPrice'] as num?)?.toDouble() ?? 0.0,
      totalPrice: (map['totalPrice'] as num?)?.toDouble() ?? 0.0,
      scheduledAt:
          DateTime.tryParse(map['scheduledAt'] ?? '') ?? DateTime.now(),
      createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? 'Unknown',
      userEmail: map['userEmail'],
      userPhone: map['userPhone'],
    );
  }
}
