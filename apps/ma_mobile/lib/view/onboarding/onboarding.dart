import 'package:flutter/material.dart';
import 'package:smartroots/core/persistence/preference_helper.dart';
import 'package:smartroots/l10n/app_localizations.dart';
import 'package:smartroots/core/theme/colors.dart';
import 'package:smartroots/view/home/home.dart';
import 'package:smartroots/view/common/accessible_button.dart';
import 'package:geolocator/geolocator.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<StatefulWidget> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  final List<Widget> _pages = const [
    _WelcomeScreen(),
    _SymbolInformationScreen(),
    _UserLocationScreen(),
    _FinishScreen(),
  ];
  int _currentPage = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _nextPage() async {
    if (_pages[_currentPage] is _UserLocationScreen) {
      await _requestLocationPermission();
    } else if (_currentPage >= _pages.length - 1) {
      PreferenceHelper.setOnboardingComplete(true);
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
      backgroundColor: SmartRootsColors.maBlueExtraDark,
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
              children: _pages,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _pages.length,
              (index) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 5),
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: index == _currentPage
                      ? SmartRootsColors.maWhite
                      : SmartRootsColors.maBlue,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 32),
            child: AccessibleButton(
              label: _currentPage < (_pages.length - 1)
                  ? AppLocalizations.of(context)!.commonContinueButtonSemantic
                  : AppLocalizations.of(
                      context,
                    )!.onboardingFinishHomeScreenButton,
              style: AccessibleButtonStyle.white,
              onTap: () => _nextPage(),
            ),
          ),
          Image.asset(width: 64, "assets/smart_logo.png"),
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
              fontSize: 28,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context)!.onboardingWelcomeSubtitle,
            style: const TextStyle(fontSize: 16, color: Colors.white),
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

class _SymbolInformationScreen extends StatelessWidget {
  const _SymbolInformationScreen();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.onboardingSymbolInformationTitle,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 28,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context)!.onboardingSymbolInformationSubtitle,
            style: const TextStyle(fontSize: 16, color: Colors.white),
          ),
          const SizedBox(height: 32),
          _SymbolLegendRow(
            iconColor: SmartRootsColors.maGreen,
            hint: AppLocalizations.of(
              context,
            )!.onboardingSymbolInformationParkingAvailable,
          ),
          const SizedBox(height: 16),
          _SymbolLegendRow(
            iconColor: SmartRootsColors.maRed,
            hint: AppLocalizations.of(
              context,
            )!.onboardingSymbolInformationParkingUnavailable,
          ),
          const SizedBox(height: 16),
          _SymbolLegendRow(
            iconColor: SmartRootsColors.maBlueExtraDark,
            hint: AppLocalizations.of(
              context,
            )!.onboardingSymbolInformationParkingUnknown,
          ),
        ],
      ),
    );
  }
}

class _SymbolLegendRow extends StatelessWidget {
  final Color iconColor;
  final String hint;

  const _SymbolLegendRow({required this.iconColor, required this.hint});

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: iconColor,
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: SmartRootsColors.maWhite, width: 1),
        ),
        child: Row(
          children: [
            Icon(
              Icons.local_parking,
              size: 16,
              color: SmartRootsColors.maWhite,
            ),
          ],
        ),
      ),
      const SizedBox(width: 16),
      Expanded(
        child: Text(
          hint,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    ],
  );
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
              fontSize: 28,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context)!.onboardingUserLocationSubtitle,
            style: const TextStyle(fontSize: 16, color: Colors.white),
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
              fontSize: 28,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context)!.onboardingFinishSubtitle,
            style: const TextStyle(fontSize: 16, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
