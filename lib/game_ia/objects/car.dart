import 'dart:math' as math;
import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';
import 'package:flutter_game_ia/game_ia/objects/sensor.dart';
import 'package:flutter_game_ia/game_medium/game_m1/control.dart';
import 'package:flutter_game_ia/utils/utils.dart';

class Car extends BodyComponent {
  final Vector2 worldSize;
  final double maxSpeed;
  final double friction = 0.2;
  final Controls controls = Controls();
  final List<Sensor> sensors;

  double speed = 0;
  double acceleration = 0.50;
  double carAngle = 0;
  double carSize = 1.6;
  double xSize = 0.25;
  double ySize = 0.5;
  double angleIncrement = 0.02;
  double angleSpread = 2;

  Car(
    this.worldSize, {
    required this.sensors,
    this.maxSpeed = 6,
  });

  @override
  Future<void> onLoad() async {
    super.onLoad();

    final sprite = Sprite(gameRef.images.fromCache('car.png'));
    add(
      SpriteComponent(
        sprite: sprite,
        size: Vector2(.6 * carSize, 1 * carSize),
        anchor: Anchor.center,
      ),
    );
  }

  @override
  Body createBody() {
    final bodyDef = BodyDef(
      position: Vector2(worldSize.x / 2, 3),
      type: BodyType.dynamic,
    );

    final shape = PolygonShape()..setAsBoxXY(xSize * carSize, ySize * carSize);
    final fixtureDef = FixtureDef(shape, isSensor: true);
    //add(sensor);
    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }

  @override
  void update(double dt) {
    super.update(dt);
    move();
    setSpeed2D();
  }

  void move() {
    setSpeedMaxSpeed();
    setFriction();

    if (hasSpeed()) {
      if (controls.left) {
        carAngle -= angleIncrement;
      }
      if (controls.right) {
        carAngle += angleIncrement;
      }
    }
  }

  void setFriction() {
    if (speed > 0) {
      speed -= friction;
    }
    if (speed < 0) {
      speed += friction;
    }
    if (speed.abs() < friction) {
      speed = 0;
    }
  }

  void setSpeedMaxSpeed() {
    if (controls.forward) {
      speed -= acceleration;
      if (speed < -maxSpeed) {
        speed = -maxSpeed;
      }
    }
    if (controls.backward) {
      speed += acceleration;
      if (speed > maxSpeed / 2) {
        speed = maxSpeed / 2;
      }
    }
  }

  bool hasSpeed() {
    return speed != 0 || body.linearVelocity != Vector2.zero();
  }

  void setSpeed2D() {
    body.setTransform(Vector2(body.position.x, body.position.y), carAngle);
    body.linearVelocity = Vector2(-math.sin(carAngle) * speed, math.cos(carAngle) * speed);
  }

  double sizeX() {
    return xSize * carSize;
  }

  double sizeY() {
    return ySize * carSize;
  }

  void updateColor(bool isColliding) {
    if (!isColliding) {
      paint.color = Colors.green;
      return;
    }
    paint.color = Colors.red;
  }

  void checkCollisions(List<List<Vector2>> paredesVector) {
    final carPosition = body.position;
    final double angle = carAngle / pi * 180;
    final double rad = angle * (pi / 180);

    //SENSOR
    updateSensorPosition(carPosition, rad);
    for (int i = 0; i < sensors.length; i++) {
      final List<Vector2> sensorVector = getSensorsVector(rad, sensors[i], i);
      checkSensorCollisionWithParedes(sensorVector, sensors[i], paredesVector);
    }

    //CAR
    final List<Vector2> carVector = getCarVector(rad);
    checkCarCollisionWithParedes(paredesVector, carVector);
  }

  void updateSensorPosition(Vector2 carPosition, double carAngleRad) {
    final double angleIncrement = angleSensor;
    for (int i = 0; i < sensors.length; i++) {
      final double sensorAngleRad = carAngleRad - pi / (2 * angleSpread) + angleIncrement * i;
      sensors[i].body.setTransform(
            Vector2(
              carPosition.x + 2.8 * sin(sensorAngleRad),
              carPosition.y - 2.8 * cos(sensorAngleRad),
            ),
            sensorAngleRad,
          );
    }
  }

  double get angleSensor => (pi / angleSpread) / (sensors.length - 1);

  List<Vector2> getSensorsVector(double carAngleRad, Sensor sensor, int i) {
    final sensorPosition = sensor.body.position;

    final double sensorAngleRad = carAngleRad - pi / (2 * angleSpread) + angleSensor * i;

    return [
      Vector2(
        sensorPosition.x + sensor.sizeY() * sin(sensorAngleRad),
        sensorPosition.y - sensor.sizeY() * cos(sensorAngleRad),
      ),
      Vector2(
        sensorPosition.x - sensor.sizeY() * sin(sensorAngleRad),
        sensorPosition.y + sensor.sizeY() * cos(sensorAngleRad),
      ),
    ];
  }

  void checkSensorCollisionWithParedes(
    List<Vector2> sensorVector,
    Sensor sensor,
    List<List<Vector2>> paredesVector,
  ) {
    Map map = polysIntersect(sensorVector, paredesVector[0]);
    if (map.isEmpty) {
      map = polysIntersect(sensorVector, paredesVector[1]);
    }
    if (map.isNotEmpty) {
      sensor.updateColor(map['offset']);
    }
  }

  List<Vector2> getCarVector(double rad) {
    final position = body.position;
    final carSizeX = sizeX() / 2;
    final carSizeY = sizeY();

    final List<Vector2> list = [
      Vector2(
        position.x + carSizeX * cos(rad) + carSizeY * sin(rad),
        position.y - carSizeY * cos(rad) - carSizeX * sin(rad),
      ),
      Vector2(
        position.x - carSizeX * cos(rad) - carSizeY * sin(rad),
        position.y - carSizeY * cos(rad) - carSizeX * sin(rad),
      ),
      Vector2(
        position.x - carSizeX * cos(rad) - carSizeY * sin(rad),
        position.y + carSizeY * cos(rad) + carSizeX * sin(rad),
      ),
      Vector2(
        position.x + carSizeX * cos(rad) + carSizeY * sin(rad),
        position.y + carSizeY * cos(rad) + carSizeX * sin(rad),
      ),
    ];
    return list;
  }

  void checkCarCollisionWithParedes(List<List<Vector2>> paredesVector, List<Vector2> carVector) {
    Map map = polysIntersect(carVector, paredesVector[0]);
    if (map.isEmpty) {
      map = polysIntersect(carVector, paredesVector[1]);
    }
    if (map.isNotEmpty && paint.color != Colors.red) {
      updateColor(true);
    } else if (paint.color != Colors.green) {
      updateColor(false);
    }
  }
}
