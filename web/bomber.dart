import 'dart:html';
import 'dart:math';

import 'actor.dart';
import 'background.dart';
import 'bomb.dart';
import 'door.dart';
import 'item.dart';
import 'explosion.dart';
import 'walking_base.dart';
import 'wall.dart';

class Bomber extends WalkingBase implements Updatable, KeyboardListener {
  static final List<Point> animWalkingDown = [
    new Point(0, 1),
    new Point(1, 1),
    new Point(0, 1),
    new Point(2, 1)
  ];
  static final List<Point> animWalkingUp = [
    new Point(0, 2),
    new Point(1, 2),
    new Point(0, 2),
    new Point(2, 2)
  ];
  static final List<Point> animWalkingRight = [
    new Point(3, 1),
    new Point(4, 1),
    new Point(3, 1),
    new Point(5, 1)
  ];
  static final List<Point> animWalkingLeft = [
    new Point(3, 2),
    new Point(4, 2),
    new Point(3, 2),
    new Point(5, 2)
  ];
  static final List<Point> animDeath = [
    new Point(0, 3),
    new Point(1, 3),
    new Point(2, 3),
    new Point(3, 3),
    new Point(4, 3),
    new Point(5, 3),
  ];

  bool buttonUp, buttonDown, buttonLeft, buttonRight, buttonBomb = false;
  Direction direction;
  bool dead = false;
  num frame = 0;
  List<Point> anim;
  List<Bomb> bombs;

  Bomber() {
    direction = Direction.none;
    anim = animWalkingDown;
    bombs = [];
  }

  @override
  void start() {
    tile = level.tileset.getTileAtPoint(animWalkingDown[0]);
  }

  @override
  void update(num dt) {
    if (dead) {
      updateDeath(dt);
    } else {
      updateInput();

      if (direction != Direction.none) {
        updateAnimation(dt);
        walkTo(direction, dt * game.bomberSpeed);
      }

      checkCollisions();
    }
  }

  @override
  bool isBlockedByTile(BackgroundTile tile) {
    if (tile == null || tile is Explosion || tile is Item || tile is Door)
      return false;
    if (tile is Bomb) return !game.bombPass;
    if (tile is Wall) return !game.wallPass;
    return true;
  }

  @override
  void reachedCell() {
    var tile = level.bg.getTileAt(backgroundX, backgroundY);
    if (tile is Item) {
      game.itemTaken(tile.type);
      tile.remove();
    } else if (tile is Door) {
      game.doorTaken();
    }
  }

  void updateAnimation(num dt) {
    frame += dt * 15;
    if (anim == null) return;
    var idx = frame.floor() % anim.length;
    tile = level.tileset.getTileAtPoint(anim[idx]);
  }

  void updateInput() {
    var prevDirection = direction;

    // See if the current direction key was released.
    switch (direction) {
      case Direction.up:
        if (!buttonUp) direction = Direction.none;
        break;

      case Direction.down:
        if (!buttonDown) direction = Direction.none;
        break;

      case Direction.left:
        if (!buttonLeft) direction = Direction.none;
        break;

      case Direction.right:
        if (!buttonRight) direction = Direction.none;
        break;

      default:
        break;
    }

    // Choose new direction.
    if (direction == Direction.none) {
      if (buttonUp)
        direction = Direction.up;
      else if (buttonDown)
        direction = Direction.down;
      else if (buttonLeft)
        direction = Direction.left;
      else if (buttonRight) direction = Direction.right;
    }

    // Direction has changed.
    if (prevDirection != direction) {
      switch (direction) {
        case Direction.up:
          anim = animWalkingUp;
          break;
        case Direction.left:
          anim = animWalkingLeft;
          break;
        case Direction.right:
          anim = animWalkingRight;
          break;
        default:
          anim = animWalkingDown;
          break;
      }
    }
  }

  @override
  void keyDown(int keyCode) {
    switch (keyCode) {
      case KeyCode.W:
        buttonUp = true;
        break;

      case KeyCode.A:
        buttonLeft = true;
        break;

      case KeyCode.S:
        buttonDown = true;
        break;

      case KeyCode.D:
        buttonRight = true;
        break;

      case KeyCode.SPACE:
        placeBomb();
        break;

      case KeyCode.SHIFT:
        if (game.detonator) detonateBombs();
        break;
    }
  }

  @override
  void keyUp(int keyCode) {
    switch (keyCode) {
      case KeyCode.W:
        buttonUp = false;
        break;

      case KeyCode.A:
        buttonLeft = false;
        break;

      case KeyCode.S:
        buttonDown = false;
        break;

      case KeyCode.D:
        buttonRight = false;
        break;
    }
  }

  void checkCollisions() {
    if (!game.flameProof && !game.invulnerability) {
      var tile = level.bg.getTileAt(backgroundX, backgroundY);
      if (tile is Explosion) {
        die();
      }
    }
  }

  void placeBomb() {
    // Update existing bombs.
    bombs.removeWhere((b) => b.exploded);

    // Current position is not empty.
    if (getNeighbourTile(0, 0) != null) return;

    // Too many bombs.
    if (bombs.length >= game.bombCapacity) return;

    // Place a bomb.
    var bomb = new Bomb(radius: game.blastRadius, lifetime: game.bombLifetime);
    level.addBackgroundTile(backgroundX, backgroundY, bomb);
    bombs.add(bomb);
  }

  void detonateBombs() {
    bombs.forEach(detonateBomb);
    bombs.clear();
  }

  void detonateBomb(Bomb bomb) {
    if (!bomb.exploded) bomb.explode();
  }

  die() {
    if (!dead) {
      dead = true;
      frame = 0;
      direction = Direction.none;
      anim = animDeath;
    }
  }

  void updateDeath(num dt) {
    frame += dt * 6;
    if (anim == null) return;
    var idx = frame.floor();
    if (idx >= anim.length) {
      game.bomberKilled();
      remove();
    } else {
      tile = level.tileset.getTileAtPoint(anim[idx]);
    }
  }
}
