import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../domain/entities/booking.dart';
import '../../domain/repositories/bookings_repository.dart';

class BookingsController extends ChangeNotifier {
  final BookingsRepository _repository;
  final List<Booking> _bookings = [];
  StreamSubscription? _subscription;
  String? _currentSpaId;
  String? _currentUserId;

  BookingsController(this._repository);

  List<Booking> get bookings => List.unmodifiable(_bookings);

  /// Load bookings for a specific spa (real-time)
  void subscribeToSpa(String spaId) {
    if (_currentSpaId == spaId) return;

    _subscription?.cancel();
    _currentSpaId = spaId;
    _bookings.clear();
    notifyListeners();

    _subscription = _repository.streamBookingsBySpaId(spaId).listen((items) {
      _bookings.clear();
      _bookings.addAll(items);
      notifyListeners();
    });
  }

  /// Create new bookings
  Future<void> addAll(List<Booking> items) async {
    for (final item in items) {
      await _repository.createBooking(item);
    }
    // No need to manually add to _bookings if we are subscribed,
    // the stream will update it. But if we are not subscribed, we might want to?
    // Actually, usually we add bookings and then navigate away, so it's fine.
  }

  /// Load bookings for a specific user (real-time)
  void subscribeToUser(String userId) {
    if (_currentUserId == userId) return;
    _subscription?.cancel();
    _currentUserId = userId;
    _currentSpaId = null;
    _bookings.clear();
    notifyListeners();
    _subscription =
        _repository.streamBookingsByUserId(userId).listen((items) {
      _bookings
        ..clear()
        ..addAll(items);
      notifyListeners();
    });
  }

  int getBookingCount(String spaId, DateTime date, String slot) {
    // Only works effectively if we are subscribed to this spaId
    if (_currentSpaId != null && _currentSpaId != spaId) {
      // If asking for a different spa than subscribed, return 0 (or handle error)
      //Ideally we should manage multiple subscriptions if needed, but for now
      // OrderSummaryPage focuses on one spa.
      return 0;
    }

    final matching = _bookings.where((b) {
      if (b.spaId != spaId) return false;
      // Compare dates (ignoring time)
      final bDate = b.scheduledAt;
      final sameDate =
          bDate.year == date.year &&
          bDate.month == date.month &&
          bDate.day == date.day;
      if (!sameDate) return false;

      // Check slot match
      final slotStart = slot.split('–').first.trim();
      final hour = bDate.hour > 12
          ? bDate.hour - 12
          : (bDate.hour == 0 ? 12 : bDate.hour);
      final minute = bDate.minute.toString().padLeft(2, '0');
      final ampm = bDate.hour >= 12 ? 'PM' : 'AM';
      final bookingTimeStr = "$hour:$minute $ampm";

      return slotStart.startsWith(bookingTimeStr);
    });
    final txIds = matching.map((b) => b.transactionId).toSet();
    return txIds.length;
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
