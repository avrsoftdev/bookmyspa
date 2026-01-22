import '../entities/booking.dart';

abstract class BookingsRepository {
  Future<void> createBooking(Booking booking);
  Stream<List<Booking>> streamBookingsBySpaId(String spaId);
  Stream<List<Booking>> streamBookingsByUserId(String userId);
}
