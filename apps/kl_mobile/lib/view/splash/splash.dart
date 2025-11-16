import 'package:flutter/material.dart';
import 'package:navi4all/core/theme/colors.dart';
import 'package:navi4all/core/persistence/preference_helper.dart';
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
    _launchHomeScreen();

    super.initState();
  }

  Future<void> _launchHomeScreen() async {
    await Future.delayed(Duration(milliseconds: 1500));

    bool isOnboardingComplete = await PreferenceHelper.isOnboardingComplete();
    if (!isOnboardingComplete) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => OnboardingScreen()),
      );
    } else {
      switch (await PreferenceHelper.getProfileMode()) {
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
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Navi4AllColors.klRed,
    body: Center(child: Image.asset("assets/stadt_kl_white.png", width: 100)),
  );
}
