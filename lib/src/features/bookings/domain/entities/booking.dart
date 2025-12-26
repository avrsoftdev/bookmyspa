class Booking {
  final String id;
  final String serviceId;
  final String serviceName;
  final int quantity;
  final double unitPrice;
  final double totalPrice;
  final DateTime scheduledAt;
  final DateTime createdAt;

  const Booking({
    required this.id,
    required this.serviceId,
    required this.serviceName,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    required this.scheduledAt,
    required this.createdAt,
  });
}
