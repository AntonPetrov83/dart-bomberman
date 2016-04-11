import 'dart:html';
import 'dart:math';

import 'actor.dart';
import 'background.dart';

enum ExplosionStyle {
  center,
  vertical,
  north,
  south,
  horizontal,
  east,
  west,
  wall
}

class Explosion extends BackgroundTile implements Updatable {
  static Map<ExplosionStyle, List<Point>> animations = {
    ExplosionStyle.center: [
      new Point(15, 1),
      new Point(15, 2),
      new Point(15, 3),
      new Point(15, 4),
      new Point(15, 3),
      new Point(15, 2),
      new Point(15, 1),
    ],
    ExplosionStyle.vertical: [
      new Point(7, 2),
      new Point(8, 2),
      new Point(9, 2),
      new Point(10, 2),
      new Point(9, 2),
      new Point(8, 2),
      new Point(7, 2),
    ],
    ExplosionStyle.north: [
      new Point(7, 1),
      new Point(8, 1),
      new Point(9, 1),
      new Point(10, 1),
      new Point(9, 1),
      new Point(8, 1),
      new Point(7, 1),
    ],
    ExplosionStyle.south: [
      new Point(7, 3),
      new Point(8, 3),
      new Point(9, 3),
      new Point(10, 3),
      new Point(9, 3),
      new Point(8, 3),
      new Point(7, 3),
    ],
    ExplosionStyle.horizontal: [
      new Point(11, 2),
      new Point(12, 2),
      new Point(13, 2),
      new Point(14, 2),
      new Point(13, 2),
      new Point(12, 2),
      new Point(11, 2),
    ],
    ExplosionStyle.west: [
      new Point(11, 1),
      new Point(12, 1),
      new Point(13, 1),
      new Point(14, 1),
      new Point(13, 1),
      new Point(12, 1),
      new Point(11, 1),
    ],
    ExplosionStyle.east: [
      new Point(11, 3),
      new Point(12, 3),
      new Point(13, 3),
      new Point(14, 3),
      new Point(13, 3),
      new Point(12, 3),
      new Point(11, 3),
    ],
    ExplosionStyle.wall: [
      new Point(3, 0),
      new Point(4, 0),
      new Point(5, 0),
      new Point(6, 0),
      new Point(7, 0),
      new Point(8, 0),
    ]
  };

  List<Point> anim;
  num frame = 0;

  Explosion(ExplosionStyle style) {
    anim = animations[style];
  }

  @override
  void update(num dt) {
    frame += dt * 10;
    var idx = frame.floor();
    if (idx >= anim.length) {
      remove();
    } else {
      tile = level.tileset.getTileAtPoint(anim[idx]);
    }
  }
}
