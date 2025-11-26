import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:navi4all/controllers/itinerary_controller.dart';
import 'package:navi4all/controllers/profile_controller.dart';
import 'package:navi4all/core/config.dart';
import 'package:navi4all/core/theme/colors.dart';
import 'package:navi4all/core/theme/labels.dart';
import 'package:navi4all/core/theme/profile_mode.dart';
import 'package:navi4all/core/utils.dart';
import 'package:navi4all/l10n/app_localizations.dart';
import 'package:navi4all/schemas/routing/mode.dart';
import 'package:navi4all/schemas/routing/request_config.dart';
import 'package:navi4all/view/common/accessible_button.dart';
import 'package:navi4all/view/common/accessible_icon_button.dart';
import 'package:navi4all/view/common/sheet_button.dart';
import 'package:provider/provider.dart';

class ItineraryOptions extends StatefulWidget {
  final bool altMode;
  final Mode routingMode;

  const ItineraryOptions({
    super.key,
    required this.altMode,
    required this.routingMode,
  });

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
                    semanticLabel: AppLocalizations.of(
                      context,
                    )!.commonBackButtonSemantic,
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
                    widget.altMode
                        ? _WidgetDepartureTimeOptions()
                        : SizedBox.shrink(),
                    _WidgetRoutingProfileOptions(),
                    _WidgetWalkOptions(),
                    _WidgetTransitOptions(),
                    // TODO: Enable bicycle options
                    // _WidgetBicycleOptions(),
                    SizedBox(height: 32),
                    widget.altMode
                        ? Align(
                            alignment: Alignment.bottomCenter,
                            child: AccessibleButton(
                              label: AppLocalizations.of(
                                context,
                              )!.altModeButtonDone,
                              style: AccessibleButtonStyle.pink,
                              onTap: () => Navigator.of(context).pop(),
                            ),
                          )
                        : SizedBox.shrink(),
                    widget.altMode ? SizedBox(height: 8) : SizedBox.shrink(),
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

class _WidgetDepartureTimeOptions extends StatelessWidget {
  Future<void> _showJourneyTimePicker(BuildContext context) async {
    final TimeOfDay? newJourneyTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(
        Provider.of<ItineraryController>(context, listen: false).time!,
      ),
    );

    if (newJourneyTime == null) {
      return;
    }

    final itineraryController = Provider.of<ItineraryController>(
      context,
      listen: false,
    );
    final DateTime currentDateTime = itineraryController.time!;
    final DateTime updatedDateTime = DateTime(
      currentDateTime.year,
      currentDateTime.month,
      currentDateTime.day,
      newJourneyTime.hour,
      newJourneyTime.minute,
    );
    itineraryController.setParameters(
      context: context,
      originPlace: itineraryController.originPlace!,
      destinationPlace: itineraryController.destinationPlace!,
      primaryMode: itineraryController.primaryMode!,
      time: updatedDateTime,
      isArrivalTime: itineraryController.isArrivalTime!,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 32),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            AppLocalizations.of(
              context,
            )!.itineraryOptionsScreenDepartureTimeTitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Theme.of(context).textTheme.displayMedium!.color,
            ),
          ),
        ),
        SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Consumer<ItineraryController>(
            builder: (context, itineraryController, _) => SheetButton(
              icon: Icons.schedule_outlined,
              label: itineraryController.hasParametersSet
                  ? AppLocalizations.of(context)!.itineraryDepartureTime(
                      DateFormat(
                        DateFormat.HOUR24_MINUTE,
                      ).format(itineraryController.time!),
                    )
                  : '...',
              onTap: () => _showJourneyTimePicker(context),
            ),
          ),
        ),
      ],
    );
  }
}

class _WidgetRoutingProfileOptions extends StatefulWidget {
  @override
  State<_WidgetRoutingProfileOptions> createState() =>
      _WidgetRoutingProfileOptionsState();
}

class _WidgetRoutingProfileOptionsState
    extends State<_WidgetRoutingProfileOptions> {
  void _setRoutingProfile(RoutingProfile? profile) {
    if (profile == null) return;

    Provider.of<ProfileController>(
      context,
      listen: false,
    ).setRoutingRequestConfig(Settings.routingRequestConfigs[profile]!);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 32),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            AppLocalizations.of(
              context,
            )!.itineraryOptionsScreenRoutingProfileItem,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Theme.of(context).textTheme.displayMedium!.color,
            ),
          ),
        ),
        SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(32.0),
              border: Border.all(color: Navi4AllColors.klPink, width: 2.0),
            ),
            child: Consumer<ProfileController>(
              builder: (context, profileController, _) =>
                  DropdownButton<RoutingProfile>(
                    dropdownColor: Theme.of(context).colorScheme.tertiary,
                    underline: Container(),
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    borderRadius: BorderRadius.circular(32.0),
                    isExpanded: true,
                    value: profileController.getAssociatedRoutingProfile(),
                    items: List.generate(
                      Settings.routingRequestConfigs.length,
                      (index) {
                        final routingProfile = Settings
                            .routingRequestConfigs
                            .keys
                            .elementAt(index);
                        return DropdownMenuItem<RoutingProfile>(
                          value: routingProfile,
                          child: Text(
                            Navi4AllLabels.getRoutingProfileLabel(
                              context,
                              routingProfile,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Theme.of(
                                context,
                              ).textTheme.displayMedium!.color,
                            ),
                          ),
                        );
                      },
                    ),
                    onChanged: _setRoutingProfile,
                  ),
            ),
          ),
        ),
      ],
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
            child: Semantics(
              excludeSemantics: true,
              child: Text(
                AppLocalizations.of(
                  context,
                )!.itineraryOptionsScreenWalkingTitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Theme.of(context).textTheme.displayMedium!.color,
                ),
              ),
            ),
          ),
          SizedBox(height: 4),
          Semantics(
            label: AppLocalizations.of(context)!
                .itineraryOptionsScreenWalkingSpeedOptionSemantic(
                  TextFormatter.formatSpeedText(
                    profileController.routingRequestConfig.walkingSpeed,
                  ),
                ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Expanded(
                    child: Semantics(
                      excludeSemantics: true,
                      child: Text(
                        AppLocalizations.of(
                          context,
                        )!.itineraryOptionsScreenWalkingSpeedOption,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Theme.of(
                            context,
                          ).textTheme.displayMedium!.color,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  AccessibleIconButton(
                    icon: Icons.remove_rounded,
                    onTap: () => _changeSpeed(
                      profileController.routingRequestConfig,
                      -1,
                    ),
                    semanticLabel: AppLocalizations.of(
                      context,
                    )!.itineraryOptionsScreenWalkingSpeedDecrementSemantic,
                  ),
                  SizedBox(width: 8),
                  SizedBox(
                    width: 64.0,
                    child: Semantics(
                      excludeSemantics: true,
                      child: Text(
                        TextFormatter.formatSpeedText(
                          profileController.routingRequestConfig.walkingSpeed,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(
                            context,
                          ).textTheme.displayMedium!.color,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  AccessibleIconButton(
                    icon: Icons.add_rounded,
                    onTap: () =>
                        _changeSpeed(profileController.routingRequestConfig, 1),
                    semanticLabel: AppLocalizations.of(
                      context,
                    )!.itineraryOptionsScreenWalkingSpeedIncrementSemantic,
                  ),
                ],
              ),
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
            semanticLabel: AppLocalizations.of(context)!
                .itineraryOptionsScreenWalkingAvoidOptionSemantic(
                  profileController.routingRequestConfig.walkingAvoid
                      ? AppLocalizations.of(
                          context,
                        )!.itineraryOptionsScreenWalkingAvoidOptionStatusEnabledSemantic
                      : AppLocalizations.of(
                          context,
                        )!.itineraryOptionsScreenWalkingAvoidOptionStatusDisabledSemantic,
                ),
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
            semanticLabel: getModeTextMapping(Mode.BUS, context),
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
            semanticLabel: getModeTextMapping(Mode.TRAM, context),
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
            semanticLabel: getModeTextMapping(Mode.SUBWAY, context),
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
            semanticLabel: getModeTextMapping(Mode.RAIL, context),
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
                  semanticLabel: AppLocalizations.of(
                    context,
                  )!.itineraryOptionsScreenBicycleSpeedDecrementSemantic,
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
                  semanticLabel: AppLocalizations.of(
                    context,
                  )!.itineraryOptionsScreenBicycleSpeedIncrementSemantic,
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
  final String semanticLabel;

  const _SwitchTile({
    this.icon,
    required this.title,
    required this.value,
    required this.onChanged,
    required this.semanticLabel,
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
                child: Semantics(
                  excludeSemantics: true,
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
              ),
              Semantics(
                label: semanticLabel,
                enabled: value,
                child: Switch(
                  value: value,
                  onChanged: onChanged,
                  activeTrackColor: Theme.of(
                    context,
                  ).textTheme.displayMedium!.color,
                ),
              ),
            ],
          ),
        ),
        Divider(height: 0, color: Navi4AllColors.klPink),
      ],
    );
  }
}
