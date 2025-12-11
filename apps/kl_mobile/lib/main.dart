import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:navi4all/controllers/canvas_controller.dart';
import 'package:navi4all/controllers/favorites_controller.dart';
import 'package:navi4all/controllers/itinerary_controller.dart';
import 'package:navi4all/controllers/place_controller.dart';
import 'package:navi4all/controllers/profile_controller.dart';
import 'package:provider/provider.dart';
import 'package:navi4all/controllers/theme_controller.dart';
import 'package:navi4all/controllers/routing_controller.dart';
// import 'package:navi4all/core/config.dart';
import 'package:navi4all/core/theme/colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:navi4all/core/theme/labels.dart';
import 'package:navi4all/view/splash/splash.dart';
import 'l10n/app_localizations.dart';
// import 'package:matomo_tracker/matomo_tracker.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Only portrait mode is currently supported
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((_) => runApp(Navi4AllApp()));

  // Initialize Matomo analytics
  /* MatomoTracker.instance.initialize(
    siteId: Settings.matomoSiteId,
    url: Settings.matomoUrl,
    cookieless: true,
  ); */
}

class Navi4AllApp extends StatelessWidget {
  late RoutingController _routingController;
  late CurrentPositionController _currentPositionController;
  late ActionTrailController _actionTrailController;
  late NavigationStatsController _navigationStatsController;
  late NavigationInstructionsController _navigationInstructionsController;
  late NavigationAudioController _navigationAudioController;
  late NavigationDigressingController _navigationDigressingController;

  Navi4AllApp({super.key}) {
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
    _navigationDigressingController = NavigationDigressingController(
      _routingController,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeController(context)),
        ChangeNotifierProvider(create: (_) => ProfileController()),
        ChangeNotifierProvider(create: (_) => FavoritesController(context)),
        ChangeNotifierProvider(create: (_) => CanvasController()),
        ChangeNotifierProvider(create: (_) => PlaceController()),
        ChangeNotifierProvider(create: (_) => ItineraryController()),
        ChangeNotifierProvider(create: (_) => _routingController),
        ChangeNotifierProvider(create: (_) => _currentPositionController),
        ChangeNotifierProvider(create: (_) => _actionTrailController),
        ChangeNotifierProvider(create: (_) => _navigationStatsController),
        ChangeNotifierProvider(
          create: (_) => _navigationInstructionsController,
        ),
        ChangeNotifierProvider(create: (_) => _navigationAudioController),
        ChangeNotifierProvider(create: (_) => _navigationDigressingController),
      ],
      child: Consumer<ThemeController>(
        builder: (context, themeController, _) => MaterialApp(
          title: Navi4AllLabels.appName,
          themeMode: themeController.themeMode,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: themeController.textColorLight,
              surface: Navi4AllColors.maSurfaceLight,
              secondary: Navi4AllColors.maSecondaryLight,
              tertiary: Navi4AllColors.maTertiaryLight,
              brightness: Brightness.light,
            ),
            textTheme: GoogleFonts.robotoTextTheme(
              Theme.of(context).textTheme.apply(
                bodyColor: themeController.textColorLight,
                displayColor: themeController.textColorLight,
              ),
            ),
            brightness: Brightness.light,
          ),
          darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: themeController.textColorDark,
              surface: Navi4AllColors.maSurfaceDark,
              secondary: Navi4AllColors.maSecondaryDark,
              tertiary: Navi4AllColors.maTertiaryDark,
              brightness: Brightness.dark,
            ),
            textTheme: GoogleFonts.robotoTextTheme(
              Theme.of(context).textTheme.apply(
                bodyColor: themeController.textColorDark,
                displayColor: themeController.textColorDark,
              ),
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
