import 'package:flutter/material.dart';
import 'package:smartroots/l10n/app_localizations.dart';
import 'package:smartroots/core/theme/colors.dart';
import 'package:smartroots/view/place/place.dart';
import 'package:smartroots/schemas/routing/place.dart';
import 'package:smartroots/services/geocoding.dart';

class SearchScreen extends StatefulWidget {
  final bool isSecondarySearch;
  final bool isOriginPlaceSearch;

  const SearchScreen({
    super.key,
    this.isSecondarySearch = false,
    this.isOriginPlaceSearch = false,
  });

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
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
        focusPointLat: 49.487164933378104,
        focusPointLon: 8.46624749208,
        limit: 4,
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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: SmartRootsColors.maBackground,
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
                            color: SmartRootsColors.maBlue,
                            width: 1.5,
                          ),
                        )
                      : null,
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.arrow_back,
                        color: SmartRootsColors.maBlueExtraExtraDark,
                        semanticLabel: AppLocalizations.of(
                          context,
                        )!.commonBackButtonSemantic,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    Expanded(
                      child: Semantics(
                        label: widget.isOriginPlaceSearch
                            ? AppLocalizations.of(
                                context,
                              )!.searchTextFieldOriginHintSemantic
                            : AppLocalizations.of(
                                context,
                              )!.searchTextFieldDestinationHintSemantic,
                        excludeSemantics: true,
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
                          style: const TextStyle(fontSize: 16),
                          onChanged: (value) {
                            setState(() {
                              _showResults = value.trim().isNotEmpty;
                            });
                          },
                        ),
                      ),
                    ),
                    /* IconButton(
                      icon: Icon(
                        Icons.mic,
                        color: SmartRootsColors.maBlueExtraExtraDark,
                        semanticLabel: AppLocalizations.of(
                          context,
                        )!.commonMicButtonSemantic,
                      ),
                      onPressed: null,
                    ), */
                  ],
                ),
              ),
              !_showResults ? SizedBox(height: 64) : SizedBox.shrink(),
              _showResults
                  ? Container(
                      decoration: const BoxDecoration(
                        color: SmartRootsColors.maBackground,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(28),
                          bottomRight: Radius.circular(28),
                        ),
                      ),
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          final place = _autocompleteResults[index];
                          return _SearchSuggestion(
                            place: place,
                            onTap: () {
                              if (widget.isSecondarySearch) {
                                Navigator.of(context).pop(place);
                              } else {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        PlaceScreen(place: place),
                                  ),
                                );
                              }
                            },
                          );
                        },
                        separatorBuilder: (context, index) {
                          return const Divider(
                            height: 1,
                            indent: 12,
                            endIndent: 12,
                            color: SmartRootsColors.maBlue,
                          );
                        },
                        itemCount: _autocompleteResults.length,
                      ),
                    )
                  : Semantics(
                      excludeSemantics: true,
                      child: Column(
                        children: [
                          Icon(
                            Icons.search_rounded,
                            size: 96,
                            color: SmartRootsColors.maBlueLight,
                          ),
                          SizedBox(height: 16),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 32),
                            child: Text(
                              AppLocalizations.of(context)!.searchScreenPrompt,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                color: SmartRootsColors.maBlue,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
              const Spacer(),
              /*AccessibleButton(
                label: AppLocalizations.of(context)!.commonHomeScreenButton,
                style: AccessibleButtonStyle.pink,
                onTap: () =>
                    Navigator.of(context).popUntil((route) => route.isFirst),
              ),*/
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchSuggestion extends StatelessWidget {
  final Place place;
  final Function onTap;
  const _SearchSuggestion({required this.place, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onTap(),
      child: Semantics(
        focusable: true,
        focused: true,
        label: AppLocalizations.of(context)!.searchResultSemantic(
          place.name,
          place.locality != null ? "in ${place.locality}" : "",
        ),
        excludeSemantics: true,
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                place.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 16,
                  color: SmartRootsColors.maBlueExtraExtraDark,
                  fontWeight: FontWeight.bold,
                ),
              ),
              place.locality != null
                  ? Text(
                      place.locality!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: SmartRootsColors.maBlueExtraExtraDark,
                      ),
                    )
                  : const SizedBox.shrink(),
            ],
          ),
        ),
      ),
    );
  }
}
