import 'package:flutter/material.dart';
import 'package:navi4all/l10n/app_localizations.dart';
import 'package:navi4all/core/theme/colors.dart';
import 'package:navi4all/schemas/routing/itinerary.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:navi4all/core/theme/icons.dart' show ModeIcons;

class ItineraryWidget extends StatelessWidget {
  final ItinerarySummary itinerary;
  final Function onTap;

  const ItineraryWidget({
    super.key,
    required this.itinerary,
    required this.onTap,
  });

  String get _duration => '${(itinerary.duration / 60).round()} min';

  String get _startTime => DateFormat.Hm().format(itinerary.startTime);

  String get _endTime => DateFormat.Hm().format(itinerary.endTime);

  String get _legSummaryDescription {
    return itinerary.legs
        .map((legSummary) {
          return '${legSummary.mode.name} (${(legSummary.duration / 60).round()} min)';
        })
        .join(', ');
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onTap(),
      child: Semantics(
        label: AppLocalizations.of(context)!.journeyOptionSemantic(
          _duration,
          _startTime,
          _endTime,
          _legSummaryDescription,
        ),
        child: Semantics(
          excludeSemantics: true,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _duration,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                    color: Navi4AllColors.klRed,
                  ),
                ),
                Text(
                  '$_startTime - $_endTime',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Navi4AllColors.klRed,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: itinerary.legs.map((legSummary) {
                    return Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFEDEB),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        padding: const EdgeInsets.symmetric(
                          vertical: 4,
                          horizontal: 4,
                        ),
                        margin: legSummary != itinerary.legs.last
                            ? EdgeInsets.only(right: 4)
                            : EdgeInsets.zero,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Icon(
                              ModeIcons.get(legSummary.mode),
                              color: Color(0xFFD82028),
                              size: 20,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${(legSummary.duration / 60).round()} min',
                              style: const TextStyle(
                                color: Navi4AllColors.klRed,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
                Divider(thickness: 1, color: Navi4AllColors.klRed),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
