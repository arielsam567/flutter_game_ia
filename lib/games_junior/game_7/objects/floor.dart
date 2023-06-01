import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter_game_ia/settings/word.dart';

class Floor extends BodyComponent {
  @override
  Body createBody() {
    final bodyDef = BodyDef(
      position: Vector2(0, worldSize.y - .75),
    );

    final shape = EdgeShape()..set(Vector2.zero(), Vector2(worldSize.x, 0));

    final fixtureDef = FixtureDef(shape)..friction = .7;

    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }
}

class Wall extends BodyComponent {
  bool isLeft;

  Wall({this.isLeft = true});

  @override
  Body createBody() {
    final bodyDef = BodyDef(
      position: Vector2(
        isLeft ? 0.02 : worldSize.x * 0.998,
        isLeft ? 0.02 : worldSize.y * 0.998,
      ),
    );

    final shape = EdgeShape()
      ..set(
        Vector2(
          0,
          isLeft ? 0.02 : -worldSize.y,
        ),
        Vector2(0.02, worldSize.y),
      );

    final fixtureDef = FixtureDef(shape)..friction = 0;

    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }
}
