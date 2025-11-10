import 'package:flutter/material.dart';
import 'package:navi4all/core/persistence/preference_helper.dart';
import 'package:navi4all/core/theme/profile_mode.dart';

class ProfileModeController extends ChangeNotifier {
  ProfileMode _profileMode = ProfileMode.general;

  ProfileModeController(BuildContext context) {
    PreferenceHelper.getProfileMode().then((mode) {
      _profileMode = mode;
    });
  }

  ProfileMode get profileMode => _profileMode;

  void setProfileMode(ProfileMode mode) {
    _profileMode = mode;
    notifyListeners();
    PreferenceHelper.setProfileMode(mode);
  }
}
