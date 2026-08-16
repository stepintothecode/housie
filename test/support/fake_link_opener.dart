import 'package:housie_bingo_caller/adapters/link_opener.dart';

/// Records the addresses asked for instead of opening them.
class FakeLinkOpener implements LinkOpener {
  FakeLinkOpener({this.succeeds = true});

  final bool succeeds;
  final List<String> opened = [];

  @override
  Future<bool> open(String url) async {
    opened.add(url);
    return succeeds;
  }
}
