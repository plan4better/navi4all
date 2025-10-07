import 'package:flutter/material.dart';
import 'package:smartroots/core/theme/colors.dart';
import 'package:smartroots/l10n/app_localizations.dart';
import 'package:smartroots/view/settings/feedback.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

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
                  color: SmartRootsColors.maBlueExtraExtraDark,
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
                      Icons.feedback_outlined,
                      color: SmartRootsColors.maBlueExtraExtraDark,
                    ),
                    title: Text(
                      AppLocalizations.of(context)!.settingsOptionFeedback,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: SmartRootsColors.maBlueExtraExtraDark,
                      ),
                    ),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const FeedbackScreen(),
                      ),
                    ),
                  ),
                  Divider(color: SmartRootsColors.maBlue, height: 0),
                  ListTile(
                    leading: Icon(
                      Icons.support_agent_outlined,
                      color: SmartRootsColors.maBlueExtraExtraDark,
                    ),
                    title: Text(
                      AppLocalizations.of(context)!.settingsOptionSupport,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: SmartRootsColors.maBlueExtraExtraDark,
                      ),
                    ),
                    onTap: () {},
                  ),
                  Divider(color: SmartRootsColors.maBlue, height: 0),
                  ListTile(
                    leading: Icon(
                      Icons.privacy_tip_outlined,
                      color: SmartRootsColors.maBlueExtraExtraDark,
                    ),
                    title: Text(
                      AppLocalizations.of(
                        context,
                      )!.settingsOptionLegalAndPrivacy,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: SmartRootsColors.maBlueExtraExtraDark,
                      ),
                    ),
                    onTap: () {},
                  ),
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
