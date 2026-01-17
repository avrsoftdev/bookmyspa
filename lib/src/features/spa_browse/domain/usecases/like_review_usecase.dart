import '../repositories/reviews_repository.dart';

class LikeReviewUseCase {
  final ReviewsRepository repository;
  LikeReviewUseCase(this.repository);
  Future<void> call({
    required String spaId,
    required String reviewId,
    required String userId,
  }) {
    return repository.likeReview(
      spaId: spaId,
      reviewId: reviewId,
      userId: userId,
    );
  }
}
