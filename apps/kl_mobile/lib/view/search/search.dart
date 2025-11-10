import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:navi4all/controllers/autocomplete_controller.dart';
import 'package:navi4all/l10n/app_localizations.dart';
import 'package:navi4all/core/theme/colors.dart';
import 'package:navi4all/view/place/place.dart';
import 'package:navi4all/schemas/routing/place.dart';

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

  @override
  void initState() {
    super.initState();
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    resizeToAvoidBottomInset: false,
    body: SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
        child: ChangeNotifierProvider(
          create: (_) => AutocompleteController(),
          child: Consumer<AutocompleteController>(
            builder: (context, autocompleteController, _) => Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.tertiary,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(32),
                      topRight: const Radius.circular(32),
                      bottomLeft:
                          autocompleteController.searchResults.isNotEmpty
                          ? const Radius.circular(0)
                          : const Radius.circular(32),
                      bottomRight:
                          autocompleteController.searchResults.isNotEmpty
                          ? const Radius.circular(0)
                          : const Radius.circular(32),
                    ),
                    border: autocompleteController.searchResults.isNotEmpty
                        ? const Border(
                            bottom: BorderSide(
                              color: Navi4AllColors.klPink,
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
                          color: Navi4AllColors.klRed,
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
                              contentPadding: EdgeInsets.symmetric(
                                vertical: 16,
                              ),
                            ),
                            style: const TextStyle(fontSize: 16),
                            onChanged: (value) =>
                                Provider.of<AutocompleteController>(
                                  context,
                                  listen: false,
                                ).updateSearchQuery(value.trim()),
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
                autocompleteController.searchResults.isNotEmpty
                    ? const SizedBox.shrink()
                    : const SizedBox(height: 32),
                autocompleteController.searchResults.isNotEmpty
                    ? Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.tertiary,
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(32),
                            bottomRight: Radius.circular(32),
                          ),
                        ),
                        child: ListView.separated(
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            final place =
                                autocompleteController.searchResults[index];
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
                              color: Navi4AllColors.klPink,
                            );
                          },
                          itemCount:
                              autocompleteController.searchResults.length,
                        ),
                      )
                    : Semantics(
                        excludeSemantics: true,
                        child: Column(
                          children: [
                            Icon(
                              Icons.search_rounded,
                              size: 96,
                              color: Navi4AllColors.klPink,
                            ),
                            SizedBox(height: 16),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                              ),
                              child: Text(
                                AppLocalizations.of(
                                  context,
                                )!.searchScreenPrompt,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Navi4AllColors.klPink,
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
      ),
    ),
  );
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
                  color: Navi4AllColors.klRed,
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
                        color: Navi4AllColors.klRed,
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
