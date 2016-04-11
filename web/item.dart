import 'background.dart';
import 'tileset.dart';

class Item extends BackgroundTile {
  static const int fire = 1; // Blast radius +1
  static const int bomb = 2; // Bomb Capacity +1
  static const int detonator = 3; // Detonates bombs at will. Lost when killed.
  static const int skates = 4; // Speed +1
  static const int bombPass = 5; // Can freely walk through a Bomb.
  static const int wallPass = 6; // Can freely walk through a Soft Block.
  static const int flameProof = 7; // Can survive blasts.
  static const int question = 8; // Invulnerability for 35 seconds.

  int type;

  Item(this.type, Tileset tileset) {
    switch (type) {
      case fire:
        tile = tileset.getTile(9, 0);
        break;

      case bomb:
        tile = tileset.getTile(10, 0);
        break;

      case skates:
        tile = tileset.getTile(11, 0);
        break;

      case detonator:
        tile = tileset.getTile(12, 0);
        break;

      case bombPass:
        tile = tileset.getTile(13, 0);
        break;

      case wallPass:
        tile = tileset.getTile(14, 0);
        break;

      default:
        throw new ArgumentError.value(type, 'type');
    }
  }
}
