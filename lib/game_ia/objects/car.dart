import 'dart:math' as math;
import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';
import 'package:flutter_game_ia/IA/neural_network.dart';
import 'package:flutter_game_ia/game_ia/game_m1.dart';
import 'package:flutter_game_ia/game_ia/objects/sensor.dart';
import 'package:flutter_game_ia/game_medium/game_m1/control.dart';
import 'package:flutter_game_ia/utils/utils.dart';

class Car extends BodyComponent {
  final double carOpacity = 0.4;
  final Vector2 worldSize;
  final double maxSpeed;
  final double friction = 0.2;
  final List<Sensor> sensors;
  final bool isTraffic;
  final Vector2? initialPosition;
  NeuralNetwork brain = NeuralNetwork([sensorNumber, sensorNumber + 3, 4]);
  final Controls controls = Controls();

  double speed = 0;
  double acceleration = 0.50;
  double carAngle = 0;
  double carSize = 1.6;
  double xSize = 0.25;
  double ySize = 0.5;
  double angleIncrement = 0.04;
  double angleSpread = 2;
  double lastPosition = 0;

  Car(
    this.worldSize, {
    required this.sensors,
    this.isTraffic = false,
    this.initialPosition,
    this.maxSpeed = 6,
  });

  @override
  Future<void> onLoad() async {
    super.onLoad();

    if (isTraffic) {
      final sprite = Sprite(gameRef.images.fromCache('car_red.png'));
      add(
        SpriteComponent(
          sprite: sprite,
          size: Vector2(.6 * carSize, 1 * carSize),
          anchor: Anchor.center,
        ),
      );
    }

    // final sprite = Sprite(gameRef.images.fromCache(isTraffic ? 'car_red.png' : 'car.png'));
    // add(
    //   SpriteComponent(
    //     sprite: sprite,
    //     size: Vector2(.6 * carSize, 1 * carSize),
    //     anchor: Anchor.center,
    //   ),
    // );
  }

  @override
  Body createBody() {
    final bodyDef = BodyDef(
      position: initialPosition ?? Vector2(worldSize.x / 2, 3),
      type: BodyType.dynamic,
    );

    final shape = PolygonShape()..setAsBoxXY(xSize * carSize, ySize * carSize);
    final fixtureDef = FixtureDef(shape, isSensor: !isTraffic);
    paint.color = Colors.green.withOpacity(carOpacity);
    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (controls.isDead) {
      body.linearVelocity = Vector2.zero();
      return;
    }
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
    if (controls.forward && !controls.isDead) {
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
    final Vector2 newVelocity = Vector2(-math.sin(carAngle) * speed, math.cos(carAngle) * speed);

    if (newVelocity != (body.linearVelocity)) {
      body.setTransform(Vector2(body.position.x, body.position.y), carAngle);
      body.linearVelocity = newVelocity;
    }
    // body.setTransform(Vector2(body.position.x, body.position.y), carAngle);
    // body.linearVelocity = Vector2(-math.sin(carAngle) * speed, math.cos(carAngle) * speed);
  }

  double sizeX() {
    return xSize * carSize;
  }

  double sizeY() {
    return ySize * carSize;
  }

  void updateColor(bool isColliding) {
    if (isColliding && Colors.red != paint.color) {
      paint.color = Colors.red;
    }
  }

  void checkCollisions(List<List<Vector2>> paredesVector, List<Car> traffic) {
    final carPosition = body.position;
    final double rad = carAngle;

    //SENSOR
    updateSensorPosition(carPosition, rad);
    for (int i = 0; i < sensors.length; i++) {
      final List<Vector2> sensorVector = getSensorsVector(rad, sensors[i], i);
      checkSensorCollisionWithTraffic(sensorVector, sensors[i], traffic, paredesVector);
    }
    final List<double> offsets = sensors.map((s) => s.reading).toList();
    final outputs = NeuralNetwork.feedForward(offsets, brain);

    if (!controls.isDead) {
      controls.forward = outputs[0] > 0;
      controls.left = outputs[1] > 0;
      controls.right = outputs[2] > 0;
      controls.backward = outputs[3] > 0;
    }

    //CAR AND PAREDES
    final List<Vector2> carVector = getCarVector(rad);
    checkCarCollisionWithParedes(paredesVector, carVector);

    //CAR AND TRAFFIC
    checkCarCollisionWithTraffic(carVector, traffic);
  }

  void updateSensorPosition(Vector2 carPosition, double carAngleRad) {
    final double angleIncrement = angleSensor;
    for (int i = 0; i < sensors.length; i++) {
      final double sensorAngleRad = carAngleRad - pi / (2 * angleSpread) + angleIncrement * i;
      final Vector2 newPosition = Vector2(
        carPosition.x + 2.8 * sin(sensorAngleRad),
        carPosition.y - 2.8 * cos(sensorAngleRad),
      );
      if (newPosition != (sensors[i].body.position)) {
        sensors[i].body.setTransform(newPosition, sensorAngleRad);
      }
    }
  }

  double get angleSensor => (pi / angleSpread) / (sensors.length - 1);

  List<Vector2> getSensorsVector(double carAngleRad, Sensor sensor, int i) {
    final sensorPosition = sensor.body.position;

    final double sensorAngleRad = carAngleRad - pi / (2 * angleSpread) + angleSensor * i;
    final double sizeY = sensor.sizeY();
    final aux = sizeY * sin(sensorAngleRad);
    final aux2 = sizeY * cos(sensorAngleRad);
    return [
      Vector2(
        sensorPosition.x + aux,
        sensorPosition.y - aux2,
      ),
      Vector2(
        sensorPosition.x - aux,
        sensorPosition.y + aux2,
      ),
    ];
  }

  void checkSensorCollisionWithTraffic(
    List<Vector2> sensorVector,
    Sensor sensor,
    List<Car> traffic,
    List<List<Vector2>> paredesVector,
  ) {
    final List<Map> touch = [];
    for (int i = 0; i < traffic.length; i++) {
      final Car car = traffic[i];
      final List<Vector2> carVector = car.getCarVector(car.carAngle);
      final Map map = polysIntersect(sensorVector, carVector);
      if (map.isNotEmpty) {
        touch.add(map);
      }
    }

    for (int i = 0; i < paredesVector.length; i++) {
      final List<Vector2> paredVector = paredesVector[i];
      final Map map = polysIntersect(sensorVector, paredVector);
      if (map.isNotEmpty) {
        touch.add(map);
      }
    }

    if (touch.isEmpty) {
      sensor.updateColor(0);
    } else {
      final List<double> offsets = touch.map((e) => e['offset'] as double).toList();
      final double min = offsets.reduce(math.min);
      sensor.updateColor(min);
    }
  }

  List<Vector2> getCarVector(double rad) {
    final position = body.position;
    final carSizeX = sizeX() / 2;
    final carSizeY = sizeY();
    final cosRad = cos(rad);
    final sinRad = sin(rad);
    final aux = carSizeX * cosRad;
    final aux2 = carSizeX * sinRad;
    final aux3 = carSizeY * cosRad;
    final aux4 = carSizeY * sinRad;

    final List<Vector2> list = [
      Vector2(
        position.x + aux + aux4,
        position.y - aux3 - aux2,
      ),
      Vector2(
        position.x - aux - aux4,
        position.y - aux3 - aux2,
      ),
      Vector2(
        position.x - aux - aux4,
        position.y + aux3 + aux2,
      ),
      Vector2(
        position.x + aux + aux4,
        position.y + aux3 + aux2,
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
      controls.setBateu();
    }
  }

  void checkCarCollisionWithTraffic(List<Vector2> carVector, List<Car> cars) {
    for (final Car element in cars) {
      final List<Vector2> oneCarVector = element.getCarVector(element.carAngle);
      final Map map = polysIntersect(carVector, oneCarVector);
      if (map.isNotEmpty && paint.color != Colors.red) {
        controls.setBateu();
        updateColor(true);
      }
    }
  }

  double getLastPosition() {
    final double lastPosition = body.position.y;
    return lastPosition;
  }

  void deleteItem() {
    world.destroyBody(body);
    gameRef.remove(this);
    for (final Sensor sensor in sensors) {
      sensor.deleteItem();
    }
  }

  bool isStopped() {
    if (lastPosition == body.position.y) {
      return true;
    }
    lastPosition = body.position.y;
    return false;
  }
}
