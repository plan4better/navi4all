import 'package:flutter/material.dart';
import 'package:navi4all/l10n/app_localizations.dart';
import 'routing/route_options.dart';
import 'package:navi4all/view/common/accessible_button.dart';
import 'package:navi4all/util/theme/colors.dart';

class AddressInfoScreen extends StatefulWidget {
  final String address;
  const AddressInfoScreen({required this.address, super.key});

  @override
  State<AddressInfoScreen> createState() => _AddressInfoScreenState();
}

class _AddressInfoScreenState extends State<AddressInfoScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<IconData> _icons = [Icons.directions_walk, Icons.directions_bus];
  final String zipcode = '67655 Kaiserslautern';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _icons.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 50),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Semantics(
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
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 0),
                              child: Text(
                                widget.address,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 16,
                                  color: Color(0xFF535353),
                                  letterSpacing: 0.5,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
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
            ),
            // Large address and zipcode below search bar
            Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      widget.address,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 28,
                        color: Navi4AllColors.klRed,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    zipcode,
                    style: const TextStyle(
                      fontSize: 18,
                      color: Navi4AllColors.klRed,
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.only(bottom: 40),
              child: Column(
                children: [
                  AccessibleButton(
                    label: AppLocalizations.of(
                      context,
                    )!.addressInfoWalkingRoutesButton,
                    style: AccessibleButtonStyle.red,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) =>
                              RouteOptionsScreen(address: widget.address),
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
                          builder: (context) =>
                              RouteOptionsScreen(address: widget.address),
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
            ),
          ],
        ),
      ),
    );
  }
}
