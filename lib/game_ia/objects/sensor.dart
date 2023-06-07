import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';

class Sensor extends BodyComponent with ContactCallbacks, Collision {
  double xSize = 0.02;
  double ySize = 2;
  double reading = 0;
  Color sensorColor = Colors.white;

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

  double sizeX() {
    return xSize;
  }

  double sizeY() {
    return ySize;
  }

  void updateColor(double percent) {
    reading = percent;
    Color newColor = Color.lerp(
      Colors.green,
      Colors.red,
      percent,
    )!;

    if (percent == 0) {
      newColor = Colors.white;
    }

    if (newColor != sensorColor) {
      paint.color = newColor;
      sensorColor = newColor;
    }
  }

  void deleteItem() {
    world.destroyBody(body);
    gameRef.remove(this);
  }
}
