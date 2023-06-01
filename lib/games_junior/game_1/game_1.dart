import 'dart:async';

import 'package:flutter_game_ia/games_junior/game_1/objects/ball.dart';
import 'package:flutter_game_ia/settings/word.dart';

class GameLesson01 extends MyGame {
  @override
  Future<void> onLoad() async {
    super.onLoad();
    add(Ball());

    //createTimer();
  }

  void createTimer() {
    Timer.periodic(const Duration(milliseconds: 500), (timer) {
      add(Ball());
    });
  }
}
