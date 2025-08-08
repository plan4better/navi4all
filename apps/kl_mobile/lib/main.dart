import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:navi4all/core/theme/colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:navi4all/view/splash/splash.dart';
import 'l10n/app_localizations.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Only portrait mode is currently supported
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((_) => runApp(const Navi4AllApp()));
}

class Navi4AllApp extends StatelessWidget {
  const Navi4AllApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Navi4All',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Navi4AllColors.klRed,
          primary: Navi4AllColors.klRed,
          secondary: Navi4AllColors.klPink,
        ),
        textTheme: GoogleFonts.robotoTextTheme(),
      ),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const Splash(),
    );
  }
}
