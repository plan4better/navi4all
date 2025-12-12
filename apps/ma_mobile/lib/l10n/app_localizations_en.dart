// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'ParkStark';

  @override
  String get commonModeWalking => 'Walking';

  @override
  String get commonModeBicycle => 'Bicycle';

  @override
  String get commonModeBus => 'Bus';

  @override
  String get commonModeTram => 'Tram';

  @override
  String get commonModeUBahn => 'U-Bahn';

  @override
  String get commonModeSBahn => 'S-Bahn';

  @override
  String get commonModeTrain => 'Train';

  @override
  String get commonModeCar => 'Car';

  @override
  String get commonHomeScreenButton => 'Home Screen';

  @override
  String get commonBackButtonSemantic => 'Back';

  @override
  String get commonMicButtonSemantic => 'Voice input';

  @override
  String get commonContinueButtonSemantic => 'Continue';

  @override
  String get onboardingWelcomeTitle => 'Welcome to\nParkStark';

  @override
  String get onboardingWelcomeSubtitle => 'Find accessible parking spots quickly and easily.';

  @override
  String get onboardingWelcomeHint => 'Press the button to continue.';

  @override
  String get onboardingSymbolInformationTitle => 'How it works';

  @override
  String get onboardingSymbolInformationSubtitle => 'These symbols help you find the right parking spot.';

  @override
  String get onboardingSymbolInformationParkingAvailable => 'Parking available';

  @override
  String get onboardingSymbolInformationParkingUnavailable => 'Parking occupied';

  @override
  String get onboardingSymbolInformationParkingUnknown => 'Real-time data unavailable';

  @override
  String get onboardingUserLocationTitle => 'Location access';

  @override
  String get onboardingUserLocationSubtitle => 'With access to your location, we can show you parking spots nearby and navigate there directly.';

  @override
  String get onboardingFinishTitle => 'Perfect - You\'re all set!';

  @override
  String get onboardingFinishSubtitle => 'Now you can find accessible parking spots nearby.';

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
  String get searchTextFieldHintSemantic => 'Search for a destination.';

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
  String get userLocationDeniedSnackbarText => 'Enable location access in system settings to use this feature.';

  @override
  String get placeScreenChangeRadiusButton => 'Change Radius';

  @override
  String get placeScreenChangeRadiusCancel => 'Cancel';

  @override
  String get placeScreenChangeRadiusConfirm => 'Change';

  @override
  String get errorUnableToFetchParkingSites => 'Unable to fetch parking sites, try again later.';

  @override
  String get errorUnableToFetchDrivingTime => 'Unable to fetch driving time, try again later.';

  @override
  String get availabilityUnknown => 'Unknown';

  @override
  String get availabilityOccupied => 'Occupied';

  @override
  String get availabilityAvailable => 'Available';

  @override
  String get parkingLocationButtonStart => 'Route';

  @override
  String get parkingLocationButtonFavourite => 'Favourite';

  @override
  String get parkingLocationButtonRouteExternal => 'Route External';

  @override
  String get errorUnableToLaunchRouteExternal => 'Unable to launch external maps app.';

  @override
  String get featureComingSoonMessage => 'This feature is coming soon.';

  @override
  String get feedbackScreenTitle => 'Feedback';

  @override
  String get feedbackTypeHint => 'Feedback type';

  @override
  String get feedbackTypeLocalData => 'Problem with parking spot';

  @override
  String get feedbackTypeAppFunctionality => 'App features';

  @override
  String get feedbackSubjectHint => 'Subject';

  @override
  String get feedbackMessageHint => 'Your feedback';

  @override
  String get feedbackImageTitle => 'Attach image';

  @override
  String get feedbackImageHint => 'In the next step, attach an image in support of your feedback (optional).';

  @override
  String get feedbackResetButton => 'Reset';

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
  String get routingScreenNavigationStartButton => 'Start';

  @override
  String get routingScreenNavigationPauseButton => 'Pause';

  @override
  String get routingScreenNavigationResumeButton => 'Resume';

  @override
  String get routingScreenNavigationDoneButton => 'Done';

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
  String navigationStepDistanceToAction(String distance) {
    return 'in $distance';
  }

  @override
  String navigationStepDistanceToActionMetres(String distance) {
    return 'in $distance metres';
  }

  @override
  String navigationStepDistanceToActionKilometres(String distance) {
    return 'in $distance kilometres';
  }

  @override
  String get navigationGettingDrivingDirections => 'Getting driving directions';

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
  String get availabilityChangeDialogTitle => 'Parking Occupied';

  @override
  String get availabilityChangeDialogMessage => 'This parking spot is now occupied.\nWould you like to find alternative spots nearby?';

  @override
  String get availabilityChangeDialogCancelButton => 'No';

  @override
  String get availabilityChangeDialogConfirmButton => 'Yes';

  @override
  String get searchScreenErrorNoSuggestions => 'No results found. Try searching for other places, addresses or transit stations.';

  @override
  String get homeMapScreenSemantic => 'Map screen.';

  @override
  String get homeMapScreenLayersButtonSemantic => 'Change map style.';

  @override
  String get homeMapScreenCurrentLocationButtonSemantic => 'Go to current location.';

  @override
  String get homeFavoritesScreenSemantic => 'Favourites screen.';

  @override
  String favoritesScreenSemantic(int count) {
    return 'Favorites screen. With $count favorites.';
  }

  @override
  String favoritesListItemSemantic(String name, String description, String status) {
    return '$name, $description. Status: $status.';
  }

  @override
  String get homeSettingsScreenSemantic => 'Settings screen.';

  @override
  String searchScreenSearchFieldSemantic(String input) {
    return 'Search field. Input: $input.';
  }

  @override
  String searchScreenRecentSearchItemSemantic(String name) {
    return 'Recent search: $name.';
  }

  @override
  String placeScreenSemantic(int count, int radius) {
    return '$count parking spaces found within $radius metres.';
  }

  @override
  String placeScreenSearchBarSemantic(String name) {
    return '$name selected. Tap to go back.';
  }

  @override
  String placeScreenSearchRadiusButtonSemantic(int radius) {
    return 'Change search radius. Currently: $radius metres.';
  }

  @override
  String placeListItemSemantic(String name, String status) {
    return '$name. $status.';
  }

  @override
  String parkingLocationScreenSearchBarSemantic(String name) {
    return '$name selected. Tap to go back.';
  }

  @override
  String get parkingLocationScreenAddToFavoritesButtonSemantic => 'Add to favorites.';

  @override
  String get parkingLocationScreenRemoveFromFavoritesButtonSemantic => 'Remove from favorites.';

  @override
  String get parkingLocationScreenRouteExternalButtonSemantic => 'Route using external maps app.';

  @override
  String get parkingLocationScreenRouteInternalButtonSemantic => 'Route using ParkStark.';

  @override
  String parkingLocationScreenEstimatedDrivingTimeSemantic(String time) {
    return 'Estimated driving time: $time.';
  }

  @override
  String parkingLocationScreenOccupancyStatusSemantic(String status) {
    return 'Occupancy status: $status.';
  }

  @override
  String get routingScreenSemantic => 'Navigation screen.';

  @override
  String get routingScreenExitRoutingButtonSemantic => 'Exit navigation.';

  @override
  String get routingScreenReroutingDialogTitle => 'Rerouting';

  @override
  String get routingScreenReroutingDialogMessage => 'You have deviated from the planned route. Would you like to find a new route?';

  @override
  String get routingScreenReroutingDialogCancelButton => 'Cancel';

  @override
  String get routingScreenReroutingDialogConfirmButton => 'Reroute';
}
