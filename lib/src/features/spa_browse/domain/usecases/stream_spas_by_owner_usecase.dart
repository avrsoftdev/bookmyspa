import '../entities/spa_entity.dart';
import '../repositories/spa_repository.dart';

class StreamSpasByOwnerUseCase {
  final SpaRepository repository;

  StreamSpasByOwnerUseCase(this.repository);

  Stream<List<SpaEntity>> call(String ownerUid) {
    return repository.streamByOwnerUid(ownerUid);
  }
}
