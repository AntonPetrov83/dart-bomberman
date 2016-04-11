import 'enemy.dart';
import 'item.dart';

class StageParams {
  Map<int, int> enemies;
  int item = 0;
  bool bonus = false;

  StageParams(this.enemies, {this.item: 0, this.bonus: false});
}

List<StageParams> stages = [
  new StageParams({Enemy.valcom: 6}, item: Item.fire),
  new StageParams({Enemy.valcom: 3, Enemy.oneal: 3}, item: Item.bomb),
  new StageParams({Enemy.valcom: 2, Enemy.oneal: 2, Enemy.dahl: 2},
      item: Item.detonator),
  new StageParams(
      {Enemy.valcom: 1, Enemy.oneal: 1, Enemy.dahl: 2, Enemy.minvo: 2},
      item: Item.skates),
  new StageParams({Enemy.oneal: 4, Enemy.dahl: 3}, item: Item.bomb),
  new StageParams({Enemy.valcom: 20}, bonus: true),
  new StageParams({Enemy.oneal: 2, Enemy.dahl: 3, Enemy.minvo: 2},
      item: Item.bomb),
  new StageParams({Enemy.oneal: 2, Enemy.dahl: 3, Enemy.ovape: 2},
      item: Item.fire),
  new StageParams({Enemy.oneal: 1, Enemy.dahl: 2, Enemy.minvo: 4},
      item: Item.detonator),
  new StageParams(
      {Enemy.oneal: 1, Enemy.dahl: 1, Enemy.minvo: 4, Enemy.doria: 1},
      item: Item.bombPass),
  new StageParams({
    Enemy.oneal: 1,
    Enemy.dahl: 1,
    Enemy.minvo: 1,
    Enemy.ovape: 1,
    Enemy.doria: 3
  }, item: Item.wallPass),
  new StageParams({Enemy.oneal: 20}, bonus: true),
];
