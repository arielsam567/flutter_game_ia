import 'dart:async';

import 'package:flame/events.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter_game_ia/games_junior/game_4/objects/ball.dart';
import 'package:flutter_game_ia/games_junior/game_4/objects/floor_static.dart';
import 'package:flutter_game_ia/settings/word.dart';

class GameLesson04 extends MyGame with TapDetector {
  final balls = [Ball4(2), Ball4(6), Ball4(10)];
  final speed = Vector2(0, -9);

  @override
  Future<void> onLoad() async {
    super.onLoad();

    add(Floor4());
    addAll(balls);
  }

  @override
  void onTapDown(TapDownInfo info) {
    super.onTapDown(info);
    balls[0].body.applyForce(speed);
    balls[1].body.applyLinearImpulse(speed);
    balls[2].body.linearVelocity = speed;
  }
}
