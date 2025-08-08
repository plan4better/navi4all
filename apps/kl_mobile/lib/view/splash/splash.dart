import 'package:flutter/material.dart';
import 'package:navi4all/core/theme/colors.dart';
import 'package:navi4all/core/persistence/preference_helper.dart';
import '../onboarding/onboarding.dart';

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<StatefulWidget> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  @override
  void initState() {
    Future.delayed(Duration(milliseconds: 1500)).then((_) {
      PreferenceHelper.incrementLaunchCount().then((launchCount) {
        if (launchCount == 1) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => Onboarding()),
          );
        } else {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => Onboarding()),
          );
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
