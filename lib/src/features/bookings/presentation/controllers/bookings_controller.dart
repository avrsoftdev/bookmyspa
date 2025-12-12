import 'package:flutter/foundation.dart';
import '../../domain/entities/booking.dart';

class BookingsController extends ChangeNotifier {
  final List<Booking> _bookings = [];

  List<Booking> get bookings => List.unmodifiable(_bookings);

  void addAll(List<Booking> items) {
    _bookings.addAll(items);
    notifyListeners();
  }
}
