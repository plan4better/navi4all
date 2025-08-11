import 'package:flutter/material.dart';
import 'package:navi4all/l10n/app_localizations.dart';
import 'package:navi4all/core/theme/colors.dart';
import 'package:navi4all/view/place/place.dart';
import 'package:navi4all/view/common/accessible_button.dart';
import 'package:navi4all/schemas/routing/place.dart';
import 'package:navi4all/services/geocoding.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode(); // Added FocusNode
  bool _showResults = false;
  String _searchQuery = "";
  DateTime? _searchTimestamp;

  List<Place> _autocompleteResults = [];

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

  Future<void> _fetchAutocompleteResults() async {
    _searchQuery = _controller.text;
    _searchTimestamp = DateTime.now();
    List<Place> places = [];
    GeocodingService geocodingService = GeocodingService();
    try {
      final response = await geocodingService.autocomplete(
        timestamp: _searchTimestamp!.toIso8601String(),
        query: _controller.text,
        // Example coordinates from Kaiserslautern
        // TODO: Replace with coarse user location
        focusPointLat: 49.43578102534064,
        focusPointLon: 7.768523468558005,
      );
      if (response.statusCode == 200) {
        final DateTime timestamp = DateTime.parse(response.data['timestamp']);
        if (_searchTimestamp != null && timestamp.isBefore(_searchTimestamp!)) {
          return;
        }
        final results = response.data['results'] as List;
        places = results.map((item) => Place.fromJson(item)).toList();
        setState(() {
          _autocompleteResults = places;
        });
      } else {
        throw Exception('Failed to load autocomplete results');
      }
    } catch (e) {
      print('Error fetching autocomplete results: $e');
      // Handle error appropriately, e.g., show a snackbar or dialog
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_controller.text != _searchQuery) {
      _fetchAutocompleteResults();
    }

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            children: [
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
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 8,
                  ),
                  child: Column(
                    children: _autocompleteResults
                        .map(
                          (place) => Column(
                            children: [
                              _SearchSuggestion(place: place),
                              if (place != _autocompleteResults.last)
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
}

class _SearchSuggestion extends StatelessWidget {
  final Place place;
  const _SearchSuggestion({required this.place});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => PlaceScreen(place: place)),
        );
      },
      child: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        child: Text(
          place.name,
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
