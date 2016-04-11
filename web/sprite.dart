import 'dart:html';

import 'actor.dart';
import 'tileset.dart';

class Sprite extends Actor implements Drawable {
  num x, y;
  Tile tile;
  num get width => (tile == null) ? 0 : tile.regionWidth;
  num get height => (tile == null) ? 0 : tile.regionHeight;
  num get top => y;
  num get bottom => y + height;
  num get left => x;
  num get right => x + width;

  Point get position => new Point(x, y);

  void set position(Point pt) {
    x = pt.x;
    y = pt.y;
  }

  @override
  void draw(CanvasRenderingContext2D context) {
    if (tile != null) tile.draw(context, x.round(), y.round());
  }

  bool collidesWithSprite(Sprite other) {
    return (other != null) &&
        (x <= other.right) &&
        (y <= other.bottom) &&
        (right >= other.x) &&
        (bottom >= other.y);
  }

  bool overlapsSprite(Sprite other, num overlap) {
    return (other != null) &&
        ((x + 2 * overlap) <= other.right) &&
        ((y + 2 * overlap) <= other.bottom) &&
        ((right - 2 * overlap) >= other.x) &&
        ((bottom - 2 * overlap) >= other.y);
  }
}
