import 'package:flutter/material.dart';
import 'package:navi4all/l10n/app_localizations.dart';
import 'package:navi4all/schemas/routing/mode.dart';
import '../routing/route_options.dart';
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
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            children: [
              Semantics(
                label: AppLocalizations.of(
                  context,
                )!.addressInfoBackToSearchButtonSemantic,
                child: Material(
                  elevation: 2,
                  borderRadius: BorderRadius.circular(28),
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
                          Semantics(
                            excludeSemantics: true,
                            child: IconButton(
                              icon: const Icon(
                                Icons.arrow_back,
                                color: Color(0xFFD82028),
                              ),
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              widget.place.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w400,
                                fontSize: 16,
                                color: Color(0xFF535353),
                                letterSpacing: 0.5,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.mic,
                              color: Color(0xFFD82028),
                              semanticLabel: AppLocalizations.of(
                                context,
                              )!.commonMicButtonSemantic,
                            ),
                            onPressed: () {},
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 32),
              Column(
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
              const Spacer(),
              SizedBox(height: 16),
              Column(
                children: [
                  AccessibleButton(
                    label: AppLocalizations.of(
                      context,
                    )!.addressInfoWalkingRoutesButton,
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
                  const SizedBox(height: 20),
                  AccessibleButton(
                    label: AppLocalizations.of(
                      context,
                    )!.addressInfoPublicTransportRoutesButton,
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
                  const SizedBox(height: 20),
                  AccessibleButton(
                    label: AppLocalizations.of(
                      context,
                    )!.addressInfoSaveAddressButton,
                    style: AccessibleButtonStyle.pink,
                    onTap: null,
                  ),
                  const SizedBox(height: 20),
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
