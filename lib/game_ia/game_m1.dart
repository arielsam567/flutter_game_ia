import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_game_ia/game_ia/objects/car.dart';
import 'package:flutter_game_ia/game_ia/objects/wall.dart';
import 'package:flutter_game_ia/game_ia/word_ia.dart';

class GameComIA extends MyGameIa {
  final car = Car(worldSize);
  @override
  Future<void> onLoad() async {
    super.onLoad();
    await loadSprite('car.png');

    await add(car);
    add(FloorBottom(worldSize));
    add(FloorTop(worldSize));

    add(
      Wall(worldSize)
        ..paint.color = const Color(0xFF0000FF)
        ..paint.strokeWidth = 100
        ..paint.style = PaintingStyle.fill,
    );
    add(Wall(worldSize, isLeft: false));

    final worldBounds = Rect.fromLTRB(0, -double.infinity, worldSize.x, worldSize.y);
    camera.followBodyComponent(car, worldBounds: worldBounds);
  }

  @override
  KeyEventResult onKeyEvent(RawKeyEvent event, Set keysPressed) {
    super.onKeyEvent(event, keysPressed);
    if (event is RawKeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.keyW) {
        car.controls.moveOn();
      }
      if (event.logicalKey == LogicalKeyboardKey.keyS) {
        car.controls.moveBack();
      }
      if (event.logicalKey == LogicalKeyboardKey.keyA) {
        car.controls.turnLeft();
      }
      if (event.logicalKey == LogicalKeyboardKey.keyD) {
        car.controls.turnRight();
      }
    }

    if (event is RawKeyUpEvent) {
      if (event.logicalKey == LogicalKeyboardKey.keyW) {
        car.controls.forward = false;
      }
      if (event.logicalKey == LogicalKeyboardKey.keyS) {
        car.controls.backward = false;
      }
      if (event.logicalKey == LogicalKeyboardKey.keyA) {
        car.controls.left = false;
      }
      if (event.logicalKey == LogicalKeyboardKey.keyD) {
        car.controls.right = false;
      }
    }

    return KeyEventResult.handled;
  }
}
