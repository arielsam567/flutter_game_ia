import 'dart:convert';

import 'package:flutter_game_ia/IA/neural_network.dart';
import 'package:flutter_game_ia/game_ia/objects/charts_line.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Storage {
  static SharedPreferences? _sharedPreferences;
  static SharedPreferences? get storage => _sharedPreferences;

  Storage() {
    init();
  }

  static Future<void> init() async {
    _sharedPreferences ??= await SharedPreferences.getInstance();
  }

  void saveBrain(NeuralNetwork neuralNetwork) {
    final Map brain = neuralNetwork.toJson();
    final String brainString = jsonEncode(brain);
    _sharedPreferences!.setString('bestCar', brainString);
  }

  NeuralNetwork? getBrain() {
    final String? brainString = _sharedPreferences!.getString('bestCar');
    if (brainString == null) {
      return null;
    }

    final Map<String, dynamic> brain = jsonDecode(brainString);
    return NeuralNetwork.fromJson(brain);
  }

  void deleteBrain() {
    _sharedPreferences!.remove('bestCar');
    _sharedPreferences!.remove('bestPosition');
    _sharedPreferences!.remove('generation');
  }

  void saveBestPosition(double bestPosition) {
    _sharedPreferences!.setDouble('bestPosition', bestPosition);
  }

  double getBestPosition() {
    return _sharedPreferences!.getDouble('bestPosition') ?? 0;
  }

  void saveNumberOfCars(int parse) {
    _sharedPreferences!.setInt('carsNumber', parse);
  }

  void saveNumberOfSensors(int parse) {
    _sharedPreferences!.setInt('sensorsNumber', parse);
  }

  int getCarsNumber() {
    return _sharedPreferences!.getInt('carsNumber') ?? 50;
  }

  int getSensorsNumber() {
    return _sharedPreferences!.getInt('sensorsNumber') ?? 10;
  }

  List<GenerationInfo> getGenerationInfo() {
    final String? generationString = _sharedPreferences!.getString('generation');
    if (generationString == null) {
      return [GenerationInfo(0, 0)];
    }

    final List<dynamic> generationJson = jsonDecode(generationString);
    final List<GenerationInfo> generation = [];
    for (final Map<String, dynamic> generationInfo in generationJson) {
      generation.add(GenerationInfo.fromJson(generationInfo));
    }
    return generation;
  }

  void addGeneration(GenerationInfo generationInfo) {
    final List<GenerationInfo> generation = getGenerationInfo();
    generation.add(generationInfo);

    final String generationString = jsonEncode(generation);
    _sharedPreferences!.setString('generation', generationString);
  }
}
