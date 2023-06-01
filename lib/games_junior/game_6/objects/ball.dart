import 'package:flame/components.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter_game_ia/games_junior/game_6/game_6.dart';
import 'package:flutter_game_ia/settings/word.dart';

class Ball6 extends BodyComponent with ContactCallbacks {
  ObjectState state = ObjectState.normal;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    renderBody = false;
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
  void update(double dt) {
    super.update(dt);

    if (state == ObjectState.explode) {
      world.destroyBody(body);
      gameRef.remove(this);
    }
  }

  void hit() {
    if (state == ObjectState.normal) {
      state = ObjectState.explode;
    }
  }

  @override
  Body createBody() {
    final bodyDef = BodyDef(
      userData: this,
      position: Vector2(worldSize.x / 2, 0),
      type: BodyType.dynamic,
    );

    final shape = CircleShape()..radius = .25;
    final fixtureDef = FixtureDef(shape)
      ..density = 5
      ..friction = .5
      ..restitution = .5;
    return world.createBody(bodyDef)
      ..createFixture(fixtureDef)
      ..angularVelocity = radians(180);
  }

  @override
  void beginContact(Object other, Contact contact) {
    if (other is Ball6) {
      hit();
    }
  }
}
