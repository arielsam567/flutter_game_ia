import 'dart:async';
import 'dart:math';

import 'package:flame/events.dart';
import 'package:flutter_game_ia/games_junior/game_4/objects/floor_static.dart';
import 'package:flutter_game_ia/games_junior/game_5/objects/ball.dart';
import 'package:flutter_game_ia/games_junior/game_5/objects/box.dart';
import 'package:flutter_game_ia/settings/word.dart';

class GameLesson05 extends MyGame with TapDetector {
  @override
  Future<void> onLoad() async {
    super.onLoad();
    await loadSprite('ball.png');
    await loadSprite('box.png');
    add(Floor4());
  }

  @override
  void onTapDown(TapDownInfo info) {
    super.onTapDown(info);
    if (Random().nextBool()) {
      add(Ball5());
    } else {
      add(Box5());
    }
  }
}
