import 'background.dart';
import 'explosion.dart';
import 'tileset.dart';

class Block extends BackgroundTile {
  Block.fromTileset(Tileset tileset) {
    tile = tileset.getTile(1, 0);
  }
}

class Wall extends BackgroundTile {
  // An item hidden behind the wall.
  BackgroundTile item;

  Wall.fromTileset(Tileset tileset) {
    tile = tileset.getTile(2, 0);
  }

  void explode() {
    if (item != null) {
      level.addBackgroundTile(bgx, bgy, item);
    } else {
      level.addBackgroundTile(bgx, bgy, new Explosion(ExplosionStyle.wall));
    }
    remove();
  }
}
