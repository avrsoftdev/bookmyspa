import '../repositories/reviews_repository.dart';
class DislikeReviewUseCase {
  final ReviewsRepository repository;
  DislikeReviewUseCase(this.repository);
  Future<void> call({required String spaId, required String reviewId}) {
    return repository.dislikeReview(spaId: spaId, reviewId: reviewId);
  }
}
