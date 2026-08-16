/// The two number ranges the caller supports.
///
/// Housie (also Tambola) draws 1-90. Bingo draws 1-75 and groups numbers into
/// five lettered columns.
enum GameMode {
  housie90(
    id: 'housie90',
    label: 'Housie',
    range: '1-90',
    maxNumber: 90,
    columns: 10,
  ),
  bingo75(
    id: 'bingo75',
    label: 'Bingo',
    range: '1-75',
    maxNumber: 75,
    columns: 5,
  );

  const GameMode({
    required this.id,
    required this.label,
    required this.range,
    required this.maxNumber,
    required this.columns,
  });

  /// Stable key written to storage. Never change these.
  final String id;

  final String label;
  final String range;
  final int maxNumber;

  /// How many cells the board lays out per row.
  ///
  /// Housie reads left to right in rows of ten. Bingo reads down five lettered
  /// columns, so a phone shows all 75 without squeezing cells to nothing.
  final int columns;

  String get title => '$label $range';

  /// Letter above a bingo number, or null in housie which has no columns.
  ///
  /// 1-15 -> B, 16-30 -> I, 31-45 -> N, 46-60 -> G, 61-75 -> O
  String? letterFor(int number) {
    if (this != bingo75) return null;
    if (number < 1 || number > maxNumber) return null;
    return _bingoLetters[(number - 1) ~/ 15];
  }

  /// How to arrange the board on a screen of this shape.
  ///
  /// A sideways screen is wide and short, so a board that works upright has
  /// to be turned on its side to stay on one screen. Bingo's five letters
  /// head the columns upright and the rows sideways; it is the same board
  /// either way, transposed.
  BoardLayout layout({required bool wide}) => switch (this) {
    housie90 => BoardLayout._(
      mode: this,
      columns: columns,
      numbersRunDown: false,
    ),
    bingo75 =>
      wide
          ? BoardLayout._(
              mode: this,
              columns: 15,
              numbersRunDown: false,
              rowLabels: _bingoLetters,
            )
          : BoardLayout._(
              mode: this,
              columns: columns,
              numbersRunDown: true,
              columnLabels: _bingoLetters,
            ),
  };

  /// How a called number reads on screen: `47` in housie, `G 47` in bingo.
  String display(int number) {
    final letter = letterFor(number);
    return letter == null ? '$number' : '$letter $number';
  }

  /// Reads an id written by a previous run. Returns null if unrecognised, so
  /// the caller decides on the fallback rather than getting a wrong mode.
  static GameMode? fromId(String? id) {
    for (final mode in values) {
      if (mode.id == id) return mode;
    }
    return null;
  }

  static const _bingoLetters = ['B', 'I', 'N', 'G', 'O'];
}

/// One arrangement of a mode's numbers into a grid.
///
/// Pure geometry: which number sits in which cell, and what the edges are
/// labelled. Nothing here knows how tall a cell ends up on screen, which is
/// the widget's job.
class BoardLayout {
  const BoardLayout._({
    required this.mode,
    required this.columns,
    required this.numbersRunDown,
    this.columnLabels = const [],
    this.rowLabels = const [],
  });

  final GameMode mode;
  final int columns;

  /// True when consecutive numbers go down a column rather than across a row.
  final bool numbersRunDown;

  /// Letters across the top, or empty.
  final List<String> columnLabels;

  /// Letters down the left, or empty.
  final List<String> rowLabels;

  int get rows => mode.maxNumber ~/ columns;

  int get cellCount => mode.maxNumber;

  /// The number in cell [index], counting left to right, top to bottom.
  /// Returns null outside the board.
  int? numberAt(int index) {
    if (index < 0 || index >= mode.maxNumber) return null;
    if (!numbersRunDown) return index + 1;
    return (index % columns) * rows + index ~/ columns + 1;
  }
}
