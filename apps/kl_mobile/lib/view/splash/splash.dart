import 'package:flutter/material.dart';
import 'package:navi4all/controllers/profile_mode_controller.dart';
import 'package:navi4all/core/theme/colors.dart';
import 'package:navi4all/core/persistence/preference_helper.dart';
import 'package:provider/provider.dart';
import 'package:navi4all/view/onboarding/onboarding.dart';
import 'package:navi4all/view/home/home.dart';
import 'package:navi4all/view_alt/home/home.dart' as home_alt;
import 'package:navi4all/core/theme/profile_mode.dart';

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<StatefulWidget> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  @override
  void initState() {
    Future.delayed(Duration(milliseconds: 1500)).then((_) {
      PreferenceHelper.isOnboardingComplete().then((isComplete) {
        if (!isComplete) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => OnboardingScreen()),
          );
        } else {
          switch (Provider.of<ProfileModeController>(
            context,
            listen: false,
          ).profileMode) {
            case ProfileMode.blind:
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => home_alt.HomeScreen()),
              );
              break;
            case ProfileMode.visionImpaired:
            case ProfileMode.general:
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => HomeScreen()),
              );
              break;
          }
        }
      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Navi4AllColors.klRed,
    body: Center(child: Image.asset("assets/stadt_kl_white.png", width: 100)),
  );
}
