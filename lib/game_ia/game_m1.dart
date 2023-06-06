//import async
import 'dart:async' as timer;

import 'package:flame/components.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_game_ia/IA/IA.dart';
import 'package:flutter_game_ia/game_ia/objects/car.dart';
import 'package:flutter_game_ia/game_ia/objects/sensor.dart';
import 'package:flutter_game_ia/game_ia/objects/wall.dart';
import 'package:flutter_game_ia/game_ia/word_ia.dart';
import 'package:flutter_game_ia/settings/storage.dart';

NeuralNetwork? bestBrain;

class GameComIA extends MyGameIa {
  final Storage storage = Storage();
  late Car bestCar;
  List<Sensor> carSensor = [];
  int sensorNumber = 10;
  final int N = 10;
  List<Car> cars = [];
  List<Car> traffic = [];
  final worldBounds = Rect.fromLTRB(0, -double.infinity, worldSize.x, worldSize.y);

  final List<Wall> paredes = [];
  List<List<Vector2>> paredesVector = [];

  final int roads = 3;

  timer.Future<void> generateCars() async {
    for (int i = 0; i < N; i++) {
      carSensor = [];
      for (int i = 0; i < sensorNumber; i++) {
        carSensor.add(Sensor());
      }
      final carAux = Car(worldSize, sensors: carSensor);

      if (i == 0 && bestBrain != null) {
        print('SET BEST BRAIN');
        carAux.brain = bestBrain!;
      }

      cars.add(carAux);
      await add(carAux);
      for (int i = 0; i < sensorNumber; i++) {
        await add(carSensor[i]);
      }
    }
    bestCar = cars[0];

    print('Cars generated');
  }

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
    await loadSprite('car.png');
    await loadSprite('car_red.png');

    await addLinesRoad();

    await generateCars();
    addTraffic();

    camera.followBodyComponent(
      bestCar,
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
        bestCar.controls.moveOn();
      }
      if (event.logicalKey == LogicalKeyboardKey.keyS) {
        bestCar.controls.moveBack();
      }
      if (event.logicalKey == LogicalKeyboardKey.keyA) {
        bestCar.controls.turnLeft();
      }
      if (event.logicalKey == LogicalKeyboardKey.keyD) {
        bestCar.controls.turnRight();
      }

      if (event.logicalKey == LogicalKeyboardKey.keyS) {
        bestBrain = bestCar.brain;
        print('SAVE BEST BRAIN');
      }
    }

    if (event is RawKeyUpEvent) {
      if (event.logicalKey == LogicalKeyboardKey.keyW) {
        bestCar.controls.forward = false;
      }
      if (event.logicalKey == LogicalKeyboardKey.keyS) {
        bestCar.controls.backward = false;
      }
      if (event.logicalKey == LogicalKeyboardKey.keyA) {
        bestCar.controls.left = false;
      }
      if (event.logicalKey == LogicalKeyboardKey.keyD) {
        bestCar.controls.right = false;
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

  @override
  void update(double dt) {
    super.update(dt);
    for (final Car element in cars) {
      element.checkCollisions(paredesVector, traffic);
    }
    setNewBestCar();
  }

  void addTraffic() {
    final t1 = Car(
      worldSize,
      sensors: [],
      maxSpeed: 2,
      isTraffic: true,
      initialPosition: Vector2(
        worldSize.x / 2,
        -2,
      ),
    );
    final t2 = Car(
      worldSize,
      sensors: [],
      maxSpeed: 2,
      isTraffic: true,
      initialPosition: Vector2(
        worldSize.x / 2 + 2.3,
        -7,
      ),
    );
    final t3 = Car(
      worldSize,
      sensors: [],
      maxSpeed: 2,
      isTraffic: true,
      initialPosition: Vector2(
        worldSize.x / 2 - 2.3,
        -7,
      ),
    );

    t1.controls.forward = true;
    t2.controls.forward = true;
    t3.controls.forward = true;
    traffic.addAll([t1, t2, t3]);
    add(t1);
    add(t2);
    add(t3);

    // timer.Timer.periodic(const Duration(seconds: 3), (timer) {
    //   final Car trafficCar = Car(
    //     worldSize,
    //     sensors: [],
    //     maxSpeed: 2,
    //     isTraffic: true,
    //     initialPosition: Vector2(
    //       Random().nextDouble() * worldSize.x * 0.8,
    //       bestCar.getLastPosition() - 7,
    //     ),
    //   );
    //   trafficCar.controls.forward = true;
    //   traffic.add(trafficCar);
    //
    //   add(trafficCar);
    // });
  }

  void setNewBestCar() {
    for (final car in cars) {
      if (car.body.position.y < bestCar.body.position.y) {
        bestCar = car;
      }
    }
    camera.followBodyComponent(
      bestCar,
      worldBounds: worldBounds,
      relativeOffset: const Anchor(0.5, 0.7),
    );
  }
}
