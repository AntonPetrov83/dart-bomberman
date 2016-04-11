import 'dart:html';

import 'level_base.dart';

class Actor {
  LevelBase level;

  void start() {}

  void remove() {
    if (level != null) level.removeActor(this);
  }
}

abstract class Updatable {
  void update(num dt);
}

abstract class Drawable {
  void draw(CanvasRenderingContext2D context);
}

abstract class KeyboardListener {
  void keyDown(int keyCode);
  void keyUp(int keyCode);
}
