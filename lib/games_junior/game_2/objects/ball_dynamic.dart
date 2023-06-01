import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter_game_ia/settings/word.dart';

class Ball extends BodyComponent {
  @override
  Body createBody() {
    final bodyDef = BodyDef(
      position: Vector2(worldSize.x / 2, 0),
      type: BodyType.dynamic,
    );

    final shape = CircleShape()..radius = 0.3;
    final fixtureDef = FixtureDef(
      shape,
      restitution: 1,
      density: 0.1,
      friction: 10,
    );
    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }
}
