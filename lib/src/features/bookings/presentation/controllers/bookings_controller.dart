import 'package:flutter/foundation.dart';
import '../../domain/entities/booking.dart';

class BookingsController extends ChangeNotifier {
  final List<Booking> _bookings = [];

  List<Booking> get bookings => List.unmodifiable(_bookings);

  void addAll(List<Booking> items) {
    _bookings.addAll(items);
    notifyListeners();
  }

  int getBookingCount(String spaId, DateTime date, String slot) {
    return _bookings.where((b) {
      if (b.spaId != spaId) return false;
      // Compare dates (ignoring time)
      final bDate = b.scheduledAt;
      final sameDate =
          bDate.year == date.year &&
          bDate.month == date.month &&
          bDate.day == date.day;
      if (!sameDate) return false;

      // Check slot match
      // Assuming slot format "10:00 AM" or "10:00 AM - 11:00 AM"
      // We need to match the start time of the slot with scheduledAt
      final slotStart = slot
          .split('–')
          .first
          .trim(); // handle "10:00 AM – 11:00 AM"
      // Convert scheduledAt to string to compare, or parse slotStart
      // Simpler: Format scheduledAt to "h:mm a" and compare
      final hour = bDate.hour > 12
          ? bDate.hour - 12
          : (bDate.hour == 0 ? 12 : bDate.hour);
      final minute = bDate.minute.toString().padLeft(2, '0');
      final ampm = bDate.hour >= 12 ? 'PM' : 'AM';
      final bookingTimeStr = "$hour:$minute $ampm";

      // Handle "10:00 AM" vs "10:00"
      return slotStart.startsWith(bookingTimeStr);
    }).length;
  }
}
