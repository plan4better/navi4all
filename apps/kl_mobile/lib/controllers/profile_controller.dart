import 'package:flutter/material.dart';
import 'package:navi4all/core/config.dart';
import 'package:navi4all/core/persistence/preference_helper.dart';
import 'package:navi4all/core/theme/profile_mode.dart';
import 'package:navi4all/schemas/routing/request_config.dart';

class ProfileController extends ChangeNotifier {
  RoutingRequestConfig _routingRequestConfig =
      Settings.routingRequestConfigs[Settings.defaultRoutingProfiles[ProfileMode
          .general]!]!;

  ProfileController() {
    _initialize();
  }

  RoutingRequestConfig get routingRequestConfig => _routingRequestConfig;

  Future<void> _initialize() async {
    RoutingRequestConfig? routingRequestConfig =
        await PreferenceHelper.getRoutingRequestConfig();

    if (routingRequestConfig != null) {
      setRoutingRequestConfig(routingRequestConfig);
      return;
    }

    ProfileMode profileMode = await PreferenceHelper.getProfileMode();
    setRoutingRequestConfig(
      Settings.routingRequestConfigs[Settings
          .defaultRoutingProfiles[profileMode]!]!,
    );
  }

  void setRoutingRequestConfig(RoutingRequestConfig config) {
    _routingRequestConfig = config;
    notifyListeners();

    PreferenceHelper.setRoutingRequestConfig(config);
  }

  Future<void> resetRoutingRequestConfig() async {
    ProfileMode profileMode = await PreferenceHelper.getProfileMode();
    RoutingRequestConfig defaultConfig = Settings
        .routingRequestConfigs[Settings.defaultRoutingProfiles[profileMode]!]!;

    setRoutingRequestConfig(defaultConfig);
  }

  RoutingProfile? getAssociatedRoutingProfile() {
    for (var entry in Settings.routingRequestConfigs.entries) {
      // Check individual fields for equality
      bool isDefault = true;
      isDefault &=
          _routingRequestConfig.walkingSpeed == entry.value.walkingSpeed;
      isDefault &=
          _routingRequestConfig.walkingAvoid == entry.value.walkingAvoid;
      isDefault &=
          _routingRequestConfig.transitModes.length ==
              entry.value.transitModes.length &&
          _routingRequestConfig.transitModes.every(
            (mode) => entry.value.transitModes.contains(mode),
          );
      isDefault &=
          _routingRequestConfig.bicycleSpeed == entry.value.bicycleSpeed;
      isDefault &= _routingRequestConfig.accessible == entry.value.accessible;

      if (isDefault) {
        return entry.key;
      }
    }

    return null;
  }
}
