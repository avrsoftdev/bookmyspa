import '../entities/spa_entity.dart';

abstract class SpaRepository {
  Stream<List<SpaEntity>> streamApprovedByCategory(String category);
  Stream<SpaEntity?> streamSpaById(String id);
}
