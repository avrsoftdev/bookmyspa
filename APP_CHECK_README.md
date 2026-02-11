# Firebase App Check — Setup and Development

This project uses Firebase App Check in `lib/src/bootstrap.dart` to protect Firebase and custom backend resources. App Check is activated per platform as follows:

- **Android**: Play Integrity (release) or Debug provider (debug builds).
- **iOS/macOS**: App Attest (release) or Debug provider (debug builds).
- **Web**: reCAPTCHA v3 (requires a site key in config; see Web setup below).

## Enforcing App Check in Firebase Console

To have Firebase reject requests without a valid App Check token:

1. Open [Firebase Console](https://console.firebase.google.com) → your project → **App Check**.
2. For each product (Firestore, Storage, etc.), open the product and turn **Enforcement** on.
3. Until enforcement is enabled, Firebase accepts requests with or without App Check; enabling it protects your resources.

## Web setup (reCAPTCHA v3)

For the Flutter **web** app, App Check uses reCAPTCHA v3. You must provide the reCAPTCHA v3 site key:

1. In Firebase Console → **App Check** → register your **Web** app with the **reCAPTCHA v3** provider (or use an existing reCAPTCHA v3 key linked to the app).
2. Copy the **reCAPTCHA v3 site key** (from App Check registration or reCAPTCHA admin).
3. Add it to `assets/config/api_keys.json`:
   ```json
   {
     "google_maps_api_key": "...",
     "recaptcha_v3_site_key": "YOUR_RECAPTCHA_V3_SITE_KEY"
   }
   ```
4. Rebuild/run the web app. Without this key, App Check is skipped on web and a console message reminds you to add it.

## Debug token (Android / iOS) — Development

In debug builds (non-web), the app uses the **debug** provider. Register a debug token so Firebase accepts requests from your dev device/emulator.

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

## Cloud Functions and custom backends

The **sendTestPush** HTTP Cloud Function requires a valid App Check token. The client must send the token in the `X-Firebase-AppCheck` header. In Flutter you can get a token with `FirebaseAppCheck.instance.getToken(forceRefresh)` and attach it to your HTTP request. Firebase client SDKs (Firestore, Storage, etc.) attach the token automatically; only custom HTTP calls need to add the header manually.

## Summary

| Platform   | Debug build        | Release build   |
|-----------|--------------------|------------------|
| Android   | Debug provider     | Play Integrity   |
| iOS/macOS | Debug provider     | App Attest       |
| Web       | reCAPTCHA v3 (key in api_keys.json) | reCAPTCHA v3   |

