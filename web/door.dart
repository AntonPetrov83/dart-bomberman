import 'background.dart';
import 'tileset.dart';

class Door extends BackgroundTile {
  Door.fromTileset(Tileset tileset) {
    tile = tileset.getTile(15, 0);
  }

  void explode() {
    // TODO: spawn a lot of enemies.
  }
}
