import 'package:flutter/material.dart';
import 'package:smartroots/l10n/app_localizations.dart';

enum Mode {
  AIRPLANE,
  BICYCLE,
  BUS,
  CABLE_CAR,
  CAR,
  COACH,
  FERRY,
  FLEX,
  FUNICULAR,
  GONDOLA,
  RAIL,
  SCOOTER,
  SUBWAY,
  TRAM,
  CARPOOL,
  TAXI,
  TRANSIT,
  WALK,
  TROLLEYBUS,
  MONORAIL,
}

enum RelativeDirection {
  DEPART,
  HARD_LEFT,
  LEFT,
  SLIGHTLY_LEFT,
  CONTINUE,
  SLIGHTLY_RIGHT,
  RIGHT,
  HARD_RIGHT,
  CIRCLE_CLOCKWISE,
  CIRCLE_COUNTERCLOCKWISE,
  ELEVATOR,
  UTURN_LEFT,
  UTURN_RIGHT,
  ENTER_STATION,
  EXIT_STATION,
  FOLLOW_SIGNS,
}

IconData getRelativeDirectionIconMapping(RelativeDirection relativeDirection) {
  switch (relativeDirection) {
    case RelativeDirection.CONTINUE:
      return Icons.straight;
    case RelativeDirection.SLIGHTLY_LEFT:
      return Icons.turn_slight_left;
    case RelativeDirection.SLIGHTLY_RIGHT:
      return Icons.turn_slight_right;
    case RelativeDirection.LEFT:
      return Icons.turn_left;
    case RelativeDirection.RIGHT:
      return Icons.turn_right;
    case RelativeDirection.HARD_LEFT:
      return Icons.turn_left;
    case RelativeDirection.HARD_RIGHT:
      return Icons.turn_right;
    case RelativeDirection.UTURN_LEFT:
      return Icons.u_turn_left;
    case RelativeDirection.UTURN_RIGHT:
      return Icons.u_turn_right;
    case RelativeDirection.DEPART:
      return Icons.play_arrow;
    case RelativeDirection.ENTER_STATION:
      return Icons.train;
    case RelativeDirection.EXIT_STATION:
      return Icons.exit_to_app;
    case RelativeDirection.FOLLOW_SIGNS:
      return Icons.signpost;
    case RelativeDirection.ELEVATOR:
      return Icons.elevator_outlined;
    case RelativeDirection.CIRCLE_CLOCKWISE:
      return Icons.rotate_right;
    case RelativeDirection.CIRCLE_COUNTERCLOCKWISE:
      return Icons.rotate_left;
  }
}

String getRelativeDirectionTextMapping(
  RelativeDirection relativeDirection,
  BuildContext context,
) {
  switch (relativeDirection) {
    case RelativeDirection.DEPART:
      return AppLocalizations.of(context)!.navigationRelativeDirectionDepart;
    case RelativeDirection.HARD_LEFT:
      return AppLocalizations.of(context)!.navigationRelativeDirectionHardLeft;
    case RelativeDirection.LEFT:
      return AppLocalizations.of(context)!.navigationRelativeDirectionLeft;
    case RelativeDirection.SLIGHTLY_LEFT:
      return AppLocalizations.of(
        context,
      )!.navigationRelativeDirectionSlightlyLeft;
    case RelativeDirection.CONTINUE:
      return AppLocalizations.of(context)!.navigationRelativeDirectionContinue;
    case RelativeDirection.SLIGHTLY_RIGHT:
      return AppLocalizations.of(
        context,
      )!.navigationRelativeDirectionSlightlyRight;
    case RelativeDirection.RIGHT:
      return AppLocalizations.of(context)!.navigationRelativeDirectionRight;
    case RelativeDirection.HARD_RIGHT:
      return AppLocalizations.of(context)!.navigationRelativeDirectionHardRight;
    case RelativeDirection.CIRCLE_CLOCKWISE:
      return AppLocalizations.of(
        context,
      )!.navigationRelativeDirectionCircleClockwise;
    case RelativeDirection.CIRCLE_COUNTERCLOCKWISE:
      return AppLocalizations.of(
        context,
      )!.navigationRelativeDirectionCircleCounterclockwise;
    case RelativeDirection.ELEVATOR:
      return AppLocalizations.of(context)!.navigationRelativeDirectionElevator;
    case RelativeDirection.UTURN_LEFT:
      return AppLocalizations.of(context)!.navigationRelativeDirectionUturnLeft;
    case RelativeDirection.UTURN_RIGHT:
      return AppLocalizations.of(
        context,
      )!.navigationRelativeDirectionUturnRight;
    case RelativeDirection.ENTER_STATION:
      return AppLocalizations.of(
        context,
      )!.navigationRelativeDirectionEnterStation;
    case RelativeDirection.EXIT_STATION:
      return AppLocalizations.of(
        context,
      )!.navigationRelativeDirectionExitStation;
    case RelativeDirection.FOLLOW_SIGNS:
      return AppLocalizations.of(
        context,
      )!.navigationRelativeDirectionFollowSigns;
  }
}

enum AbsoluteDirection {
  NORTH,
  NORTHEAST,
  EAST,
  SOUTHEAST,
  SOUTH,
  SOUTHWEST,
  WEST,
  NORTHWEST,
}
