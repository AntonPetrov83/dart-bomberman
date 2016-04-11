import 'dart:html';
import 'dart:math';

import 'actor.dart';
import 'bomber.dart';
import 'background.dart';
import 'door.dart';
import 'item.dart';
import 'explosion.dart';
import 'level.dart';
import 'walking_base.dart';
import 'wall.dart';

abstract class Enemy extends WalkingBase implements Updatable {
  static const int valcom = 1;
  static const int oneal = 2;
  static const int dahl = 3;
  static const int minvo = 4;
  static const int ovape = 5;
  static const int doria = 6;
  static const int pass = 7;
  static const int pontan = 8;

  Random _rnd;
  bool dead = false;
  bool changingDirection = false;
  num frame = 0;
  Direction direction;
  num straightDistance = 0;
  List<Point> anim;

  List<Point> get animWalkingLeft;
  List<Point> get animWalkingRight;
  List<Point> get animDeath;

  num get speed;

  Bomber get bomber => (level as Level).bomber;

  Enemy() {
    anim = animWalkingLeft;
    direction = Direction.none;
  }

  @override
  bool isBlockedByTile(BackgroundTile tile) {
    if (tile == null || tile is Door || tile is Item) return false;
    if (!changingDirection && tile is Explosion) return false;
    return true;
  }

  @override
  void start() {
    super.start();
    _rnd = (level as Level).rnd;
  }

  @override
  void update(num dt) {
    if (dead) {
      updateDeath(dt);
    } else {
      updateMovement(dt);
      checkExplosionCollision();
      checkPlayerCollision();
      updateAnimation(dt);
    }
  }

  @override
  void reachedCell() {
    var prevDirection = direction;
    straightDistance++;

    var changed = false;
    if (_rnd.nextInt(100) < changeDirectionWill) changed = changeDirection();

    if (!changed && (_rnd.nextInt(100) < bomberPursuitWill))
      changed = persueBomber();

    if (prevDirection != direction) {
      straightDistance = 0;
      directionChanged();
    }
  }

  void checkPlayerCollision() {
    if (game.invulnerability) return;
    var bomber = (level as Level).bomber;
    if (overlapsSprite(bomber, 4)) bomber.die();
  }

  void checkExplosionCollision() {
    if (getNeighbourTile(0, 0) is Explosion) die();
  }

  void updateMovement(num dt) {
    // TODO: not every frame.
    if (direction == Direction.none) {
      changeDirection();
    } else if (!walkTo(direction, dt * speed)) {
      changeDirection();
    }
  }

  void updateAnimation(num dt) {
    frame += dt * 3;
    if (anim == null) return;
    var idx = frame.floor() % anim.length;
    tile = level.tileset.getTileAtPoint(anim[idx]);
  }

  num get distanceToBomber => max((backgroundX - bomber.backgroundX).abs(),
      (backgroundY - bomber.backgroundY).abs());

  num get changeDirectionWill => 0;

  num get bomberPursuitWill => 0;

  num get avoidBombsWill => 0;

  bool changeDirection() {
    var prev = direction;
    changingDirection = true;
    direction = randomizeDirection();
    directionChanged();
    changingDirection = false;
    return prev != direction;
  }

  void directionChanged() {
    if (direction == Direction.left) {
      anim = animWalkingLeft;
    } else if (direction == Direction.right) {
      anim = animWalkingRight;
    }
  }

  Direction randomizeDirection() {
    var n = (level as Level).rnd.nextInt(4);
    for (var i = 0; i < 4; ++i) {
      switch ((n + i) % 4) {
        case 0:
          if (!isBlockedByNeighbourTileAt(0, -1)) return Direction.up;
          break;

        case 1:
          if (!isBlockedByNeighbourTileAt(0, 1)) return Direction.down;
          break;

        case 2:
          if (!isBlockedByNeighbourTileAt(-1, 0)) return Direction.left;
          break;

        case 3:
          if (!isBlockedByNeighbourTileAt(1, 0)) return Direction.right;
          break;
      }
    }
    return Direction.none;
  }

  bool persueBomber() {
    if ((bomber.backgroundX - backgroundX).abs() <
        (bomber.backgroundY - backgroundY).abs()) {
      return persueBomberX() || persueBomberY();
    } else {
      return persueBomberY() || persueBomberX();
    }
  }

  bool persueBomberX() {
    if ((bomber.backgroundX < backgroundX) &&
        !isBlockedByNeighbourTileAt(-1, 0)) {
      direction = Direction.left;
      return true;
    }

    if ((bomber.backgroundX > backgroundX) &&
        !isBlockedByNeighbourTileAt(1, 0)) {
      direction = Direction.right;
      return true;
    }

    return false;
  }

  bool persueBomberY() {
    if ((bomber.backgroundY < backgroundY) &&
        !isBlockedByNeighbourTileAt(0, -1)) {
      direction = Direction.up;
      return true;
    }

    if ((bomber.backgroundY < backgroundY) &&
        !isBlockedByNeighbourTileAt(0, -1)) {
      direction = Direction.down;
      return true;
    }

    return false;
  }

  void updateDeath(num dt) {
    frame += dt * 3;
    if (anim == null) return;
    var idx = frame.floor();
    if (idx >= anim.length) {
      game.enemyKilled(Enemy.valcom);
      remove();
    } else
      tile = level.tileset.getTileAtPoint(anim[idx]);
  }

  void die() {
    dead = true;
    frame = 0;
    anim = animDeath;
  }
}

// The very first enemy.
class Valcom extends Enemy {
  static final List<Point> _animWalkingLeft = [
    new Point(0, 4),
    new Point(1, 4),
    new Point(2, 4),
    new Point(1, 4),
  ];
  static final List<Point> _animWalkingRight = [
    new Point(3, 4),
    new Point(4, 4),
    new Point(5, 4),
    new Point(4, 4),
  ];
  static final List<Point> _animDeath = [
    new Point(6, 4),
    new Point(6, 4),
    new Point(6, 4),
    new Point(6, 4),
    new Point(6, 4),
    new Point(7, 4),
    new Point(8, 4),
    new Point(9, 4),
    new Point(10, 4),
  ];

  @override
  List<Point> get animWalkingLeft => _animWalkingLeft;

  @override
  List<Point> get animWalkingRight => _animWalkingRight;

  @override
  List<Point> get animDeath => _animDeath;

  @override
  num get speed => 24;

  @override
  num get changeDirectionWill =>
      (straightDistance > 3) ? straightDistance * 5 : 0;

  @override
  num get bomberPursuitWill => (distanceToBomber <= 6)
      ? 30
      : 0; // seesBomber ? 50 : distanceToBomber * 5;
}

class Oneal extends Enemy {
  static final List<Point> _animWalkingLeft = [
    new Point(0, 5),
    new Point(1, 5),
    new Point(2, 5),
    new Point(1, 5),
  ];
  static final List<Point> _animWalkingRight = [
    new Point(3, 5),
    new Point(4, 5),
    new Point(5, 5),
    new Point(4, 5),
  ];
  static final List<Point> _animDeath = [
    new Point(6, 5),
    new Point(6, 5),
    new Point(6, 5),
    new Point(6, 5),
    new Point(6, 5),
    new Point(7, 4),
    new Point(8, 4),
    new Point(9, 4),
    new Point(10, 4),
  ];

  @override
  List<Point> get animWalkingLeft => _animWalkingLeft;

  @override
  List<Point> get animWalkingRight => _animWalkingRight;

  @override
  List<Point> get animDeath => _animDeath;

  @override
  num get speed => 32;

  @override
  num get changeDirectionWill =>
      (straightDistance > 3) ? straightDistance * 5 : 0;

  @override
  num get bomberPursuitWill => (distanceToBomber <= 6) ? 60 : 0;
}

class Dahl extends Enemy {
  static final List<Point> _animWalkingLeft = [
    new Point(0, 6),
    new Point(1, 6),
    new Point(2, 6),
    new Point(1, 6),
  ];
  static final List<Point> _animWalkingRight = [
    new Point(3, 6),
    new Point(4, 6),
    new Point(5, 6),
    new Point(4, 6),
  ];
  static final List<Point> _animDeath = [
    new Point(6, 6),
    new Point(6, 6),
    new Point(6, 6),
    new Point(6, 6),
    new Point(6, 6),
    new Point(7, 4),
    new Point(8, 4),
    new Point(9, 4),
    new Point(10, 4),
  ];

  @override
  List<Point> get animWalkingLeft => _animWalkingLeft;

  @override
  List<Point> get animWalkingRight => _animWalkingRight;

  @override
  List<Point> get animDeath => _animDeath;

  @override
  num get speed => 40;

  @override
  num get changeDirectionWill =>
      (straightDistance > 2) ? straightDistance * 10 : 0;

  @override
  num get bomberPursuitWill => (distanceToBomber <= 6) ? 20 : 0;
}

class Minvo extends Enemy {
  static final List<Point> _animWalkingLeft = [
    new Point(0, 8),
    new Point(1, 8),
    new Point(2, 8),
    new Point(1, 8),
  ];
  static final List<Point> _animWalkingRight = [
    new Point(3, 8),
    new Point(4, 8),
    new Point(5, 8),
    new Point(4, 8),
  ];
  static final List<Point> _animDeath = [
    new Point(6, 8),
    new Point(6, 8),
    new Point(6, 8),
    new Point(6, 8),
    new Point(6, 8),
    new Point(7, 4),
    new Point(8, 4),
    new Point(9, 4),
    new Point(10, 4),
  ];

  @override
  List<Point> get animWalkingLeft => _animWalkingLeft;

  @override
  List<Point> get animWalkingRight => _animWalkingRight;

  @override
  List<Point> get animDeath => _animDeath;

  @override
  num get speed => 48;

  @override
  num get changeDirectionWill =>
      (straightDistance > 3) ? straightDistance * 5 : 0;

  @override
  num get bomberPursuitWill => (distanceToBomber <= 6) ? 30 : 0;
}

class Ovape extends Enemy {
  static final List<Point> _animWalkingLeft = [
    new Point(7, 6),
    new Point(8, 6),
    new Point(9, 6),
    new Point(8, 6),
  ];
  static final List<Point> _animWalkingRight = [
    new Point(10, 6),
    new Point(11, 6),
    new Point(12, 6),
    new Point(11, 6),
  ];
  static final List<Point> _animDeath = [
    new Point(13, 6),
    new Point(13, 6),
    new Point(13, 6),
    new Point(13, 6),
    new Point(13, 6),
    new Point(7, 4),
    new Point(8, 4),
    new Point(9, 4),
    new Point(10, 4),
  ];

  @override
  List<Point> get animWalkingLeft => _animWalkingLeft;

  @override
  List<Point> get animWalkingRight => _animWalkingRight;

  @override
  List<Point> get animDeath => _animDeath;

  @override
  num get speed => 12;

  @override
  num get changeDirectionWill => ((distanceToBomber > 6) &&
      (straightDistance > 3)) ? straightDistance * 20 : 0;

  @override
  num get bomberPursuitWill => (distanceToBomber <= 6) ? 60 : 0;

  @override
  bool isBlockedByTile(BackgroundTile tile) {
    if (tile is Wall) return false;
    return super.isBlockedByTile(tile);
  }
}

class Doria extends Enemy {
  static final List<Point> _animWalkingLeft = [
    new Point(7, 5),
    new Point(8, 5),
    new Point(9, 5),
    new Point(8, 5),
  ];
  static final List<Point> _animWalkingRight = [
    new Point(10, 5),
    new Point(11, 5),
    new Point(12, 5),
    new Point(11, 5),
  ];
  static final List<Point> _animDeath = [
    new Point(13, 5),
    new Point(13, 5),
    new Point(13, 5),
    new Point(13, 5),
    new Point(13, 5),
    new Point(7, 4),
    new Point(8, 4),
    new Point(9, 4),
    new Point(10, 4),
  ];

  @override
  List<Point> get animWalkingLeft => _animWalkingLeft;

  @override
  List<Point> get animWalkingRight => _animWalkingRight;

  @override
  List<Point> get animDeath => _animDeath;

  @override
  num get speed => 24;

  @override
  num get changeDirectionWill =>
      (straightDistance > 3) ? straightDistance * 5 : 0;

  @override
  num get bomberPursuitWill => (distanceToBomber <= 6)
      ? 30
      : 0; // seesBomber ? 50 : distanceToBomber * 5;

  @override
  bool isBlockedByTile(BackgroundTile tile) {
    if (tile is Wall) return false;
    return super.isBlockedByTile(tile);
  }
}

class Pass extends Enemy {
  static final List<Point> _animWalkingLeft = [
    new Point(7, 8),
    new Point(8, 8),
    new Point(9, 8),
    new Point(8, 8),
  ];
  static final List<Point> _animWalkingRight = [
    new Point(10, 8),
    new Point(11, 8),
    new Point(12, 8),
    new Point(11, 8),
  ];
  static final List<Point> _animDeath = [
    new Point(13, 8),
    new Point(13, 8),
    new Point(13, 8),
    new Point(13, 8),
    new Point(13, 8),
    new Point(7, 4),
    new Point(8, 4),
    new Point(9, 4),
    new Point(10, 4),
  ];

  @override
  List<Point> get animWalkingLeft => _animWalkingLeft;

  @override
  List<Point> get animWalkingRight => _animWalkingRight;

  @override
  List<Point> get animDeath => _animDeath;

  @override
  num get speed => 56;

  @override
  num get changeDirectionWill => ((distanceToBomber > 6) &&
      (straightDistance > 3)) ? straightDistance * 5 : 0;

  @override
  num get bomberPursuitWill => (distanceToBomber <= 6) ? 80 : 0;

  @override
  bool isBlockedByTile(BackgroundTile tile) {
    if (tile is Wall) return false;
    return super.isBlockedByTile(tile);
  }
}

class Pontan extends Enemy {
  static final List<Point> _animWalkingLeft = [
    new Point(7, 7),
    new Point(8, 7),
    new Point(9, 7),
    new Point(8, 7),
  ];
  static final List<Point> _animWalkingRight = [
    new Point(10, 7),
    new Point(11, 7),
    new Point(12, 7),
    new Point(11, 7),
  ];
  static final List<Point> _animDeath = [
    new Point(13, 7),
    new Point(13, 7),
    new Point(13, 7),
    new Point(13, 7),
    new Point(13, 7),
    new Point(7, 4),
    new Point(8, 4),
    new Point(9, 4),
    new Point(10, 4),
  ];

  @override
  List<Point> get animWalkingLeft => _animWalkingLeft;

  @override
  List<Point> get animWalkingRight => _animWalkingRight;

  @override
  List<Point> get animDeath => _animDeath;

  @override
  num get speed => 64;

  @override
  num get changeDirectionWill =>
      (straightDistance > 3) ? straightDistance * 5 : 0;

  @override
  bool isBlockedByTile(BackgroundTile tile) {
    if (tile is Wall) return false;
    return super.isBlockedByTile(tile);
  }
}
