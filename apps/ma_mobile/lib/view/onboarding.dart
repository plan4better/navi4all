import 'package:flutter/material.dart';
import 'package:smart_roots/l10n/app_localizations.dart';
import 'package:smart_roots/util/theme/colors.dart';
import 'home.dart';
import 'package:smart_roots/view/common/accessible_selector.dart';
import 'package:smart_roots/view/common/accessible_button.dart';

class Onboarding extends StatefulWidget {
  const Onboarding({super.key});

  @override
  State<StatefulWidget> createState() => _OnboardingState();
}

class _OnboardingState extends State<Onboarding> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Navi4AllColors.klRed,
      body: Column(
        children: [
          SizedBox(height: 100),
          Expanded(
            child: PageView(
              controller: _controller,
              onPageChanged: (index) {
                setState(() => _currentPage = index);
              },
              children: const [
                _WelcomeScreen(),
                _ProfileSelectionScreen(),
                _FinishScreen(),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              3,
              (index) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 5),
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: index == _currentPage
                      ? Navi4AllColors.klWhite
                      : Navi4AllColors.klPink,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
          SizedBox(height: 80),
          Image.asset(width: 100, "assets/stadt_kl_white.png"),
          SizedBox(height: 80),
        ],
      ),
    );
  }
}

class _WelcomeScreen extends StatelessWidget {
  const _WelcomeScreen();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.onboardingWelcomeTitle,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 32,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context)!.onboardingWelcomeSubtitle,
            style: const TextStyle(fontSize: 18, color: Colors.white),
          ),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context)!.onboardingWelcomeHint,
            style: const TextStyle(fontSize: 14, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class _ProfileSelectionScreen extends StatefulWidget {
  const _ProfileSelectionScreen();

  @override
  State<_ProfileSelectionScreen> createState() =>
      _ProfileSelectionScreenState();
}

class _ProfileSelectionScreenState extends State<_ProfileSelectionScreen> {
  int _selectedIndex = 2;

  @override
  Widget build(BuildContext context) {
    final profiles = [
      AppLocalizations.of(context)!.onboardingProfileSelectionBlindUserTitle,
      AppLocalizations.of(
        context,
      )!.onboardingProfileSelectionVisionImpairedUserTitle,
      AppLocalizations.of(context)!.onboardingProfileSelectionGeneralUserTitle,
    ];
    return Scaffold(
      backgroundColor: Navi4AllColors.klRed,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: Text(
                AppLocalizations.of(context)!.onboardingProfileSelectionTitle,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 32,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 32),
            Column(
              children: List.generate(
                profiles.length,
                (index) => Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: AccessibleSelector(
                    label: profiles[index],
                    selected: _selectedIndex == index,
                    onTap: () {
                      setState(() => _selectedIndex = index);
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FinishScreen extends StatelessWidget {
  const _FinishScreen();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            AppLocalizations.of(context)!.onboardingFinishTitle,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 32,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 32),
          Text(
            AppLocalizations.of(context)!.onboardingFinishSubtitle,
            style: const TextStyle(fontSize: 18, color: Colors.white),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          Column(
            children: [
              AccessibleButton(
                label: AppLocalizations.of(
                  context,
                )!.onboardingFinishAppTutorialButton,
                style: AccessibleButtonStyle.white,
                onTap: null,
              ),
              const SizedBox(height: 20),
              AccessibleButton(
                label: AppLocalizations.of(
                  context,
                )!.onboardingFinishHomeScreenButton,
                style: AccessibleButtonStyle.white,
                onTap: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => const HomeScreen()),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
