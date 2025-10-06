import 'package:flutter/material.dart';
import 'package:smartroots/l10n/app_localizations.dart';

String getOccupancyText(
  BuildContext context,
  Map<String, dynamic> parkingSite,
) {
  if (parkingSite["has_realtime_data"]) {
    return '${parkingSite["occupied_disabled"] ?? AppLocalizations.of(context)!.availabilityUnknown}/${parkingSite["capacity_disabled"] ?? AppLocalizations.of(context)!.availabilityUnknown}';
  } else {
    return '${AppLocalizations.of(context)!.availabilityUnknown}/${parkingSite["capacity_disabled"] ?? AppLocalizations.of(context)!.availabilityUnknown}';
  }
}
