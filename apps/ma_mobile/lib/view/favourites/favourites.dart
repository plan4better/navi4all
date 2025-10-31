import 'package:flutter/material.dart';
import 'package:smartroots/core/theme/colors.dart';
import 'package:smartroots/l10n/app_localizations.dart';
import 'package:smartroots/services/poi_parking.dart';
import 'package:smartroots/core/persistence/preference_helper.dart';
import 'package:smartroots/core/utils.dart';
import 'package:smartroots/view/parking_site/parking_site.dart';

class FavouritesScreen extends StatefulWidget {
  final bool screenInFocus;
  const FavouritesScreen(this.screenInFocus, {super.key});

  @override
  State<StatefulWidget> createState() => _FavouritesScreenState();
}

class _FavouritesScreenState extends State<FavouritesScreen> {
  bool _wasScreenInFocus = false;
  List<Map<String, dynamic>> _parkingLocations = [];

  Future<void> _fetchParkingLocations() async {
    List<Map<String, dynamic>> favoriteParkingLocations =
        await PreferenceHelper.getFavoriteParkingLocations();

    List<Map<String, dynamic>> parkingLocations = [];
    POIParkingService parkingService = POIParkingService();
    try {
      for (var item in favoriteParkingLocations) {
        var details = await parkingService.getParkingLocationDetails(
          id: item["id"],
          parkingType: item["parking_type"],
        );
        if (details != null) {
          parkingLocations.add(details);
        }
      }
      parkingLocations.sort(
        (a, b) => a["name"].toString().toLowerCase().compareTo(
          b["name"].toString().toLowerCase(),
        ),
      );
      setState(() {
        _parkingLocations = parkingLocations;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.errorUnableToFetchParkingSites,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.screenInFocus && !_wasScreenInFocus) {
      _fetchParkingLocations();
    }
    _wasScreenInFocus = widget.screenInFocus;

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 128),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                AppLocalizations.of(context)!.favouritesTitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: SmartRootsColors.maBlueExtraExtraDark,
                ),
              ),
            ),
            SizedBox(height: 8),
            Expanded(
              child: _parkingLocations.isNotEmpty
                  ? ListView.builder(
                      padding: EdgeInsets.all(16),
                      shrinkWrap: true,
                      itemCount: _parkingLocations.length,
                      itemBuilder: (context, index) => _FavouritesListItem(
                        parkingLocation: _parkingLocations[index],
                      ),
                    )
                  : Expanded(
                      child: Align(
                        alignment: Alignment.center,
                        child: Semantics(
                          excludeSemantics: true,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.star,
                                size: 72,
                                color: SmartRootsColors.maBlue,
                              ),
                              SizedBox(height: 16),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 32,
                                ),
                                child: Text(
                                  AppLocalizations.of(
                                    context,
                                  )!.favouritesScreenPrompt,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: SmartRootsColors.maBlue,
                                  ),
                                ),
                              ),
                              SizedBox(height: 32),
                            ],
                          ),
                        ),
                      ),
                    ),
            ),
            SizedBox(height: 96),
          ],
        ),
      ),
    );
  }
}

class _FavouritesListItem extends StatelessWidget {
  final Map<String, dynamic> parkingLocation;

  const _FavouritesListItem({required this.parkingLocation});

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: () => Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            ParkingSiteScreen(parkingLocation: parkingLocation),
      ),
    ),
    child: Column(
      children: [
        SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: parkingLocation['has_realtime_data']
                      ? parkingLocation['disabled_parking_available']
                            ? SmartRootsColors.maGreen
                            : SmartRootsColors.maRed
                      : SmartRootsColors.maBlueExtraDark,
                  borderRadius: BorderRadius.circular(32),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.local_parking,
                      size: 16,
                      color: SmartRootsColors.maWhite,
                    ),
                  ],
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      parkingLocation["name"],
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: SmartRootsColors.maBlueExtraExtraDark,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      parkingLocation["city"] ??
                          parkingLocation["address"] ??
                          '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: SmartRootsColors.maBlueExtraExtraDark,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 12),
              Container(
                padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.tertiary,
                  borderRadius: BorderRadius.circular(16),
                ),
                width: 92,
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        getOccupancyText(context, parkingLocation),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: SmartRootsColors.maBlueExtraExtraDark,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              /*SizedBox(width: 16),
                            Icon(
                              Icons.more_vert,
                              color: SmartRootsColors.maBlueExtraExtraDark,
                            ),*/
            ],
          ),
        ),
        SizedBox(height: 4),
        Divider(color: SmartRootsColors.maBlue, height: 0),
      ],
    ),
  );
}
