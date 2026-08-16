import 'package:housie_bingo_caller/adapters/device.dart';
import 'package:housie_bingo_caller/core/settings.dart';

/// Counts what the app asked the handset to do.
class FakeDevice implements Device {
  int taps = 0;
  int thuds = 0;
  bool awake = false;
  OrientationLock lock = OrientationLock.auto;

  /// Every lock asked for, in order.
  final List<OrientationLock> lockCalls = [];

  /// Every keepAwake call in order, so a test can prove the screen was not
  /// held on and off repeatedly.
  final List<bool> wakeCalls = [];

  @override
  Future<void> tap() async => taps++;

  @override
  Future<void> thud() async => thuds++;

  @override
  Future<void> keepAwake(bool on) async {
    awake = on;
    wakeCalls.add(on);
  }

  @override
  Future<void> lockOrientation(OrientationLock next) async {
    lock = next;
    lockCalls.add(next);
  }
}
