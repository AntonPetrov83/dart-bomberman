import 'dart:html';
import 'dart:math';

class Tile {
  ImageElement image;
  num regionX, regionY, regionWidth, regionHeight;

  Tile(this.image, this.regionX, this.regionY, this.regionWidth,
      this.regionHeight);

  draw(CanvasRenderingContext2D context, num x, num y) {
    context.drawImageScaledFromSource(image, regionX, regionY, regionWidth,
        regionHeight, x, y, regionWidth, regionHeight);
  }

  drawScaled(
      CanvasRenderingContext2D context, num x, num y, num width, num height) {
    context.drawImageScaledFromSource(image, regionX, regionY, regionWidth,
        regionHeight, x, y, width, height);
  }
}

class Tileset {
  ImageElement image;
  int tileSize;
  int width, height;
  List<Tile> tiles;

  Tileset(this.image, this.tileSize) {
    tiles = [];
    width = (image.width / tileSize).floor();
    height = (image.height / tileSize).floor();

    for (int i = 0; i < height; ++i) {
      for (int j = 0; j < width; ++j) {
        var tile =
            new Tile(image, j * tileSize, i * tileSize, tileSize, tileSize);
        tiles.add(tile);
      }
    }
  }

  Tile getTile(num column, num row) {
    if (column < 0 || column >= width) throw new ArgumentError('column');
    if (row < 0 || row >= height) throw new ArgumentError('row');

    return tiles[row * width + column];
  }

  Tile getTileAtPoint(Point pt) {
    return getTile(pt.x, pt.y);
  }
}
