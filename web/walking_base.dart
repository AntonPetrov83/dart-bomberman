import 'dart:math';

import 'background.dart';
import 'game.dart';
import 'level.dart';
import 'sprite.dart';

enum Direction { none, up, right, down, left }

class WalkingBase extends Sprite {
  Game get game => (level as Level).game;

  int get backgroundX => (x / level.tileSize).round();
  int get backgroundY => (y / level.tileSize).round();

  num get perfectX => backgroundX * level.tileSize;
  num get perfectY => backgroundY * level.tileSize;

  // Overridable.
  bool isBlockedByTile(BackgroundTile tile) {
    return tile != null;
  }

  bool walkTo(Direction direction, num dist) {
    switch (direction) {
      case Direction.up:
        return moveY(-dist);

      case Direction.down:
        return moveY(dist);

      case Direction.left:
        return moveX(-dist);

      case Direction.right:
        return moveX(dist);

      default:
        return true;
    }
  }

  bool moveX(num dx) {
    var prevx = x;
    var nx = x + dx;
    if (dx < 0) {
      if (isBlockedByTile(getAnotherBlockAt(nx, y + 8))) {
        if (!isBlockedByTile(getAnotherBlockAt(x, y + 8))) x = perfectX;
        return false;
      }
    } else {
      if (isBlockedByTile(getAnotherBlockAt(nx + 16, y + 8))) {
        if (!isBlockedByTile(getAnotherBlockAt(x + 16, y + 8))) x = perfectX;
        return false;
      }
    }

    x = nx;

    // Cut corners and auto align along axis Y;
    if (y < perfectY) {
      y = min(y + dx.abs(), perfectY);
    } else if (y > perfectY) {
      y = max(y - dx.abs(), perfectY);
    }

    // Notify when reached a new cell.
    if (dx < 0) {
      if (prevx >= perfectX && x < perfectX) reachedCell();
    } else {
      if (prevx < perfectX && x >= perfectX) reachedCell();
    }

    return true;
  }

  bool moveY(num dy) {
    var prevy = y;
    var ny = y + dy;
    if (dy < 0) {
      if (isBlockedByTile(getAnotherBlockAt(x + 8, ny))) {
        if (!isBlockedByTile(getAnotherBlockAt(x + 8, y))) y = perfectY;
        return false;
      }
    } else {
      if (isBlockedByTile(getAnotherBlockAt(x + 8, ny + 16))) {
        if (!isBlockedByTile(getAnotherBlockAt(x + 8, y + 16))) y = perfectY;
        return false;
      }
    }

    y = ny;

    // Cut corners and auto align along axis X;
    if (x < perfectX) {
      x = min(x + dy.abs(), perfectX);
    } else if (x > perfectX) {
      x = max(x - dy.abs(), perfectX);
    }

    // Notify when reached a new cell.
    if (dy < 0) {
      if (prevy >= perfectY && y < perfectY) reachedCell();
    } else {
      if (prevy < perfectY && y >= perfectY) reachedCell();
    }

    return true;
  }

  void reachedCell() {}

  bool isBlockedByNeighbourTileAt(int dx, int dy) {
    return isBlockedByTile(getNeighbourTile(dx, dy));
  }

  BackgroundTile getNeighbourTile(int dx, int dy) {
    var bgx = backgroundX;
    var bgy = backgroundY;
    return level.bg.isInside(bgx + dx, bgy + dy)
        ? level.bg.getTileAt(bgx + dx, bgy + dy)
        : null;
  }

  BackgroundTile getAnotherBlockAt(int nx, int ny) {
    var ax = nx ~/ level.tileSize;
    var ay = ny ~/ level.tileSize;
    if (backgroundX == ax && backgroundY == ay) return null;
    return level.bg.isInside(ax, ay) ? level.bg.getTileAt(ax, ay) : null;
  }
}
