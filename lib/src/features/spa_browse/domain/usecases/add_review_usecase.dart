import '../repositories/reviews_repository.dart';
class AddReviewUseCase {
  final ReviewsRepository repository;
  AddReviewUseCase(this.repository);
  Future<void> call({
    required String spaId,
    required String userId,
    required String userName,
    required double rating,
    required String text,
  }) {
    return repository.addReview(
      spaId: spaId,
      userId: userId,
      userName: userName,
      rating: rating,
      text: text,
    );
  }
}
