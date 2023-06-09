import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_game_ia/game_ia/objects/charts_line.dart';
import 'package:flutter_game_ia/game_ia/word_ia.dart';
import 'package:flutter_game_ia/settings/routes.dart';

class MyGameWidgetIa extends StatelessWidget {
  final MyGameIa game;
  final List<GenerationInfo> generation;
  final bool selfDrive;

  const MyGameWidgetIa({
    required this.game,
    required this.generation,
    this.selfDrive = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
        leading: IconButton(
          onPressed: () {
            Routes.navigatorKey.currentState?.pushNamedAndRemoveUntil(Routes.menu, (r) => false);
          },
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.amber,
          ),
        ),
      ),
      body: Column(
        children: [
          if (!selfDrive) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              height: 200,
              width: MediaQuery.of(context).size.width,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.2,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Generation: ${getCurrentGeneration()}'),
                        Text('Best location: ${getBestLocation()}'),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 200,
                    width: MediaQuery.of(context).size.width * 0.7,
                    child: LineChartPage(
                      chartData: generation,
                    ),
                  ),
                ],
              ),
            ),
          ],
          SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height - (selfDrive ? 0 : 200),
            child: GameWidget(
              game: game,
            ),
          ),
        ],
      ),
    );
  }

  String getCurrentGeneration() {
    return generation.length.toString();
  }

  String getBestLocation() {
    if (generation.isEmpty) {
      return '0';
    } else {
      generation.sort((a, b) => a.distance.compareTo(b.distance));
      return generation.last.distance.toStringAsFixed(2);
    }
  }
}
