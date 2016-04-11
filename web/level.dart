import 'dart:html';
import 'dart:math';

import 'actor.dart';
import 'background.dart';
import 'bomber.dart';
import 'enemy.dart';
import 'item.dart';
import 'door.dart';
import 'game.dart';
import 'level_base.dart';
import 'stages.dart';
import 'tileset.dart';
import 'wall.dart';

class Level extends LevelBase {
  Game game;
  Random rnd = new Random();
  List<Enemy> enemies;
  Bomber bomber;

  Level(this.game, Tileset tileset, int width, int height, StageParams stage)
      : super(tileset, width, height) {
    print("Creating blocks and walls.");
    initWalls(stage.bonus ? 0 : 25);

    print("Spawning enemies.");
    enemies = [];
    stage.enemies.forEach(spawnEnemies);

    if (!stage.bonus) {
      print("Hiding items.");
      hideItem(stage.item);

      print("Hiding exit door.");
      hideDoor();
    }

    print('Spawning bomber');
    bomber = new Bomber();
    addActor(bomber);
    bomber.position = backgroundToSprite(1, 1);

    print("Level constructed.");
  }

  @override
  void addActor(Actor actor) {
    if (actor is Enemy) enemies.add(actor);
    super.addActor(actor);
  }

  @override
  void removeActor(Actor actor) {
    if (actor is Enemy) enemies.remove(actor);
    super.removeActor(actor);
  }

  void initWalls(num wallsPercent) {
    for (num y = 0; y < height; ++y) {
      for (num x = 0; x < width; ++x) {
        var border =
            (x == 0) || (y == 0) || (x == width - 1) || (y == height - 1);

        var block = ((x % 2) == 0) && ((y % 2) == 0);

        if (block || border) {
          addBackgroundTile(x, y, new Block.fromTileset(tileset));
        } else {
          if (rnd.nextInt(100) < wallsPercent)
            addBackgroundTile(x, y, new Wall.fromTileset(tileset));
        }
      }
    }

    // Remove walls at bomberman start spot.
    clearTileAt(1, 1);
    clearTileAt(1, 2);
    clearTileAt(2, 1);
  }

  void clearTileAt(int bgx, int bgy) {
    var tile = bg.getTileAt(bgx, bgy);
    if (tile != null) tile.remove();
  }

  void spawnEnemies(int type, int count) {
    for (var i = 0; i < count; ++i) {
      spawnEnemy(type);
    }
  }

  void spawnEnemy(int type) {
    Enemy enemy;
    switch (type) {
      case Enemy.valcom:
        enemy = new Valcom();
        break;

      case Enemy.oneal:
        enemy = new Oneal();
        break;

      case Enemy.dahl:
        enemy = new Dahl();
        break;

      case Enemy.minvo:
        enemy = new Minvo();
        break;

      case Enemy.ovape:
        enemy = new Ovape();
        break;

      case Enemy.doria:
        enemy = new Doria();
        break;

      case Enemy.pass:
        enemy = new Pass();
        break;

      case Enemy.pontan:
        enemy = new Pontan();
        break;

      default:
        return;
    }

    addActor(enemy);
    while (true) {
      var pt = getRandomBackgroundPoint((t) => t == null);
      if (pt.x <= 4 && pt.y <= 4) continue;
      enemy.position = backgroundToSprite(pt.x, pt.y);
      break;
    }
  }

  void hideItem(int type) {
    var item = new Item(type, tileset);
    var pt = getRandomBackgroundPoint(isTileSuitableForHidingBonus);
    assert(pt != null);
    var wall = bg.getTileAt(pt.x, pt.y) as Wall;
    wall.item = item;
  }

  void hideDoor() {
    var pt = getRandomBackgroundPoint(isTileSuitableForHidingBonus);
    assert(pt != null);
    var wall = bg.getTileAt(pt.x, pt.y) as Wall;
    wall.item = new Door.fromTileset(tileset);
  }

  bool isTileSuitableForHidingBonus(BackgroundTile tile) {
    return (tile is Wall) && (tile.item == null);
  }

  Point getRandomBackgroundPoint(bool predicate(BackgroundTile tile)) {
    var initialX = rnd.nextInt(width);
    var initialY = rnd.nextInt(height);
    var x = initialX;
    var y = initialY;
    while (true) {
      if (predicate(bg.getTileAt(x, y))) return new Point(x, y);

      x++;
      if (x == width) {
        x = 0;
        y++;
        if (y == height) y = 0;
      }

      if (y == initialY && x == initialX) return null;
    }
  }
}
