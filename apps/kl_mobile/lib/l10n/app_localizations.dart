import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Navi4All'**
  String get appTitle;

  /// No description provided for @commonModeWalking.
  ///
  /// In en, this message translates to:
  /// **'Walking'**
  String get commonModeWalking;

  /// No description provided for @commonModeBus.
  ///
  /// In en, this message translates to:
  /// **'Bus'**
  String get commonModeBus;

  /// No description provided for @commonModeTram.
  ///
  /// In en, this message translates to:
  /// **'Tram'**
  String get commonModeTram;

  /// No description provided for @commonModeUBahn.
  ///
  /// In en, this message translates to:
  /// **'Subway'**
  String get commonModeUBahn;

  /// No description provided for @commonModeSBahn.
  ///
  /// In en, this message translates to:
  /// **'S-Bahn'**
  String get commonModeSBahn;

  /// No description provided for @commonModeTrain.
  ///
  /// In en, this message translates to:
  /// **'Train'**
  String get commonModeTrain;

  /// No description provided for @commonHomeScreenButton.
  ///
  /// In en, this message translates to:
  /// **'Home Screen'**
  String get commonHomeScreenButton;

  /// No description provided for @commonBackButtonSemantic.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get commonBackButtonSemantic;

  /// No description provided for @commonMicButtonSemantic.
  ///
  /// In en, this message translates to:
  /// **'Voice input'**
  String get commonMicButtonSemantic;

  /// No description provided for @commonContinueButtonSemantic.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get commonContinueButtonSemantic;

  /// No description provided for @onboardingWelcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to\nNavi4All'**
  String get onboardingWelcomeTitle;

  /// No description provided for @onboardingWelcomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'The app that guides you\nthrough Kaiserslautern.'**
  String get onboardingWelcomeSubtitle;

  /// No description provided for @onboardingWelcomeHint.
  ///
  /// In en, this message translates to:
  /// **'Press the button to continue.'**
  String get onboardingWelcomeHint;

  /// No description provided for @onboardingProfileSelectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Select your profile'**
  String get onboardingProfileSelectionTitle;

  /// No description provided for @onboardingProfileSelectionBlindUserTitle.
  ///
  /// In en, this message translates to:
  /// **'Blind User'**
  String get onboardingProfileSelectionBlindUserTitle;

  /// No description provided for @onboardingProfileSelectionVisionImpairedUserTitle.
  ///
  /// In en, this message translates to:
  /// **'Vision Impaired User'**
  String get onboardingProfileSelectionVisionImpairedUserTitle;

  /// No description provided for @onboardingProfileSelectionGeneralUserTitle.
  ///
  /// In en, this message translates to:
  /// **'General User'**
  String get onboardingProfileSelectionGeneralUserTitle;

  /// No description provided for @onboardingUserLocationTitle.
  ///
  /// In en, this message translates to:
  /// **'We need access to your location'**
  String get onboardingUserLocationTitle;

  /// No description provided for @onboardingUserLocationSubtitle.
  ///
  /// In en, this message translates to:
  /// **'This is necessary for search and navigation to work correctly.'**
  String get onboardingUserLocationSubtitle;

  /// No description provided for @onboardingFinishTitle.
  ///
  /// In en, this message translates to:
  /// **'All done!'**
  String get onboardingFinishTitle;

  /// No description provided for @onboardingFinishSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your profile has been selected.\nWelcome to Navi4All.'**
  String get onboardingFinishSubtitle;

  /// No description provided for @onboardingFinishAppTutorialButton.
  ///
  /// In en, this message translates to:
  /// **'View App Tutorial'**
  String get onboardingFinishAppTutorialButton;

  /// No description provided for @onboardingFinishHomeScreenButton.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get onboardingFinishHomeScreenButton;

  /// No description provided for @homeSearchButton.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get homeSearchButton;

  /// No description provided for @homeSavedButton.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get homeSavedButton;

  /// No description provided for @homeRouteButton.
  ///
  /// In en, this message translates to:
  /// **'Route'**
  String get homeRouteButton;

  /// No description provided for @homeSettingsButton.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get homeSettingsButton;

  /// No description provided for @searchTextFieldHint.
  ///
  /// In en, this message translates to:
  /// **'Search here'**
  String get searchTextFieldHint;

  /// No description provided for @searchTextFieldOriginHintSemantic.
  ///
  /// In en, this message translates to:
  /// **'Text input. Type to search for an origin location.'**
  String get searchTextFieldOriginHintSemantic;

  /// No description provided for @searchTextFieldDestinationHintSemantic.
  ///
  /// In en, this message translates to:
  /// **'Text input. Type to search for a destination location.'**
  String get searchTextFieldDestinationHintSemantic;

  /// No description provided for @searchScreenPrompt.
  ///
  /// In en, this message translates to:
  /// **'Start typing to search for places, addresses or transit stations.'**
  String get searchScreenPrompt;

  /// No description provided for @searchScreenNoResults.
  ///
  /// In en, this message translates to:
  /// **'No results found.'**
  String get searchScreenNoResults;

  /// No description provided for @addressInfoBackToSearchButtonSemantic.
  ///
  /// In en, this message translates to:
  /// **'Selected destination: {name}, tap to return to search results.'**
  String addressInfoBackToSearchButtonSemantic(String name);

  /// No description provided for @addressInfoWalkingRoutesButton.
  ///
  /// In en, this message translates to:
  /// **'Walking'**
  String get addressInfoWalkingRoutesButton;

  /// No description provided for @addressInfoWalkingRoutesButtonSemantic.
  ///
  /// In en, this message translates to:
  /// **'Find walking route options.'**
  String get addressInfoWalkingRoutesButtonSemantic;

  /// No description provided for @addressInfoPublicTransportRoutesButton.
  ///
  /// In en, this message translates to:
  /// **'Public Transport'**
  String get addressInfoPublicTransportRoutesButton;

  /// No description provided for @addressInfoPublicTransportRoutesButtonSemantic.
  ///
  /// In en, this message translates to:
  /// **'Find public transport route options.'**
  String get addressInfoPublicTransportRoutesButtonSemantic;

  /// No description provided for @addressInfoSaveAddressButton.
  ///
  /// In en, this message translates to:
  /// **'Favourite'**
  String get addressInfoSaveAddressButton;

  /// No description provided for @addressInfoRemoveAddressButton.
  ///
  /// In en, this message translates to:
  /// **'Unfavourite'**
  String get addressInfoRemoveAddressButton;

  /// No description provided for @routeOptionsRouteSettingsButton.
  ///
  /// In en, this message translates to:
  /// **'Route Settings'**
  String get routeOptionsRouteSettingsButton;

  /// No description provided for @routeOptionsSaveRouteButton.
  ///
  /// In en, this message translates to:
  /// **'Save Route'**
  String get routeOptionsSaveRouteButton;

  /// No description provided for @origDestPickerSwapButtonSemantic.
  ///
  /// In en, this message translates to:
  /// **'Swap origin and destination.'**
  String get origDestPickerSwapButtonSemantic;

  /// No description provided for @origDestPickerOriginSemantic.
  ///
  /// In en, this message translates to:
  /// **'Origin: {origin}. Tap to change.'**
  String origDestPickerOriginSemantic(String origin);

  /// No description provided for @origDestPickerDestinationSemantic.
  ///
  /// In en, this message translates to:
  /// **'Destination: {destination}. Tap to change.'**
  String origDestPickerDestinationSemantic(String destination);

  /// No description provided for @journeyOptionSemantic.
  ///
  /// In en, this message translates to:
  /// **'Journey option: {duration}, from {startTime} until {endTime}, consisting of {segmentsDescription}.'**
  String journeyOptionSemantic(String duration, String startTime, String endTime, String segmentsDescription);

  /// No description provided for @routeNavigationDescriptionSemantic.
  ///
  /// In en, this message translates to:
  /// **'Navigating to: {address}. You will arrive in {time}.'**
  String routeNavigationDescriptionSemantic(String address, String time);

  /// No description provided for @routeNavigationTitle.
  ///
  /// In en, this message translates to:
  /// **'Navigating to'**
  String get routeNavigationTitle;

  /// No description provided for @routeNavigationTimeToArrival.
  ///
  /// In en, this message translates to:
  /// **'you will arrive in {time}'**
  String routeNavigationTimeToArrival(String time);

  /// No description provided for @routeNavigationStepContinueStraight.
  ///
  /// In en, this message translates to:
  /// **'Continue straight'**
  String get routeNavigationStepContinueStraight;

  /// No description provided for @routeNavigationStepTurnLeft.
  ///
  /// In en, this message translates to:
  /// **'Turn left'**
  String get routeNavigationStepTurnLeft;

  /// No description provided for @routeNavigationStepTurnRight.
  ///
  /// In en, this message translates to:
  /// **'Turn right'**
  String get routeNavigationStepTurnRight;

  /// No description provided for @routeNavigationStepOntoLocation.
  ///
  /// In en, this message translates to:
  /// **'onto {location}'**
  String routeNavigationStepOntoLocation(String location);

  /// No description provided for @routeNavigationStepAwaitMode.
  ///
  /// In en, this message translates to:
  /// **'Wait for the {mode}'**
  String routeNavigationStepAwaitMode(String mode);

  /// No description provided for @routeNavigationStepModeDescription.
  ///
  /// In en, this message translates to:
  /// **'line {line}, towards {direction}'**
  String routeNavigationStepModeDescription(String line, String direction);

  /// No description provided for @routeNavigationStepTimeToAction.
  ///
  /// In en, this message translates to:
  /// **'in {timeToAction}'**
  String routeNavigationStepTimeToAction(String timeToAction);

  /// No description provided for @routeNavigationStepSemantic.
  ///
  /// In en, this message translates to:
  /// **'Navigation step {index}: {action} {description} {timeToStep}.'**
  String routeNavigationStepSemantic(int index, String action, String description, String timeToStep);

  /// No description provided for @routeNavigationMuteButtonMuteText.
  ///
  /// In en, this message translates to:
  /// **'Mute Audio'**
  String get routeNavigationMuteButtonMuteText;

  /// No description provided for @routeNavigationMuteButtonUnmuteText.
  ///
  /// In en, this message translates to:
  /// **'Unmute Audio'**
  String get routeNavigationMuteButtonUnmuteText;

  /// No description provided for @routeNavigationPauseButtonPauseText.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get routeNavigationPauseButtonPauseText;

  /// No description provided for @routeNavigationPauseButtonResumeText.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get routeNavigationPauseButtonResumeText;

  /// No description provided for @routeNavigationStopButton.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get routeNavigationStopButton;

  /// No description provided for @errorUnableToFetchItineraries.
  ///
  /// In en, this message translates to:
  /// **'Unable to fetch itineraries.'**
  String get errorUnableToFetchItineraries;

  /// No description provided for @errorNoItinerariesFound.
  ///
  /// In en, this message translates to:
  /// **'No itineraries found for the selected origin and destination.'**
  String get errorNoItinerariesFound;

  /// No description provided for @searchResultSemantic.
  ///
  /// In en, this message translates to:
  /// **'Search result: {name}, {locality}.'**
  String searchResultSemantic(String name, String locality);

  /// No description provided for @origDestCurrentLocation.
  ///
  /// In en, this message translates to:
  /// **'Current location'**
  String get origDestCurrentLocation;

  /// No description provided for @homeNavigationMapTitle.
  ///
  /// In en, this message translates to:
  /// **'Map'**
  String get homeNavigationMapTitle;

  /// No description provided for @homeNavigationFavouritesTitle.
  ///
  /// In en, this message translates to:
  /// **'Favourites'**
  String get homeNavigationFavouritesTitle;

  /// No description provided for @homeNavigationSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get homeNavigationSettingsTitle;

  /// No description provided for @homeSearchButtonHint.
  ///
  /// In en, this message translates to:
  /// **'Search here'**
  String get homeSearchButtonHint;

  /// No description provided for @homeChangeBaseMapTitle.
  ///
  /// In en, this message translates to:
  /// **'Map Style'**
  String get homeChangeBaseMapTitle;

  /// No description provided for @homeBaseMapStyleTitleLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get homeBaseMapStyleTitleLight;

  /// No description provided for @homeBaseMapStyleTitleDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get homeBaseMapStyleTitleDark;

  /// No description provided for @homeBaseMapStyleTitleSatellite.
  ///
  /// In en, this message translates to:
  /// **'Satellite'**
  String get homeBaseMapStyleTitleSatellite;

  /// No description provided for @homeBaseMapStyleTitleUnknown.
  ///
  /// In en, this message translates to:
  /// **'Base Map'**
  String get homeBaseMapStyleTitleUnknown;

  /// No description provided for @favouritesTitle.
  ///
  /// In en, this message translates to:
  /// **'Favourites'**
  String get favouritesTitle;

  /// No description provided for @favouritesScreenPrompt.
  ///
  /// In en, this message translates to:
  /// **'Add favourites to see them here.'**
  String get favouritesScreenPrompt;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsOptionFeedback.
  ///
  /// In en, this message translates to:
  /// **'Feedback'**
  String get settingsOptionFeedback;

  /// No description provided for @settingsOptionSupport.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get settingsOptionSupport;

  /// No description provided for @settingsOptionLegalAndPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Legal & Privacy'**
  String get settingsOptionLegalAndPrivacy;

  /// No description provided for @settingsOptionSetupGuide.
  ///
  /// In en, this message translates to:
  /// **'Setup Guide'**
  String get settingsOptionSetupGuide;

  /// No description provided for @featureComingSoonMessage.
  ///
  /// In en, this message translates to:
  /// **'This feature is coming soon.'**
  String get featureComingSoonMessage;

  /// No description provided for @feedbackScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Feedback'**
  String get feedbackScreenTitle;

  /// No description provided for @feedbackTypeHint.
  ///
  /// In en, this message translates to:
  /// **'Feedback type'**
  String get feedbackTypeHint;

  /// No description provided for @feedbackTypeLocalData.
  ///
  /// In en, this message translates to:
  /// **'Local Data'**
  String get feedbackTypeLocalData;

  /// No description provided for @feedbackTypeAppFunctionality.
  ///
  /// In en, this message translates to:
  /// **'App Features'**
  String get feedbackTypeAppFunctionality;

  /// No description provided for @feedbackSubjectHint.
  ///
  /// In en, this message translates to:
  /// **'Subject'**
  String get feedbackSubjectHint;

  /// No description provided for @feedbackMessageHint.
  ///
  /// In en, this message translates to:
  /// **'Your feedback'**
  String get feedbackMessageHint;

  /// No description provided for @feedbackSubmitButton.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get feedbackSubmitButton;

  /// No description provided for @feedbackFieldErrorRequired.
  ///
  /// In en, this message translates to:
  /// **'This field is required.'**
  String get feedbackFieldErrorRequired;

  /// No description provided for @legalPrivacyScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Legal & Privacy'**
  String get legalPrivacyScreenTitle;

  /// No description provided for @legalPrivacyLocationAccess.
  ///
  /// In en, this message translates to:
  /// **'Location Access'**
  String get legalPrivacyLocationAccess;

  /// No description provided for @legalPrivacyDataProtection.
  ///
  /// In en, this message translates to:
  /// **'Data Protection'**
  String get legalPrivacyDataProtection;

  /// No description provided for @placeScreenChangeRadiusCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get placeScreenChangeRadiusCancel;

  /// No description provided for @placeScreenChangeRadiusConfirm.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get placeScreenChangeRadiusConfirm;

  /// No description provided for @userLocationDeniedSnackbarText.
  ///
  /// In en, this message translates to:
  /// **'Enable location access in system settings to use this feature.'**
  String get userLocationDeniedSnackbarText;

  /// No description provided for @placeScreenStartButton.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get placeScreenStartButton;

  /// No description provided for @placeScreenRouteButton.
  ///
  /// In en, this message translates to:
  /// **'Route'**
  String get placeScreenRouteButton;

  /// No description provided for @navigationRelativeDirectionDepart.
  ///
  /// In en, this message translates to:
  /// **'Depart'**
  String get navigationRelativeDirectionDepart;

  /// No description provided for @navigationRelativeDirectionHardLeft.
  ///
  /// In en, this message translates to:
  /// **'Sharp left'**
  String get navigationRelativeDirectionHardLeft;

  /// No description provided for @navigationRelativeDirectionLeft.
  ///
  /// In en, this message translates to:
  /// **'Turn left'**
  String get navigationRelativeDirectionLeft;

  /// No description provided for @navigationRelativeDirectionSlightlyLeft.
  ///
  /// In en, this message translates to:
  /// **'Slight left'**
  String get navigationRelativeDirectionSlightlyLeft;

  /// No description provided for @navigationRelativeDirectionContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get navigationRelativeDirectionContinue;

  /// No description provided for @navigationRelativeDirectionSlightlyRight.
  ///
  /// In en, this message translates to:
  /// **'Slight right'**
  String get navigationRelativeDirectionSlightlyRight;

  /// No description provided for @navigationRelativeDirectionRight.
  ///
  /// In en, this message translates to:
  /// **'Turn right'**
  String get navigationRelativeDirectionRight;

  /// No description provided for @navigationRelativeDirectionHardRight.
  ///
  /// In en, this message translates to:
  /// **'Sharp right'**
  String get navigationRelativeDirectionHardRight;

  /// No description provided for @navigationRelativeDirectionCircleClockwise.
  ///
  /// In en, this message translates to:
  /// **'Enter roundabout'**
  String get navigationRelativeDirectionCircleClockwise;

  /// No description provided for @navigationRelativeDirectionCircleCounterclockwise.
  ///
  /// In en, this message translates to:
  /// **'Enter roundabout'**
  String get navigationRelativeDirectionCircleCounterclockwise;

  /// No description provided for @navigationRelativeDirectionElevator.
  ///
  /// In en, this message translates to:
  /// **'Take the lift'**
  String get navigationRelativeDirectionElevator;

  /// No description provided for @navigationRelativeDirectionUturnLeft.
  ///
  /// In en, this message translates to:
  /// **'Make a U-turn'**
  String get navigationRelativeDirectionUturnLeft;

  /// No description provided for @navigationRelativeDirectionUturnRight.
  ///
  /// In en, this message translates to:
  /// **'Make a U-turn'**
  String get navigationRelativeDirectionUturnRight;

  /// No description provided for @navigationRelativeDirectionEnterStation.
  ///
  /// In en, this message translates to:
  /// **'Enter station'**
  String get navigationRelativeDirectionEnterStation;

  /// No description provided for @navigationRelativeDirectionExitStation.
  ///
  /// In en, this message translates to:
  /// **'Exit station'**
  String get navigationRelativeDirectionExitStation;

  /// No description provided for @navigationRelativeDirectionFollowSigns.
  ///
  /// In en, this message translates to:
  /// **'Follow signs'**
  String get navigationRelativeDirectionFollowSigns;

  /// No description provided for @navigationRelativeDirectionArrive.
  ///
  /// In en, this message translates to:
  /// **'Arrive'**
  String get navigationRelativeDirectionArrive;

  /// No description provided for @itineraryDepartureTime.
  ///
  /// In en, this message translates to:
  /// **'Depart at {time}'**
  String itineraryDepartureTime(String time);

  /// No description provided for @itineraryModeTabWalking.
  ///
  /// In en, this message translates to:
  /// **'Walking'**
  String get itineraryModeTabWalking;

  /// No description provided for @itineraryModeTabPublicTransport.
  ///
  /// In en, this message translates to:
  /// **'Transit'**
  String get itineraryModeTabPublicTransport;

  /// No description provided for @navigationStepDistanceToActionMetres.
  ///
  /// In en, this message translates to:
  /// **'in {distance} metres'**
  String navigationStepDistanceToActionMetres(String distance);

  /// No description provided for @navigationStepDistanceToActionKilometres.
  ///
  /// In en, this message translates to:
  /// **'in {distance} kilometres'**
  String navigationStepDistanceToActionKilometres(String distance);

  /// No description provided for @navigationGettingDirections.
  ///
  /// In en, this message translates to:
  /// **'Getting directions'**
  String get navigationGettingDirections;

  /// No description provided for @navigationNoRouteFound.
  ///
  /// In en, this message translates to:
  /// **'No route found'**
  String get navigationNoRouteFound;

  /// No description provided for @routingDisclaimerTitle.
  ///
  /// In en, this message translates to:
  /// **'Attention'**
  String get routingDisclaimerTitle;

  /// No description provided for @routingDisclaimerMessage.
  ///
  /// In en, this message translates to:
  /// **'Navigation guidance provided by this app is currently under beta testing and may be incorrect. Please exercise caution and verify route details independently. Always follow local traffic laws and regulations and pay attention to road conditions.'**
  String get routingDisclaimerMessage;

  /// No description provided for @routingDisclaimerCancelButton.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get routingDisclaimerCancelButton;

  /// No description provided for @routingDisclaimerAcceptButton.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get routingDisclaimerAcceptButton;

  /// No description provided for @errorUnableToFetchTravelTime.
  ///
  /// In en, this message translates to:
  /// **'Unable to fetch travel time, try again later.'**
  String get errorUnableToFetchTravelTime;

  /// No description provided for @routingScreenNavigationStartButton.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get routingScreenNavigationStartButton;

  /// No description provided for @routingScreenNavigationPauseButton.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get routingScreenNavigationPauseButton;

  /// No description provided for @routingScreenNavigationResumeButton.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get routingScreenNavigationResumeButton;

  /// No description provided for @routingScreenNavigationDoneButton.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get routingScreenNavigationDoneButton;

  /// No description provided for @settingsOptionChangeAppProfile.
  ///
  /// In en, this message translates to:
  /// **'Change Profile'**
  String get settingsOptionChangeAppProfile;

  /// No description provided for @modeBicycle.
  ///
  /// In en, this message translates to:
  /// **'Bicycle'**
  String get modeBicycle;

  /// No description provided for @modeBus.
  ///
  /// In en, this message translates to:
  /// **'Bus'**
  String get modeBus;

  /// No description provided for @modeCableCar.
  ///
  /// In en, this message translates to:
  /// **'Cable Car'**
  String get modeCableCar;

  /// No description provided for @modeCar.
  ///
  /// In en, this message translates to:
  /// **'Car'**
  String get modeCar;

  /// No description provided for @modeCoach.
  ///
  /// In en, this message translates to:
  /// **'Coach'**
  String get modeCoach;

  /// No description provided for @modeFerry.
  ///
  /// In en, this message translates to:
  /// **'Ferry'**
  String get modeFerry;

  /// No description provided for @modeFunicular.
  ///
  /// In en, this message translates to:
  /// **'Funicular'**
  String get modeFunicular;

  /// No description provided for @modeGondola.
  ///
  /// In en, this message translates to:
  /// **'Gondola'**
  String get modeGondola;

  /// No description provided for @modeRail.
  ///
  /// In en, this message translates to:
  /// **'Train'**
  String get modeRail;

  /// No description provided for @modeSubway.
  ///
  /// In en, this message translates to:
  /// **'U-Bahn'**
  String get modeSubway;

  /// No description provided for @modeTram.
  ///
  /// In en, this message translates to:
  /// **'Tram'**
  String get modeTram;

  /// No description provided for @modeTransit.
  ///
  /// In en, this message translates to:
  /// **'Transit'**
  String get modeTransit;

  /// No description provided for @modeWalk.
  ///
  /// In en, this message translates to:
  /// **'Walk'**
  String get modeWalk;

  /// No description provided for @modeTrolleybus.
  ///
  /// In en, this message translates to:
  /// **'Trolleybus'**
  String get modeTrolleybus;

  /// No description provided for @modeMonorail.
  ///
  /// In en, this message translates to:
  /// **'Monorail'**
  String get modeMonorail;

  /// No description provided for @itineraryOptionsScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Journey Options'**
  String get itineraryOptionsScreenTitle;

  /// No description provided for @itineraryOptionsScreenDepartureTimeTitle.
  ///
  /// In en, this message translates to:
  /// **'Departure Time'**
  String get itineraryOptionsScreenDepartureTimeTitle;

  /// No description provided for @itineraryOptionsScreenRoutingProfileItem.
  ///
  /// In en, this message translates to:
  /// **'Routing Profile'**
  String get itineraryOptionsScreenRoutingProfileItem;

  /// No description provided for @itineraryOptionsScreenRoutingProfileItemHint.
  ///
  /// In en, this message translates to:
  /// **'Select a profile'**
  String get itineraryOptionsScreenRoutingProfileItemHint;

  /// No description provided for @itineraryOptionsScreenWalkingTitle.
  ///
  /// In en, this message translates to:
  /// **'Walking'**
  String get itineraryOptionsScreenWalkingTitle;

  /// No description provided for @itineraryOptionsScreenWalkingSpeedOption.
  ///
  /// In en, this message translates to:
  /// **'Speed'**
  String get itineraryOptionsScreenWalkingSpeedOption;

  /// No description provided for @itineraryOptionsScreenWalkingSpeedOptionSemantic.
  ///
  /// In en, this message translates to:
  /// **'Walking speed. Currently {speed}.'**
  String itineraryOptionsScreenWalkingSpeedOptionSemantic(String speed);

  /// No description provided for @itineraryOptionsScreenWalkingSpeedIncrementSemantic.
  ///
  /// In en, this message translates to:
  /// **'Increase walking speed'**
  String get itineraryOptionsScreenWalkingSpeedIncrementSemantic;

  /// No description provided for @itineraryOptionsScreenWalkingSpeedDecrementSemantic.
  ///
  /// In en, this message translates to:
  /// **'Decrease walking speed'**
  String get itineraryOptionsScreenWalkingSpeedDecrementSemantic;

  /// No description provided for @itineraryOptionsScreenWalkingAvoidOption.
  ///
  /// In en, this message translates to:
  /// **'Avoid walking'**
  String get itineraryOptionsScreenWalkingAvoidOption;

  /// No description provided for @itineraryOptionsScreenWalkingAvoidOptionStatusEnabledSemantic.
  ///
  /// In en, this message translates to:
  /// **'On'**
  String get itineraryOptionsScreenWalkingAvoidOptionStatusEnabledSemantic;

  /// No description provided for @itineraryOptionsScreenWalkingAvoidOptionStatusDisabledSemantic.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get itineraryOptionsScreenWalkingAvoidOptionStatusDisabledSemantic;

  /// No description provided for @itineraryOptionsScreenWalkingAvoidOptionSemantic.
  ///
  /// In en, this message translates to:
  /// **'Avoid walking option, {status}.'**
  String itineraryOptionsScreenWalkingAvoidOptionSemantic(String status);

  /// No description provided for @itineraryOptionsScreenModesTitle.
  ///
  /// In en, this message translates to:
  /// **'Transit Modes'**
  String get itineraryOptionsScreenModesTitle;

  /// No description provided for @itineraryOptionsScreenBicycleTitle.
  ///
  /// In en, this message translates to:
  /// **'Bicycle'**
  String get itineraryOptionsScreenBicycleTitle;

  /// No description provided for @itineraryOptionsScreenBicycleSpeedOption.
  ///
  /// In en, this message translates to:
  /// **'Speed'**
  String get itineraryOptionsScreenBicycleSpeedOption;

  /// No description provided for @itineraryOptionsScreenBicycleSpeedIncrementSemantic.
  ///
  /// In en, this message translates to:
  /// **'Increase bicycle speed'**
  String get itineraryOptionsScreenBicycleSpeedIncrementSemantic;

  /// No description provided for @itineraryOptionsScreenBicycleSpeedDecrementSemantic.
  ///
  /// In en, this message translates to:
  /// **'Decrease bicycle speed'**
  String get itineraryOptionsScreenBicycleSpeedDecrementSemantic;

  /// No description provided for @itineraryOptionsScreenApplyButtonTitle.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get itineraryOptionsScreenApplyButtonTitle;

  /// No description provided for @itineraryOptionsScreenResetButtonTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get itineraryOptionsScreenResetButtonTitle;

  /// No description provided for @routingProfileLabelStandard.
  ///
  /// In en, this message translates to:
  /// **'Standard'**
  String get routingProfileLabelStandard;

  /// No description provided for @routingProfileLabelVisionImpairment.
  ///
  /// In en, this message translates to:
  /// **'Vision Impairment'**
  String get routingProfileLabelVisionImpairment;

  /// No description provided for @routingProfileLabelWheelchair.
  ///
  /// In en, this message translates to:
  /// **'Wheelchair'**
  String get routingProfileLabelWheelchair;

  /// No description provided for @routingProfileLabelRollator.
  ///
  /// In en, this message translates to:
  /// **'Rollator'**
  String get routingProfileLabelRollator;

  /// No description provided for @routingProfileLabelSlightWalkingDisability.
  ///
  /// In en, this message translates to:
  /// **'Slight Walking Disability'**
  String get routingProfileLabelSlightWalkingDisability;

  /// No description provided for @routingProfileLabelModerateWalkingDisability.
  ///
  /// In en, this message translates to:
  /// **'Moderate Walking Disability'**
  String get routingProfileLabelModerateWalkingDisability;

  /// No description provided for @routingProfileLabelSevereWalkingDisability.
  ///
  /// In en, this message translates to:
  /// **'Severe Walking Disability'**
  String get routingProfileLabelSevereWalkingDisability;

  /// No description provided for @routingProfileLabelStroller.
  ///
  /// In en, this message translates to:
  /// **'Stroller'**
  String get routingProfileLabelStroller;

  /// No description provided for @altModeButtonDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get altModeButtonDone;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['de', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de': return AppLocalizationsDe();
    case 'en': return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
