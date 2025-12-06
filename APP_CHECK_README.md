# Firebase App Check (Debug) — Development Instructions

This project initializes Firebase App Check in `lib/src/bootstrap.dart`.
In debug builds App Check is activated using the debug provider so you can
register a debug token in the Firebase Console for local development.

Follow these steps to get a debug token and register it in the Firebase Console:

1. Add the dependency and run pub get

   After the changes were applied, add the package (if not already added) and fetch packages:

   ```powershell
   cd C:\Projects\bookmyspa
   flutter pub get
   ```

2. Run the app on your development device/emulator and look for the debug token

   - For Android (emulator or device): open `adb logcat` and run the app. Look for a line like:

     ```
     I/FirebaseAppCheck: App Check debug token:
     <YOUR_DEBUG_TOKEN_HERE>
     ```

     To view logcat (PowerShell):

     ```powershell
     adb logcat -d | Select-String "App Check debug token"
     ```

   - For iOS (simulator/device): watch the Xcode console or run the app from `flutter run` and look for the same message.

   - For Web: the token will be printed to the browser console when the debug provider is active.

3. Register the debug token in Firebase Console

   - Open the Firebase Console: https://console.firebase.google.com
   - Select your project, then go to **App Check** on the left menu.
   - Select the app for which you want to register a debug token (Android or iOS or Web).
   - Under **Debug tokens**, click **Add debug token** (or similar action) and paste the token you copied from the logs.
   - Save / confirm.

4. Re-run the app

   Once the debug token is registered, App Check requests from that device should be accepted by Firebase services.

Notes and troubleshooting

- The debug provider is safe for local development only. Do not ship debug tokens or debug configuration to production builds.
- In `lib/src/bootstrap.dart` App Check is activated using `AndroidProvider.debug` / `AppleProvider.debug` when the app runs in Dart `kDebugMode`. The production providers used in release builds are Play Integrity and App Attest.
- If you prefer to use the Firebase Emulators for Storage during development, run:

  ```powershell
  firebase emulators:start --only storage
  ```

  and configure the app to use the emulator endpoint instead of the real Storage bucket.

- If you do not register a debug token and App Check enforcement is enabled for your Firebase project/storage bucket, uploads may be rejected with 404/Not Found or session-terminated errors.

If you want, I can also:
- Add emulator wiring helpers to the project and a convenience flag to connect to emulators.
- Add a small runtime UI which prints the current App Check debug token to the app screen while in debug mode.

