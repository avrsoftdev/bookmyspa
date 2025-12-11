class CartItem {
  final String serviceId;
  final String serviceName;
  final double price;
  final int quantity;

  const CartItem({
    required this.serviceId,
    required this.serviceName,
    required this.price,
    required this.quantity,
  });

  CartItem copyWith({
    String? serviceId,
    String? serviceName,
    double? price,
    int? quantity,
  }) {
    return CartItem(
      serviceId: serviceId ?? this.serviceId,
      serviceName: serviceName ?? this.serviceName,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
    );
  }

  double get totalPrice => price * quantity;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CartItem && other.serviceId == serviceId;
  }

  @override
  int get hashCode => serviceId.hashCode;
}