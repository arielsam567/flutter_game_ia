import 'package:flutter/material.dart';
import 'package:flutter_game_ia/IA/neural_network.dart';
import 'package:flutter_game_ia/utils/utils.dart';

class Visualizer {
  static void drawNetwork(Canvas ctx, NeuralNetwork network, Size size) {
    const double margin = 50;
    const double left = margin;
    const double top = margin;
    final double width = size.width - margin * 2;
    final double height = size.height - margin * 2;

    final double levelHeight = height / network.levels.length;

    final Paint paint = Paint();
    for (int i = network.levels.length - 1; i >= 0; i--) {
      final double levelTop = top +
          lerp(
            height - levelHeight,
            0,
            network.levels.length == 1 ? 0.5 : i / (network.levels.length - 1),
          );
      paint.style = PaintingStyle.stroke;
      paint.strokeWidth = 1.0;
      paint.color = Colors.black;

      drawLevel(
        ctx,
        network.levels[i],
        left,
        levelTop,
        width,
        levelHeight,
        i == network.levels.length - 1 ? ['🠉', '🠈', '🠊', '🠋'] : [],
        paint,
      );
    }
  }

  static void drawLevel(Canvas ctx, Level level, double left, double top, double width,
      double height, List<String> outputLabels, Paint paint) {
    final double right = left + width;
    final double bottom = top + height;

    for (int i = 0; i < level.inputs.length; i++) {
      for (int j = 0; j < level.outputs.length; j++) {
        ctx.drawLine(
          Offset(getNodeX(level.inputs, i, left, right), bottom),
          Offset(getNodeX(level.outputs, j, left, right), top),
          paint,
        );
      }
    }

    const double nodeRadius = 18;
    for (int i = 0; i < level.inputs.length; i++) {
      final double x = getNodeX(level.inputs, i, left, right);
      ctx.drawCircle(Offset(x, bottom), nodeRadius, paint);
      ctx.drawCircle(Offset(x, bottom), nodeRadius * 0.6, paint);
    }

    for (int i = 0; i < level.outputs.length; i++) {
      final double x = getNodeX(level.outputs, i, left, right);
      ctx.drawCircle(Offset(x, top), nodeRadius, paint);
      ctx.drawCircle(Offset(x, top), nodeRadius * 0.6, paint);

      ctx.drawCircle(Offset(x, top), nodeRadius * 0.8, paint);

      final TextPainter textPainter = TextPainter(
        text: TextSpan(
            text: outputLabels[i],
            style: const TextStyle(color: Colors.black, fontSize: nodeRadius * 1.5)),
        textDirection: TextDirection.ltr,
      );

      textPainter.layout();
      textPainter.paint(ctx, Offset(x, top + nodeRadius * 0.1));
    }
  }

  static double getNodeX(List<double> nodes, int index, double left, double right) {
    return lerp(
      left,
      right,
      nodes.length == 1 ? 0.5 : index / (nodes.length - 1),
    );
  }
}

class NetworkPainter extends CustomPainter {
  final NeuralNetwork network;

  NetworkPainter(this.network);

  @override
  void paint(Canvas canvas, Size size) {
    Visualizer.drawNetwork(canvas, network, size);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
