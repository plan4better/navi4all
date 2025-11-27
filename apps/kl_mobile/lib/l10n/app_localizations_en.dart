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
  String get onboardingWelcomeTitle => 'Welcome to\nNavi4All';

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
  String get addressInfoWalkingRoutesButtonSemantic => 'Find walking routes.';

  @override
  String get addressInfoPublicTransportRoutesButton => 'Public Transport';

  @override
  String get addressInfoPublicTransportRoutesButtonSemantic => 'Find public transport routes.';

  @override
  String get addressInfoSaveAddressButton => 'Favourite';

  @override
  String get addressInfoRemoveAddressButton => 'Unfavourite';

  @override
  String get routeOptionsRouteSettingsButton => 'Route Settings';

  @override
  String get routeOptionsSaveRouteButton => 'Save Route';

  @override
  String get origDestPickerSwapButtonSemantic => 'Swap origin and destination.';

  @override
  String origDestPickerOriginSemantic(String origin) {
    return 'Origin: $origin.';
  }

  @override
  String origDestPickerDestinationSemantic(String destination) {
    return 'Destination: $destination.';
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
    return 'Result: $name, $locality.';
  }

  @override
  String get origDestCurrentLocation => 'Current location';

  @override
  String get homeNavigationMapTitle => 'Map';

  @override
  String get homeNavigationFavouritesTitle => 'Favourites';

  @override
  String get homeNavigationSettingsTitle => 'Settings';

  @override
  String get homeSearchButtonHint => 'Search here';

  @override
  String get homeChangeBaseMapTitle => 'Map Style';

  @override
  String get homeBaseMapStyleTitleLight => 'Light';

  @override
  String get homeBaseMapStyleTitleDark => 'Dark';

  @override
  String get homeBaseMapStyleTitleSatellite => 'Satellite';

  @override
  String get homeBaseMapStyleTitleUnknown => 'Base Map';

  @override
  String get favouritesTitle => 'Favourites';

  @override
  String get favouritesScreenPrompt => 'Add favourites to see them here.';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsOptionFeedback => 'Feedback';

  @override
  String get settingsOptionSupport => 'Support';

  @override
  String get settingsOptionLegalAndPrivacy => 'Legal & Privacy';

  @override
  String get settingsOptionSetupGuide => 'Setup Guide';

  @override
  String get featureComingSoonMessage => 'This feature is coming soon.';

  @override
  String get feedbackScreenTitle => 'Feedback';

  @override
  String get feedbackTypeHint => 'Feedback type';

  @override
  String get feedbackTypeLocalData => 'Local Data';

  @override
  String get feedbackTypeAppFunctionality => 'App Features';

  @override
  String get feedbackSubjectHint => 'Subject';

  @override
  String get feedbackMessageHint => 'Your feedback';

  @override
  String get feedbackSubmitButton => 'Submit';

  @override
  String get feedbackFieldErrorRequired => 'This field is required.';

  @override
  String get legalPrivacyScreenTitle => 'Legal & Privacy';

  @override
  String get legalPrivacyLocationAccess => 'Location Access';

  @override
  String get legalPrivacyDataProtection => 'Data Protection';

  @override
  String get placeScreenChangeRadiusCancel => 'Cancel';

  @override
  String get placeScreenChangeRadiusConfirm => 'Change';

  @override
  String get userLocationDeniedSnackbarText => 'Enable location access in system settings to use this feature.';

  @override
  String get placeScreenStartButton => 'Start';

  @override
  String get placeScreenRouteButton => 'Route';

  @override
  String get navigationRelativeDirectionDepart => 'Depart';

  @override
  String get navigationRelativeDirectionHardLeft => 'Sharp left';

  @override
  String get navigationRelativeDirectionLeft => 'Turn left';

  @override
  String get navigationRelativeDirectionSlightlyLeft => 'Slight left';

  @override
  String get navigationRelativeDirectionContinue => 'Continue';

  @override
  String get navigationRelativeDirectionSlightlyRight => 'Slight right';

  @override
  String get navigationRelativeDirectionRight => 'Turn right';

  @override
  String get navigationRelativeDirectionHardRight => 'Sharp right';

  @override
  String get navigationRelativeDirectionCircleClockwise => 'Enter roundabout';

  @override
  String get navigationRelativeDirectionCircleCounterclockwise => 'Enter roundabout';

  @override
  String get navigationRelativeDirectionElevator => 'Take the lift';

  @override
  String get navigationRelativeDirectionUturnLeft => 'Make a U-turn';

  @override
  String get navigationRelativeDirectionUturnRight => 'Make a U-turn';

  @override
  String get navigationRelativeDirectionEnterStation => 'Enter station';

  @override
  String get navigationRelativeDirectionExitStation => 'Exit station';

  @override
  String get navigationRelativeDirectionFollowSigns => 'Follow signs';

  @override
  String get navigationRelativeDirectionArrive => 'Arrive';

  @override
  String itineraryDepartureTime(String time) {
    return 'Depart $time';
  }

  @override
  String get itineraryModeTabWalking => 'Walking';

  @override
  String get itineraryModeTabPublicTransport => 'Transit';

  @override
  String navigationStepDistanceToActionMetres(String distance) {
    return 'in $distance metres';
  }

  @override
  String navigationStepDistanceToActionKilometres(String distance) {
    return 'in $distance kilometres';
  }

  @override
  String get navigationGettingDirections => 'Getting directions';

  @override
  String get navigationNoRouteFound => 'No route found';

  @override
  String get routingDisclaimerTitle => 'Attention';

  @override
  String get routingDisclaimerMessage => 'Navigation guidance provided by this app is currently under beta testing and may be incorrect. Please exercise caution and verify route details independently. Always follow local traffic laws and regulations and pay attention to road conditions.';

  @override
  String get routingDisclaimerCancelButton => 'Cancel';

  @override
  String get routingDisclaimerAcceptButton => 'Continue';

  @override
  String get errorUnableToFetchTravelTime => 'Unable to fetch travel time, try again later.';

  @override
  String get routingScreenNavigationStartButton => 'Start';

  @override
  String get routingScreenNavigationPauseButton => 'Pause';

  @override
  String get routingScreenNavigationResumeButton => 'Resume';

  @override
  String get routingScreenNavigationDoneButton => 'Done';

  @override
  String get settingsOptionChangeAppProfile => 'Change Profile';

  @override
  String get modeBicycle => 'Bicycle';

  @override
  String get modeBus => 'Bus';

  @override
  String get modeCableCar => 'Cable Car';

  @override
  String get modeCar => 'Car';

  @override
  String get modeCoach => 'Coach';

  @override
  String get modeFerry => 'Ferry';

  @override
  String get modeFunicular => 'Funicular';

  @override
  String get modeGondola => 'Gondola';

  @override
  String get modeRail => 'Train';

  @override
  String get modeSubway => 'U-Bahn';

  @override
  String get modeTram => 'Tram';

  @override
  String get modeTransit => 'Transit';

  @override
  String get modeWalk => 'Walk';

  @override
  String get modeTrolleybus => 'Trolleybus';

  @override
  String get modeMonorail => 'Monorail';

  @override
  String get itineraryOptionsScreenTitle => 'Route Settings';

  @override
  String get itineraryOptionsScreenSemantic => 'Route settings screen';

  @override
  String get itineraryOptionsScreenDepartureTimeTitle => 'Departure Time';

  @override
  String get itineraryOptionsScreenRoutingProfileItem => 'Routing Profile';

  @override
  String get itineraryOptionsScreenRoutingProfileItemHint => 'Select a profile';

  @override
  String get itineraryOptionsScreenWalkingTitle => 'Walking';

  @override
  String get itineraryOptionsScreenWalkingSpeedOption => 'Speed';

  @override
  String itineraryOptionsScreenWalkingSpeedOptionSemantic(String speed) {
    return 'Walking speed. Currently $speed.';
  }

  @override
  String get itineraryOptionsScreenWalkingSpeedIncrementSemantic => 'Increase walking speed';

  @override
  String get itineraryOptionsScreenWalkingSpeedDecrementSemantic => 'Decrease walking speed';

  @override
  String get itineraryOptionsScreenWalkingAvoidOption => 'Avoid walking';

  @override
  String get itineraryOptionsScreenWalkingAvoidOptionStatusEnabledSemantic => 'Enabled';

  @override
  String get itineraryOptionsScreenWalkingAvoidOptionStatusDisabledSemantic => 'Disabled';

  @override
  String itineraryOptionsScreenWalkingAvoidOptionSemantic(String status) {
    return 'Avoid walking option, $status.';
  }

  @override
  String get itineraryOptionsScreenModesTitle => 'Transit Modes';

  @override
  String get itineraryOptionsScreenBicycleTitle => 'Bicycle';

  @override
  String get itineraryOptionsScreenBicycleSpeedOption => 'Speed';

  @override
  String get itineraryOptionsScreenBicycleSpeedIncrementSemantic => 'Increase bicycle speed';

  @override
  String get itineraryOptionsScreenBicycleSpeedDecrementSemantic => 'Decrease bicycle speed';

  @override
  String get itineraryOptionsScreenApplyButtonTitle => 'Apply';

  @override
  String get itineraryOptionsScreenResetButtonTitle => 'Reset';

  @override
  String get routingProfileLabelStandard => 'Standard';

  @override
  String get routingProfileLabelVisionImpairment => 'Vision Impairment';

  @override
  String get routingProfileLabelWheelchair => 'Wheelchair';

  @override
  String get routingProfileLabelRollator => 'Rollator';

  @override
  String get routingProfileLabelSlightWalkingDisability => 'Slight Walking Disability';

  @override
  String get routingProfileLabelModerateWalkingDisability => 'Moderate Walking Disability';

  @override
  String get routingProfileLabelSevereWalkingDisability => 'Severe Walking Disability';

  @override
  String get routingProfileLabelStroller => 'Stroller';

  @override
  String get altModeButtonDone => 'Done';

  @override
  String get homeScreenSemantic => 'Home screen';

  @override
  String favoritesScreenSemantic(int count) {
    return 'Favorites screen. With $count favorites.';
  }

  @override
  String placeScreenSemantic(String name, String description) {
    return '$name, in $description.';
  }

  @override
  String get settingsScreenSemantic => 'Settings screen';

  @override
  String get placeScreenSearchBarSemantic => 'Search for another location.';

  @override
  String searchScreenSearchFieldSemantic(String input) {
    return 'Search field. Input: $input.';
  }

  @override
  String get itinerariesScreenSemantic => 'Journeys screen.';

  @override
  String get routingScreenSemantic => 'Navigation screen.';

  @override
  String get routingScreenExitRoutingButtonSemantic => 'Exit navigation.';
}
