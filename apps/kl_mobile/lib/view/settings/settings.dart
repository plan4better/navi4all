import 'package:flutter/material.dart';
import 'package:navi4all/core/persistence/preference_helper.dart';
import 'package:navi4all/core/theme/colors.dart';
import 'package:navi4all/core/theme/profile_mode.dart';
import 'package:navi4all/l10n/app_localizations.dart';
import 'package:navi4all/view/common/accessible_button.dart';
import 'package:navi4all/view/common/selection_tile.dart';
import 'package:navi4all/view/common/sheet_button.dart';
import 'package:navi4all/view/onboarding/onboarding.dart';
import 'package:navi4all/view/settings/feedback.dart';
import 'package:navi4all/view/settings/legal_privacy.dart';
import 'package:navi4all/view/splash/splash.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:navi4all/core/config.dart';

class SettingsScreen extends StatelessWidget {
  final bool altMode;

  const SettingsScreen({super.key, this.altMode = false});

  Future<void> _changeAppProfile(BuildContext context) async {
    ProfileMode selectedProfileMode = await PreferenceHelper.getProfileMode();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) => Dialog(
            backgroundColor: Theme.of(context).colorScheme.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(32),
            ),
            child: Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      AppLocalizations.of(context)!.homeChangeBaseMapTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Navi4AllColors.klRed,
                      ),
                    ),
                  ),
                  SizedBox(height: 24),
                  Column(
                    children: [
                      SelectionTile(
                        title: AppLocalizations.of(
                          context,
                        )!.onboardingProfileSelectionBlindUserTitle,
                        isSelected: selectedProfileMode == ProfileMode.blind,
                        leadingIcon: Icons.circle,
                        onTap: () {
                          setStateDialog(() {
                            selectedProfileMode = ProfileMode.blind;
                          });
                        },
                      ),
                      SizedBox(height: 16),
                      SelectionTile(
                        title: AppLocalizations.of(
                          context,
                        )!.onboardingProfileSelectionVisionImpairedUserTitle,
                        isSelected:
                            selectedProfileMode == ProfileMode.visionImpaired,
                        leadingIcon: Icons.blur_on,
                        onTap: () {
                          setStateDialog(() {
                            selectedProfileMode = ProfileMode.visionImpaired;
                          });
                        },
                      ),
                      SizedBox(height: 16),
                      SelectionTile(
                        title: AppLocalizations.of(
                          context,
                        )!.onboardingProfileSelectionGeneralUserTitle,
                        isSelected: selectedProfileMode == ProfileMode.general,
                        leadingIcon: Icons.circle_outlined,
                        onTap: () {
                          setStateDialog(() {
                            selectedProfileMode = ProfileMode.general;
                          });
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: SheetButton(
                          label: AppLocalizations.of(
                            context,
                          )!.placeScreenChangeRadiusCancel,
                          onTap: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: SheetButton(
                          label: AppLocalizations.of(
                            context,
                          )!.placeScreenChangeRadiusConfirm,
                          onTap: () async {
                            await PreferenceHelper.setProfileMode(
                              selectedProfileMode,
                            );
                            Navigator.of(context).pop();
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(builder: (context) => Splash()),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

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
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 64),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
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
                  shrinkWrap: true,
                  children: [
                    ListTile(
                      leading: Icon(
                        Icons.visibility_outlined,
                        color: Navi4AllColors.klRed,
                      ),
                      title: Text(
                        AppLocalizations.of(
                          context,
                        )!.settingsOptionChangeAppProfile,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: Navi4AllColors.klRed),
                      ),
                      onTap: () => _changeAppProfile(context),
                    ),
                    Divider(color: Navi4AllColors.klPink, height: 0),
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
                    Divider(color: Navi4AllColors.klPink, height: 0),
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
              altMode
                  ? Align(
                      alignment: Alignment.bottomCenter,
                      child: AccessibleButton(
                        label: AppLocalizations.of(
                          context,
                        )!.commonHomeScreenButton,
                        style: AccessibleButtonStyle.pink,
                        onTap: () => Navigator.of(
                          context,
                        ).popUntil((route) => route.isFirst),
                      ),
                    )
                  : SizedBox.shrink(),
              altMode ? SizedBox(height: 32) : SizedBox.shrink(),
            ],
          ),
        ),
      ),
    );
  }
}
