import 'package:flutter/material.dart';
import 'package:smart_roots/l10n/app_localizations.dart';
import 'package:smart_roots/util/theme/colors.dart';
import 'address_info.dart';
import 'package:smart_roots/view/common/accessible_button.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode(); // Added FocusNode
  bool _showResults = false;

  final List<String> _sampleResults = [
    'Kaiserslautern Hauptbahnhof',
    'Königstraße',
    'Pfalztheater Kaiserslautern',
    'Mainzer Straße',
  ];

  @override
  void initState() {
    super.initState();
    _focusNode.requestFocus(); // Request focus on launch
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose(); // Dispose FocusNode
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.white,
    resizeToAvoidBottomInset: false,
    body: SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          children: [
            const SizedBox(height: 32),
            // Search bar
            Material(
              elevation: 2,
              borderRadius: BorderRadius.circular(28),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEDEB),
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(28),
                    topRight: const Radius.circular(28),
                    bottomLeft: _showResults
                        ? const Radius.circular(0)
                        : const Radius.circular(28),
                    bottomRight: _showResults
                        ? const Radius.circular(0)
                        : const Radius.circular(28),
                  ),
                  border: _showResults
                      ? const Border(
                          bottom: BorderSide(
                            color: Navi4AllColors.klRed,
                            width: 2,
                          ),
                        )
                      : null,
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.arrow_back,
                        color: Color(0xFFD82028),
                        semanticLabel: AppLocalizations.of(
                          context,
                        )!.commonBackButtonSemantic,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        focusNode: _focusNode,
                        decoration: InputDecoration(
                          hintText: AppLocalizations.of(
                            context,
                          )!.searchTextFieldHint,
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 16),
                        ),
                        style: const TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 16,
                          color: Color(0xFF535353),
                          letterSpacing: 0.5,
                        ),
                        onChanged: (value) {
                          setState(() {
                            _showResults = value.trim().isNotEmpty;
                          });
                        },
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
            // Suggestions/results
            if (_showResults)
              Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFEDEB),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(28),
                    bottomRight: Radius.circular(28),
                  ),
                ),
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                child: Column(
                  children: _sampleResults
                      .map(
                        (place) => Column(
                          children: [
                            _SearchSuggestion(text: place),
                            if (place != _sampleResults.last)
                              const Divider(
                                height: 1,
                                color: Color(0xFFD82028),
                              ),
                          ],
                        ),
                      )
                      .toList(),
                ),
              ),
            const Spacer(),
            AccessibleButton(
              label: AppLocalizations.of(context)!.commonHomeScreenButton,
              style: AccessibleButtonStyle.pink,
              onTap: () =>
                  Navigator.of(context).popUntil((route) => route.isFirst),
            ),
          ],
        ),
      ),
    ),
  );
}

class _SearchSuggestion extends StatelessWidget {
  final String text;
  const _SearchSuggestion({required this.text});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => AddressInfoScreen(address: text),
          ),
        );
      },
      child: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        child: Text(
          text,
          style: const TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: 16,
            color: Color(0xFFD82028),
          ),
        ),
      ),
    );
  }
}
