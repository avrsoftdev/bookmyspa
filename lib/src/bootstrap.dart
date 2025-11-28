import 'package:flutter/material.dart';
import 'app.dart';
import 'core/di/di.dart';

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initDependencies();
  runApp(const App());
}
