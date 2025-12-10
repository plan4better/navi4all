import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:smartroots/controllers/autocomplete_controller.dart';
import 'package:smartroots/controllers/availability_controller.dart';
import 'package:smartroots/controllers/favorites_controller.dart';
import 'package:smartroots/controllers/routing_controller.dart';
import 'package:smartroots/controllers/theme_controller.dart';
import 'package:smartroots/core/config.dart';
import 'package:smartroots/core/theme/colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smartroots/core/theme/labels.dart';
import 'package:smartroots/view/splash/splash.dart';
import 'l10n/app_localizations.dart';
import 'package:matomo_tracker/matomo_tracker.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Only portrait mode is currently supported
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((_) => runApp(SmartRootsApp()));

  // Initialize Matomo analytics
  MatomoTracker.instance.initialize(
    siteId: Settings.matomoSiteId,
    url: Settings.matomoUrl,
    cookieless: true,
  );
}

class SmartRootsApp extends StatelessWidget {
  late RoutingController _routingController;
  late CurrentPositionController _currentPositionController;
  late ActionTrailController _actionTrailController;
  late NavigationStatsController _navigationStatsController;
  late NavigationInstructionsController _navigationInstructionsController;
  late NavigationAudioController _navigationAudioController;

  SmartRootsApp({super.key}) {
    _routingController = RoutingController();
    _currentPositionController = CurrentPositionController(_routingController);
    _actionTrailController = ActionTrailController(_routingController);
    _navigationStatsController = NavigationStatsController(_routingController);
    _navigationInstructionsController = NavigationInstructionsController(
      _routingController,
    );
    _navigationAudioController = NavigationAudioController(
      _navigationInstructionsController,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeController(context)),
        ChangeNotifierProvider(create: (_) => FavoritesController(context)),
        ChangeNotifierProvider(create: (_) => AvailabilityController()),
        ChangeNotifierProvider(create: (_) => AutocompleteController()),
        ChangeNotifierProvider(create: (_) => _routingController),
        ChangeNotifierProvider(create: (_) => _currentPositionController),
        ChangeNotifierProvider(create: (_) => _actionTrailController),
        ChangeNotifierProvider(create: (_) => _navigationStatsController),
        ChangeNotifierProvider(
          create: (_) => _navigationInstructionsController,
        ),
        ChangeNotifierProvider(create: (_) => _navigationAudioController),
      ],
      child: Consumer<ThemeController>(
        builder: (context, themeController, _) => MaterialApp(
          title: SmartRootsLabels.appName,
          themeMode: themeController.themeMode,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: SmartRootsColors.maBlueExtraDark,
              surface: SmartRootsColors.maSurfaceLight,
              secondary: SmartRootsColors.maSecondaryLight,
              tertiary: SmartRootsColors.maTertiaryLight,
              brightness: Brightness.light,
            ),
            textTheme: GoogleFonts.robotoTextTheme(),
            brightness: Brightness.light,
          ),
          darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: SmartRootsColors.maBlueExtraDark,
              surface: SmartRootsColors.maSurfaceDark,
              secondary: SmartRootsColors.maSecondaryDark,
              tertiary: SmartRootsColors.maTertiaryDark,
              brightness: Brightness.dark,
            ),
            textTheme: GoogleFonts.robotoTextTheme(
              ThemeData(brightness: Brightness.dark).textTheme,
            ),
            brightness: Brightness.dark,
          ),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const Splash(),
        ),
      ),
    );
  }
}
