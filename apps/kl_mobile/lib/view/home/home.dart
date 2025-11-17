import 'package:flutter/material.dart';
// import 'package:matomo_tracker/matomo_tracker.dart';
import 'package:navi4all/view/search/search.dart';
import 'package:navi4all/view/favourites/favorites.dart';
import 'package:navi4all/view/settings/settings.dart';
// import 'package:navi4all/core/analytics/events.dart';
import 'package:navi4all/l10n/app_localizations.dart';
import 'package:navi4all/view/home/map.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<StatefulWidget> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _pageIndex = 0;
  List<Widget> get _pages => [HomeMap(), FavoritesScreen(), SettingsScreen()];

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
                child: Padding(
                  padding: const EdgeInsets.only(top: 64.0),
                  child: TickerMode(enabled: _pageIndex == 1, child: _pages[1]),
                ),
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

                            // Analytics event
                            /* MatomoTracker.instance.trackEvent(
                              eventInfo: EventInfo(
                                category: EventCategory.homeMapScreen
                                    .toString(),
                                action: EventAction.homeMapScreenSearchClicked
                                    .toString(),
                              ),
                            ); */
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
                                Icon(
                                  Icons.search,
                                  color: Theme.of(
                                    context,
                                  ).textTheme.displayMedium?.color,
                                ),
                                SizedBox(width: 16),
                                Expanded(
                                  child: Text(
                                    AppLocalizations.of(
                                      context,
                                    )!.homeSearchButtonHint,
                                    style: const TextStyle(fontSize: 16),
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
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                );
                              }
                              return const TextStyle(
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
                              color: Theme.of(
                                context,
                              ).textTheme.displayMedium?.color,
                            ),
                            selectedIcon: Icon(
                              Icons.place_rounded,
                              color: Theme.of(
                                context,
                              ).textTheme.displayMedium?.color,
                            ),
                            label: AppLocalizations.of(
                              context,
                            )!.homeNavigationMapTitle,
                          ),
                          NavigationDestination(
                            icon: Icon(
                              Icons.star_border,
                              color: Theme.of(
                                context,
                              ).textTheme.displayMedium?.color,
                            ),
                            selectedIcon: Icon(
                              Icons.star,
                              color: Theme.of(
                                context,
                              ).textTheme.displayMedium?.color,
                            ),
                            label: AppLocalizations.of(
                              context,
                            )!.homeNavigationFavouritesTitle,
                          ),
                          NavigationDestination(
                            icon: Icon(
                              Icons.settings_outlined,
                              color: Theme.of(
                                context,
                              ).textTheme.displayMedium?.color,
                            ),
                            selectedIcon: Icon(
                              Icons.settings,
                              color: Theme.of(
                                context,
                              ).textTheme.displayMedium?.color,
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
