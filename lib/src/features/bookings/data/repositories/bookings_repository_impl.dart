import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/booking.dart';
import '../../domain/repositories/bookings_repository.dart';

class BookingsRepositoryImpl implements BookingsRepository {
  final FirebaseFirestore _firestore;

  BookingsRepositoryImpl(this._firestore);

  @override
  Future<void> createBooking(Booking booking) async {
    await _firestore
        .collection('bookings')
        .doc(booking.id)
        .set(booking.toMap());
  }

  @override
  Stream<List<Booking>> streamBookingsBySpaId(String spaId) {
    return _firestore
        .collection('bookings')
        .where('spaId', isEqualTo: spaId)
        .snapshots()
        .map((snapshot) {
          final items = snapshot.docs
              .map((doc) => Booking.fromMap(doc.data()))
              .toList();
          items.sort((a, b) => b.scheduledAt.compareTo(a.scheduledAt));
          return items;
        });
  }

  @override
  Stream<List<Booking>> streamBookingsByUserId(String userId) {
    return _firestore
        .collection('bookings')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          final items = snapshot.docs
              .map((doc) => Booking.fromMap(doc.data()))
              .toList();
          items.sort((a, b) => b.scheduledAt.compareTo(a.scheduledAt));
          return items;
        });
  }
}
