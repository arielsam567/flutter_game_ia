import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter_game_ia/settings/word.dart';

class Ball4 extends BodyComponent {
  final double positionX;

  Ball4(this.positionX);

  @override
  Body createBody() {
    final bodyDef = BodyDef(
      position: Vector2(positionX, worldSize.y - 1),
      type: BodyType.dynamic,
    );

    final shape = CircleShape()..radius = .35;
    final fixtureDef = FixtureDef(shape)
      ..density = 10
      ..friction = 5
      ..restitution = 1;
    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }
}
