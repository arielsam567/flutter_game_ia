import 'package:flame_forge2d/flame_forge2d.dart';

class Wall extends BodyComponent {
  bool isLeft;
  final Vector2 worldSize;

  Wall(this.worldSize, {this.isLeft = true});

  @override
  Body createBody() {
    final bodyDef = BodyDef(
      position: Vector2(
        isLeft ? 0.1 : worldSize.x - 0.1,
        isLeft ? 0 : 0,
      ),
    );

    // final shape = EdgeShape()
    //   ..set(
    //     Vector2(
    //       isLeft ? 0 : 0,
    //       isLeft ? 0 : worldSize.y,
    //     ),
    //     Vector2(
    //       isLeft ? 0 : 0,
    //       isLeft ? worldSize.y : 0,
    //     ),
    //   );

    final poly = PolygonShape()
      ..setAsBoxXY(
        0.1,
        worldSize.y,
      );

    final fixtureDef = FixtureDef(poly)..friction = 0;

    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }
}
