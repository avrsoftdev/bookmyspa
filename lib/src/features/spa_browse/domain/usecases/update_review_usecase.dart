import '../repositories/reviews_repository.dart';

class UpdateReviewUseCase {
  final ReviewsRepository repository;
  UpdateReviewUseCase(this.repository);

  Future<void> call({
    required String spaId,
    required String reviewId,
    required double rating,
    required String text,
  }) {
    return repository.updateReview(
      spaId: spaId,
      reviewId: reviewId,
      rating: rating,
      text: text,
    );
  }
}
