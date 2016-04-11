import 'dart:html';

abstract class GameBase {
  CanvasRenderingContext2D ctx;
  int width, height;
  num scale;
  num _lastTimeStamp = 0;

  GameBase(this.ctx, this.scale) {
    width = ctx.canvas.width ~/ scale;
    height = ctx.canvas.height ~/ scale;
  }

  void run() {
    window.animationFrame.then(step);
  }

  void step(num now) {
    var dt = (now - _lastTimeStamp) * 0.001;
    _lastTimeStamp = now;
    if (dt > 1) dt = 1;

    update(dt);

    ctx.resetTransform();
    ctx.scale(scale, scale);

    draw(ctx);

    window.animationFrame.then(step);
  }

  void update(num dt);
  void draw(CanvasRenderingContext2D ctx);
}
