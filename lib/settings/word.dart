import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_game_ia/settings/routes.dart';
import 'package:flutter_game_ia/utils/themes.dart';

final Vector2 screenSize = Vector2(1280, 720);
const double zoom = 100;
final Vector2 worldSize = Vector2(1280 / zoom, 720 / zoom);

class MyGame extends Forge2DGame with KeyboardEvents {
  final totalBodies = TextComponent(position: Vector2(5, 690))
    ..positionType = PositionType.viewport;
  final fps = FpsTextComponent(position: Vector2(5, 665))..positionType = PositionType.viewport;

  MyGame() : super(zoom: zoom, gravity: Vector2(0, 15));

  @override
  Future<void> onLoad() async {
    camera.viewport = FixedResolutionViewport(screenSize);

    add(Background(size: screenSize)..positionType = PositionType.viewport);

    add(fps);
    add(totalBodies);
  }

  @override
  void update(double dt) {
    super.update(dt);
    totalBodies.text = 'Bodies: ${world.bodies.length}';
  }

  @override
  KeyEventResult onKeyEvent(RawKeyEvent event, Set keysPressed) {
    if (event is RawKeyDownEvent) {
      if (keysPressed.contains(LogicalKeyboardKey.escape)) {
        Routes.navigatorKey.currentState?.pushNamedAndRemoveUntil(Routes.menu, (r) => false);
        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }
}

class Background extends PositionComponent {
  Background({super.size});

  @override
  void render(Canvas canvas) {
    canvas.drawRect(Rect.fromLTWH(0, 0, size.x, size.y), grayPaint);
  }
}

class MyGameWidget extends StatelessWidget {
  final MyGame game;

  const MyGameWidget({required this.game, super.key});

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
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: GameWidget(
        game: game,
      ),
    );
  }
}
