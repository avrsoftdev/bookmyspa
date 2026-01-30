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
        final lb = data['likedBy'];
        final db = data['dislikedBy'];
        final likedBy = lb is List
            ? lb.map((e) => e.toString()).toList()
            : <String>[];
        final dislikedBy = db is List
            ? db.map((e) => e.toString()).toList()
            : <String>[];
        final likesRaw = data['likes'];
        final dislikesRaw = data['dislikes'];
        int likes = likedBy.length;
        int dislikes = dislikedBy.length;
        if (likes == 0 && likesRaw != null) {
          likes = likesRaw is num
              ? likesRaw.toInt()
              : int.tryParse(likesRaw.toString()) ?? 0;
        }
        if (dislikes == 0 && dislikesRaw != null) {
          dislikes = dislikesRaw is num
              ? dislikesRaw.toInt()
              : int.tryParse(dislikesRaw.toString()) ?? 0;
        }
        return ReviewEntity(
          id: d.id,
          userId: data['userId'] ?? '',
          userName: data['userName'] ?? '',
          rating: rating,
          text: data['text'] ?? '',
          createdAt: createdAt,
          likes: likes,
          dislikes: dislikes,
          likedBy: likedBy,
          dislikedBy: dislikedBy,
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
    final reviewsRef = spaRef.collection('reviews').doc(userId);
    await firestore.runTransaction((tx) async {
      final existing = await tx.get(reviewsRef);
      if (existing.exists) {
        throw Exception('You have already submitted a review for this spa');
      }
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
        'likedBy': <String>[],
        'dislikedBy': <String>[],
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
    required String userId,
  }) async {
    final ref = firestore
        .collection('spas')
        .doc(spaId)
        .collection('reviews')
        .doc(reviewId);
    await firestore.runTransaction((tx) async {
      final snap = await tx.get(ref);
      final data = snap.data() ?? {};
      final likedBy =
          (data['likedBy'] as List?)?.map((e) => e.toString()).toList() ??
          <String>[];
      final dislikedBy =
          (data['dislikedBy'] as List?)?.map((e) => e.toString()).toList() ??
          <String>[];
      bool hasLiked = likedBy.contains(userId);
      bool hasDisliked = dislikedBy.contains(userId);
      if (hasLiked) {
        likedBy.remove(userId);
      } else {
        likedBy.add(userId);
        if (hasDisliked) {
          dislikedBy.remove(userId);
        }
      }
      final likes = likedBy.length;
      final dislikes = dislikedBy.length;
      tx.update(ref, {
        'likedBy': likedBy,
        'dislikedBy': dislikedBy,
        'likes': likes,
        'dislikes': dislikes,
      });
    });
  }

  @override
  Future<void> dislikeReview({
    required String spaId,
    required String reviewId,
    required String userId,
  }) async {
    final ref = firestore
        .collection('spas')
        .doc(spaId)
        .collection('reviews')
        .doc(reviewId);
    await firestore.runTransaction((tx) async {
      final snap = await tx.get(ref);
      final data = snap.data() ?? {};
      final likedBy =
          (data['likedBy'] as List?)?.map((e) => e.toString()).toList() ??
          <String>[];
      final dislikedBy =
          (data['dislikedBy'] as List?)?.map((e) => e.toString()).toList() ??
          <String>[];
      bool hasLiked = likedBy.contains(userId);
      bool hasDisliked = dislikedBy.contains(userId);
      if (hasDisliked) {
        dislikedBy.remove(userId);
      } else {
        dislikedBy.add(userId);
        if (hasLiked) {
          likedBy.remove(userId);
        }
      }
      final likes = likedBy.length;
      final dislikes = dislikedBy.length;
      tx.update(ref, {
        'likedBy': likedBy,
        'dislikedBy': dislikedBy,
        'likes': likes,
        'dislikes': dislikes,
      });
    });
  }

  @override
  Future<void> updateReview({
    required String spaId,
    required String reviewId,
    required double rating,
    required String text,
  }) async {
    final spaRef = firestore.collection('spas').doc(spaId);
    final reviewRef = spaRef.collection('reviews').doc(reviewId);
    await firestore.runTransaction((tx) async {
      final reviewSnap = await tx.get(reviewRef);
      if (!reviewSnap.exists) {
        throw Exception('Review not found');
      }
      final currentData = reviewSnap.data()!;
      final oldRatingRaw = currentData['rating'];
      final oldRating = oldRatingRaw is num
          ? oldRatingRaw.toDouble()
          : double.tryParse(oldRatingRaw?.toString() ?? '') ?? 0.0;

      final spaSnap = await tx.get(spaRef);
      final spaData = spaSnap.data() ?? {};
      final rcRaw = spaData['ratingCount'];
      final arRaw = spaData['averageRating'];
      final count = rcRaw is num
          ? rcRaw.toInt()
          : int.tryParse(rcRaw?.toString() ?? '') ?? 0;
      final avg = arRaw is num
          ? arRaw.toDouble()
          : double.tryParse(arRaw?.toString() ?? '') ?? 0.0;
      final denom = count <= 0 ? 1 : count;
      final newAvg = ((avg * denom) - oldRating + rating) / denom;

      tx.update(reviewRef, {
        'rating': rating,
        'text': text,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      tx.update(spaRef, {
        'averageRating': double.parse(newAvg.toStringAsFixed(2)),
        'ratingCount': count,
      });
    });
  }
}
