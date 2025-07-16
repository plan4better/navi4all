// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'Navi4All';

  @override
  String get commonModeWalking => 'Zu Fuß';

  @override
  String get commonModeBus => 'Bus';

  @override
  String get commonModeTram => 'Straßenbahn';

  @override
  String get commonModeUBahn => 'U-Bahn';

  @override
  String get commonModeSBahn => 'S-Bahn';

  @override
  String get commonModeTrain => 'Bahn';

  @override
  String get commonHomeScreenButton => 'Startbildschirm';

  @override
  String get commonBackButtonSemantic => 'Zurück';

  @override
  String get commonMicButtonSemantic => 'Spracheingabe';

  @override
  String get onboardingWelcomeTitle => 'Willkommen bei\nNavi4All.';

  @override
  String get onboardingWelcomeSubtitle => 'Die App, die Sie durch\nKaiserslautern führt.';

  @override
  String get onboardingWelcomeHint => 'Wischen Sie nach links, um fortzufahren.';

  @override
  String get onboardingProfileSelectionTitle => 'Wählen Sie Ihr Profil';

  @override
  String get onboardingProfileSelectionBlindUserTitle => 'Blind';

  @override
  String get onboardingProfileSelectionVisionImpairedUserTitle => 'Sehbehindert';

  @override
  String get onboardingProfileSelectionGeneralUserTitle => 'Andere';

  @override
  String get onboardingFinishTitle => 'Sie sind fertig!';

  @override
  String get onboardingFinishSubtitle => 'Ihr Profil wurde erfolgreich ausgewählt.\nWas möchten Sie nun tun?';

  @override
  String get onboardingFinishAppTutorialButton => 'Zum App-Tutorial';

  @override
  String get onboardingFinishHomeScreenButton => 'Zum Startbildschirm';

  @override
  String get homeSearchButton => 'Suchen';

  @override
  String get homeSavedButton => 'Gespeichert';

  @override
  String get homeRouteButton => 'Route';

  @override
  String get homeSettingsButton => 'Einstellungen';

  @override
  String get searchTextFieldHint => 'Hier suchen';

  @override
  String get addressInfoBackToSearchButtonSemantic => 'Zurück zu Suchergebnissen';

  @override
  String get addressInfoWalkingRoutesButton => 'zu Fuß';

  @override
  String get addressInfoPublicTransportRoutesButton => 'ÖPNV';

  @override
  String get addressInfoSaveAddressButton => 'Speichern Adresse';

  @override
  String get routeOptionsCurrentLocationText => 'Aktuell Position';

  @override
  String get routeOptionsRouteSettingsButton => 'Routeneinstellungen';

  @override
  String get routeOptionsSaveRouteButton => 'Route speichern';

  @override
  String get origDestPickerSwapButtonSemantic => 'Start- und Zielort tauschen';

  @override
  String origDestPickerOriginSemantic(String origin) {
    return 'Startort: $origin';
  }

  @override
  String origDestPickerDestinationSemantic(String destination) {
    return 'Zielort: $destination';
  }

  @override
  String journeyOptionSemantic(String duration, String startTime, String endTime, String segmentsDescription) {
    return 'Reiseoption: $duration, von $startTime bis $endTime, bestehend aus $segmentsDescription.';
  }

  @override
  String routeNavigationDescriptionSemantic(String address, String time) {
    return 'Sie fahren nach $address. In $time erreichen Sie Ihr Ziel.';
  }

  @override
  String get routeNavigationTitle => 'Sie fahren nach';

  @override
  String routeNavigationTimeToArrival(String time) {
    return 'in $time erreichen Sie Ihr Ziel';
  }

  @override
  String get routeNavigationStepContinueStraight => 'Gehen Sie geradeaus';

  @override
  String get routeNavigationStepTurnLeft => 'Biegen Sie links ab';

  @override
  String get routeNavigationStepTurnRight => 'Biegen Sie rechts ab';

  @override
  String routeNavigationStepOntoLocation(String location) {
    return 'auf $location';
  }

  @override
  String routeNavigationStepAwaitMode(String mode) {
    return 'Warten Sie auf den $mode';
  }

  @override
  String routeNavigationStepModeDescription(String line, String direction) {
    return 'linie $line, Richtung $direction';
  }

  @override
  String routeNavigationStepTimeToAction(String timeToAction) {
    return 'in $timeToAction';
  }

  @override
  String routeNavigationStepSemantic(int index, String action, String description, String timeToStep) {
    return 'Navigation Schritt $index: $action $description $timeToStep.';
  }

  @override
  String get routeNavigationMuteButtonMuteText => 'Stummschalten';

  @override
  String get routeNavigationMuteButtonUnmuteText => 'Ton an';

  @override
  String get routeNavigationPauseButtonPauseText => 'Pause';

  @override
  String get routeNavigationPauseButtonResumeText => 'Fortsetzen';

  @override
  String get routeNavigationStopButton => 'Ende';
}
