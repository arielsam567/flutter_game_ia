import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';

class Wall extends BodyComponent {
  bool isLeft;
  final Vector2 worldSize;
  double xSize = 0.02;
  double ySize = 10000;

  Wall(this.worldSize, {this.isLeft = true});

  @override
  Body createBody() {
    final bodyDef = BodyDef(
      position: Vector2(
        isLeft ? 0.15 : worldSize.x - 0.15,
        isLeft ? 0 : 0,
      ),
    )..userData = this;

    final poly = PolygonShape()
      ..setAsBoxXY(
        xSize,
        ySize,
      );

    final fixtureDef = FixtureDef(poly)..friction = 1;

    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }

  double sizeX() {
    return xSize;
  }

  double sizeY() {
    return ySize;
  }
}

class FloorBottom extends BodyComponent {
  final Vector2 worldSize;

  FloorBottom(this.worldSize);

  @override
  Body createBody() {
    final bodyDef = BodyDef(position: Vector2(0, worldSize.y));

    final shape = EdgeShape()..set(Vector2.zero(), Vector2(worldSize.x, 0));

    return world.createBody(bodyDef)..createFixtureFromShape(shape);
  }
}

class FloorTop extends BodyComponent {
  final Vector2 worldSize;

  FloorTop(this.worldSize);

  @override
  Body createBody() {
    final bodyDef = BodyDef(position: Vector2(0, -worldSize.y));

    final shape = EdgeShape()..set(Vector2.zero(), Vector2(worldSize.x, 0));

    return world.createBody(bodyDef)..createFixtureFromShape(shape);
  }
}

class DashedWall extends BodyComponent {
  late Paint _paint;
  late Vector2 _start;
  late Vector2 _end;
  late int _dashCount;
  final double xPosition;

  DashedWall(
    Vector2 worldSize, {
    required this.xPosition,
    dashCount = 100,
    Color color = Colors.white,
    double strokeWidth = .2,
  }) {
    _start = Vector2(xPosition, -110);
    _end = Vector2(xPosition, worldSize.y);
    _dashCount = dashCount;

    _paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;
  }
  //  : _start = start,
  //         _end = end,
  //         _dashCount = dashCount,
  //         _paint = Paint()
  //           ..color = color
  //           ..strokeWidth = strokeWidth
  //           ..style = PaintingStyle.stroke

  @override
  void render(Canvas c) {
    final double startOffset = _start.distanceTo(Vector2.zero());
    final double endOffset = _end.distanceTo(Vector2.zero());
    final double totalLength = endOffset - startOffset;

    final double dashLength = totalLength / _dashCount;
    final double dashSpace = dashLength / 2;

    final double realLength = dashLength - dashSpace;

    for (int i = 0; i < _dashCount; ++i) {
      final double startPercent = i * (realLength + dashSpace) / totalLength;
      final double endPercent = (i * (realLength + dashSpace) + realLength) / totalLength;

      final Vector2 startPoint = lerpVector2(_start, _end, startPercent);
      final Vector2 endPoint = lerpVector2(_start, _end, endPercent);

      c.drawLine(
        Offset(startPoint.x, startPoint.y),
        Offset(endPoint.x, endPoint.y),
        _paint,
      );
    }
  }

  Vector2 lerpVector2(Vector2 a, Vector2 b, double t) {
    return Vector2(
      a.x + (b.x - a.x) * t,
      a.y + (b.y - a.y) * t,
    );
  }

  @override
  Body createBody() {
    final shape = EdgeShape()..set(_start, _end);
    final fixtureDef = FixtureDef(
      shape,
      isSensor: true,
    )
      ..restitution = 0.0
      ..friction = 0.0;
    final bodyDef = BodyDef()..type = BodyType.static;
    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }
}
