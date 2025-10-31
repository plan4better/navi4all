import 'package:flutter/material.dart';
import 'package:smartroots/l10n/app_localizations.dart';
import 'package:smartroots/core/theme/colors.dart';
import 'package:smartroots/view/home/map.dart';
import 'package:smartroots/view/favourites/favourites.dart';
import 'package:smartroots/view/settings/settings.dart';
import 'package:smartroots/view/search/search.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<StatefulWidget> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _pageIndex = 0;
  List<Widget> get _pages => [
    HomeMap(),
    FavouritesScreen(_pageIndex == 1),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Stack(
            children: [
              Offstage(
                offstage: _pageIndex != 0,
                child: TickerMode(enabled: _pageIndex == 0, child: _pages[0]),
              ),
              Offstage(
                offstage: _pageIndex != 1,
                child: TickerMode(enabled: _pageIndex == 1, child: _pages[1]),
              ),
              Offstage(
                offstage: _pageIndex != 2,
                child: TickerMode(enabled: _pageIndex == 2, child: _pages[2]),
              ),
            ],
          ),
          _pageIndex <= 1
              ? SafeArea(
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: Padding(
                      padding: const EdgeInsets.only(
                        top: 32,
                        left: 16,
                        right: 16,
                      ),
                      child: Material(
                        elevation: _pageIndex == 0 ? 4 : 0,
                        borderRadius: BorderRadius.circular(28),
                        child: InkWell(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const SearchScreen(),
                              ),
                            );
                          },
                          child: Container(
                            height: 56,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(32),
                              color: _pageIndex == 0
                                  ? Theme.of(context).colorScheme.secondary
                                  : Theme.of(context).colorScheme.tertiary,
                            ),
                            child: Row(
                              children: [
                                SizedBox(width: 24),
                                const Icon(
                                  Icons.search,
                                  color: SmartRootsColors.maBlueExtraExtraDark,
                                ),
                                SizedBox(width: 16),
                                Expanded(
                                  child: Text(
                                    AppLocalizations.of(
                                      context,
                                    )!.homeSearchButtonHint,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color:
                                          SmartRootsColors.maBlueExtraExtraDark,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                )
              : Container(),
          SafeArea(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
                child: Material(
                  elevation: _pageIndex == 0 ? 4 : 0,
                  borderRadius: BorderRadius.circular(64),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(32)),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.all(Radius.circular(32)),
                      child: NavigationBar(
                        labelTextStyle:
                            WidgetStateProperty.resolveWith<TextStyle>((
                              states,
                            ) {
                              if (states.contains(WidgetState.selected)) {
                                return const TextStyle(
                                  color: SmartRootsColors.maBlueExtraExtraDark,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                );
                              }
                              return const TextStyle(
                                color: SmartRootsColors.maBlueExtraExtraDark,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              );
                            }),
                        backgroundColor: _pageIndex == 0
                            ? Theme.of(context).colorScheme.secondary
                            : Theme.of(context).colorScheme.tertiary,
                        selectedIndex: _pageIndex,
                        onDestinationSelected: (index) => setState(() {
                          _pageIndex = index;
                        }),
                        labelPadding: EdgeInsets.all(4),
                        height: 72,
                        destinations: [
                          NavigationDestination(
                            icon: Icon(
                              Icons.place_outlined,
                              color: SmartRootsColors.maBlueExtraExtraDark,
                            ),
                            selectedIcon: Icon(
                              Icons.place_rounded,
                              color: SmartRootsColors.maBlueExtraExtraDark,
                            ),
                            label: AppLocalizations.of(
                              context,
                            )!.homeNavigationMapTitle,
                          ),
                          NavigationDestination(
                            icon: Icon(
                              Icons.star_border,
                              color: SmartRootsColors.maBlueExtraExtraDark,
                            ),
                            selectedIcon: Icon(
                              Icons.star,
                              color: SmartRootsColors.maBlueExtraExtraDark,
                            ),
                            label: AppLocalizations.of(
                              context,
                            )!.homeNavigationFavouritesTitle,
                          ),
                          NavigationDestination(
                            icon: Icon(
                              Icons.settings_outlined,
                              color: SmartRootsColors.maBlueExtraExtraDark,
                            ),
                            selectedIcon: Icon(
                              Icons.settings,
                              color: SmartRootsColors.maBlueExtraExtraDark,
                            ),
                            label: AppLocalizations.of(
                              context,
                            )!.homeNavigationSettingsTitle,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
