import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../firebase_options.dart';
import 'app.dart';
import 'core/di/di.dart';
import 'core/services/admob_service.dart';
import 'core/services/fcm_service.dart';
import 'core/services/local_notifications_service.dart';
import 'package:permission_handler/permission_handler.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
}

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase first
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  // Initialize Firebase App Check and await activation so that any
  // subsequent Firebase requests (Storage, Firestore, etc.) have a
  // chance to obtain a valid App Check token first.
  // - Web: use reCAPTCHA v3 (site key in assets/config/api_keys.json).
  // - Debug (Android/iOS): use debug provider; register token in Firebase Console.
  // - Release: Play Integrity (Android), App Attest (iOS).
  try {
    String? recaptchaSiteKey;
    if (kIsWeb) {
      try {
        final raw = await rootBundle.loadString('assets/config/api_keys.json');
        final map = jsonDecode(raw) as Map<String, dynamic>?;
        recaptchaSiteKey = map?['recaptcha_v3_site_key'] as String?;
      } catch (_) {}
      if ((recaptchaSiteKey ?? '').isEmpty) {
        debugPrint('AppCheck: Web reCAPTCHA v3 site key missing in api_keys.json; add recaptcha_v3_site_key from Firebase Console → App Check.');
      }
    }

    if (kIsWeb && (recaptchaSiteKey ?? '').isNotEmpty) {
      debugPrint('AppCheck: activating Web reCAPTCHA v3 provider');
      await FirebaseAppCheck.instance.activate(
        androidProvider: AndroidProvider.playIntegrity,
        appleProvider: AppleProvider.appAttest,
        providerWeb: ReCaptchaV3Provider(recaptchaSiteKey!),
      );
    } else if (kDebugMode && !kIsWeb) {
      debugPrint('AppCheck: activating Debug provider');
      await FirebaseAppCheck.instance.activate(
        androidProvider: AndroidProvider.debug,
        appleProvider: AppleProvider.debug,
      );
    } else if (!kIsWeb) {
      debugPrint('AppCheck: activating platform provider');
      await FirebaseAppCheck.instance.activate(
        androidProvider: AndroidProvider.playIntegrity,
        appleProvider: AppleProvider.appAttest,
      );
    } else {
      debugPrint('AppCheck: skipping activation (web without reCAPTCHA key)');
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
    await sl.get<FcmService>().requestPermissions();
  } catch (_) {}
  try {
    await sl.get<LocalNotificationsService>().initialize();
  } catch (_) {}
  try {
    await Permission.notification.request();
  } catch (_) {}
  try {
    FirebaseMessaging.onMessage.listen((message) async {
      await sl.get<LocalNotificationsService>().showRemoteMessage(message);
    });
  } catch (_) {}
  try {
    await sl.get<AdMobService>().initialize();
  } catch (_) {}
  runApp(const App());
}
