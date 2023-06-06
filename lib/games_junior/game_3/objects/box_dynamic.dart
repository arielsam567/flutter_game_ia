import 'package:flame_forge2d/flame_forge2d.dart';

class Box extends BodyComponent {
  @override
  Body createBody() {
    final bodyDef = BodyDef(
      position: Vector2(12, 0),
      type: BodyType.dynamic,
    );

    final shape = PolygonShape()..setAsBoxXY(2, .25);
    final fixtureDef = FixtureDef(shape)
      ..density = 1
      ..friction = 01
      ..restitution = 0.1;
    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }
}
