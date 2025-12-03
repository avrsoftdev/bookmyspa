import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import '../models/user_dto.dart';

class GoogleAuthDataSource {
  final GoogleSignIn _googleSignIn;

  GoogleAuthDataSource({GoogleSignIn? googleSignIn})
    : _googleSignIn = googleSignIn ?? GoogleSignIn(scopes: ['email']);

  Future<UserDto> signIn() async {
    // Sign out any existing session to force fresh login
    if (fb.FirebaseAuth.instance.currentUser != null) {
      await fb.FirebaseAuth.instance.signOut();
    }
    await _googleSignIn.signOut();
    try {
      await _googleSignIn.disconnect();
    } catch (_) {
      // ignore: disconnect may throw if not previously connected
    }
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) {
      throw Exception('Sign-in cancelled');
    }
    final googleAuth = await googleUser.authentication;
    final credential = fb.GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    final userCredential = await fb.FirebaseAuth.instance.signInWithCredential(
      credential,
    );
    final user = userCredential.user;
    if (user == null) {
      throw Exception('Firebase sign-in failed');
    }
    return UserDto(
      id: user.uid,
      name: user.displayName ?? '',
      email: user.email ?? '',
    );
  }

  Future<void> signOut() async {
    await fb.FirebaseAuth.instance.signOut();
    await _googleSignIn.signOut();
  }
}
