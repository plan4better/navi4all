import 'package:flutter/widgets.dart';
import 'package:navi4all/core/theme/profile_mode.dart';
import 'package:navi4all/l10n/app_localizations.dart';

class Navi4AllLabels {
  static const String appName = 'Navi4All';

  static getRoutingProfileLabel(BuildContext context, RoutingProfile profile) {
    switch (profile) {
      case RoutingProfile.standard:
        return AppLocalizations.of(context)!.routingProfileLabelStandard;
      case RoutingProfile.visionImpairment:
        return AppLocalizations.of(
          context,
        )!.routingProfileLabelVisionImpairment;
      case RoutingProfile.wheelchair:
        return AppLocalizations.of(context)!.routingProfileLabelWheelchair;
      case RoutingProfile.rollator:
        return AppLocalizations.of(context)!.routingProfileLabelRollator;
      case RoutingProfile.slightWalkingDisability:
        return AppLocalizations.of(
          context,
        )!.routingProfileLabelSlightWalkingDisability;
      case RoutingProfile.moderateWalkingDisability:
        return AppLocalizations.of(
          context,
        )!.routingProfileLabelModerateWalkingDisability;
      case RoutingProfile.severeWalkingDisability:
        return AppLocalizations.of(
          context,
        )!.routingProfileLabelSevereWalkingDisability;
      case RoutingProfile.stroller:
        return AppLocalizations.of(context)!.routingProfileLabelStroller;
    }
  }
}
