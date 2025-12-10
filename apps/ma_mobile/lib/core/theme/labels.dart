import 'package:flutter/widgets.dart';
import 'package:smartroots/l10n/app_localizations.dart';
import 'package:smartroots/schemas/routing/mode.dart';

class SmartRootsLabels {
  static const String appName = 'ParkStark';

  static String getModeString(BuildContext context, Mode mode) {
    switch (mode) {
      case Mode.WALK:
        return AppLocalizations.of(context)!.commonModeWalking;
      case Mode.BICYCLE:
        return AppLocalizations.of(context)!.commonModeBicycle;
      case Mode.BUS:
        return AppLocalizations.of(context)!.commonModeBus;
      case Mode.TRAM:
        return AppLocalizations.of(context)!.commonModeTram;
      case Mode.SUBWAY:
        return AppLocalizations.of(context)!.commonModeUBahn;
      case Mode.RAIL:
        return AppLocalizations.of(context)!.commonModeTrain;
      case Mode.CAR:
        return AppLocalizations.of(context)!.commonModeCar;
      default:
        return mode.name;
    }
  }
}
