import '../repositories/reviews_repository.dart';

class DislikeReviewUseCase {
  final ReviewsRepository repository;
  DislikeReviewUseCase(this.repository);
  Future<void> call({
    required String spaId,
    required String reviewId,
    required String userId,
  }) {
    return repository.dislikeReview(
      spaId: spaId,
      reviewId: reviewId,
      userId: userId,
    );
  }
}
