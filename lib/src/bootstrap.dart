import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import '../firebase_options.dart';
import 'app.dart';
import 'core/di/di.dart';
import 'core/services/admob_service.dart';

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase first
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize Firebase App Check and await activation so that any
  // subsequent Firebase requests (Storage, Firestore, etc.) have a
  // chance to obtain a valid App Check token first.
  // - In debug builds use the debug provider so you can register the
  //   debug token in the Firebase Console for local development and testing.
  // - In release builds activate platform providers (Play Integrity / App Attest).
  try {
    if (kDebugMode) {
      debugPrint('AppCheck: activating Debug provider');
      await FirebaseAppCheck.instance.activate(
        androidProvider: AndroidProvider.debug,
        appleProvider: AppleProvider.debug,
      );
    } else {
      debugPrint('AppCheck: activating platform provider');
      await FirebaseAppCheck.instance.activate(
        androidProvider: AndroidProvider.playIntegrity,
        appleProvider: AppleProvider.appAttest,
      );
    }
    debugPrint('AppCheck: activation completed');
  } catch (e, st) {
    // Log the error and continue startup. In many development setups the
    // App Check API or attestation may fail; registering a debug token or
    // enabling the API (see README) will resolve it. We don't crash the app
    // here to avoid blocking developers, but uploads may be rejected until
    // App Check is properly configured.
    debugPrint('AppCheck: activation failed: $e');
    debugPrint(st.toString());
  }
  
  await initDependencies();
  try {
    await sl.get<AdMobService>().initialize();
  } catch (_) {}
  runApp(const App());
}
