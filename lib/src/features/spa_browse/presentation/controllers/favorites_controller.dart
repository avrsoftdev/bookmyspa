import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../domain/entities/spa_entity.dart';

class FavoritesController extends ChangeNotifier {
  final FirebaseFirestore firestore;
  final AuthController authController;

  FavoritesController({required this.firestore, required this.authController});

  String? get _uid => authController.currentUser?.id;

  CollectionReference<Map<String, dynamic>>? get _favCol =>
      _uid != null ? firestore.collection('users').doc(_uid).collection('favorites') : null;

  Stream<bool> isFavoriteStream(String spaId) {
    final col = _favCol;
    if (col == null) return Stream<bool>.value(false);
    return col.doc(spaId).snapshots().map((doc) => doc.exists);
  }

  Future<void> toggleFavorite(String spaId, SpaEntity spa) async {
    final col = _favCol;
    if (col == null) {
      throw Exception('Please login to add favourites');
    }
    final docRef = col.doc(spaId);
    final doc = await docRef.get();
    if (doc.exists) {
      await docRef.delete();
    } else {
      await docRef.set({
        'spaId': spaId,
        'businessName': spa.businessName,
        'city': spa.city,
        'thumbnail': spa.photos.isNotEmpty ? spa.photos.first : null,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  Stream<List<String>> favoriteSpaIdsStream() {
    final col = _favCol;
    if (col == null) return Stream<List<String>>.value(const []);
    return col.orderBy('createdAt', descending: true).snapshots().map((snap) {
      return snap.docs.map((d) => d.id).toList();
    });
  }
}
