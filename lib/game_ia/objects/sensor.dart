import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';

class Sensor extends BodyComponent {
  double xSize = 0.02;
  double ySize = 2;
  double reading = 0;
  Color sensorColor = Colors.white;
  Vector2 position = Vector2.zero();
  double angleSensor = 0;
  static const Color safe = Colors.green;
  static const Color danger = Colors.red;

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

  double sizeY() {
    return ySize;
  }

  void setReading(double percent) {
    reading = percent;
  }

  void deleteItem() {
    world.destroyBody(body);
    gameRef.remove(this);
  }

  void updateColor(double percent) {
    reading = percent;
    Color newColor = Color.lerp(
      safe,
      danger,
      reading,
    )!;

    if (reading == 0) {
      newColor = Colors.white;
    }

    if (newColor != sensorColor) {
      paint.color = newColor;
      sensorColor = newColor;
    }
  }
}
