import 'package:flutter/material.dart';
import 'package:smartroots/core/theme/colors.dart';

class SlidingBottomSheet extends StatelessWidget {
  final String title;
  final String subtitle;
  final int? travelTimeInMinutes;
  final List<dynamic> _listItems;
  final Map<String, dynamic> parkingSite;

  const SlidingBottomSheet(
    this.title,
    this.subtitle,
    this.travelTimeInMinutes,
    this._listItems,
    this.parkingSite, {
    super.key,
  });

  String _getOccupancyText() {
    if (parkingSite["has_realtime_data"]) {
      return '${parkingSite["occupied_spaces"]}/${parkingSite["total_spaces"]}';
    } else {
      return '?/${parkingSite["total_spaces"]}';
    }
  }

  @override
  Widget build(BuildContext context) => SizedBox.expand(
    child: DraggableScrollableSheet(
      minChildSize: 0.35,
      initialChildSize: 0.35,
      maxChildSize: 0.4,
      builder: ((BuildContext context, ScrollController controller) => Material(
        elevation: 4.0,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(32.0),
          topRight: Radius.circular(32.0),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: SmartRootsColors.maWhite,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(32.0),
              topRight: Radius.circular(32.0),
            ),
          ),
          child: Column(
            children: <Widget>[
              SingleChildScrollView(
                controller: controller,
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 16.0,
                          horizontal: 24.0,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Align(
                              alignment: Alignment.topCenter,
                              child: Container(
                                width: 32.0,
                                height: 4.0,
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                              ),
                            ),
                            SizedBox(height: 24.0),
                            Text(
                              title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: SmartRootsColors.maBlueExtraExtraDark,
                              ),
                            ),
                            Text(
                              subtitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: SmartRootsColors.maBlueExtraExtraDark,
                              ),
                            ),
                            SizedBox(height: 16.0),
                            Row(
                              children: [
                                Icon(
                                  Icons.directions_car_outlined,
                                  color: SmartRootsColors.maBlueExtraExtraDark,
                                ),
                                SizedBox(width: 8.0),
                                travelTimeInMinutes != null
                                    ? Text(
                                        '$travelTimeInMinutes min',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: SmartRootsColors
                                              .maBlueExtraExtraDark,
                                          fontSize: 16,
                                        ),
                                      )
                                    : SizedBox.shrink(),
                              ],
                            ),
                            SizedBox(height: 8.0),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: parkingSite['has_realtime_data']
                                        ? SmartRootsColors.maBlueExtraExtraDark
                                        : SmartRootsColors.maBlue,
                                    borderRadius: BorderRadius.circular(32),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        parkingSite['has_realtime_data']
                                            ? Icons.local_parking
                                            : Icons.question_mark,
                                        size: 16,
                                        color: SmartRootsColors.maWhite,
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(width: 8),
                                Text(
                                  _getOccupancyText(),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color:
                                        SmartRootsColors.maBlueExtraExtraDark,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 16),
                            Row(
                              children: [
                                InkWell(
                                  onTap: () {},
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: SmartRootsColors.maBlueLight,
                                      borderRadius: BorderRadius.circular(32),
                                    ),
                                    child: Text(
                                      'Starten',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: SmartRootsColors
                                            .maBlueExtraExtraDark,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                Spacer(),
                                SizedBox(width: 8),
                                InkWell(
                                  onTap: () {},
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: SmartRootsColors.maBlueLight,
                                      borderRadius: BorderRadius.circular(32),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.star_border,
                                          size: 20,
                                          color: SmartRootsColors
                                              .maBlueExtraExtraDark,
                                        ),
                                        SizedBox(width: 4),
                                        Text(
                                          'Favorit',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: SmartRootsColors
                                                .maBlueExtraExtraDark,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Spacer(),
                                SizedBox(width: 8),
                                InkWell(
                                  onTap: () {},
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: SmartRootsColors.maBlueLight,
                                      borderRadius: BorderRadius.circular(32),
                                    ),
                                    child: Text(
                                      'Routing Extern',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: SmartRootsColors
                                            .maBlueExtraExtraDark,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      )),
    ),
  );
}
