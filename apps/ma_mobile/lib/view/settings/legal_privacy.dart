import 'package:flutter/material.dart';
import 'package:smartroots/core/theme/colors.dart';
import 'package:smartroots/l10n/app_localizations.dart';

class LegalPrivacyScreen extends StatefulWidget {
  const LegalPrivacyScreen({super.key});

  @override
  State<LegalPrivacyScreen> createState() => _LegalPrivacyScreenState();
}

class _LegalPrivacyScreenState extends State<LegalPrivacyScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 32),
              Row(
                children: [
                  InkWell(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: const Icon(
                        Icons.arrow_back,
                        color: SmartRootsColors.maBlueExtraExtraDark,
                      ),
                    ),
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  SizedBox(width: 8),
                  Text(
                    AppLocalizations.of(context)!.legalPrivacyScreenTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: SmartRootsColors.maBlueExtraExtraDark,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 32),
              Expanded(
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    ListTile(
                      leading: Icon(
                        Icons.gps_fixed_outlined,
                        color: SmartRootsColors.maBlueExtraExtraDark,
                      ),
                      title: Text(
                        AppLocalizations.of(
                          context,
                        )!.legalPrivacyLocationAccess,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: SmartRootsColors.maBlueExtraExtraDark,
                        ),
                      ),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              AppLocalizations.of(
                                context,
                              )!.featureComingSoonMessage,
                            ),
                          ),
                        );
                      },
                    ),
                    Divider(color: SmartRootsColors.maBlue, height: 0),
                    ListTile(
                      leading: Icon(
                        Icons.security_outlined,
                        color: SmartRootsColors.maBlueExtraExtraDark,
                      ),
                      title: Text(
                        AppLocalizations.of(
                          context,
                        )!.legalPrivacyDataProtection,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: SmartRootsColors.maBlueExtraExtraDark,
                        ),
                      ),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              AppLocalizations.of(
                                context,
                              )!.featureComingSoonMessage,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
