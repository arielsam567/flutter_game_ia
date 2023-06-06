import 'package:flutter_game_ia/game_ia/objects/car.dart';
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

  void saveBestCar(Car car) {
    final String brain = car.brain.toString();
    print('brain: $brain');
    _sharedPreferences!.setString('bestCar', brain);
  }
}
