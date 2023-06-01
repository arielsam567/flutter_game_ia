import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter_game_ia/settings/word.dart';

class FloorTorto extends BodyComponent {
  @override
  Body createBody() {
    final bodyDef = BodyDef(
      position: Vector2(0, worldSize.y - .75),
    );

    final shape = EdgeShape()..set(Vector2.zero(), Vector2(worldSize.x, -2));
    final fixtureDef = FixtureDef(shape)..friction = .1;
    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }
}
