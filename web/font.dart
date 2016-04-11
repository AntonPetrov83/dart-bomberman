import 'dart:html';

import 'tileset.dart';

class Font {
  Tileset _tileset;
  Map<int, Tile> _codeUnits;

  int get charWidth => _tileset.tileSize;
  int get charHeight => _tileset.tileSize;

  Font(this._tileset) {
    _codeUnits = new Map<int, Tile>();

    for (int i = 0; i < 10; ++i)
      _codeUnits['0'.codeUnitAt(0) + i] = _tileset.getTile(i, 0);

    for (int i = 0; i < 26; ++i)
      _codeUnits['A'.codeUnitAt(0) + i] =
          _tileset.getTile((1 + i) % 16, 1 + (1 + i) ~/ 16);
  }

  void drawText(CanvasRenderingContext2D ctx, int x, int y, String text) {
    if (text.isEmpty) return;
    for (var c in text.codeUnits) {
      var tile = _codeUnits[c];
      if (tile != null) tile.draw(ctx, x, y);
      x += charWidth;
    }
  }
}
