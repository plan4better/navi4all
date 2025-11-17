import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:navi4all/controllers/itinerary_controller.dart';
import 'package:navi4all/controllers/place_controller.dart';
import 'package:navi4all/core/theme/colors.dart';
import 'package:navi4all/core/theme/icons.dart';
import 'package:navi4all/core/theme/values.dart';
import 'package:navi4all/l10n/app_localizations.dart';
import 'package:navi4all/schemas/routing/mode.dart';
import 'package:navi4all/schemas/routing/place.dart';
import 'package:navi4all/view/common/sheet_button.dart';
import 'package:navi4all/view/routing/routing.dart';
import 'package:navi4all/view_alt/routing/itinerary_widget.dart';
import 'package:navi4all/view/search/search.dart';
import 'package:provider/provider.dart';

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
      originPlace: itineraryController.originPlace!,
      destinationPlace: itineraryController.destinationPlace!,
      modes: itineraryController.modes!,
      time: updatedDateTime,
      isArrivalTime: itineraryController.isArrivalTime!,
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
                Ink(
                  decoration: ShapeDecoration(
                    shape: CircleBorder(),
                    color: Theme.of(context).colorScheme.tertiary,
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.menu_rounded,
                      color: Theme.of(context).textTheme.displayMedium?.color,
                    ),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            AppLocalizations.of(
                              context,
                            )!.featureComingSoonMessage,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(width: 8),
                Ink(
                  decoration: ShapeDecoration(
                    shape: CircleBorder(),
                    color: Theme.of(context).colorScheme.tertiary,
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.close_rounded,
                      color: Theme.of(context).textTheme.displayMedium?.color,
                    ),
                    onPressed: () {
                      itineraryController.reset();
                      Provider.of<PlaceController>(
                        context,
                        listen: false,
                      ).reset();
                      Navigator.of(context).pop();
                    },
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 8),
          DefaultTabController(
            length: _modes.length,
            initialIndex: _modes.keys.toList().indexOf(
              itineraryController.modes!.first,
            ),
            child: TabBar(
              onTap: (index) {
                itineraryController.setParameters(
                  originPlace: itineraryController.originPlace!,
                  destinationPlace: itineraryController.destinationPlace!,
                  modes: [_modes.keys.toList()[index]],
                  time: itineraryController.time!,
                  isArrivalTime: itineraryController.isArrivalTime!,
                );
              },
              labelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              indicatorSize: TabBarIndicatorSize.tab,
              indicatorColor: Theme.of(context).textTheme.displayMedium?.color,
              unselectedLabelColor: Theme.of(
                context,
              ).textTheme.displayMedium?.color,
              labelColor: Theme.of(context).textTheme.displayMedium?.color,
              indicatorPadding: EdgeInsets.only(
                bottom: 8.0,
                left: 24.0,
                right: 24.0,
              ),
              splashBorderRadius: BorderRadius.circular(16.0),
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              dividerHeight: 0.0,
              tabs: [
                Tab(
                  icon: Icon(Icons.directions_walk_outlined),
                  text: AppLocalizations.of(context)!.itineraryModeTabWalking,
                ),
                Tab(
                  icon: Icon(Icons.directions_transit_outlined),
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

  const ItineraryList({super.key, required this.scrollController});

  @override
  State<ItineraryList> createState() => _ItineraryListState();
}

class _ItineraryListState extends State<ItineraryList> {
  @override
  Widget build(BuildContext context) {
    return Consumer<ItineraryController>(
      builder: (context, itineraryController, _) => ListView.separated(
        controller: widget.scrollController,
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        itemBuilder: (context, index) => ItineraryWidget(
          itinerary: itineraryController.itineraries[index],
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => RoutingScreen(
                  originPlace: itineraryController.originPlace!,
                  destinationPlace: itineraryController.destinationPlace!,
                  itinerarySummary: itineraryController.itineraries[index],
                ),
              ),
            );
          },
        ),
        separatorBuilder: (_, __) =>
            Divider(height: 0, color: Navi4AllColors.klPink),
        itemCount: itineraryController.itineraries.length,
      ),
    );
  }
}

class OrigDestPicker extends StatefulWidget {
  const OrigDestPicker({super.key});

  @override
  State<StatefulWidget> createState() => _OrigDestPickerState();
}

class _OrigDestPickerState extends State<OrigDestPicker> {
  Future<void> _onOriginTap() async {
    Place? originPlace = await Navigator.of(context).push(
      MaterialPageRoute<Place>(
        builder: (context) =>
            SearchScreen(isOriginPlaceSearch: true, isSecondarySearch: true),
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
      originPlace: originPlace,
      destinationPlace: itineraryController.destinationPlace!,
      modes: itineraryController.modes!,
      time: itineraryController.time!,
      isArrivalTime: itineraryController.isArrivalTime!,
    );
  }

  Future<void> _onDestinationTap() async {
    Place? destinationPlace = await Navigator.of(context).push(
      MaterialPageRoute<Place>(
        builder: (context) =>
            SearchScreen(isOriginPlaceSearch: false, isSecondarySearch: true),
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
      originPlace: itineraryController.originPlace!,
      destinationPlace: destinationPlace,
      modes: itineraryController.modes!,
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
      originPlace: destinationPlace!,
      destinationPlace: originPlace!,
      modes: itineraryController.modes!,
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24.0),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Semantics(
                    label: AppLocalizations.of(context)!
                        .origDestPickerOriginSemantic(
                          itineraryController.originPlace!.id ==
                                  Navi4AllValues.userLocation
                              ? AppLocalizations.of(
                                  context,
                                )!.origDestCurrentLocation
                              : itineraryController.originPlace!.name,
                        ),
                    excludeSemantics: true,
                    child: InkWell(
                      onTap: _onOriginTap,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(24.0),
                        topRight: Radius.circular(24.0),
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8.0,
                          vertical: 4.0,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(24.0),
                          ),
                        ),
                        child: Row(
                          children: [
                            SizedBox(width: 8.0),
                            Icon(
                              itineraryController.originPlace!.id ==
                                      Navi4AllValues.userLocation
                                  ? Icons.my_location
                                  : Icons.place_rounded,
                              color: Theme.of(
                                context,
                              ).textTheme.displayMedium?.color,
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                itineraryController.originPlace!.id ==
                                        Navi4AllValues.userLocation
                                    ? AppLocalizations.of(
                                        context,
                                      )!.origDestCurrentLocation
                                    : itineraryController.originPlace!.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontSize: 16.0),
                              ),
                            ),
                            /* Material(
                              child: Ink(
                                decoration: ShapeDecoration(
                                  shape: CircleBorder(),
                                  color: Theme.of(context).colorScheme.tertiary,
                                ),
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.more_vert_outlined,
                                    color: Theme.of(
                                      context,
                                    ).textTheme.displayMedium?.color,
                                  ),
                                  onPressed: () {},
                                ),
                              ),
                            ), */
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
                          itineraryController.destinationPlace!.id ==
                                  Navi4AllValues.userLocation
                              ? AppLocalizations.of(
                                  context,
                                )!.origDestCurrentLocation
                              : itineraryController.destinationPlace!.name,
                        ),
                    excludeSemantics: true,
                    child: InkWell(
                      onTap: _onDestinationTap,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(24.0),
                        bottomRight: Radius.circular(24.0),
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(4.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.vertical(
                            bottom: Radius.circular(24.0),
                          ),
                        ),
                        child: Row(
                          children: [
                            SizedBox(width: 12.0),
                            Icon(
                              itineraryController.destinationPlace!.id ==
                                      Navi4AllValues.userLocation
                                  ? Icons.my_location
                                  : Icons.place_rounded,
                              color: Theme.of(
                                context,
                              ).textTheme.displayMedium?.color,
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                itineraryController.destinationPlace!.id ==
                                        Navi4AllValues.userLocation
                                    ? AppLocalizations.of(
                                        context,
                                      )!.origDestCurrentLocation
                                    : itineraryController
                                          .destinationPlace!
                                          .name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            SizedBox(width: 16.0),
                            Material(
                              borderRadius: BorderRadius.circular(24.0),
                              child: Ink(
                                decoration: ShapeDecoration(
                                  shape: CircleBorder(),
                                  color: Theme.of(context).colorScheme.tertiary,
                                ),
                                child: IconButton(
                                  padding: EdgeInsets.zero,
                                  icon: Icon(
                                    Icons.swap_vert_outlined,
                                    color: Theme.of(
                                      context,
                                    ).textTheme.displayMedium?.color,
                                  ),
                                  onPressed: _swapOriginDestination,
                                ),
                              ),
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
