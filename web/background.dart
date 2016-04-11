import 'dart:html';
import 'dart:math';

import 'actor.dart';
import 'tileset.dart';

class BackgroundTile extends Actor {
  Tile tile;
  int bgx;
  int bgy;
}

class Background {
  int width, height;
  int tileSize;
  List<BackgroundTile> tiles;

  String clearStyle = 'black';

  Background(this.width, this.height, this.tileSize) {
    assert(width > 0);
    assert(height > 0);
    tiles = new List<BackgroundTile>(width * height);
  }

  bool isInside(int x, int y) {
    return (x >= 0) && (x < width) && (y >= 0) && (y < height);
  }

  BackgroundTile getTileAt(int x, int y) {
    assert(isInside(x, y));
    return tiles[y * width + x];
  }

  BackgroundTile getTileAtPoint(Point pt) {
    return getTileAt(pt.x, pt.y);
  }

  void setTileAt(int x, int y, BackgroundTile tile) {
    assert(isInside(x, y));
    tiles[y * width + x] = tile;
    if (tile != null) {
      tile.bgx = x;
      tile.bgy = y;
    }
  }

  void setTileAtPoint(Point pt, BackgroundTile tile) {
    setTileAt(pt.x, pt.y, tile);
  }

  void draw(CanvasRenderingContext2D ctx) {
    ctx.fillStyle = clearStyle;
    ctx.fillRect(0, 0, width * tileSize, height * tileSize);

    var n = 0;
    for (var y = 0; y < height; ++y) {
      for (var x = 0; x < width; ++x, ++n) {
        if (tiles[n] != null) {
          var tile = tiles[n].tile;
          if (tile != null) tile.draw(ctx, x * tileSize, y * tileSize);
        }
      }
    }
  }
}
