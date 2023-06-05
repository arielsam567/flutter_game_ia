import 'package:flame/components.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_game_ia/game_ia/objects/car.dart';
import 'package:flutter_game_ia/game_ia/objects/sensor.dart';
import 'package:flutter_game_ia/game_ia/objects/wall.dart';
import 'package:flutter_game_ia/game_ia/word_ia.dart';

class GameComIA extends MyGameIa {
  late Car car;
  List<Sensor> carSensor = [];
  int sensorNumber = 5;

  final List<Wall> paredes = [];
  List<List<Vector2>> paredesVector = [];

  final int roads = 3;

  void initParedeVector() {
    for (final Wall element in paredes) {
      final paredePosition = element.body.position;
      paredesVector.add([
        Vector2(paredePosition.x + element.sizeX(), paredePosition.y - element.sizeY()),
        Vector2(paredePosition.x - element.sizeX(), paredePosition.y + element.sizeY()),
      ]);
    }
  }

  @override
  Future<void> onLoad() async {
    super.onLoad();

    car = Car(worldSize);
    await loadSprite('car.png');

    await addLinesRoad();

    await add(car);
    for (int i = 0; i < sensorNumber; i++) {
      carSensor.add(Sensor());
      await add(carSensor[i]);
    }

    final worldBounds = Rect.fromLTRB(0, -double.infinity, worldSize.x, worldSize.y);
    camera.followBodyComponent(
      car,
      worldBounds: worldBounds,
      relativeOffset: const Anchor(0.5, 0.7),
    );
    initParedeVector();
  }

  @override
  KeyEventResult onKeyEvent(RawKeyEvent event, Set keysPressed) {
    super.onKeyEvent(event, keysPressed);
    if (event is RawKeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.keyW) {
        car.controls.moveOn();
      }
      if (event.logicalKey == LogicalKeyboardKey.keyS) {
        car.controls.moveBack();
      }
      if (event.logicalKey == LogicalKeyboardKey.keyA) {
        car.controls.turnLeft();
      }
      if (event.logicalKey == LogicalKeyboardKey.keyD) {
        car.controls.turnRight();
      }
    }

    if (event is RawKeyUpEvent) {
      if (event.logicalKey == LogicalKeyboardKey.keyW) {
        car.controls.forward = false;
      }
      if (event.logicalKey == LogicalKeyboardKey.keyS) {
        car.controls.backward = false;
      }
      if (event.logicalKey == LogicalKeyboardKey.keyA) {
        car.controls.left = false;
      }
      if (event.logicalKey == LogicalKeyboardKey.keyD) {
        car.controls.right = false;
      }
    }

    return KeyEventResult.handled;
  }

  Future<void> addLinesRoad() async {
    final paredeEsqueda = Wall(worldSize);
    final paredeDireita = Wall(worldSize, isLeft: false);
    paredes.addAll([paredeDireita, paredeEsqueda]);
    await add(paredeEsqueda);
    await add(paredeDireita);
    for (int i = 0; i < roads - 1; i++) {
      add(
        DashedWall(
          worldSize,
          xPosition: (worldSize.x / (roads)) * (i + 1),
        ),
      );
    }
  }

  List<Vector2> lastVector = [];
  @override
  void update(double dt) {
    super.update(dt);
    car.checkCollisions(paredesVector, carSensor[0]);
  }
}
