import '../entities/review_entity.dart';
import '../repositories/reviews_repository.dart';
class StreamReviewsBySpaUseCase {
  final ReviewsRepository repository;
  StreamReviewsBySpaUseCase(this.repository);
  Stream<List<ReviewEntity>> call(String spaId) => repository.streamBySpaId(spaId);
}
