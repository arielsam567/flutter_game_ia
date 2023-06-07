import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';

class Sensor extends BodyComponent with ContactCallbacks, Collision {
  double xSize = 0.02;
  double ySize = 2;
  double reading = 0;
  @override
  Body createBody() {
    final bodyDef = BodyDef(
      position: Vector2(0, 0),
      type: BodyType.dynamic,
    );

    final shape = PolygonShape()..setAsBoxXY(xSize, ySize);
    final fixtureDef = FixtureDef(shape, isSensor: true);
    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }

  //overflow detector
  @override
  void beginContact(Object other, Contact contact) {
    final Body bodyA = contact.fixtureA.body;
    final Body bodyB = contact.fixtureB.body;

    print('SENSOR - beginContact | bodyA $bodyA | bodyB $bodyB');
  }

  double sizeX() {
    return xSize;
  }

  double sizeY() {
    return ySize;
  }

  void updateColor(double percent) {
    reading = percent;
    Color color = Color.lerp(
      Colors.green,
      Colors.red,
      percent,
    )!;

    if (percent == 0) {
      color = Colors.white;
    }

    paint.color = color;
  }

  void deleteItem() {
    world.destroyBody(body);
    gameRef.remove(this);
  }
}
