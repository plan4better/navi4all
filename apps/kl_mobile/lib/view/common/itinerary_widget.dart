import 'package:flutter/material.dart';
import 'package:navi4all/core/utils.dart';
import 'package:navi4all/l10n/app_localizations.dart';
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
          TextFormatter.formatDurationText(itinerary.duration),
          _startTime,
          _endTime,
          _legSummaryDescription,
        ),
        child: Semantics(
          excludeSemantics: true,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  TextFormatter.formatDurationText(itinerary.duration),
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                  ),
                ),
                Text('$_startTime - $_endTime'),
                const SizedBox(height: 4),
                Row(
                  children: itinerary.legs.map((legSummary) {
                    return Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.tertiary,
                          borderRadius: BorderRadius.only(
                            topLeft: legSummary == itinerary.legs.first
                                ? Radius.circular(32)
                                : Radius.circular(0),
                            topRight: legSummary == itinerary.legs.last
                                ? Radius.circular(32)
                                : Radius.circular(0),
                            bottomLeft: legSummary == itinerary.legs.first
                                ? Radius.circular(32)
                                : Radius.circular(0),
                            bottomRight: legSummary == itinerary.legs.last
                                ? Radius.circular(32)
                                : Radius.circular(0),
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(
                          vertical: 4,
                          horizontal: 8,
                        ),
                        margin: legSummary != itinerary.legs.last
                            ? EdgeInsets.only(right: 4)
                            : EdgeInsets.zero,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Icon(
                              ModeIcons.get(legSummary.mode),
                              color: Theme.of(
                                context,
                              ).textTheme.displayMedium?.color,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                TextFormatter.formatDurationText(
                                  legSummary.duration,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
