import 'dart:async';

import 'package:flutter_game_ia/games_junior/game_2/objects/ball_dynamic.dart';
import 'package:flutter_game_ia/games_junior/game_2/objects/box_kinematic.dart';
import 'package:flutter_game_ia/games_junior/game_2/objects/floor_static.dart';
import 'package:flutter_game_ia/settings/word.dart';

class GameLesson02 extends MyGame {
  @override
  Future<void> onLoad() async {
    super.onLoad();
    add(FloorStatic());
    add(BoxKinematic());
    add(Ball());
    //createTimer();
  }
}
