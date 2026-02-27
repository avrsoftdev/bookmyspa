import 'src/bootstrap.dart';

// Note: Firebase and Firebase App Check are initialized inside
// `lib/src/bootstrap.dart`. App Check is configured to use the
// debug provider during debug builds to make local development easier.
//sieji
Future<void> main() async {
  await bootstrap();
}
