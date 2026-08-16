import 'package:flutter/material.dart';

import '../../adapters/link_opener.dart';
import '../game_controller.dart';
import '../orientation_controller.dart';
import '../settings_controller.dart';
import '../theme/tokens.dart';
import 'game_screen.dart';
import 'settings_screen.dart';
import 'support_screen.dart';

/// The three tabs. Game is where the app opens and where it stays.
///
/// Portrait puts them along the bottom. Landscape puts them in a rail down the
/// right hand edge, next to the controls, rather than eating one of the few
/// rows of height a sideways phone has.
class HomeShell extends StatefulWidget {
  const HomeShell({
    super.key,
    required this.game,
    required this.settings,
    required this.orientation,
    required this.links,
  });

  final GameController game;
  final SettingsController settings;
  final OrientationController orientation;
  final LinkOpener links;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

/// One definition, used to build both the bar and the rail.
const _destinations = [
  (icon: Icons.casino_outlined, active: Icons.casino_rounded, label: 'Game'),
  (icon: Icons.tune_outlined, active: Icons.tune_rounded, label: 'Settings'),
  (
    icon: Icons.favorite_outline_rounded,
    active: Icons.favorite_rounded,
    label: 'Support',
  ),
];

class _HomeShellState extends State<HomeShell> {
  int _tab = 0;

  void _select(int index) => setState(() => _tab = index);

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final landscape =
        MediaQuery.orientationOf(context) == Orientation.landscape;

    // Only the visible tab is built. An IndexedStack would keep all three
    // alive and lay all three out again on every rotation, which is three
    // times the work for two screens nobody is looking at. The game itself
    // lives in the controller, not in the widget, so nothing is lost by
    // rebuilding it.
    final pages = switch (_tab) {
      0 => GameScreen(game: widget.game, orientation: widget.orientation),
      1 => SettingsScreen(settings: widget.settings, game: widget.game),
      _ => SupportScreen(links: widget.links),
    };

    if (!landscape) {
      return Scaffold(
        body: pages,
        bottomNavigationBar: NavigationBar(
          selectedIndex: _tab,
          onDestinationSelected: _select,
          destinations: [
            for (final d in _destinations)
              NavigationDestination(
                icon: Icon(d.icon),
                selectedIcon: Icon(d.active),
                label: d.label,
              ),
          ],
        ),
      );
    }

    return Scaffold(
      body: Row(
        children: [
          Expanded(child: pages),
          VerticalDivider(width: 1, thickness: 1, color: palette.border),
          NavigationRail(
            selectedIndex: _tab,
            onDestinationSelected: _select,
            labelType: NavigationRailLabelType.all,
            groupAlignment: 0,
            destinations: [
              for (final d in _destinations)
                NavigationRailDestination(
                  icon: Icon(d.icon),
                  selectedIcon: Icon(d.active),
                  label: Text(d.label),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
