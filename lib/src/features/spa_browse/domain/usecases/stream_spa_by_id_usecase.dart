import '../entities/spa_entity.dart';
import '../repositories/spa_repository.dart';

class StreamSpaByIdUseCase {
  final SpaRepository repository;
  StreamSpaByIdUseCase(this.repository);
  Stream<SpaEntity?> call(String id) => repository.streamSpaById(id);
}
