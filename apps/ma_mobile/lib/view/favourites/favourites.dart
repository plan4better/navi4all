import 'package:flutter/material.dart';
import 'package:smartroots/core/theme/colors.dart';
import 'package:smartroots/l10n/app_localizations.dart';

class FavouritesScreen extends StatefulWidget {
  const FavouritesScreen({super.key});

  @override
  State<StatefulWidget> createState() => _FavouritesScreenState();
}

class _FavouritesScreenState extends State<FavouritesScreen> {
  List<Map<String, dynamic>> get _favourites => [
    {"site_name": "E5 12", "total_spots": 5, "occupied_spots": 2},
    {"site_name": "D4 9-10", "total_spots": 2, "occupied_spots": 1},
    {"site_name": "D6 6", "total_spots": 1, "occupied_spots": 0},
  ];

  @override
  Widget build(BuildContext context) {
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
              child: ListView.separated(
                padding: EdgeInsets.all(16),
                shrinkWrap: true,
                itemCount: _favourites.length,
                itemBuilder: (context, index) => Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
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
                          _favourites[index]["site_name"],
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: SmartRootsColors.maBlueExtraExtraDark,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(width: 16),
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
                              "${_favourites[index]["occupied_spots"]}/${_favourites[index]["total_spots"]}",
                              style: TextStyle(
                                color: SmartRootsColors.maWhite,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 16),
                      Icon(
                        Icons.more_vert,
                        color: SmartRootsColors.maBlueExtraExtraDark,
                      ),
                    ],
                  ),
                ),
                separatorBuilder: (context, index) =>
                    Divider(color: SmartRootsColors.maBlue, height: 0),
              ),
            ),
            SizedBox(height: 96),
          ],
        ),
      ),
    );
  }
}
