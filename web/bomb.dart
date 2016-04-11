import 'dart:html';
import 'dart:math';

import 'actor.dart';
import 'background.dart';
import 'door.dart';
import 'explosion.dart';
import 'wall.dart';

class Bomb extends BackgroundTile implements Updatable {
  static List<Point> anim = [
    new Point(6, 2),
    new Point(6, 1),
    new Point(6, 3),
    new Point(6, 1)
  ];

  int radius;
  num lifetime;
  num time = 0;
  num frame = 0;
  bool exploded = false;

  Bomb({this.radius: 1, this.lifetime: 0}) {}

  @override
  void update(num dt) {
    updateAnimation(dt);

    if (lifetime > 0) {
      time += dt;
      if (time >= lifetime) explode();
    }
  }

  void updateAnimation(num dt) {
    frame += dt * 3;
    var idx = frame.floor() % anim.length;
    tile = level.tileset.getTileAtPoint(anim[idx]);
  }

  void explode() {
    exploded = true;

    // center.
    level.addBackgroundTile(bgx, bgy, new Explosion(ExplosionStyle.center));

    // west ray.
    for (int r = 1; r <= radius; ++r) {
      if (explodeTileAt(bgx - r, bgy)) break;
      level.addBackgroundTile(
          bgx - r,
          bgy,
          new Explosion(
              (r == radius) ? ExplosionStyle.west : ExplosionStyle.horizontal));
    }

    // east ray.
    for (int r = 1; r <= radius; ++r) {
      if (explodeTileAt(bgx + r, bgy)) break;
      level.addBackgroundTile(
          bgx + r,
          bgy,
          new Explosion(
              (r == radius) ? ExplosionStyle.east : ExplosionStyle.horizontal));
    }

    // north ray.
    for (int r = 1; r <= radius; ++r) {
      if (explodeTileAt(bgx, bgy - r)) break;
      level.addBackgroundTile(
          bgx,
          bgy - r,
          new Explosion(
              (r == radius) ? ExplosionStyle.north : ExplosionStyle.vertical));
    }

    // south ray.
    for (int r = 1; r <= radius; ++r) {
      if (explodeTileAt(bgx, bgy + r)) break;
      level.addBackgroundTile(
          bgx,
          bgy + r,
          new Explosion(
              (r == radius) ? ExplosionStyle.south : ExplosionStyle.vertical));
    }

    remove();
  }

  bool explodeTileAt(int x, int y) {
    var tile = level.bg.getTileAt(x, y);
    if (tile == null) return false;

    if (tile is Bomb) {
      (tile as Bomb).explode();
    } else if (tile is Wall) {
      (tile as Wall).explode();
    } else if (tile is Door) {
      (tile as Door).explode();
    }
    return true;
  }
}
