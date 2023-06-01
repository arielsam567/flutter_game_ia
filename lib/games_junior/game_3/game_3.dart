import 'dart:async';

import 'package:flutter_game_ia/games_junior/game_3/objects/box_dynamic.dart';
import 'package:flutter_game_ia/games_junior/game_3/objects/floor_static.dart';
import 'package:flutter_game_ia/settings/word.dart';

class GameLesson03 extends MyGame {
  @override
  Future<void> onLoad() async {
    super.onLoad();
    add(FloorTorto());
    add(Box());
  }
}
