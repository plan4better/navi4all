import 'package:flutter/material.dart';
import 'package:navi4all/core/theme/colors.dart';
import 'package:navi4all/l10n/app_localizations.dart';
import 'package:navi4all/view/onboarding/onboarding.dart';
import 'package:navi4all/view/settings/feedback.dart';
import 'package:navi4all/view/settings/legal_privacy.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:navi4all/core/config.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  void _launchSupport() async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: Settings.supportEmailUrl,
      query: 'subject=${Settings.supportEmailSubject}',
    );

    await launchUrl(emailLaunchUri);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                AppLocalizations.of(context)!.settingsTitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Navi4AllColors.klRed,
                ),
              ),
            ),
            SizedBox(height: 16),
            Expanded(
              child: ListView(
                padding: EdgeInsets.all(16),
                shrinkWrap: true,
                children: [
                  ListTile(
                    leading: Icon(
                      Icons.play_circle_outline,
                      color: Navi4AllColors.klRed,
                    ),
                    title: Text(
                      AppLocalizations.of(context)!.settingsOptionSetupGuide,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Navi4AllColors.klRed),
                    ),
                    onTap: () => Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => OnboardingScreen(),
                      ),
                    ),
                  ),
                  Divider(color: Navi4AllColors.klRed, height: 0),
                  ListTile(
                    leading: Icon(
                      Icons.feedback_outlined,
                      color: Navi4AllColors.klRed,
                    ),
                    title: Text(
                      AppLocalizations.of(context)!.settingsOptionFeedback,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Navi4AllColors.klRed),
                    ),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const FeedbackScreen(),
                      ),
                    ),
                  ),
                  Divider(color: Navi4AllColors.klPink, height: 0),
                  ListTile(
                    leading: Icon(
                      Icons.support_agent_outlined,
                      color: Navi4AllColors.klRed,
                    ),
                    title: Text(
                      AppLocalizations.of(context)!.settingsOptionSupport,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Navi4AllColors.klRed),
                    ),
                    onTap: () => _launchSupport(),
                  ),
                  Divider(color: Navi4AllColors.klPink, height: 0),
                  ListTile(
                    leading: Icon(
                      Icons.privacy_tip_outlined,
                      color: Navi4AllColors.klRed,
                    ),
                    title: Text(
                      AppLocalizations.of(
                        context,
                      )!.settingsOptionLegalAndPrivacy,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Navi4AllColors.klRed),
                    ),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const LegalPrivacyScreen(),
                      ),
                    ),
                  ),
                  Divider(color: Navi4AllColors.klPink, height: 0),
                ],
              ),
            ),
            SizedBox(height: 96),
          ],
        ),
      ),
    );
  }
}
