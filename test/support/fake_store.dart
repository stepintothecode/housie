import 'dart:convert';

import 'package:housie_bingo_caller/adapters/store.dart';

/// Holds values in memory, round-tripped through JSON so a test fails on
/// anything the real store could not have encoded.
class FakeStore implements Store {
  FakeStore([Map<String, Map<String, Object?>>? seed]) {
    seed?.forEach((key, value) => _values[key] = _encoded(value));
  }

  final Map<String, Map<String, Object?>> _values = {};

  int writes = 0;

  @override
  Map<String, Object?>? read(String key) => _values[key];

  @override
  Future<void> write(String key, Map<String, Object?> value) async {
    writes++;
    _values[key] = _encoded(value);
  }

  @override
  Future<void> remove(String key) async => _values.remove(key);

  /// Puts a raw value in place without going through [write], for testing
  /// what happens when storage holds something unreadable.
  void seedRaw(String key, Map<String, Object?> value) => _values[key] = value;

  static Map<String, Object?> _encoded(Map<String, Object?> value) =>
      jsonDecode(jsonEncode(value)) as Map<String, Object?>;
}
