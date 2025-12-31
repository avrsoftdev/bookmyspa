import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleCubit extends Cubit<Locale> {
  final SharedPreferences prefs;
  static const _key = 'languageCode';

  LocaleCubit(this.prefs) : super(const Locale('en'));

  Future<void> load() async {
    final systemCode =
        WidgetsBinding.instance.platformDispatcher.locale.languageCode;
    final code = prefs.getString(_key) ?? systemCode;
    emit(Locale(code));
  }

  Future<void> setLanguage(String code) async {
    await prefs.setString(_key, code);
    emit(Locale(code));
  }
}
