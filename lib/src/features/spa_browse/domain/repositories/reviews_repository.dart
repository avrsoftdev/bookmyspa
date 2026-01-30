import '../entities/review_entity.dart';

abstract class ReviewsRepository {
  Stream<List<ReviewEntity>> streamBySpaId(String spaId);
  Future<void> addReview({
    required String spaId,
    required String userId,
    required String userName,
    required double rating,
    required String text,
  });
  Future<void> likeReview({
    required String spaId,
    required String reviewId,
    required String userId,
  });
  Future<void> dislikeReview({
    required String spaId,
    required String reviewId,
    required String userId,
  });
  Future<void> updateReview({
    required String spaId,
    required String reviewId,
    required double rating,
    required String text,
  });
}
