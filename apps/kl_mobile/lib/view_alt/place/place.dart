import 'package:flutter/material.dart';
import 'package:navi4all/l10n/app_localizations.dart';
import 'package:navi4all/schemas/routing/mode.dart';
import '../../view/routing/route_options.dart';
import 'package:navi4all/view/common/accessible_button.dart';
import 'package:navi4all/core/theme/colors.dart';
import 'package:navi4all/schemas/routing/place.dart';

class PlaceScreen extends StatefulWidget {
  final Place place;
  const PlaceScreen({required this.place, super.key});

  @override
  State<PlaceScreen> createState() => _PlaceScreenState();
}

class _PlaceScreenState extends State<PlaceScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
          child: Column(
            children: [
              Semantics(
                label: AppLocalizations.of(
                  context,
                )!.addressInfoBackToSearchButtonSemantic(widget.place.name),
                excludeSemantics: true,
                child: InkWell(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    height: 56,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFEDEB),
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Navi4AllColors.klRed,
                          ),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                        Expanded(
                          child: Text(
                            widget.place.name,
                            style: const TextStyle(fontSize: 16),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.mic,
                            color: Navi4AllColors.klRed,
                            semanticLabel: AppLocalizations.of(
                              context,
                            )!.commonMicButtonSemantic,
                          ),
                          onPressed: null,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 32),
              Semantics(
                excludeSemantics: true,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        widget.place.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 28,
                          color: Navi4AllColors.klRed,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.place.description,
                      style: const TextStyle(
                        fontSize: 18,
                        color: Navi4AllColors.klRed,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              SizedBox(height: 16),
              Column(
                children: [
                  AccessibleButton(
                    label: AppLocalizations.of(
                      context,
                    )!.addressInfoWalkingRoutesButton,
                    semanticLabel: AppLocalizations.of(
                      context,
                    )!.addressInfoWalkingRoutesButtonSemantic,
                    style: AccessibleButtonStyle.red,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => RouteOptionsScreen(
                            mode: Mode.WALK,
                            place: widget.place,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  AccessibleButton(
                    label: AppLocalizations.of(
                      context,
                    )!.addressInfoPublicTransportRoutesButton,
                    semanticLabel: AppLocalizations.of(
                      context,
                    )!.addressInfoPublicTransportRoutesButtonSemantic,
                    style: AccessibleButtonStyle.red,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => RouteOptionsScreen(
                            mode: Mode.TRANSIT,
                            place: widget.place,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  AccessibleButton(
                    label: AppLocalizations.of(
                      context,
                    )!.addressInfoSaveAddressButton,
                    style: AccessibleButtonStyle.pink,
                    onTap: null,
                  ),
                  const SizedBox(height: 16),
                  AccessibleButton(
                    label: AppLocalizations.of(context)!.commonHomeScreenButton,
                    style: AccessibleButtonStyle.pink,
                    onTap: () => Navigator.of(
                      context,
                    ).popUntil((route) => route.isFirst),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
