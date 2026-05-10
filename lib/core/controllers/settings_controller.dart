import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class SettingsController extends GetxController {
  static SettingsController get to => Get.find();

  final _box = GetStorage();
  final _themeKey = 'isDarkMode';
  final _langKey = 'languageCode';

  late Rx<ThemeMode> _themeMode;
  ThemeMode get themeMode => _themeMode.value;

  late Rx<Locale> _locale;
  Locale get locale => _locale.value;

  @override
  void onInit() {
    super.onInit();

    final bool? isDarkMode = _box.read(_themeKey);
    if (isDarkMode == null) {
      _themeMode = ThemeMode.system.obs;
    } else {
      _themeMode = (isDarkMode ? ThemeMode.dark : ThemeMode.light).obs;
    }

    final String? langCode = _box.read(_langKey);
    if (langCode == 'en') {
      _locale = const Locale('en', 'US').obs;
    } else {
      _locale = const Locale('vi', 'VN').obs;
    }
  }

  void setThemeMode(ThemeMode mode) {
    _themeMode.value = mode;
    Get.changeThemeMode(mode);
    if (mode == ThemeMode.system) {
      _box.remove(_themeKey);
    } else {
      _box.write(_themeKey, mode == ThemeMode.dark);
    }
  }

  void setLanguage(String langCode) {
    Locale newLocale;
    if (langCode == 'en') {
      newLocale = const Locale('en', 'US');
    } else {
      newLocale = const Locale('vi', 'VN');
    }

    _locale.value = newLocale;
    Get.updateLocale(newLocale);
    _box.write(_langKey, langCode);
  }
}
