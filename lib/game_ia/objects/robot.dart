import 'package:flame/components.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter_game_ia/settings/word.dart';

enum RobotState {
  duck,
  fall,
  idle,
  jump,
  walk,
}

class Robot extends BodyComponent with KeyboardHandler {
  final _componentPosition = Vector2(0, 0);
  static int proporcao = 2;
  final _size = Vector2(1.80 / proporcao, 2.4 / proporcao);
  double maxSpeed = 3;
  double atritoAr = 0.05;
  double acceleration = 1.5;
  double accelerationX = 0;
  bool isDucking = false;
  RobotState state = RobotState.idle;

  late final SpriteComponent roboAbaixado;
  late final SpriteComponent roboCaindo;
  late final SpriteComponent roboParado;
  late final SpriteComponent roboPulando;
  late final SpriteAnimationComponent roboAndadando;
  late Component currentComponent;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    renderBody = false;

    final duck = await gameRef.loadSprite('robot/robot_duck.png');
    final fall = await gameRef.loadSprite('robot/robot_fall.png');
    final idle = await gameRef.loadSprite('robot/robot_idle.png');
    final jump = await gameRef.loadSprite('robot/robot_jump.png');
    final walk0 = await gameRef.loadSprite('robot/robot_walk0.png');
    final walk1 = await gameRef.loadSprite('robot/robot_walk1.png');
    final walk2 = await gameRef.loadSprite('robot/robot_walk2.png');
    final walk3 = await gameRef.loadSprite('robot/robot_walk3.png');
    final walk4 = await gameRef.loadSprite('robot/robot_walk4.png');
    final walk5 = await gameRef.loadSprite('robot/robot_walk5.png');
    final walk6 = await gameRef.loadSprite('robot/robot_walk6.png');
    final walk7 = await gameRef.loadSprite('robot/robot_walk7.png');

    roboAbaixado = SpriteComponent(
      sprite: duck,
      size: _size,
      position: _componentPosition,
      anchor: Anchor.center,
    );

    roboCaindo = SpriteComponent(
      sprite: fall,
      size: _size,
      position: _componentPosition,
      anchor: Anchor.center,
    );

    roboParado = SpriteComponent(
      sprite: idle,
      size: _size,
      position: _componentPosition,
      anchor: Anchor.center,
    );

    roboPulando = SpriteComponent(
      sprite: jump,
      size: _size,
      position: _componentPosition,
      anchor: Anchor.center,
    );

    final walkAnimation = SpriteAnimation.spriteList(
      [
        walk0,
        walk1,
        walk2,
        walk3,
        walk4,
        walk5,
        walk6,
        walk7,
      ],
      stepTime: 0.05,
    );

    roboAndadando = SpriteAnimationComponent(
      animation: walkAnimation,
      anchor: Anchor.center,
      position: _componentPosition,
      size: _size,
    );

    currentComponent = roboParado;
    add(roboParado);
  }

  void idle() {
    accelerationX = 0;
    isDucking = false;
  }

  void walkLeft() {
    accelerationX -= acceleration;
  }

  void walkRight() {
    accelerationX += acceleration;
  }

  void duck() {
    isDucking = true;
  }

  void jump() {
    if (state == RobotState.jump || state == RobotState.fall) {
      return;
    }
    final velocity = body.linearVelocity;

    body.linearVelocity = Vector2(velocity.x, -10);
    state = RobotState.jump;
  }

  @override
  void update(double dt) {
    super.update(dt);

    final velocity = body.linearVelocity;

    if (velocity.y > 0.1) {
      state = RobotState.fall;
    } else if (velocity.y < 0.1 && state != RobotState.jump) {
      if (accelerationX != 0) {
        state = RobotState.walk;
      } else if (isDucking) {
        state = RobotState.duck;
      } else {
        state = RobotState.idle;
      }
    }

    velocity.x = accelerationX.clamp(-maxSpeed, maxSpeed);
    body.linearVelocity = velocity;

    if (state == RobotState.jump) {
      _setComponent(roboPulando);
    } else if (state == RobotState.fall) {
      _setComponent(roboCaindo);
    } else if (state == RobotState.walk) {
      _setComponent(roboAndadando);
    } else if (state == RobotState.duck) {
      _setComponent(roboAbaixado);
    } else if (state == RobotState.idle) {
      _setComponent(roboParado);
    }
  }

  void _setComponent(PositionComponent component) {
    if (accelerationX < 0) {
      if (!component.isFlippedHorizontally) {
        component.flipHorizontally();
      }
    } else {
      if (component.isFlippedHorizontally) {
        component.flipHorizontally();
      }
    }

    if (component == currentComponent) {
      return;
    }
    remove(currentComponent);
    currentComponent = component;
    add(component);
  }

  @override
  Body createBody() {
    final bodyDef = BodyDef(
      userData: this,
      position: Vector2(worldSize.x / 2, worldSize.y - 3),
      type: BodyType.dynamic,
    );

    final shape = PolygonShape()..setAsBoxXY(_size.x / (2), _size.y / 2);

    final fixtureDef = FixtureDef(shape)
      ..density = 10
      ..friction = 0
      ..restitution = 0;
    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }
}
