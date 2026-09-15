import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  static const String _themeKey = 'theme_mode';
  static const String _currencyKey = 'currency_symbol';

  ThemeMode _themeMode = ThemeMode.system;
  String _currencySymbol = '₹';

  ThemeMode get themeMode => _themeMode;
  String get currencySymbol => _currencySymbol;

  bool get isDarkMode => _themeMode == ThemeMode.dark;

  ThemeProvider() {
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final themeIndex = prefs.getInt(_themeKey);
    if (themeIndex != null && themeIndex >= 0 && themeIndex < ThemeMode.values.length) {
      _themeMode = ThemeMode.values[themeIndex];
    }
    _currencySymbol = prefs.getString(_currencyKey) ?? '₹';
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeKey, mode.index);
  }

  Future<void> toggleDarkMode(bool enabled) async {
    await setThemeMode(enabled ? ThemeMode.dark : ThemeMode.light);
  }

  Future<void> setCurrencySymbol(String symbol) async {
    _currencySymbol = symbol;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currencyKey, symbol);
  }

  String formatAmount(double amount) {
    return '$_currencySymbol ${amount.toStringAsFixed(2)}';
  }
}
