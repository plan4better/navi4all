// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Navi4All';

  @override
  String get commonModeWalking => 'Walking';

  @override
  String get commonModeBus => 'Bus';

  @override
  String get commonModeTram => 'Tram';

  @override
  String get commonModeUBahn => 'Subway';

  @override
  String get commonModeSBahn => 'S-Bahn';

  @override
  String get commonModeTrain => 'Train';

  @override
  String get commonHomeScreenButton => 'Home Screen';

  @override
  String get commonBackButtonSemantic => 'Back';

  @override
  String get commonMicButtonSemantic => 'Voice input';

  @override
  String get commonContinueButtonSemantic => 'Continue';

  @override
  String get onboardingWelcomeTitle => 'Welcome to\nNavi4All.';

  @override
  String get onboardingWelcomeSubtitle => 'The app that guides you\nthrough Kaiserslautern.';

  @override
  String get onboardingWelcomeHint => 'Press the button to continue.';

  @override
  String get onboardingProfileSelectionTitle => 'Select your profile';

  @override
  String get onboardingProfileSelectionBlindUserTitle => 'Blind User';

  @override
  String get onboardingProfileSelectionVisionImpairedUserTitle => 'Vision Impaired User';

  @override
  String get onboardingProfileSelectionGeneralUserTitle => 'General User';

  @override
  String get onboardingUserLocationTitle => 'We need access to your location';

  @override
  String get onboardingUserLocationSubtitle => 'This is necessary for search and navigation to work correctly.';

  @override
  String get onboardingFinishTitle => 'All done!';

  @override
  String get onboardingFinishSubtitle => 'Your profile has been selected.\nWelcome to Navi4All.';

  @override
  String get onboardingFinishAppTutorialButton => 'View App Tutorial';

  @override
  String get onboardingFinishHomeScreenButton => 'Get Started';

  @override
  String get homeSearchButton => 'Search';

  @override
  String get homeSavedButton => 'Saved';

  @override
  String get homeRouteButton => 'Route';

  @override
  String get homeSettingsButton => 'Settings';

  @override
  String get searchTextFieldHint => 'Search here';

  @override
  String get searchTextFieldOriginHintSemantic => 'Text input. Type to search for an origin location.';

  @override
  String get searchTextFieldDestinationHintSemantic => 'Text input. Type to search for a destination location.';

  @override
  String get searchScreenPrompt => 'Start typing to search for places, addresses or transit stations.';

  @override
  String get searchScreenNoResults => 'No results found.';

  @override
  String addressInfoBackToSearchButtonSemantic(String name) {
    return 'Selected destination: $name, tap to return to search results.';
  }

  @override
  String get addressInfoWalkingRoutesButton => 'Walking';

  @override
  String get addressInfoWalkingRoutesButtonSemantic => 'Find walking route options.';

  @override
  String get addressInfoPublicTransportRoutesButton => 'Public Transport';

  @override
  String get addressInfoPublicTransportRoutesButtonSemantic => 'Find public transport route options.';

  @override
  String get addressInfoSaveAddressButton => 'Save Address';

  @override
  String get routeOptionsRouteSettingsButton => 'Route Settings';

  @override
  String get routeOptionsSaveRouteButton => 'Save Route';

  @override
  String get origDestPickerSwapButtonSemantic => 'Swap origin and destination.';

  @override
  String origDestPickerOriginSemantic(String origin) {
    return 'Origin: $origin. Tap to change.';
  }

  @override
  String origDestPickerDestinationSemantic(String destination) {
    return 'Destination: $destination. Tap to change.';
  }

  @override
  String journeyOptionSemantic(String duration, String startTime, String endTime, String segmentsDescription) {
    return 'Journey option: $duration, from $startTime until $endTime, consisting of $segmentsDescription.';
  }

  @override
  String routeNavigationDescriptionSemantic(String address, String time) {
    return 'Navigating to: $address. You will arrive in $time.';
  }

  @override
  String get routeNavigationTitle => 'Navigating to';

  @override
  String routeNavigationTimeToArrival(String time) {
    return 'you will arrive in $time';
  }

  @override
  String get routeNavigationStepContinueStraight => 'Continue straight';

  @override
  String get routeNavigationStepTurnLeft => 'Turn left';

  @override
  String get routeNavigationStepTurnRight => 'Turn right';

  @override
  String routeNavigationStepOntoLocation(String location) {
    return 'onto $location';
  }

  @override
  String routeNavigationStepAwaitMode(String mode) {
    return 'Wait for the $mode';
  }

  @override
  String routeNavigationStepModeDescription(String line, String direction) {
    return 'line $line, towards $direction';
  }

  @override
  String routeNavigationStepTimeToAction(String timeToAction) {
    return 'in $timeToAction';
  }

  @override
  String routeNavigationStepSemantic(int index, String action, String description, String timeToStep) {
    return 'Navigation step $index: $action $description $timeToStep.';
  }

  @override
  String get routeNavigationMuteButtonMuteText => 'Mute Audio';

  @override
  String get routeNavigationMuteButtonUnmuteText => 'Unmute Audio';

  @override
  String get routeNavigationPauseButtonPauseText => 'Pause';

  @override
  String get routeNavigationPauseButtonResumeText => 'Resume';

  @override
  String get routeNavigationStopButton => 'Stop';

  @override
  String get errorUnableToFetchItineraries => 'Unable to fetch itineraries.';

  @override
  String get errorNoItinerariesFound => 'No itineraries found for the selected origin and destination.';

  @override
  String searchResultSemantic(String name, String locality) {
    return 'Search result: $name, $locality.';
  }

  @override
  String get origDestCurrentLocation => 'Current location';
}
