import 'package:flutter/material.dart';
import 'package:flutter_game_ia/settings/routes.dart';

class LessonMenu extends StatelessWidget {
  const LessonMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SizedBox(
          width: 350,
          child: ListView(
            children: const [
              SizedBox(height: 32),
              ButtonItem(
                title: '1- The world, bodies, shapes and fixtures',
                route: Routes.lesson01,
              ),
              ButtonItem(
                title: '2- Body types: dynamic, static & kinematic',
                route: Routes.lesson02,
              ),
              ButtonItem(
                title: '3- Friction, density & restitution',
                route: Routes.lesson03,
              ),
              ButtonItem(
                title: '4- Forces, impulses & linear velocity',
                route: Routes.lesson04,
              ),
              ButtonItem(
                title: '5- Bodies and sprites',
                route: Routes.lesson05,
              ),
              ButtonItem(
                title: '6- Collisions',
                route: Routes.lesson06,
              ),
              ButtonItem(
                title: '7- Collisions with animated sprites',
                route: Routes.lesson07,
              ),
              ButtonItem(
                title: '8- Animated sprites: walk, jump, duck',
                route: Routes.lesson08,
              ),
              ButtonItem(
                title: '9- Working with the camera',
                route: Routes.lesson09,
              ),
              ButtonItem(
                title: '10 - Car game - auto-driver - Neural Network',
                route: Routes.lesson10,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ButtonItem extends StatelessWidget {
  final String title;
  final String route;
  final Object? args;

  const ButtonItem({
    required this.title,
    required this.route,
    this.args,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(title),
          ),
          onPressed: () {
            Navigator.of(context).pushNamed(route, arguments: args);
          },
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}
