import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:navi4all/controllers/itinerary_controller.dart';
import 'package:navi4all/controllers/place_controller.dart';
import 'package:navi4all/controllers/profile_controller.dart';
import 'package:navi4all/core/theme/colors.dart';
import 'package:navi4all/core/theme/icons.dart';
import 'package:navi4all/core/theme/values.dart';
import 'package:navi4all/l10n/app_localizations.dart';
import 'package:navi4all/schemas/routing/mode.dart';
import 'package:navi4all/schemas/routing/place.dart';
import 'package:navi4all/view/common/accessible_icon_button.dart';
import 'package:navi4all/view/common/sheet_button.dart';
import 'package:navi4all/view/itinerary/itinerary_options.dart';
import 'package:navi4all/view/routing/routing.dart';
import 'package:navi4all/view/common/itinerary_widget.dart';
import 'package:navi4all/view/search/search.dart';
import 'package:provider/provider.dart';
import 'package:navi4all/view/alt/routing/routing.dart' as routing_alt;

class ItineraryScreen extends StatefulWidget {
  const ItineraryScreen({super.key});

  @override
  State<ItineraryScreen> createState() => _ItineraryScreenState();
}

class _ItineraryScreenState extends State<ItineraryScreen> {
  final Map<Mode, IconData> _modes = {
    Mode.WALK: ModeIcons.get(Mode.WALK),
    Mode.TRANSIT: ModeIcons.get(Mode.TRANSIT),
  };

  Future<void> _showJourneyTimePicker() async {
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

  Future<void> _showItineraryOptions() async {
    var _ = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ItineraryOptions(
          altMode: false,
          routingMode: Provider.of<ItineraryController>(
            context,
            listen: false,
          ).primaryMode!,
        ),
      ),
    );

    ItineraryController itineraryController = Provider.of<ItineraryController>(
      context,
      listen: false,
    );
    if (!itineraryController.hasParametersSet) {
      super.dispose();
      return;
    }
    itineraryController.setParameters(
      context: context,
      originPlace: itineraryController.originPlace!,
      destinationPlace: itineraryController.destinationPlace!,
      time: itineraryController.time!,
      primaryMode: itineraryController.primaryMode!,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ItineraryController>(
      builder: (context, itineraryController, _) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                SheetButton(
                  icon: Icons.schedule_outlined,
                  label: itineraryController.hasParametersSet
                      ? AppLocalizations.of(context)!.itineraryDepartureTime(
                          DateFormat(
                            DateFormat.HOUR24_MINUTE,
                          ).format(itineraryController.time!),
                        )
                      : '...',
                  onTap: _showJourneyTimePicker,
                ),
                Spacer(),
                SizedBox(width: 8),
                Consumer<ProfileController>(
                  builder: (context, profileController, _) =>
                      AccessibleIconButton(
                        icon: Icons.tune_rounded,
                        onTap: _showItineraryOptions,
                        hasNotification:
                            profileController.getAssociatedRoutingProfile() ==
                            null,
                      ),
                ),
                SizedBox(width: 8),
                AccessibleIconButton(
                  icon: Icons.close_rounded,
                  onTap: () {
                    itineraryController.reset(context);
                    Provider.of<PlaceController>(
                      context,
                      listen: false,
                    ).reset();
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ),
          SizedBox(height: 4),
          DefaultTabController(
            length: _modes.length,
            initialIndex: itineraryController.hasParametersSet
                ? _modes.keys.toList().indexOf(itineraryController.primaryMode!)
                : 0,
            child: TabBar(
              onTap: (index) {
                itineraryController.setParameters(
                  context: context,
                  originPlace: itineraryController.originPlace!,
                  destinationPlace: itineraryController.destinationPlace!,
                  primaryMode: _modes.keys.toList()[index],
                  time: itineraryController.time!,
                  isArrivalTime: itineraryController.isArrivalTime!,
                );
              },
              labelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              indicatorSize: TabBarIndicatorSize.tab,
              unselectedLabelColor: Theme.of(
                context,
              ).textTheme.displayMedium?.color,
              labelColor: Theme.of(context).textTheme.displayMedium?.color,
              indicatorPadding: EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 6.0,
              ),
              splashBorderRadius: BorderRadius.circular(16.0),
              padding: EdgeInsets.symmetric(horizontal: 24.0),
              dividerHeight: 0.0,
              indicator: BoxDecoration(
                borderRadius: BorderRadius.circular(16.0),
                border: Border.all(color: Navi4AllColors.klPink, width: 2.0),
              ),
              tabs: [
                Tab(
                  icon: Icon(Icons.directions_walk_rounded),
                  text: AppLocalizations.of(context)!.itineraryModeTabWalking,
                ),
                Tab(
                  icon: Icon(Icons.directions_transit_rounded),
                  text: AppLocalizations.of(
                    context,
                  )!.itineraryModeTabPublicTransport,
                ),
              ],
            ),
          ),
          Divider(height: 0, color: Navi4AllColors.klPink),
        ],
      ),
    );
  }
}

class ItineraryList extends StatefulWidget {
  final ScrollController scrollController;
  final bool altMode;

  const ItineraryList({
    super.key,
    required this.scrollController,
    this.altMode = false,
  });

  @override
  State<ItineraryList> createState() => _ItineraryListState();
}

class _ItineraryListState extends State<ItineraryList> {
  @override
  Widget build(BuildContext context) {
    return Consumer<ItineraryController>(
      builder: (context, itineraryController, _) =>
          itineraryController.state == ItineraryControllerState.idle &&
              itineraryController.itineraries.isNotEmpty
          ? ListView.separated(
              controller: widget.scrollController,
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              itemBuilder: (context, index) => ItineraryWidget(
                itinerary: itineraryController.itineraries[index],
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) {
                        if (!widget.altMode) {
                          return RoutingScreen(
                            originPlace: itineraryController.originPlace!,
                            destinationPlace:
                                itineraryController.destinationPlace!,
                            itinerarySummary:
                                itineraryController.itineraries[index],
                          );
                        }
                        return routing_alt.RoutingScreen(
                          originPlace: itineraryController.originPlace!,
                          destinationPlace:
                              itineraryController.destinationPlace!,
                          itinerarySummary:
                              itineraryController.itineraries[index],
                        );
                      },
                    ),
                  );
                },
              ),
              separatorBuilder: (_, __) =>
                  Divider(height: 0, color: Navi4AllColors.klPink),
              itemCount: itineraryController.itineraries.length,
            )
          : ProgressWidget(state: itineraryController.state),
    );
  }
}

class ProgressWidget extends StatelessWidget {
  final ItineraryControllerState state;

  const ProgressWidget({super.key, required this.state});

  IconData get icon {
    switch (state) {
      case ItineraryControllerState.idle:
        return Icons.error_outline;
      case ItineraryControllerState.refreshing:
        return Icons.directions_outlined;
      case ItineraryControllerState.error:
        return Icons.error_outline;
    }
  }

  String message(BuildContext context) {
    switch (state) {
      case ItineraryControllerState.idle:
        return AppLocalizations.of(context)!.navigationNoRouteFound;
      case ItineraryControllerState.refreshing:
        return AppLocalizations.of(context)!.navigationGettingDirections;
      case ItineraryControllerState.error:
        return AppLocalizations.of(context)!.navigationNoRouteFound;
    }
  }

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: Theme.of(context).textTheme.displayMedium?.color,
            size: 48,
          ),
          SizedBox(height: 16),
          Text(
            message(context),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    ),
  );
}

class OrigDestPicker extends StatefulWidget {
  final bool altMode;

  const OrigDestPicker({super.key, required this.altMode});

  @override
  State<StatefulWidget> createState() => _OrigDestPickerState();
}

class _OrigDestPickerState extends State<OrigDestPicker> {
  Future<void> _onOriginTap() async {
    Place? originPlace = await Navigator.of(context).push(
      MaterialPageRoute<Place>(
        builder: (context) => SearchScreen(
          isOriginPlaceSearch: true,
          isSecondarySearch: true,
          altMode: widget.altMode,
        ),
      ),
    );

    if (originPlace == null) {
      return;
    }

    final itineraryController = Provider.of<ItineraryController>(
      context,
      listen: false,
    );

    itineraryController.setParameters(
      context: context,
      originPlace: originPlace,
      destinationPlace: itineraryController.destinationPlace!,
      primaryMode: itineraryController.primaryMode!,
      time: itineraryController.time!,
      isArrivalTime: itineraryController.isArrivalTime!,
    );
  }

  Future<void> _onDestinationTap() async {
    Place? destinationPlace = await Navigator.of(context).push(
      MaterialPageRoute<Place>(
        builder: (context) => SearchScreen(
          isOriginPlaceSearch: false,
          isSecondarySearch: true,
          altMode: widget.altMode,
        ),
      ),
    );

    if (destinationPlace == null) {
      return;
    }

    final itineraryController = Provider.of<ItineraryController>(
      context,
      listen: false,
    );

    itineraryController.setParameters(
      context: context,
      originPlace: itineraryController.originPlace!,
      destinationPlace: destinationPlace,
      primaryMode: itineraryController.primaryMode!,
      time: itineraryController.time!,
      isArrivalTime: itineraryController.isArrivalTime!,
    );
  }

  void _swapOriginDestination() {
    final itineraryController = Provider.of<ItineraryController>(
      context,
      listen: false,
    );
    final originPlace = itineraryController.originPlace;
    final destinationPlace = itineraryController.destinationPlace;

    itineraryController.setParameters(
      context: context,
      originPlace: destinationPlace!,
      destinationPlace: originPlace!,
      primaryMode: itineraryController.primaryMode!,
      time: itineraryController.time!,
      isArrivalTime: itineraryController.isArrivalTime!,
    );
  }

  @override
  Widget build(BuildContext context) => Consumer<ItineraryController>(
    builder: (context, itineraryController, _) => Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
      child: Material(
        elevation: 4.0,
        color: !widget.altMode
            ? Theme.of(context).colorScheme.surface
            : Navi4AllColors.klLightRed,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Semantics(
                    label: itineraryController.hasParametersSet
                        ? AppLocalizations.of(
                            context,
                          )!.origDestPickerOriginSemantic(
                            itineraryController.originPlace!.id ==
                                    Navi4AllValues.userLocation
                                ? AppLocalizations.of(
                                    context,
                                  )!.origDestCurrentLocation
                                : itineraryController.originPlace!.name,
                          )
                        : '',
                    excludeSemantics: true,
                    child: InkWell(
                      onTap: _onOriginTap,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(16.0),
                        topRight: Radius.circular(16.0),
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8.0,
                          vertical: 4.0,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(16.0),
                          ),
                        ),
                        child: Row(
                          children: [
                            SizedBox(width: 8.0),
                            Padding(
                              padding: const EdgeInsets.all(2.0),
                              child: Material(
                                elevation: 2.0,
                                borderRadius: BorderRadius.circular(12.0),
                                child: Container(
                                  width: 20.0,
                                  height: 20.0,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Color(0xFF3685E2),
                                    border: Border.all(
                                      color: Navi4AllColors.klWhite,
                                      width: 3.0,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                itineraryController.hasParametersSet
                                    ? itineraryController.originPlace!.id ==
                                              Navi4AllValues.userLocation
                                          ? AppLocalizations.of(
                                              context,
                                            )!.origDestCurrentLocation
                                          : itineraryController
                                                .originPlace!
                                                .name
                                    : '...',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontSize: 16.0),
                              ),
                            ),
                            SizedBox(width: 48.0, height: 48.0),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Divider(height: 0, color: Navi4AllColors.klPink),
                  Semantics(
                    label: AppLocalizations.of(context)!
                        .origDestPickerDestinationSemantic(
                          itineraryController.hasParametersSet
                              ? itineraryController.destinationPlace!.id ==
                                        Navi4AllValues.userLocation
                                    ? AppLocalizations.of(
                                        context,
                                      )!.origDestCurrentLocation
                                    : itineraryController.destinationPlace!.name
                              : '',
                        ),
                    excludeSemantics: true,
                    child: InkWell(
                      onTap: _onDestinationTap,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(16.0),
                        bottomRight: Radius.circular(16.0),
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(4.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.vertical(
                            bottom: Radius.circular(16.0),
                          ),
                        ),
                        child: Row(
                          children: [
                            SizedBox(width: 12.0),
                            Icon(
                              Icons.place_rounded,
                              color: Theme.of(
                                context,
                              ).textTheme.displayMedium?.color,
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                itineraryController.hasParametersSet
                                    ? itineraryController
                                                  .destinationPlace!
                                                  .id ==
                                              Navi4AllValues.userLocation
                                          ? AppLocalizations.of(
                                              context,
                                            )!.origDestCurrentLocation
                                          : itineraryController
                                                .destinationPlace!
                                                .name
                                    : '...',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            SizedBox(width: 16.0),
                            AccessibleIconButton(
                              icon: Icons.swap_vert_rounded,
                              onTap: _swapOriginDestination,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
