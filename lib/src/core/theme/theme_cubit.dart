import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  final SharedPreferences prefs;
  static const _key = 'isDarkTheme';

  ThemeCubit(this.prefs) : super(ThemeMode.light);

  Future<void> load() async {
    final isDark = prefs.getBool(_key) ?? false;
    emit(isDark ? ThemeMode.dark : ThemeMode.light);
  }

  Future<void> setDark(bool isDark) async {
    await prefs.setBool(_key, isDark);
    emit(isDark ? ThemeMode.dark : ThemeMode.light);
  }
}
