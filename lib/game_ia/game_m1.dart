import 'dart:async' as timer;
import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_game_ia/IA/neural_network.dart';
import 'package:flutter_game_ia/game_ia/objects/car.dart';
import 'package:flutter_game_ia/game_ia/objects/charts_line.dart';
import 'package:flutter_game_ia/game_ia/objects/sensor.dart';
import 'package:flutter_game_ia/game_ia/objects/wall.dart';
import 'package:flutter_game_ia/game_ia/word_ia.dart';
import 'package:flutter_game_ia/settings/routes.dart';
import 'package:flutter_game_ia/settings/storage.dart';
import 'package:flutter_game_ia/utils/utils.dart';

int durationToNewGeneration = 15;
double mutateRate = 0.25;

class GameComIA extends MyGameIa {
  late List<GenerationInfo> generation;
  final Storage storage = Storage();
  late Car bestCar;
  List<Sensor> carSensor = [];
  List<Car> cars = [];
  List<Car> traffic = [];
  final worldBounds = Rect.fromLTRB(0, -double.infinity, worldSize.x, worldSize.y);
  NeuralNetwork? bestBrain;
  bool closePage = false;
  late timer.Timer _timer;

  final List<Wall> walls = [];
  List<List<Vector2>> wallsVector = [];
  double lastPosition = 0;

  final int roads = 5;

  timer.Future<void> generateCars() async {
    generation = storage.getGenerationInfo();

    final int N = storage.getCarsNumber();
    final int sensorNumber = storage.getSensorsNumber();
    for (int i = 0; i < N; i++) {
      carSensor = [];
      for (int i = 0; i < sensorNumber; i++) {
        carSensor.add(Sensor());
      }
      final carAux = Car(worldSize, sensors: carSensor);

      cars.add(carAux);
      await add(carAux);
    }
    for (int i = 0; i < sensorNumber; i++) {
      add(carSensor[i]);
    }

    debugPrint('\nCars generated');
  }

  void initWallsVector() {
    for (final Wall element in walls) {
      final paredePosition = element.body.position;
      wallsVector.add([
        Vector2(paredePosition.x + element.sizeX(), paredePosition.y - element.sizeY()),
        Vector2(paredePosition.x - element.sizeX(), paredePosition.y + element.sizeY()),
      ]);
    }
  }

  @override
  Future<void> onLoad() async {
    super.onLoad();
    await Future.wait([
      loadSprite('car.png'),
      loadSprite('car_red.png'),
      addLinesRoad(),
      generateCars(),
    ]);
    setBestBrain();

    addTraffic();

    camera.followBodyComponent(
      bestCar,
      worldBounds: worldBounds,
      relativeOffset: const Anchor(0.5, 0.7),
    );
    initWallsVector();
    startNewGeneration();
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

      if (event.logicalKey == LogicalKeyboardKey.keyM) {
        showMessage('Best brain saved');
        storage.saveBrain(bestCar.brain);
        showMessage('Best brain saved');
      }

      if (keysPressed.contains(LogicalKeyboardKey.escape)) {
        closePage = true;
        storage.deleteBrain();
        showMessage('Best brain removed', color: '#B83131');
        return KeyEventResult.handled;
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
    final leftWall = Wall(worldSize);
    final rightWall = Wall(worldSize, isLeft: false);
    walls.addAll([rightWall, leftWall]);
    await add(leftWall);
    await add(rightWall);
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
    updateCars();
  }

  void updateCars() {
    for (final Car element in cars) {
      element.checkCollisions(wallsVector, traffic);
    }
    checkBestCar();
  }

  double getLaneCenter(double road) {
    final laneWidth = worldSize.x / roads;
    return (0 + laneWidth / 2 + min(road, roads - 1) * laneWidth);
  }

  timer.Future<void> createOneCarToTraffic(List<double> roads, double yPosition,
      [double maxSpeed = 2]) async {
    for (final double element in roads) {
      final c1 = Car(
        worldSize,
        sensors: [],
        maxSpeed: maxSpeed,
        isTraffic: true,
        initialPosition: Vector2(
          getLaneCenter(element),
          yPosition,
        ),
      );

      traffic.add(c1);

      await add(c1);
    }
  }

  timer.Future<void> addTraffic() async {
    await Future.wait([
      createOneCarToTraffic([2], -2),
      createOneCarToTraffic([1, 3], -6),
      createOneCarToTraffic([0, 2, 4], -10),
      createOneCarToTraffic([1, 3], -14),
      createOneCarToTraffic([0, 1, 2, 4], -18),
      createOneCarToTraffic([-0.3, 0.5, 3.5, 4.3], -22),
    ]);

    _timer = timer.Timer.periodic(const Duration(seconds: 2), (timer) {
      checkStoppedCars();
      double position = bestCar.body.position.y;
      if (position < -19) {
        position += -6;

        createOneCarToTraffic([
          Random().nextDouble() * 4,
          Random().nextDouble() * 4,
          Random().nextDouble() * 4,
        ], position);
      }
    });
  }

  @override
  void onRemove() {
    super.onRemove();
    closePage = true;
    _timer.cancel();
  }

  void checkBestCar() {
    cars.removeWhere((element) => element.controls.isDead);

    for (int i = 0; i < cars.length; i++) {
      if (cars[i].body.position.y < bestCar.body.position.y) {
        bestCar = cars[i];
      }
    }

    camera.followBodyComponent(
      bestCar,
      worldBounds: worldBounds,
      relativeOffset: const Anchor(0.5, 0.7),
    );
    for (int t = 0; t < carSensor.length; t++) {
      carSensor[t].body.setTransform(bestCar.sensors[t].position, bestCar.sensors[t].angleSensor);
      carSensor[t].updateColor(bestCar.sensors[t].reading);
    }
  }

  void setBestBrain() {
    bestBrain = storage.getBrain();

    if (bestBrain != null) {
      debugPrint('HAS BEST BRAIN');
      final double mutationRate = mutateRate;

      for (int i = 0; i < cars.length; i++) {
        cars[i].brain = bestBrain!.clone();
        if (i > 0) {
          NeuralNetwork.mutate(cars[i].brain, mutationRate);
        }
      }
    } else {
      debugPrint('NO BEST BRAIN');
    }
    bestCar = cars[0];
  }

  void startNewGeneration({bool isRestart = false}) {
    Future.delayed(
      Duration(seconds: isRestart ? 0 : durationToNewGeneration),
      () async {
        if (!closePage) {
          closePage = true;
          pauseEngine();
          await Future.delayed(const Duration(seconds: 1), () {});
          saveBestBrain();
          final distance = bestCar.getLastPosition().abs();
          storage.addGeneration(GenerationInfo(getNewGeneration(), distance));
          Routes.generateNewGeneration();
        }
      },
    );
  }

  void saveBestBrain() {
    final double bestScore = storage.getBestPosition();
    final currentScore = bestCar.body.position.y;
    if (currentScore < bestScore) {
      storage.saveBrain(bestCar.brain);
      storage.saveBestPosition(currentScore);
      showMessage('Best brain saved');
    }
    debugPrint('currentScore $currentScore | bestScore $bestScore');
  }

  int getNewGeneration() {
    return generation.last.generation == 0 ? generation.length : generation.length + 1;
  }

  void checkStoppedCars() {
    cars.removeWhere((element) {
      final bool delete = element.isStopped() || element.getLastPosition() > 3;
      if (delete) {
        element.deleteItem();
        return true;
      }
      return false;
    });
    if (cars.isEmpty) {
      startNewGeneration(isRestart: true);
    }
  }
}
