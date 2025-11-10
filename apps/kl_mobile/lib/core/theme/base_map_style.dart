import 'package:flutter/material.dart';
import 'package:navi4all/l10n/app_localizations.dart';

enum BaseMapStyle { light, dark, satellite }

String getBaseMapStyleTitle(BuildContext context, BaseMapStyle baseMapStyle) {
  switch (baseMapStyle) {
    case BaseMapStyle.light:
      return AppLocalizations.of(context)!.homeBaseMapStyleTitleLight;
    case BaseMapStyle.dark:
      return AppLocalizations.of(context)!.homeBaseMapStyleTitleDark;
    case BaseMapStyle.satellite:
      return AppLocalizations.of(context)!.homeBaseMapStyleTitleSatellite;
  }
}
