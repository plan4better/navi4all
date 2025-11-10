import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:navi4all/controllers/favorites_controller.dart';
import 'package:navi4all/controllers/profile_mode_controller.dart';
import 'package:provider/provider.dart';
import 'package:navi4all/controllers/theme_controller.dart';
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
  ]).then((_) => runApp(const Navi4AllApp()));

  // Initialize Matomo analytics
  /* MatomoTracker.instance.initialize(
    siteId: Settings.matomoSiteId,
    url: Settings.matomoUrl,
    cookieless: true,
  ); */
}

class Navi4AllApp extends StatelessWidget {
  const Navi4AllApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeController(context)),
        ChangeNotifierProvider(create: (_) => ProfileModeController(context)),
        ChangeNotifierProvider(create: (_) => FavoritesController(context)),
      ],
      child: Consumer<ThemeController>(
        builder: (context, themeController, _) => MaterialApp(
          title: Navi4AllLabels.appName,
          themeMode: themeController.themeMode,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Navi4AllColors.klRed,
              surface: Navi4AllColors.maSurfaceLight,
              secondary: Navi4AllColors.maSecondaryLight,
              tertiary: Navi4AllColors.maTertiaryLight,
              brightness: Brightness.light,
            ),
            textTheme: GoogleFonts.robotoTextTheme(),
            brightness: Brightness.light,
          ),
          darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Navi4AllColors.klRed,
              surface: Navi4AllColors.maSurfaceDark,
              secondary: Navi4AllColors.maSecondaryDark,
              tertiary: Navi4AllColors.maTertiaryDark,
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
