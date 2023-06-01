import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter_game_ia/settings/word.dart';

class FloorStatic extends BodyComponent {
  @override
  Body createBody() {
    final bodyDef = BodyDef(position: Vector2(0, worldSize.y - 0.5));
    final shape = EdgeShape()..set(Vector2.zero(), Vector2(worldSize.x, 0));
    return world.createBody(bodyDef)..createFixtureFromShape(shape);
  }
}
