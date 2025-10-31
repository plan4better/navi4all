import 'package:flutter/material.dart';
import 'package:smartroots/core/theme/colors.dart';
import 'package:smartroots/core/persistence/preference_helper.dart';
import 'package:smartroots/view/home/home.dart';
import 'package:smartroots/view/onboarding/onboarding.dart';

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
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => HomeScreen()),
          );
        }
      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: SmartRootsColors.maBlueExtraExtraDark,
    body: Align(
      alignment: Alignment.bottomCenter,
      child: Image.asset("assets/p_reserviert.png", width: 250),
    ),
  );
}
