import 'package:flutter/foundation.dart';

import '../adapters/device.dart';
import '../core/settings.dart';

/// Which way up the app is pinned, for people whose handset has auto rotate
/// switched off.
///
/// One button drives this, and it has two moves rather than three: from auto
/// it pins whichever way you are not currently facing, and from pinned it
/// lets go. So a tap turns the app sideways and another tap turns it back,
/// which is the whole point, while anyone who does have auto rotate on still
/// gets their handset's behaviour by default.
class OrientationController extends ChangeNotifier {
  OrientationController({required Device device}) : _device = device;

  final Device _device;

  OrientationLock _lock = OrientationLock.auto;
  OrientationLock get lock => _lock;

  /// [showingWide] is what is on screen right now, which is the only way to
  /// know which orientation "the other one" is.
  Future<void> toggle({required bool showingWide}) {
    return _apply(
      _lock.isLocked
          ? OrientationLock.auto
          : (showingWide
                ? OrientationLock.portrait
                : OrientationLock.landscape),
    );
  }

  Future<void> _apply(OrientationLock next) async {
    if (next == _lock) return;
    _lock = next;
    notifyListeners();
    await _device.lockOrientation(next);
  }
}
