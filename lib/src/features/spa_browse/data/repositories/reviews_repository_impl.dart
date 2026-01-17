import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/review_entity.dart';
import '../../domain/repositories/reviews_repository.dart';

class ReviewsRepositoryImpl implements ReviewsRepository {
  final FirebaseFirestore firestore;
  ReviewsRepositoryImpl(this.firestore);

  @override
  Stream<List<ReviewEntity>> streamBySpaId(String spaId) {
    final col = firestore
        .collection('spas')
        .doc(spaId)
        .collection('reviews')
        .orderBy('createdAt', descending: true);
    return col.snapshots().map((snap) {
      return snap.docs.map((d) {
        final data = d.data();
        final created = data['createdAt'];
        DateTime createdAt;
        if (created is Timestamp) {
          createdAt = created.toDate();
        } else {
          createdAt =
              DateTime.tryParse(created?.toString() ?? '') ?? DateTime.now();
        }
        final r = data['rating'];
        final rating = r is num
            ? r.toDouble()
            : double.tryParse(r?.toString() ?? '') ?? 0.0;
        final likesRaw = data['likes'];
        final dislikesRaw = data['dislikes'];
        final likes = likesRaw is num
            ? likesRaw.toInt()
            : int.tryParse(likesRaw?.toString() ?? '') ?? 0;
        final dislikes = dislikesRaw is num
            ? dislikesRaw.toInt()
            : int.tryParse(dislikesRaw?.toString() ?? '') ?? 0;
        return ReviewEntity(
          id: d.id,
          userId: data['userId'] ?? '',
          userName: data['userName'] ?? '',
          rating: rating,
          text: data['text'] ?? '',
          createdAt: createdAt,
          likes: likes,
          dislikes: dislikes,
        );
      }).toList();
    });
  }

  @override
  Future<void> addReview({
    required String spaId,
    required String userId,
    required String userName,
    required double rating,
    required String text,
  }) async {
    final spaRef = firestore.collection('spas').doc(spaId);
    final reviewsRef = spaRef.collection('reviews').doc();
    await firestore.runTransaction((tx) async {
      final spaSnap = await tx.get(spaRef);
      final data = spaSnap.data() ?? {};
      final rcRaw = data['ratingCount'];
      final arRaw = data['averageRating'];
      final count = rcRaw is num
          ? rcRaw.toInt()
          : int.tryParse(rcRaw?.toString() ?? '') ?? 0;
      final avg = arRaw is num
          ? arRaw.toDouble()
          : double.tryParse(arRaw?.toString() ?? '') ?? 0.0;
      final newCount = count + 1;
      final newAvg = ((avg * count) + rating) / newCount;
      tx.set(reviewsRef, {
        'userId': userId,
        'userName': userName,
        'rating': rating,
        'text': text,
        'createdAt': FieldValue.serverTimestamp(),
        'likes': 0,
        'dislikes': 0,
      });
      tx.update(spaRef, {
        'averageRating': double.parse(newAvg.toStringAsFixed(2)),
        'ratingCount': newCount,
      });
    });
  }

  @override
  Future<void> likeReview({
    required String spaId,
    required String reviewId,
  }) async {
    final ref = firestore
        .collection('spas')
        .doc(spaId)
        .collection('reviews')
        .doc(reviewId);
    await ref.update({'likes': FieldValue.increment(1)});
  }

  @override
  Future<void> dislikeReview({
    required String spaId,
    required String reviewId,
  }) async {
    final ref = firestore
        .collection('spas')
        .doc(spaId)
        .collection('reviews')
        .doc(reviewId);
    await ref.update({'dislikes': FieldValue.increment(1)});
  }
}
