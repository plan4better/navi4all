// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'SmartRoots';

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
  String get commonContinueButtonSemantic => 'Weiter';

  @override
  String get onboardingWelcomeTitle => 'Willkommen bei\nNavi4All.';

  @override
  String get onboardingWelcomeSubtitle => 'Die App, die Sie durch\nKaiserslautern führt.';

  @override
  String get onboardingWelcomeHint => 'Drücken Sie die Taste, um fortzufahren.';

  @override
  String get onboardingProfileSelectionTitle => 'Wählen Sie Ihr Profil';

  @override
  String get onboardingProfileSelectionBlindUserTitle => 'Blind';

  @override
  String get onboardingProfileSelectionVisionImpairedUserTitle => 'Sehbehindert';

  @override
  String get onboardingProfileSelectionGeneralUserTitle => 'Andere';

  @override
  String get onboardingUserLocationTitle => 'Wir benötigen Zugriff auf Ihren Standort';

  @override
  String get onboardingUserLocationSubtitle => 'Dies ist notwendig, damit die Such- und Navigationsfunktionen funktionieren.';

  @override
  String get onboardingFinishTitle => 'Alles erledigt!';

  @override
  String get onboardingFinishSubtitle => 'Ihr Profil wurde erfolgreich ausgewählt.\nWillkommen bei Navi4All.';

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
  String get searchTextFieldOriginHintSemantic => 'Textfeld für die Eingabe. Tippen Sie, um einen Startort zu suchen.';

  @override
  String get searchTextFieldDestinationHintSemantic => 'Textfeld für die Eingabe. Tippen Sie, um einen Zielort zu suchen.';

  @override
  String get searchScreenPrompt => 'Beginnen Sie mit der Eingabe, um nach Orten, Adressen oder Haltestellen zu suchen.';

  @override
  String get searchScreenNoResults => 'Keine Ergebnisse gefunden.';

  @override
  String addressInfoBackToSearchButtonSemantic(String name) {
    return 'Ausgewähltes Ziel: $name, tippen Sie, um zu den Suchergebnissen zurückzukehren.';
  }

  @override
  String get addressInfoWalkingRoutesButton => 'Zu Fuß';

  @override
  String get addressInfoWalkingRoutesButtonSemantic => 'Finden Sie Fußweg-Optionen.';

  @override
  String get addressInfoPublicTransportRoutesButton => 'ÖPNV';

  @override
  String get addressInfoPublicTransportRoutesButtonSemantic => 'Finden Sie ÖPNV-Optionen.';

  @override
  String get addressInfoSaveAddressButton => 'Speichern Adresse';

  @override
  String get routeOptionsRouteSettingsButton => 'Routeneinstellungen';

  @override
  String get routeOptionsSaveRouteButton => 'Route speichern';

  @override
  String get origDestPickerSwapButtonSemantic => 'Start- und Zielort tauschen';

  @override
  String origDestPickerOriginSemantic(String origin) {
    return 'Startort: $origin. Tippen Sie, um zu ändern.';
  }

  @override
  String origDestPickerDestinationSemantic(String destination) {
    return 'Zielort: $destination. Tippen Sie, um zu ändern.';
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

  @override
  String get errorUnableToFetchItineraries => 'Routen konnten nicht abgerufen werden.';

  @override
  String get errorNoItinerariesFound => 'Keine Routen für den ausgewählten Start- und Zielort gefunden.';

  @override
  String searchResultSemantic(String name, String locality) {
    return 'Suchergebnis: $name, $locality.';
  }

  @override
  String get origDestCurrentLocation => 'Aktueller Standort';

  @override
  String get homeNavigationMapTitle => 'Karte';

  @override
  String get homeNavigationFavouritesTitle => 'Favoriten';

  @override
  String get homeNavigationSettingsTitle => 'Einstellungen';

  @override
  String get homeSearchButtonHint => 'Hier suchen';

  @override
  String get favouritesTitle => 'Favoriten';

  @override
  String get settingsTitle => 'Einstellungen';

  @override
  String get settingsOptionFeedback => 'Feedback';

  @override
  String get settingsOptionSupport => 'Support';

  @override
  String get settingsOptionLegalAndPrivacy => 'Rechtliches & Datenschutz';

  @override
  String get userLocationDeniedSnackbarText => 'Aktivieren Sie den Standortzugriff in den Systemeinstellungen, um diese Funktion zu nutzen.';

  @override
  String get placeScreenChangeRadiusButton => 'Radius wählen';

  @override
  String get placeScreenChangeRadiusCancel => 'Abbrechen';

  @override
  String get placeScreenChangeRadiusConfirm => 'Ändern';

  @override
  String get errorUnableToFetchParkingSites => 'Parkplätze konnten nicht abgerufen werden, bitte versuchen Sie es später erneut.';

  @override
  String get errorUnableToFetchDrivingTime => 'Fahrzeit konnte nicht abgerufen werden, bitte versuchen Sie es später erneut.';

  @override
  String get availabilityUnknown => 'Unbekannt';

  @override
  String get parkingLocationButtonStart => 'Start';

  @override
  String get parkingLocationButtonFavourite => 'Favorit';

  @override
  String get parkingLocationButtonRouteExternal => 'Route extern';

  @override
  String get errorUnableToLaunchRouteExternal => 'Externe Karten-App konnte nicht gestartet werden.';

  @override
  String get featureComingSoonMessage => 'Diese Funktion kommt bald.';
}
