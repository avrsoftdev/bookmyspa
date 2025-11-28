import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_dto.dart';

class GoogleAuthDataSource {
  final GoogleSignIn _googleSignIn;

  GoogleAuthDataSource({GoogleSignIn? googleSignIn})
      : _googleSignIn = googleSignIn ?? GoogleSignIn(scopes: ['email']);

  Future<UserDto> signIn() async {
    final account = await _googleSignIn.signIn();
    if (account == null) {
      throw Exception('Sign-in cancelled');
    }
    return UserDto(id: account.id, name: account.displayName ?? '', email: account.email);
  }
}
