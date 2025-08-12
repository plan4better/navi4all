import 'package:flutter/material.dart';
import 'package:navi4all/l10n/app_localizations.dart';
import 'package:navi4all/core/theme/colors.dart';
import '../home/home.dart';
import 'package:navi4all/view/common/accessible_selector.dart';
import 'package:navi4all/view/common/accessible_button.dart';
import 'package:geolocator/geolocator.dart';

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

  Future<void> _nextPage() async {
    if (_currentPage == 2) {
      await _requestLocationPermission();
    } else if (_currentPage >= 3) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    }
    _controller.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _requestLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Navi4AllColors.klRed,
      body: Column(
        children: [
          SizedBox(height: 64),
          Expanded(
            child: PageView(
              controller: _controller,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (index) {
                setState(() => _currentPage = index);
              },
              children: const [
                _WelcomeScreen(),
                _ProfileSelectionScreen(),
                _UserLocationScreen(),
                _FinishScreen(),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              4,
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 32),
            child: AccessibleButton(
              label: _currentPage < 3
                  ? AppLocalizations.of(context)!.commonContinueButtonSemantic
                  : AppLocalizations.of(
                      context,
                    )!.onboardingFinishHomeScreenButton,
              style: AccessibleButtonStyle.white,
              onTap: () => _nextPage(),
            ),
          ),
          Image.asset(width: 100, "assets/stadt_kl_white.png"),
          SizedBox(height: 48),
        ],
      ),
    );
  }
}

class _WelcomeScreen extends StatelessWidget {
  const _WelcomeScreen();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 32),
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 32),
          Center(
            child: Text(
              AppLocalizations.of(context)!.onboardingProfileSelectionTitle,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 28,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 32),
          Column(
            children: List.generate(
              profiles.length,
              (index) => Padding(
                padding: const EdgeInsets.only(bottom: 24),
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
    );
  }
}

class _UserLocationScreen extends StatelessWidget {
  const _UserLocationScreen();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            AppLocalizations.of(context)!.onboardingUserLocationTitle,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 32,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context)!.onboardingUserLocationSubtitle,
            style: const TextStyle(fontSize: 18, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class _FinishScreen extends StatelessWidget {
  const _FinishScreen();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.onboardingFinishTitle,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 32,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context)!.onboardingFinishSubtitle,
            style: const TextStyle(fontSize: 18, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
