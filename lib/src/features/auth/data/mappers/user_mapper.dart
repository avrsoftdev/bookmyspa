import '../../domain/entities/user.dart';
import '../models/user_dto.dart';

class UserMapper {
  static User toDomain(UserDto dto) {
    return User(id: dto.id, name: dto.name, email: dto.email);
  }
}
