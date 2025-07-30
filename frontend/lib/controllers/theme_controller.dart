import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController extends ChangeNotifier {
  static const _key = 'theme_mode';
  ThemeMode _mode = ThemeMode.system;

  ThemeMode get mode => _mode;

  Future<void> load() async {
    final pref = await SharedPreferences.getInstance();
    final idx = pref.getInt(_key) ?? 0;
    _mode = ThemeMode.values[idx];
    notifyListeners();
  }

  Future<void> toggle() async {
    _mode = (_mode == ThemeMode.dark) ? ThemeMode.light : ThemeMode.dark;
    final pref = await SharedPreferences.getInstance();
    await pref.setInt(_key, ThemeMode.values.indexOf(_mode));
    notifyListeners();
  }
}
