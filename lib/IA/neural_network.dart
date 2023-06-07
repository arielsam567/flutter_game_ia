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

  NeuralNetwork.fromJson(Map<String, dynamic> json)
      : levels = (json['levels'] as List)
            .map((item) => Level.fromJson(item as Map<String, dynamic>))
            .toList();

  Map<String, dynamic> toJson() => {'levels': levels.map((level) => level.toJson()).toList()};

  static List<double> feedForward(List<double> givenInputs, NeuralNetwork network) {
    List<double> outputs = Level.feedForward(givenInputs, network.levels[0]);
    for (int i = 1; i < network.levels.length; i++) {
      outputs = Level.feedForward(outputs, network.levels[i]);
    }
    return outputs;
  }

  static mutate(NeuralNetwork network, [double amount = 1]) {
    for (final Level level in network.levels) {
      for (int i = 0; i < level.biases.length; i++) {
        level.biases[i] = lerp(level.biases[i], Random().nextDouble() * 2 - 1, amount);
      }
      for (int i = 0; i < level.weights.length; i++) {
        for (int j = 0; j < level.weights[i].length; j++) {
          level.weights[i][j] = lerp(
            level.weights[i][j],
            Random().nextDouble() * 2 - 1,
            amount,
          );
        }
      }
    }
  }

  NeuralNetwork clone() {
    final List<int> neuronCounts = levels.map((level) => level.inputs.length).toList();
    neuronCounts.add(levels.last.outputs.length);
    final NeuralNetwork clone = NeuralNetwork(neuronCounts);
    for (int i = 0; i < levels.length; i++) {
      clone.levels[i].biases = List.from(levels[i].biases);
      clone.levels[i].weights = levels[i].weights.map((list) => List<double>.from(list)).toList();
    }
    return clone;
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

  Level.fromJson(Map<String, dynamic> json)
      : inputs = List<double>.from(json['inputs']),
        outputs = List<double>.from(json['outputs']),
        biases = List<double>.from(json['biases']),
        weights = (json['weights'] as List).map((item) => List<double>.from(item)).toList();

  // Método adicional para JSON
  Map<String, dynamic> toJson() => {
        'inputs': inputs,
        'outputs': outputs,
        'biases': biases,
        'weights': weights,
      };
}
