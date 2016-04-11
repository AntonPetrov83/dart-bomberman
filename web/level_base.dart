import 'dart:async';
import 'dart:html';

import 'actor.dart';
import 'background.dart';
import 'tileset.dart';

class LevelBase {
  Tileset tileset;
  int width, height, tileSize;
  Background bg;
  List<Updatable> updatables;
  List<Drawable> drawables;
  List<KeyboardListener> keyboardListeners;
  StreamSubscription keyDownSub, keyUpSub;

  int get widthInPixels => width * tileSize;
  int get heightInPixels => height * tileSize;

  LevelBase(this.tileset, this.width, this.height) {
    print("Constructing background.");
    tileSize = tileset.tileSize;
    bg = new Background(width, height, tileSize);
    bg.clearStyle = 'rgb(31,139,0)'; // green grass
    updatables = [];
    drawables = [];
    keyboardListeners = [];

    keyDownSub = window.onKeyDown.listen(keyDown);
    keyUpSub = window.onKeyUp.listen(keyUp);
  }

  void dispose() {
    keyDownSub.cancel();
    keyUpSub.cancel();
  }

  void addBackgroundTile(int bgx, int bgy, BackgroundTile tile) {
    addActor(tile);
    bg.setTileAt(bgx, bgy, tile);
  }

  void addActor(Actor actor) {
    if (actor != null) {
      assert(actor.level == null);

      if (actor is Updatable) {
        updatables.add(actor as Updatable);
      }

      if (actor is Drawable) {
        drawables.add(actor as Drawable);
      }

      if (actor is KeyboardListener) {
        keyboardListeners.add(actor as KeyboardListener);
      }

      actor.level = this;
      actor.start();
    }
  }

  void removeActor(Actor actor) {
    if (actor != null && actor.level == this) {
      updatables.remove(actor);
      drawables.remove(actor);
      keyboardListeners.remove(actor);

      if (actor is BackgroundTile) {
        if (bg.getTileAt(actor.bgx, actor.bgy) == actor) {
          bg.setTileAt(actor.bgx, actor.bgy, null);
        }
      }

      actor.level = null;
    }
  }

  void update(num dt) {
    for (var i = 0; i < updatables.length; ++i) {
      updatables[i].update(dt);
    }
  }

  void draw(CanvasRenderingContext2D context) {
    bg.draw(context);
    for (var drawable in drawables) {
      drawable.draw(context);
    }
  }

  Point backgroundToSprite(int x, int y) {
    return new Point(x * tileSize, y * tileSize);
  }

  void keyDown(KeyboardEvent e) {
    for (var i = 0; i < keyboardListeners.length; ++i) {
      keyboardListeners[i].keyDown(e.keyCode);
    }
  }

  void keyUp(KeyboardEvent e) {
    for (var i = 0; i < keyboardListeners.length; ++i) {
      keyboardListeners[i].keyUp(e.keyCode);
    }
  }
}
