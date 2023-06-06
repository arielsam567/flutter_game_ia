import 'dart:math';

import 'package:flutter_game_ia/utils/utils.dart';

class NeuralNetwork {
  List<Level> levels = [];

  NeuralNetwork(List<int> neuronCounts) {
    levels = [];
    for (int i = 0; i < neuronCounts.length - 1; i++) {
      levels.add(Level(neuronCounts[i], neuronCounts[i + 1]));
    }
  }

  static List<double> feedForward(List<double> givenInputs, NeuralNetwork network) {
    List<double> outputs = Level.feedForward(givenInputs, network.levels[0]);
    for (int i = 1; i < network.levels.length; i++) {
      outputs = Level.feedForward(outputs, network.levels[i]);
    }
    return outputs;
  }

  static void mutate(NeuralNetwork network, [double amount = 1]) {
    for (final Level level in network.levels) {
      for (int i = 0; i < level.biases.length; i++) {
        level.biases[i] = lerp(level.biases[i], Random().nextDouble() * 2 - 1, amount);
      }
      for (int i = 0; i < level.weights.length; i++) {
        for (int j = 0; j < level.weights[i].length; j++) {
          level.weights[i][j] = lerp(level.weights[i][j], Random().nextDouble() * 2 - 1, amount);
        }
      }
    }
  }
}

class Level {
  List<double> inputs = [];
  List<double> outputs = [];
  List<double> biases = [];
  List<List<double>> weights = [];

  Level(int inputCount, int outputCount) {
    inputs = List.filled(inputCount, 0);
    outputs = List.filled(outputCount, 0);
    biases = List.filled(outputCount, 0.0);

    weights = List.generate(inputCount, (_) => List.filled(outputCount, 0.0));

    randomize(this);
  }

  void randomize(Level level) {
    for (int i = 0; i < level.inputs.length; i++) {
      for (int j = 0; j < level.outputs.length; j++) {
        level.weights[i][j] = Random().nextDouble() * 2 - 1;
      }
    }

    for (int i = 0; i < level.biases.length; i++) {
      level.biases[i] = Random().nextDouble() * 2 - 1;
    }
  }

  static List<double> feedForward(List<double> givenInputs, Level level) {
    for (int i = 0; i < level.inputs.length; i++) {
      level.inputs[i] = givenInputs[i];
    }

    for (int i = 0; i < level.outputs.length; i++) {
      double sum = 0;
      for (int j = 0; j < level.inputs.length; j++) {
        sum += level.inputs[j] * level.weights[j][i];
      }

      if (sum > level.biases[i]) {
        level.outputs[i] = 1;
      } else {
        level.outputs[i] = 0;
      }
    }

    return level.outputs;
  }
}
