import '../entities/spa_entity.dart';
import '../repositories/spa_repository.dart';

class StreamAllApprovedSpasUseCase {
  final SpaRepository repository;
  StreamAllApprovedSpasUseCase(this.repository);

  Stream<List<SpaEntity>> call() {
    return repository.streamApprovedAll();
  }
}
