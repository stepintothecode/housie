import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../adapters/link_opener.dart';
import '../../core/app_info.dart';
import '../theme/tokens.dart';
import '../widgets/full_house.dart';
import '../widgets/secret_tap.dart';
import '../widgets/settings_tiles.dart';

/// What this app is, what it promises, and how to chip in if you want to.
///
/// A page rather than a bare donate button: the promises below are the reason
/// the button is there at all.
class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key, required this.links});

  final LinkOpener links;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Scaffold(
      appBar: AppBar(title: const Text('About & support')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          Space.lg,
          Space.sm,
          Space.lg,
          Space.xxl,
        ),
        children: [
          const _Identity(),
          const SizedBox(height: Space.xl),
          _SupportButton(onPressed: () => _open(context, AppInfo.supportUrl)),
          const SizedBox(height: Space.md),
          Text(
            'A voluntary tip, not a purchase. It buys no features, no priority '
            'support and no say over the app. Opens in your browser.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: palette.muted,
              fontSize: 12.5,
              height: 1.45,
            ),
          ),
          const SizedBox(height: Space.xl),
          Container(
            padding: const EdgeInsets.all(Space.xl),
            decoration: BoxDecoration(
              color: palette.surface,
              borderRadius: BorderRadius.circular(Radii.card),
              border: Border.all(color: palette.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Free, and staying free',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: Space.md),
                Text(
                  'No ads. No tracking. No account. No paid version, and nothing '
                  'held back behind one.',
                  style: TextStyle(
                    color: palette.muted,
                    fontSize: 15,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: Space.lg),
                const _Promise(
                  icon: Icons.wifi_off_rounded,
                  text: 'Works with no internet at all',
                ),
                const _Promise(
                  icon: Icons.visibility_off_outlined,
                  text: 'Collects nothing, sends nothing',
                ),
                const _Promise(
                  icon: Icons.block_rounded,
                  text: 'Not a single advert, ever',
                ),
              ],
            ),
          ),
          const SizedBox(height: Space.xl),
          SettingsSection(
            title: 'More',
            children: [
              LinkRow(
                icon: Icons.star_outline_rounded,
                title: 'Rate the app',
                subtitle: 'A review helps more than a tip does.',
                onTap: () => _open(context, AppInfo.playStoreUrl),
              ),
              LinkRow(
                icon: Icons.code_rounded,
                title: 'Source code',
                subtitle: 'The whole app, open on GitHub.',
                onTap: () => _open(context, AppInfo.githubUrl),
              ),
              LinkRow(
                icon: Icons.play_circle_outline_rounded,
                // Same spelling as the publisher line above. Two versions of
                // one name on a single screen reads as a mistake.
                title: AppInfo.publisher,
                subtitle: 'Other things I build.',
                onTap: () => _open(context, AppInfo.youtubeUrl),
              ),
              LinkRow(
                icon: Icons.shield_outlined,
                title: 'Privacy',
                subtitle: 'The short version, in full.',
                onTap: () => _showPrivacy(context),
              ),
            ],
          ),
          const SizedBox(height: Space.xl),
          Text(
            '${AppInfo.name} ${AppInfo.version}',
            textAlign: TextAlign.center,
            style: TextStyle(color: palette.muted, fontSize: 12),
          ),
        ],
      ),
    );
  }

  /// Every link on this page goes through here, so a phone with no browser
  /// behaves the same way whichever one was tapped.
  Future<void> _open(BuildContext context, String url) async {
    if (await links.open(url)) return;
    if (!context.mounted) return;

    // Nothing took it. Hand the address over rather than appearing to do
    // nothing at all.
    final copied = await _copy(url);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          copied
              ? 'Could not open a browser. Link copied: $url'
              : 'Could not open a browser. The link is $url',
        ),
        duration: const Duration(seconds: 8),
      ),
    );
  }

  /// The clipboard is a platform call like any other and can refuse. The
  /// message above changes rather than the whole thing being abandoned.
  static Future<bool> _copy(String url) async {
    try {
      await Clipboard.setData(ClipboardData(text: url));
      return true;
    } catch (_) {
      return false;
    }
  }

  void _showPrivacy(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Privacy'),
        content: const Text(
          'This app collects nothing and sends nothing.\n\n'
          'It has no analytics, no crash reporting and no adverts. It never '
          'asks for an account. Your settings and the numbers called in the '
          'current game are stored on this phone only, and are deleted with '
          'the app.\n\n'
          'The only time it reaches the internet is when you tap a link on '
          'this page, which opens in your browser.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

/// Who made this and what it is called, with the same mark as the launcher.
class _Identity extends StatelessWidget {
  const _Identity();

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Row(
      children: [
        // Seven taps on the icon brings the house down. It looks like a
        // picture, which is the point.
        SecretTap(
          onUnlocked: () => FullHouse.celebrate(context),
          child: _tile(palette),
        ),
        const SizedBox(width: Space.lg),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(AppInfo.name, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 2),
              Text(
                AppInfo.publisher,
                style: TextStyle(color: palette.muted, fontSize: 14),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// The icon's own background is the same near-black as this page in dark
  /// mode, so without an outline the tile has no edge at all.
  Widget _tile(Palette palette) => Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(Radii.card),
      border: Border.all(color: palette.border),
    ),
    clipBehavior: Clip.antiAlias,
    child: Image.asset(
      AppInfo.iconAsset,
      width: _iconSize,
      height: _iconSize,
      // The source art is 1024px square and all flat colour, so it scales
      // down cleanly.
      filterQuality: FilterQuality.medium,
    ),
  );

  static const _iconSize = 64.0;
}

class _Promise extends StatelessWidget {
  const _Promise({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Padding(
      padding: const EdgeInsets.only(bottom: Space.md),
      child: Row(
        children: [
          Icon(icon, size: 20, color: palette.accent),
          const SizedBox(width: Space.md),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: palette.text, fontSize: 14.5),
            ),
          ),
        ],
      ),
    );
  }
}

class _SupportButton extends StatelessWidget {
  const _SupportButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Material(
      color: palette.accent,
      borderRadius: BorderRadius.circular(Radii.button),
      child: InkWell(
        borderRadius: BorderRadius.circular(Radii.button),
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: Space.xl,
            horizontal: Space.lg,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.favorite_rounded, color: palette.accentInk, size: 22),
              const SizedBox(width: Space.md),
              Text(
                'Support this app',
                style: TextStyle(
                  color: palette.accentInk,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: Space.sm),
              Icon(
                Icons.open_in_new_rounded,
                color: palette.accentInk,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
