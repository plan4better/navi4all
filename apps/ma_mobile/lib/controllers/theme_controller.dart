import 'package:flutter/material.dart';
import 'package:smartroots/core/persistence/preference_helper.dart';
import 'package:smartroots/core/theme/base_map_style.dart';

class ThemeController extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;
  BaseMapStyle _baseMapStyle = BaseMapStyle.light;

  ThemeController(BuildContext context) {
    Brightness platformBrightness = MediaQuery.of(context).platformBrightness;

    PreferenceHelper.getThemeMode().then((mode) {
      _themeMode = mode;
      if (_themeMode == ThemeMode.system) {
        _baseMapStyle = platformBrightness == Brightness.dark
            ? BaseMapStyle.dark
            : BaseMapStyle.light;
        notifyListeners();
      } else {
        PreferenceHelper.getBaseMapStyle().then((style) {
          _baseMapStyle = style;
          notifyListeners();
        });
      }
    });
  }

  ThemeMode get themeMode => _themeMode;
  BaseMapStyle get baseMapStyle => _baseMapStyle;

  void setBaseMapStyle(BaseMapStyle style) {
    switch (style) {
      case BaseMapStyle.light:
        _themeMode = ThemeMode.light;
        break;
      case BaseMapStyle.dark:
        _themeMode = ThemeMode.dark;
        break;
      case BaseMapStyle.satellite:
        _themeMode = ThemeMode.light;
        break;
    }

    _baseMapStyle = style;
    notifyListeners();

    PreferenceHelper.setThemeMode(_themeMode);
    PreferenceHelper.setBaseMapStyle(style);
  }
}
