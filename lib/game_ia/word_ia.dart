import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_game_ia/main.dart';
import 'package:flutter_game_ia/settings/routes.dart';
import 'package:flutter_game_ia/utils/themes.dart';

const double sizeX = 720;
const double sizeY = 1280;
const double zoom = 100;
Vector2 gravity = Vector2(0, 0);
final Vector2 screenSize = Vector2(sizeX, sizeY);
final Vector2 worldSize = Vector2(sizeX / zoom, sizeY / zoom);

class MyGameIa extends Forge2DGame with KeyboardEvents {
  final totalBodies = TextComponent(
    position: Vector2(sizeX / 2, sizeY - 30),
  )
    ..positionType = PositionType.viewport
    ..textRenderer = TextPaint(
      style: const TextStyle(
        fontSize: 20,
        color: Colors.black,
      ),
    );

  final fps = FpsTextComponent(position: Vector2(sizeX / 2, sizeY - 60))
    ..positionType = PositionType.viewport;

  MyGameIa() : super(zoom: zoom, gravity: gravity);

  @override
  Future<void> onLoad() async {
    camera.viewport = FixedResolutionViewport(screenSize);

    // Adds a black background to the viewport
    add(_Background(size: screenSize)..positionType = PositionType.viewport);

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
        navigatorKey.currentState?.pushNamedAndRemoveUntil(Routes.menu, (r) => false);
        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }

  @override
  Color backgroundColor() {
    // Paints the background red
    return Colors.amber;
  }
}

class _Background extends PositionComponent {
  _Background({super.size});

  @override
  void render(Canvas canvas) {
    canvas.drawRect(Rect.fromLTWH(0, 0, size.x, size.y), grayPaint);
  }
}

class MyGameWidgetIa extends StatelessWidget {
  final MyGameIa game;

  const MyGameWidgetIa({required this.game, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
        leading: IconButton(
          onPressed: () {
            navigatorKey.currentState?.pushNamedAndRemoveUntil(Routes.menu, (r) => false);
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
