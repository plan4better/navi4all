import 'package:flutter/material.dart';
import 'package:navi4all/controllers/profile_controller.dart';
import 'package:navi4all/core/theme/colors.dart';
import 'package:navi4all/core/utils.dart';
import 'package:navi4all/l10n/app_localizations.dart';
import 'package:navi4all/schemas/routing/mode.dart';
import 'package:navi4all/schemas/routing/request_config.dart';
import 'package:navi4all/view/common/accessible_icon_button.dart';
import 'package:provider/provider.dart';

class ItineraryOptions extends StatefulWidget {
  final Mode routingMode;

  const ItineraryOptions({super.key, required this.routingMode});

  @override
  State<ItineraryOptions> createState() => _ItineraryOptionsState();
}

class _ItineraryOptionsState extends State<ItineraryOptions> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 16),
              Row(
                children: [
                  AccessibleIconButton(
                    icon: Icons.arrow_back_rounded,
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  SizedBox(width: 16),
                  Text(
                    AppLocalizations.of(context)!.itineraryOptionsScreenTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Expanded(
                child: ListView(
                  children: [
                    _WidgetWalkOptions(),
                    _WidgetTransitOptions(),
                    _WidgetBicycleOptions(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WidgetWalkOptions extends StatefulWidget {
  @override
  State<_WidgetWalkOptions> createState() => _WidgetWalkOptionsState();
}

class _WidgetWalkOptionsState extends State<_WidgetWalkOptions> {
  final double _minSpeed = 1;
  final double _maxSpeed = 10;

  void _changeSpeed(RoutingRequestConfig routingRequestConfig, double delta) {
    setState(() {
      if ((routingRequestConfig.walkingSpeed + delta) >= _minSpeed &&
          (routingRequestConfig.walkingSpeed + delta) <= _maxSpeed) {
        Provider.of<ProfileController>(
          context,
          listen: false,
        ).setRoutingRequestConfig(
          routingRequestConfig.copyWith(
            walkingSpeed: routingRequestConfig.walkingSpeed + delta,
          ),
        );
      }
    });
  }

  void _setAvoidValue(RoutingRequestConfig routingRequestConfig, bool value) {
    setState(() {
      Provider.of<ProfileController>(
        context,
        listen: false,
      ).setRoutingRequestConfig(
        routingRequestConfig.copyWith(walkingAvoid: value),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileController>(
      builder: (context, profileController, _) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 32),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              AppLocalizations.of(context)!.itineraryOptionsScreenWalkingTitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Theme.of(context).textTheme.displayMedium!.color,
              ),
            ),
          ),
          SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    AppLocalizations.of(
                      context,
                    )!.itineraryOptionsScreenWalkingSpeedOption,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Theme.of(context).textTheme.displayMedium!.color,
                    ),
                  ),
                ),
                Spacer(),
                SizedBox(width: 8),
                AccessibleIconButton(
                  icon: Icons.remove_rounded,
                  onTap: () =>
                      _changeSpeed(profileController.routingRequestConfig, -1),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    TextFormatter.formatSpeedText(
                      profileController.routingRequestConfig.walkingSpeed,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.displayMedium!.color,
                    ),
                  ),
                ),
                SizedBox(width: 8),
                AccessibleIconButton(
                  icon: Icons.add_rounded,
                  onTap: () =>
                      _changeSpeed(profileController.routingRequestConfig, 1),
                ),
              ],
            ),
          ),
          SizedBox(height: 8),
          Divider(height: 0.0, color: Navi4AllColors.klPink),
          _SwitchTile(
            title: AppLocalizations.of(
              context,
            )!.itineraryOptionsScreenWalkingAvoidOption,
            value: profileController.routingRequestConfig.walkingAvoid,
            onChanged: (bool value) {
              _setAvoidValue(profileController.routingRequestConfig, value);
            },
          ),
        ],
      ),
    );
  }
}

class _WidgetTransitOptions extends StatelessWidget {
  void _setModeValue(
    BuildContext context,
    RoutingRequestConfig routingRequestConfig,
    Mode mode,
    bool value,
  ) {
    List<Mode> updatedModes = List.from(routingRequestConfig.transitModes);
    if (value) {
      if (!updatedModes.contains(mode)) {
        updatedModes.add(mode);
      }
    } else {
      updatedModes.remove(mode);
    }

    Provider.of<ProfileController>(
      context,
      listen: false,
    ).setRoutingRequestConfig(
      routingRequestConfig.copyWith(transitModes: updatedModes),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileController>(
      builder: (context, profileController, _) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 32),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              AppLocalizations.of(context)!.itineraryOptionsScreenModesTitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Theme.of(context).textTheme.displayMedium!.color,
              ),
            ),
          ),
          SizedBox(height: 4),
          _SwitchTile(
            icon: Icons.directions_bus_outlined,
            title: getModeTextMapping(Mode.BUS, context),
            value: profileController.routingRequestConfig.transitModes.contains(
              Mode.BUS,
            ),
            onChanged: (bool value) {
              _setModeValue(
                context,
                profileController.routingRequestConfig,
                Mode.BUS,
                value,
              );
            },
          ),
          _SwitchTile(
            icon: Icons.tram_outlined,
            title: getModeTextMapping(Mode.TRAM, context),
            value: profileController.routingRequestConfig.transitModes.contains(
              Mode.TRAM,
            ),
            onChanged: (bool value) {
              _setModeValue(
                context,
                profileController.routingRequestConfig,
                Mode.TRAM,
                value,
              );
            },
          ),
          _SwitchTile(
            icon: Icons.subway_outlined,
            title: getModeTextMapping(Mode.SUBWAY, context),
            value: profileController.routingRequestConfig.transitModes.contains(
              Mode.SUBWAY,
            ),
            onChanged: (bool value) {
              _setModeValue(
                context,
                profileController.routingRequestConfig,
                Mode.SUBWAY,
                value,
              );
            },
          ),
          _SwitchTile(
            icon: Icons.train_outlined,
            title: getModeTextMapping(Mode.RAIL, context),
            value: profileController.routingRequestConfig.transitModes.contains(
              Mode.RAIL,
            ),
            onChanged: (bool value) {
              _setModeValue(
                context,
                profileController.routingRequestConfig,
                Mode.RAIL,
                value,
              );
            },
          ),
        ],
      ),
    );
  }
}

class _WidgetBicycleOptions extends StatefulWidget {
  @override
  _WidgetBicycleOptionsState createState() => _WidgetBicycleOptionsState();
}

class _WidgetBicycleOptionsState extends State<_WidgetBicycleOptions> {
  final double _minSpeed = 10;
  final double _maxSpeed = 30;

  void _changeSpeed(RoutingRequestConfig routingRequestConfig, double delta) {
    setState(() {
      if ((routingRequestConfig.bicycleSpeed + delta) >= _minSpeed &&
          (routingRequestConfig.bicycleSpeed + delta) <= _maxSpeed) {
        Provider.of<ProfileController>(
          context,
          listen: false,
        ).setRoutingRequestConfig(
          routingRequestConfig.copyWith(
            bicycleSpeed: routingRequestConfig.bicycleSpeed + delta,
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileController>(
      builder: (context, profileController, _) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 32),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              AppLocalizations.of(context)!.itineraryOptionsScreenBicycleTitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Theme.of(context).textTheme.displayMedium!.color,
              ),
            ),
          ),
          SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    AppLocalizations.of(
                      context,
                    )!.itineraryOptionsScreenWalkingSpeedOption,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Theme.of(context).textTheme.displayMedium!.color,
                    ),
                  ),
                ),
                Spacer(),
                SizedBox(width: 8),
                AccessibleIconButton(
                  icon: Icons.remove_rounded,
                  onTap: () =>
                      _changeSpeed(profileController.routingRequestConfig, -1),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    TextFormatter.formatSpeedText(
                      profileController.routingRequestConfig.bicycleSpeed,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.displayMedium!.color,
                    ),
                  ),
                ),
                SizedBox(width: 8),
                AccessibleIconButton(
                  icon: Icons.add_rounded,
                  onTap: () =>
                      _changeSpeed(profileController.routingRequestConfig, 1),
                ),
              ],
            ),
          ),
          SizedBox(height: 8),
          Divider(height: 0.0, color: Navi4AllColors.klPink),
        ],
      ),
    );
  }
}

class _SwitchTile extends StatelessWidget {
  final IconData? icon;
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SwitchTile({
    this.icon,
    required this.title,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
          child: Row(
            children: [
              if (icon != null)
                Icon(
                  icon,
                  color: Theme.of(context).textTheme.displayMedium!.color,
                ),
              if (icon != null) SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Theme.of(context).textTheme.displayMedium!.color,
                    fontSize: 14.0,
                  ),
                ),
              ),
              Switch(
                value: value,
                onChanged: onChanged,
                activeTrackColor: Theme.of(
                  context,
                ).textTheme.displayMedium!.color,
              ),
            ],
          ),
        ),
        Divider(height: 0, color: Navi4AllColors.klPink),
      ],
    );
  }
}
