import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/cart_item.dart';

// Events
abstract class CartEvent extends Equatable {
  const CartEvent();

  @override
  List<Object> get props => [];
}

class AddToCart extends CartEvent {
  final CartItem item;
  const AddToCart(this.item);

  @override
  List<Object> get props => [item];
}

class RemoveFromCart extends CartEvent {
  final String serviceId;
  const RemoveFromCart(this.serviceId);

  @override
  List<Object> get props => [serviceId];
}

class UpdateQuantity extends CartEvent {
  final String serviceId;
  final int quantity;
  const UpdateQuantity(this.serviceId, this.quantity);

  @override
  List<Object> get props => [serviceId, quantity];
}

class ClearCart extends CartEvent {}

// State
class CartState extends Equatable {
  final List<CartItem> items;
  final double totalAmount;
  final int totalItems;

  const CartState({
    this.items = const [],
    this.totalAmount = 0.0,
    this.totalItems = 0,
  });

  CartState copyWith({
    List<CartItem>? items,
    double? totalAmount,
    int? totalItems,
  }) {
    return CartState(
      items: items ?? this.items,
      totalAmount: totalAmount ?? this.totalAmount,
      totalItems: totalItems ?? this.totalItems,
    );
  }

  @override
  List<Object> get props => [items, totalAmount, totalItems];
}

// Bloc
class CartBloc extends Bloc<CartEvent, CartState> {
  CartBloc() : super(const CartState()) {
    on<AddToCart>(_onAddToCart);
    on<RemoveFromCart>(_onRemoveFromCart);
    on<UpdateQuantity>(_onUpdateQuantity);
    on<ClearCart>(_onClearCart);
  }

  void _onAddToCart(AddToCart event, Emitter<CartState> emit) {
    final items = List<CartItem>.from(state.items);
    final existingIndex = items.indexWhere((item) => item.serviceId == event.item.serviceId);

    if (existingIndex >= 0) {
      items[existingIndex] = items[existingIndex].copyWith(
        quantity: items[existingIndex].quantity + 1,
      );
    } else {
      items.add(event.item);
    }

    _emitUpdatedState(emit, items);
  }

  void _onRemoveFromCart(RemoveFromCart event, Emitter<CartState> emit) {
    final items = state.items.where((item) => item.serviceId != event.serviceId).toList();
    _emitUpdatedState(emit, items);
  }

  void _onUpdateQuantity(UpdateQuantity event, Emitter<CartState> emit) {
    if (event.quantity <= 0) {
      add(RemoveFromCart(event.serviceId));
      return;
    }

    final items = state.items.map((item) {
      if (item.serviceId == event.serviceId) {
        return item.copyWith(quantity: event.quantity);
      }
      return item;
    }).toList();

    _emitUpdatedState(emit, items);
  }

  void _onClearCart(ClearCart event, Emitter<CartState> emit) {
    emit(const CartState());
  }

  void _emitUpdatedState(Emitter<CartState> emit, List<CartItem> items) {
    final totalAmount = items.fold<double>(0.0, (sum, item) => sum + item.totalPrice);
    final totalItems = items.fold<int>(0, (sum, item) => sum + item.quantity);

    emit(CartState(
      items: items,
      totalAmount: totalAmount,
      totalItems: totalItems,
    ));
  }
}