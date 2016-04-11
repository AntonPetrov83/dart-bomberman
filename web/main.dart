import 'dart:async';
import 'dart:html';

import 'game.dart';
import 'font.dart';
import 'tileset.dart';

Future<ImageElement> loadImage(String src) {
  var image = new ImageElement(src: src);
  return image.onLoad.first.then((e) => image);
}

main() async {
//  var canvas =
//      new CanvasElement(width: 31 * 16 * scale, height: 15 * 16 * scale);
//  document.body.children.add(canvas);

  print("Loading tileset image.");
  var tileset = new Tileset(await loadImage("tileset.png"), 16);

  print("Loading font image.");
  var font = new Font(new Tileset(await loadImage("font.png"), 8));

  var canvas = querySelector('#canvas');
  canvas.focus();

  print("Constructing game object.");
  var game = new Game(tileset, font, canvas.context2D);
  game.run();
}
