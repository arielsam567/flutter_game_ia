import 'package:flutter_game_ia/game_ia/game_ia/objects/wall.dart';
import 'package:flutter_game_ia/game_ia/game_ia/word_ia.dart';

class GameComIA extends MyGameIa {
  @override
  Future<void> onLoad() async {
    super.onLoad();

    add(Car());
    add(Wall(worldSize));
    add(Wall(worldSize, isLeft: false));
  }
}
