import 'dart:math';

import 'game_mode.dart';

/// One game in progress: which numbers have been called, and in what order.
///
/// Immutable. Every move returns a new state, or null when the move is not
/// possible, so a caller never has to guess whether anything happened.
class CallerState {
  CallerState({required this.mode, List<int> drawn = const []})
    : drawn = List.unmodifiable(drawn),
      _drawnSet = Set.unmodifiable(drawn);

  final GameMode mode;

  /// Call order, oldest first. The last entry is the number on screen.
  final List<int> drawn;

  /// Same numbers as [drawn], kept for the board's 90 lookups per rebuild.
  final Set<int> _drawnSet;

  /// The number showing now, or null before the first draw.
  int? get current => drawn.isEmpty ? null : drawn.last;

  int get calledCount => drawn.length;

  int get remainingCount => mode.maxNumber - drawn.length;

  bool get isComplete => remainingCount == 0;

  bool get isFresh => drawn.isEmpty;

  bool wasCalled(int number) => _drawnSet.contains(number);

  /// Most recent first, newest call at index 0.
  List<int> get recent => drawn.reversed.toList(growable: false);

  /// Draws one number that has not come up yet.
  ///
  /// Returns null once every number is called, rather than a state that
  /// silently did nothing.
  CallerState? draw(Random random) {
    if (isComplete) return null;
    final pool = [
      for (var n = 1; n <= mode.maxNumber; n++)
        if (!_drawnSet.contains(n)) n,
    ];
    final picked = pool[random.nextInt(pool.length)];
    return CallerState(mode: mode, drawn: [...drawn, picked]);
  }

  /// Takes back the last call. Returns null when there is nothing to undo.
  CallerState? undo() {
    if (drawn.isEmpty) return null;
    return CallerState(mode: mode, drawn: drawn.sublist(0, drawn.length - 1));
  }

  /// An empty game in the same mode.
  CallerState reset() => CallerState(mode: mode);

  /// Switches range. Always starts a fresh game, because calls from a 1-90
  /// game are meaningless on a 1-75 board.
  CallerState withMode(GameMode next) =>
      next == mode ? this : CallerState(mode: next);

  Map<String, Object?> toJson() => {'mode': mode.id, 'drawn': drawn};

  /// Rebuilds a saved game. Returns null if the data is missing, from an
  /// unknown mode, or holds numbers the mode cannot produce.
  static CallerState? fromJson(Map<String, Object?>? json) {
    if (json == null) return null;
    final rawMode = json['mode'];
    // Checked rather than cast: a cast would throw on a value of the wrong
    // type, and this runs before the first frame.
    final mode = GameMode.fromId(rawMode is String ? rawMode : null);
    if (mode == null) return null;

    final raw = json['drawn'];
    if (raw is! List) return null;

    final drawn = <int>[];
    final seen = <int>{};
    for (final entry in raw) {
      final number = entry is int ? entry : int.tryParse('$entry');
      if (number == null) return null;
      if (number < 1 || number > mode.maxNumber) return null;
      if (!seen.add(number)) return null;
      drawn.add(number);
    }
    return CallerState(mode: mode, drawn: drawn);
  }
}
