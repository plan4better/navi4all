import 'package:flutter/material.dart';
import 'package:navi4all/core/config.dart';
import 'package:navi4all/core/persistence/preference_helper.dart';
import 'package:navi4all/core/theme/profile_mode.dart';
import 'package:navi4all/schemas/routing/request_config.dart';

class ProfileController extends ChangeNotifier {
  RoutingRequestConfig _routingRequestConfig =
      Settings.defaultRoutingRequestConfigs[ProfileMode.general]!;

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
      Settings.defaultRoutingRequestConfigs[profileMode]!,
    );
  }

  void setRoutingRequestConfig(RoutingRequestConfig config) {
    _routingRequestConfig = config;
    notifyListeners();

    PreferenceHelper.setRoutingRequestConfig(config);
  }

  Future<void> resetRoutingRequestConfig() async {
    ProfileMode profileMode = await PreferenceHelper.getProfileMode();
    RoutingRequestConfig defaultConfig =
        Settings.defaultRoutingRequestConfigs[profileMode]!;

    setRoutingRequestConfig(defaultConfig);
  }

  Future<bool> get isDefaultRoutingRequestConfig async {
    ProfileMode profileMode = await PreferenceHelper.getProfileMode();
    RoutingRequestConfig defaultConfig =
        Settings.defaultRoutingRequestConfigs[profileMode]!;

    // Check inidividual fields for equality
    bool isDefault = true;
    isDefault &=
        _routingRequestConfig.walkingSpeed == defaultConfig.walkingSpeed;
    isDefault &=
        _routingRequestConfig.walkingAvoid == defaultConfig.walkingAvoid;
    isDefault &=
        _routingRequestConfig.transitModes.length ==
            defaultConfig.transitModes.length &&
        _routingRequestConfig.transitModes.every(
          (mode) => defaultConfig.transitModes.contains(mode),
        );
    isDefault &=
        _routingRequestConfig.bicycleSpeed == defaultConfig.bicycleSpeed;
    isDefault &= _routingRequestConfig.accessible == defaultConfig.accessible;

    return isDefault;
  }
}
