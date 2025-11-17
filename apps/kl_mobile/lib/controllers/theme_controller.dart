import 'package:flutter/material.dart';
import 'package:navi4all/core/persistence/preference_helper.dart';
import 'package:navi4all/core/theme/base_map_style.dart';
import 'package:navi4all/core/theme/colors.dart';
import 'package:navi4all/core/theme/profile_mode.dart';

class ThemeController extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;
  BaseMapStyle _baseMapStyle = BaseMapStyle.light;
  ProfileMode _profileMode = ProfileMode.general;
  Color textColorLight = Navi4AllColors.klRed;
  Color textColorDark = Navi4AllColors.klRed;

  ThemeController(BuildContext context) {
    _initialize(context);
  }

  Future<void> _initialize(BuildContext context) async {
    setProfileMode(await PreferenceHelper.getProfileMode());

    Brightness platformBrightness = MediaQuery.of(context).platformBrightness;
    _themeMode = await PreferenceHelper.getThemeMode();
    if (_themeMode == ThemeMode.system) {
      _baseMapStyle = platformBrightness == Brightness.dark
          ? BaseMapStyle.dark
          : BaseMapStyle.light;
      notifyListeners();
    } else {
      _baseMapStyle = await PreferenceHelper.getBaseMapStyle();
      notifyListeners();
    }
  }

  ThemeMode get themeMode => _themeMode;
  BaseMapStyle get baseMapStyle => _baseMapStyle;
  ProfileMode get profileMode => _profileMode;

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

  void setProfileMode(ProfileMode mode) {
    _profileMode = mode;

    switch (mode) {
      case ProfileMode.blind:
        textColorLight = Navi4AllColors.klRed;
        textColorDark = Navi4AllColors.klRed;
        break;
      case ProfileMode.visionImpaired:
        textColorLight = Navi4AllColors.klDarkRed;
        textColorDark = Navi4AllColors.klLightRed;
        break;
      case ProfileMode.general:
        textColorLight = Navi4AllColors.klRed;
        textColorDark = Navi4AllColors.klRed;
        break;
    }

    notifyListeners();
  }
}
