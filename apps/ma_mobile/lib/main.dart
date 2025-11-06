import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:smartroots/controllers/availability_controller.dart';
import 'package:smartroots/controllers/favourites_controller.dart';
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
  ]).then((_) => runApp(const SmartRootsApp()));

  // Initialize Matomo analytics
  MatomoTracker.instance.initialize(
    siteId: Settings.matomoSiteId,
    url: Settings.matomoUrl,
    cookieless: true,
  );
}

class SmartRootsApp extends StatelessWidget {
  const SmartRootsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeController(context)),
        ChangeNotifierProvider(create: (_) => FavouritesController(context)),
        ChangeNotifierProvider(create: (_) => AvailabilityController()),
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
