import 'dart:html';
import 'dart:math';

import 'game_base.dart';
import 'font.dart';
import 'hud.dart';
import 'item.dart';
import 'enemy.dart';
import 'level.dart';
import 'stages.dart';
import 'tileset.dart';

Map<int, int> pointsPerEnemy = {
  Enemy.valcom: 100,
  Enemy.oneal: 200,
  Enemy.dahl: 400,
  Enemy.minvo: 800,
  Enemy.ovape: 1000,
  Enemy.doria: 2000,
  Enemy.pass: 4000,
  Enemy.pontan: 8000
};

enum GameState { stage, level, death, door, gameOver }

class Game extends GameBase {
  Tileset tileset;
  Font font;

  GameState state;

  // Current stage number.
  int stage;

  // Bomberman lifes remaining.
  int lifes;

  // Player's current score.
  int score;

  // Number of items taken.
  Map<int, int> items;

  StageParams stageParams;
  Level level;
  num levelTime;
  num stateTime;
  Hud hud;

  int get timeLimit => stageParams.bonus ? 30 : 200;
  int get timeLeft => max(timeLimit - levelTime.floor(), 0);
  int get blastRadius => min(5, 1 + items[Item.fire]);
  int get bombCapacity => min(10, 1 + items[Item.bomb]);
  int get bomberSpeed => (items[Item.skates] > 0) ? 64 : 48;
  bool get detonator => items[Item.detonator] > 0;
  num get bombLifetime => detonator ? 0 : 3;
  bool get bombPass => items[Item.bombPass] > 0;
  bool get wallPass => items[Item.wallPass] > 0;
  bool get flameProof => stageParams.bonus || (items[Item.flameProof] > 0);
  bool get invulnerability => stageParams.bonus;

  Game(this.tileset, this.font, CanvasRenderingContext2D ctx) : super(ctx, 2) {
    ctx.imageSmoothingEnabled = false;
    hud = new Hud(this, font, width, 32);
    startNewGame();
  }

  @override
  void update(num dt) {
    stateTime += dt;
    switch (state) {
      case GameState.level:
        var prevLevelTime = levelTime;
        levelTime += dt;
        level.update(dt);
        if (prevLevelTime < timeLimit && levelTime >= timeLimit) timeOut();
        break;

      case GameState.death:
        if (stateTime >= 3) startStageScreen();
        break;

      case GameState.stage:
        if (stateTime >= 3) startLevel();
        break;

      case GameState.door:
        if (stateTime >= 3) startStageScreen();
        break;

      case GameState.gameOver:
        if (stateTime >= 3) startNewGame();
        break;

      default:
        break;
    }
  }

  @override
  void draw(CanvasRenderingContext2D ctx) {
    switch (state) {
      case GameState.level:
      case GameState.death:
      case GameState.door:
        drawLevel(ctx);
        break;

      case GameState.stage:
        drawStageScreen(ctx);
        break;

      case GameState.gameOver:
        drawGameOverScreen(ctx);
        break;

      default:
        break;
    }
  }

  void drawLevel(CanvasRenderingContext2D ctx) {
    hud.draw(ctx);
    ctx.translate(horizontalScroll, 32);
    level.draw(ctx);
  }

  int get horizontalScroll {
    if (level == null) return 0;
    if (level.widthInPixels <= width) return 0;
    var half = width ~/ 2;
    var bomberX = level.bomber.x + 8;
    var scroll = half - bomberX;
    var minScroll = -level.widthInPixels + 2 * half;
    if (scroll > 0) return 0;
    if (scroll < minScroll) return minScroll;
    return scroll;
  }

  void drawStageScreen(CanvasRenderingContext2D ctx) {
    ctx.fillStyle = 'black';
    ctx.fillRect(0, 0, width, height);

    var stageNum = stage - (stage ~/ 6); // every 6-th stage is a bonus stage.
    if (stageParams.bonus)
      font.drawText(ctx, 80, 112, 'BONUS STAGE');
    else
      font.drawText(ctx, 96, 112, 'STAGE ' + (stageNum + 1).toString());
  }

  void drawGameOverScreen(CanvasRenderingContext2D ctx) {
    ctx.fillStyle = 'black';
    ctx.fillRect(0, 0, width, height);

    font.drawText(ctx, 88, 112, 'GAME OVER');
  }

  void startNewGame() {
    score = 0;
    lifes = 2;
    stage = 0;
    items = {
      Item.fire: 0,
      Item.bomb: 0,
      Item.skates: 0,
      Item.detonator: 0,
      Item.bombPass: 0,
      Item.wallPass: 0,
      Item.flameProof: 0
    };

    startStageScreen();
  }

  void startStageScreen() {
    stageParams = stages[stage];
    state = GameState.stage;
    stateTime = 0;
  }

  void startLevel() {
    if (level != null) {
      level.dispose();
      level = null;
    }

    print("Initializing stage $stage.");
    stageParams = stages[stage];
    level = new Level(this, tileset, 31, 13, stageParams);
    levelTime = 0;
    stateTime = 0;
    state = GameState.level;
  }

  void startGameOverScreen() {
    state = GameState.gameOver;
    stateTime = 0;
  }

  void itemTaken(int type) {
    items[type] += 1;
  }

  void doorTaken() {
    if (level.enemies.length == 0) {
      incrementStage();
      stateTime = 0;
      state = GameState.door;
    }
  }

  void enemyKilled(int enemyType) {
    score += pointsPerEnemy[enemyType];
  }

  void bomberKilled() {
    print('lifes before: $lifes');
    lifes--;
    print('lifes after: $lifes');
    items[Item.detonator] = 0;
    items[Item.bombPass] = 0;
    items[Item.wallPass] = 0;
//  items[Item.flameProof] = 0;
    if (lifes >= 0) {
      stateTime = 0;
      state = GameState.death;
    } else
      startGameOverScreen();
  }

  void timeOut() {
    if (stageParams.bonus) {
      bonusStageFinished();
    } else {
      // todo: spawn pontans
    }
  }

  void bonusStageFinished() {
    incrementStage();
    stateTime = 0;
    state = GameState.door;
  }

  void incrementStage() {
    stage = (stage + 1) % stages.length;
  }
}
