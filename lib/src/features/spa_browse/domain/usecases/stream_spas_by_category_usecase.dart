import '../entities/spa_entity.dart';
import '../repositories/spa_repository.dart';

class StreamSpasByCategoryUseCase {
  final SpaRepository repository;

  StreamSpasByCategoryUseCase(this.repository);

  Stream<List<SpaEntity>> call(String category) {
    return repository.streamApprovedByCategory(category);
  }
}
