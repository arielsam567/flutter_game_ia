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

int sensorNumber = 10;
int durationToNewGeneration = 15;

class GameComIA extends MyGameIa {
  final List<GenerationInfo> generation;
  final Storage storage = Storage();
  late Car bestCar;
  List<Sensor> carSensor = [];
  final int N = 10;
  List<Car> cars = [];
  List<Car> traffic = [];
  final worldBounds = Rect.fromLTRB(0, -double.infinity, worldSize.x, worldSize.y);
  NeuralNetwork? bestBrain;
  bool closePage = false;
  late timer.Timer _timer;

  final List<Wall> paredes = [];
  List<List<Vector2>> paredesVector = [];

  final int roads = 5;

  GameComIA(this.generation);

  timer.Future<void> generateCars() async {
    for (int i = 0; i < N; i++) {
      carSensor = [];
      for (int i = 0; i < sensorNumber; i++) {
        carSensor.add(Sensor());
      }
      final carAux = Car(worldSize, sensors: carSensor);

      cars.add(carAux);
      await add(carAux);
      for (int i = 0; i < sensorNumber; i++) {
        await add(carSensor[i]);
      }
    }
    bestCar = cars[0];

    debugPrint('Cars generated');
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
    setBestBrain();

    addTraffic();

    camera.followBodyComponent(
      bestCar,
      worldBounds: worldBounds,
      relativeOffset: const Anchor(0.5, 0.7),
    );
    initParedeVector();
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

      if (event.logicalKey == LogicalKeyboardKey.keyR) {
        closePage = true;

        storage.deleteBrain();
        showMessage('Best brain removed', color: '#B83131');
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
    deleteDumbCars();
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
    await createOneCarToTraffic([2], -2);
    await createOneCarToTraffic([1, 3], -6);
    await createOneCarToTraffic([0, 2, 4], -9);
    await createOneCarToTraffic([0, 1, 2, 4], -13);
    await createOneCarToTraffic([0, 1, 3, 4], -18);

    _timer = timer.Timer.periodic(const Duration(seconds: 2), (timer) {
      checkStoppedCars();
      // final Car trafficCar = Car(
      //   worldSize,
      //   sensors: [],
      //   maxSpeed: 2,
      //   isTraffic: true,
      //   initialPosition: Vector2(
      //     Random().nextDouble() * worldSize.x * 0.8,
      //     bestCar.getLastPosition() - 7,
      //   ),
      // );
      // trafficCar.controls.forward = true;
      // traffic.add(trafficCar);
      //
      // add(trafficCar);
    });
  }

  @override
  void onRemove() {
    super.onRemove();
    _timer.cancel();
  }

  void checkBestCar() {
    cars.removeWhere((element) => element.controls.isDead);
    for (int i = 0; i < cars.length; i++) {
      if (cars[i].body.position.y < bestCar.body.position.y) {
        bestCar = cars[i];
        cars[i].paint.color = Colors.amber;
      } else {
        cars[i].paint.color = Colors.green;
      }
    }
    camera.followBodyComponent(
      bestCar,
      worldBounds: worldBounds,
      relativeOffset: const Anchor(0.5, 0.7),
    );
  }

  void setBestBrain() {
    bestBrain = storage.getBrain();
    if (bestBrain != null) {
      debugPrint('HAS BEST BRAIN');

      for (int i = 0; i < cars.length; i++) {
        cars[i].brain = bestBrain!.clone();
        if (i > 0) {
          NeuralNetwork.mutate(cars[i].brain, 0.25);
        }
      }
    } else {
      debugPrint('NO BEST BRAIN');
    }
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
          generation.add(GenerationInfo(getNewGeneration(), distance));
          Routes.generateNewGeneration(generation);
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
    }
  }

  int getNewGeneration() {
    return generation.last.generation == 0 ? generation.length : generation.length + 1;
  }

  void deleteDumbCars() {
    cars.removeWhere((element) {
      final bool delete = element.getLastPosition() > 3.1;
      if (delete) {
        element.deleteItem();
      }
      return delete;
    });
  }

  void checkStoppedCars() {
    cars.removeWhere((element) {
      final bool delete = element.isStopped();
      if (delete) {
        element.deleteItem();
      }
      return delete;
    });
    if (cars.isEmpty) {
      startNewGeneration(isRestart: true);
    }
  }
}
