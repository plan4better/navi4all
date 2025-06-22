import 'package:flutter/material.dart';
import 'package:navi4all/util/theme/colors.dart';
import 'home.dart';
import 'package:navi4all/view/common/accessible_selector.dart';
import 'package:navi4all/view/common/accessible_button.dart';

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
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Willkommen bei\nNavi4All.',
            textAlign: TextAlign.left,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 31,
              color: Colors.white,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Die App, die Sie durch\nKaiserslautern führt.',
            textAlign: TextAlign.left,
            style: const TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 16,
              color: Colors.white,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Wischen Sie nach links, um fortzufahren.',
            style: const TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 13,
              color: Colors.white,
              height: 1.2,
            ),
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
      'Blinde Benutzer',
      'Sehbehinderunge Benutzer',
      'Allgemeine Benutzer',
    ];
    return Scaffold(
      backgroundColor: Navi4AllColors.klRed,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 40),
            Center(
              child: Text(
                'Wählen Sie Ihr Profil',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 25,
                  color: Colors.white,
                  height: 1.2,
                ),
              ),
            ),
            const SizedBox(height: 60),
            Column(
              children: List.generate(
                profiles.length,
                (index) => Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: AccessibleSelector(
                    label: profiles[index],
                    selected: _selectedIndex == index,
                    onTap: () {
                      setState(() {
                        if (_selectedIndex == index) {
                          _selectedIndex = -1; // Deselect if already selected
                        } else {
                          _selectedIndex = index; // Select the new profile
                        }
                      });
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
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Sie sind fertig!',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 31,
              color: Colors.white,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 40),
          Text(
            'Ihr Profil wurde erfolgreich\nausgewählt. Was möchten Sie\nnun tun?',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 16,
              color: Colors.white,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 40),
          Column(
            children: [
              AccessibleButton(
                label: 'Zum App-Tutorial',
                style: AccessibleButtonStyle.white,
                onTap: () {
                  // TODO: Navigate to app tutorial
                },
              ),
              const SizedBox(height: 24),
              AccessibleButton(
                label: 'Startbildschirm gehen',
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
