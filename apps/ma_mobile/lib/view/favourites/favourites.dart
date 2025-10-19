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
    List<String> favouriteParkingLocationIds =
        await PreferenceHelper.getFavoriteParkingSites();

    List<Map<String, dynamic>> parkingLocations = [];
    POIParkingService parkingService = POIParkingService();
    try {
      for (String id in favouriteParkingLocationIds) {
        var details = await parkingService.getParkingLocationDetails(
          parkingId: id,
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
            SizedBox(height: 16),
            Expanded(
              child: _parkingLocations.isNotEmpty
                  ? ListView.separated(
                      padding: EdgeInsets.all(16),
                      shrinkWrap: true,
                      itemCount: _parkingLocations.length,
                      itemBuilder: (context, index) => _FavouritesListItem(
                        parkingLocation: _parkingLocations[index],
                      ),
                      separatorBuilder: (context, index) =>
                          Divider(color: SmartRootsColors.maBlue, height: 0),
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
                                color: SmartRootsColors.maBlueLight,
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
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    child: InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ParkingSiteScreen(parkingSite: parkingLocation),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.place_outlined,
            color: SmartRootsColors.maBlueExtraExtraDark,
          ),
          SizedBox(width: 16),
          Expanded(
            child: Text(
              parkingLocation["name"],
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: SmartRootsColors.maBlueExtraExtraDark,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(width: 8),
          Container(
            padding: EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: SmartRootsColors.maBlue,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(1),
                  decoration: BoxDecoration(
                    color: SmartRootsColors.maBlueExtraExtraDark,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: SmartRootsColors.maWhite,
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    Icons.local_parking,
                    size: 16,
                    color: SmartRootsColors.maWhite,
                  ),
                ),
                SizedBox(width: 4),
                Text(
                  getOccupancyText(context, parkingLocation),
                  style: TextStyle(
                    color: SmartRootsColors.maWhite,
                    fontWeight: FontWeight.bold,
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
  );
}
