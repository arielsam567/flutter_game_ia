import 'dart:convert';

import 'package:flutter_game_ia/IA/neural_network.dart';
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
  }

  void saveBestPosition(double bestPosition) {
    _sharedPreferences!.setDouble('bestPosition', bestPosition);
  }

  double getBestPosition() {
    return _sharedPreferences!.getDouble('bestPosition') ?? 0;
  }
}
