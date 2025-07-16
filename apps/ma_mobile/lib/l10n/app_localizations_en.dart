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
  String get onboardingWelcomeTitle => 'Welcome to\nNavi4All.';

  @override
  String get onboardingWelcomeSubtitle => 'The app that guides you\nthrough Kaiserlautern.';

  @override
  String get onboardingWelcomeHint => 'Swipe left to continue with setup.';

  @override
  String get onboardingProfileSelectionTitle => 'Select your profile';

  @override
  String get onboardingProfileSelectionBlindUserTitle => 'Blind User';

  @override
  String get onboardingProfileSelectionVisionImpairedUserTitle => 'Vision Impaired User';

  @override
  String get onboardingProfileSelectionGeneralUserTitle => 'General User';

  @override
  String get onboardingFinishTitle => 'All done!';

  @override
  String get onboardingFinishSubtitle => 'Your profile has been selected.\nWhat would you like to do next?';

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
  String get addressInfoBackToSearchButtonSemantic => 'Back to search results';

  @override
  String get addressInfoWalkingRoutesButton => 'Walking';

  @override
  String get addressInfoPublicTransportRoutesButton => 'Public Transport';

  @override
  String get addressInfoSaveAddressButton => 'Save Address';

  @override
  String get routeOptionsCurrentLocationText => 'Current location';

  @override
  String get routeOptionsRouteSettingsButton => 'Route Settings';

  @override
  String get routeOptionsSaveRouteButton => 'Save Route';

  @override
  String get origDestPickerSwapButtonSemantic => 'Start- und Zielort tauschen';

  @override
  String origDestPickerOriginSemantic(String origin) {
    return 'Origin: $origin';
  }

  @override
  String origDestPickerDestinationSemantic(String destination) {
    return 'Destination: $destination';
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
}
