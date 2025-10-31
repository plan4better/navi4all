import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:smartroots/controllers/favourites_controller.dart';
import 'package:smartroots/controllers/theme_controller.dart';
import 'package:smartroots/core/theme/colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smartroots/core/theme/labels.dart';
import 'package:smartroots/view/splash/splash.dart';
import 'l10n/app_localizations.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Only portrait mode is currently supported
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((_) => runApp(const SmartRootsApp()));
}

class SmartRootsApp extends StatelessWidget {
  const SmartRootsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeController(context)),
        ChangeNotifierProvider(create: (_) => FavouritesController(context)),
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
