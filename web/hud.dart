import 'dart:html';

import 'font.dart';
import 'game.dart';

class Hud {
  Game game;
  Font font;
  int width, height;

  Hud(this.game, this.font, this.width, this.height);

  void draw(CanvasRenderingContext2D ctx) {
    ctx.fillStyle = 'rgb(185,185,185)';
    ctx.fillRect(0, 0, width, height);

    drawText(ctx, 1, 2, 'TIME ' + game.timeLeft.toString());

    var score = game.score.toString();
    drawText(ctx, 20 - score.length, 2, score);

    drawText(ctx, 24, 2, 'LEFT ' + game.lifes.toString());
  }

  void drawText(CanvasRenderingContext2D ctx, int x, int y, String text) {
    font.drawText(ctx, x * 8, y * 8, text);
  }
}
