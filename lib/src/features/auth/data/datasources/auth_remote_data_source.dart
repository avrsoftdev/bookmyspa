import '../models/user_dto.dart';

class AuthRemoteDataSource {
  Future<UserDto> login({required String email, required String password}) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return UserDto(id: '1', name: 'User', email: email);
  }
}
