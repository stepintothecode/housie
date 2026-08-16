import 'package:url_launcher/url_launcher.dart';

/// Opens a web address outside the app.
///
/// Always the real browser, never an in-app web view. Apple requires
/// donations to be collected outside the app, and an external browser is also
/// the only place the address bar proves where the money is going.
abstract class LinkOpener {
  /// Returns false if no browser would take it, so the screen can offer the
  /// address to copy instead of appearing to do nothing.
  Future<bool> open(String url);
}

class BrowserLinkOpener implements LinkOpener {
  @override
  Future<bool> open(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return false;
    try {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      return false;
    }
  }
}
