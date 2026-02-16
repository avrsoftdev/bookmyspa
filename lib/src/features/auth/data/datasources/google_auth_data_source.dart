import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/foundation.dart';
import '../models/user_dto.dart';

class GoogleAuthDataSource {
  final GoogleSignIn _googleSignIn;

  GoogleAuthDataSource({GoogleSignIn? googleSignIn})
    : _googleSignIn = googleSignIn ?? GoogleSignIn(
        scopes: ['email'],
        // Web client ID for Firebase project
        clientId: '28024749368-i5l4rhs5bg4rri5bqd5295871joansqo.apps.googleusercontent.com',
      );

  Future<UserDto> signIn() async {
    try {
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
      
      debugPrint('GoogleAuthDataSource: Starting Google Sign-In...');
      final googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        debugPrint('GoogleAuthDataSource: Sign-in cancelled by user');
        throw Exception('Sign-in cancelled');
      }
      
      debugPrint('GoogleAuthDataSource: Got Google user: ${googleUser.email}');
      final googleAuth = await googleUser.authentication;
      debugPrint('GoogleAuthDataSource: Got Google authentication tokens');
      
      final credential = fb.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      
      debugPrint('GoogleAuthDataSource: Signing in with Firebase...');
      final userCredential = await fb.FirebaseAuth.instance.signInWithCredential(
        credential,
      );
      
      final user = userCredential.user;
      if (user == null) {
        debugPrint('GoogleAuthDataSource: Firebase sign-in failed - no user returned');
        throw Exception('Firebase sign-in failed');
      }
      
      debugPrint('GoogleAuthDataSource: Firebase sign-in successful: ${user.email}');
      return UserDto(
        id: user.uid,
        name: user.displayName ?? '',
        email: user.email ?? '',
      );
    } catch (e) {
      debugPrint('GoogleAuthDataSource: Error during sign-in: $e');
      rethrow;
    }
  }

  Future<void> signOut() async {
    await fb.FirebaseAuth.instance.signOut();
    await _googleSignIn.signOut();
  }
}
