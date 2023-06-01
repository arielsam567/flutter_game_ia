import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter_game_ia/settings/word.dart';

class Ball5 extends BodyComponent {
  @override
  Future<void> onLoad() async {
    super.onLoad();
    final sprite = Sprite(gameRef.images.fromCache('ball.png'));
    add(
      SpriteComponent(
        sprite: sprite,
        size: Vector2(.5, .5),
        anchor: Anchor.center,
      ),
    );
  }

  @override
  Body createBody() {
    final bodyDef = BodyDef(
      position: Vector2(worldSize.x / 2, 0),
      type: BodyType.dynamic,
    );

    final shape = CircleShape()..radius = .25;
    final fixtureDef = FixtureDef(shape)
      ..density = 10
      ..friction = 10
      ..restitution = 0.1;
    return world.createBody(bodyDef)
      ..createFixture(fixtureDef)
      ..angularVelocity = Random().nextBool() ? -radians(180) : radians(180);
  }
}
