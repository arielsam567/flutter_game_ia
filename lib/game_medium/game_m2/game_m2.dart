import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_game_ia/game_medium/game_m1/objects/robot.dart';
import 'package:flutter_game_ia/games_junior/game_7/objects/floor.dart';
import 'package:flutter_game_ia/settings/word.dart';

class GameLesson09 extends MyGame {
  final robot = Box();

  @override
  Future<void> onLoad() async {
    super.onLoad();

    add(Floor());
    await add(robot);
    camera.followBodyComponent(robot);
  }

  @override
  KeyEventResult onKeyEvent(RawKeyEvent event, Set keysPressed) {
    super.onKeyEvent(event, keysPressed);
    if (event is RawKeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.keyW) {
        robot.jump();
      }
    }

    if (keysPressed.contains(LogicalKeyboardKey.keyD)) {
      robot.walkRight();
    } else if (keysPressed.contains(LogicalKeyboardKey.keyA)) {
      robot.walkLeft();
    } else if (keysPressed.contains(LogicalKeyboardKey.keyS)) {
      robot.duck();
    } else {
      robot.idle();
    }

    return KeyEventResult.handled;
  }
}
