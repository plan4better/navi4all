import 'package:flutter/material.dart';
import 'search.dart';
import 'package:navi4all/view/common/accessible_button.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 32),
              Spacer(),
              AccessibleButton(
                label: 'Suchen',
                style: AccessibleButtonStyle.pink,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const SearchScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 32),
              AccessibleButton(
                label: 'Gespeichert',
                style: AccessibleButtonStyle.pink,
                onTap: () {},
              ),
              const SizedBox(height: 32),
              AccessibleButton(
                label: 'Route',
                style: AccessibleButtonStyle.pink,
                onTap: () {},
              ),
              const SizedBox(height: 32),
              AccessibleButton(
                label: 'Einstellungen',
                style: AccessibleButtonStyle.pink,
                onTap: () {},
              ),
              const SizedBox(height: 32),
              Spacer(),
              Image.asset("assets/stadt_kl_red.png", width: 100),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
