import 'dart:html' as html;

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_game_ia/settings/routes.dart';
import 'package:flutter_game_ia/settings/storage.dart';
import 'package:flutter_game_ia/utils/utils.dart';

class LessonMenu extends StatelessWidget {
  final Storage storage = Storage();

  LessonMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: SizedBox(
        width: 350,
        child: ListView(children: [
          const SizedBox(height: 32),
          const ButtonItem(
            title: '1- The world, bodies, shapes and fixtures',
            route: Routes.lesson01,
          ),
          const ButtonItem(
            title: '2- Body types: dynamic, static & kinematic',
            route: Routes.lesson02,
          ),
          const ButtonItem(
            title: '3- Friction, density & restitution',
            route: Routes.lesson03,
          ),
          const ButtonItem(
            title: '4- Forces, impulses & linear velocity',
            route: Routes.lesson04,
          ),
          const ButtonItem(
            title: '5- Bodies and sprites',
            route: Routes.lesson05,
          ),
          const ButtonItem(
            title: '6- Collisions',
            route: Routes.lesson06,
          ),
          const ButtonItem(
            title: '7- Collisions with animated sprites',
            route: Routes.lesson07,
          ),
          const ButtonItem(
            title: '8- Animated sprites: walk, jump, duck',
            route: Routes.lesson08,
          ),
          const ButtonItem(
            title: '9- Working with the camera',
            route: Routes.lesson09,
          ),
          const ButtonItem(
            title: '10 - Car - Self-driving - Neural Network',
            route: Routes.lesson10,
          ),

          const SizedBox(
            height: 100,
          ),
          //RichText CREATED BY ARIEL SAM
          Center(
            child: RichText(
              text: TextSpan(
                text: 'Created by ',
                style: const TextStyle(color: Colors.black),
                children: [
                  TextSpan(
                    text: 'Ariel Sam',
                    style: const TextStyle(
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        if (kIsWeb) {
                          html.window.open(
                            'https://www.linkedin.com/in/ariel-sam-0b7586155/',
                            '_blank',
                          );
                        }
                      },
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(28.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                imageButton(
                  'https://www.linkedin.com/in/ariel-sam-0b7586155/',
                  'linkedin.png',
                ),
                const SizedBox(width: 20),
                imageButton(
                  'https://github.com/arielsam567?tab=repositories',
                  'github.png',
                ),
                const SizedBox(width: 20),
                imageButton(
                  'https://www.youtube.com/channel/UCd2MxZWKiN5Tqfmp7S4WcfA',
                  'youtube.png',
                ),
              ],
            ),
          ),
        ]),
      ),
    ));
  }

  Widget imageButton(String url, String path) {
    return SizedBox(
      height: 50,
      width: 50,
      child: InkWell(
        onTap: () {
          html.window.open(url, '_blank');
        },
        child: Image.asset('assets/images/$path'),
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
          onPressed: () async {
            if (route == Routes.lesson10) {
              await showAlertDialog(context);
            }
            Navigator.of(context).pushNamed(route, arguments: args);
          },
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Future<void> showAlertDialog(context) async {
    final formKey = GlobalKey<FormState>();
    final storage = Storage();
    final sensorsController = TextEditingController(text: '${storage.getSensorsNumber()}');
    final carsController = TextEditingController(text: '${storage.getCarsNumber()}');
    return showDialog<void>(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: ListBody(
                  children: <Widget>[
                    const Text('Informe quantos sensores o carro deve ter'),
                    Container(
                      width: 50,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: TextFormField(
                        controller: sensorsController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        decoration: const InputDecoration(
                          labelText: 'Quantidade de sensores',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Informe um valor';
                          }
                          if (int.parse(value) < 1) {
                            return 'Informe um valor maior que 0';
                          }
                          return null;
                        },
                      ),
                    ),
                    const Text('Informe quantos carros devem ser gerados'),
                    Container(
                      width: 50,
                      padding: const EdgeInsets.only(top: 12),
                      child: TextFormField(
                        controller: carsController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        decoration: const InputDecoration(
                          labelText: 'Quantidade de carros',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Informe um valor';
                          }
                          if (int.parse(value) < 1) {
                            return 'Informe um valor maior que 0';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('Continuar'),
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    final sensorNumber = int.parse(sensorsController.text);
                    final int carNumber = int.parse(carsController.text);
                    storage.deleteBrain();
                    storage.carsNumber(carNumber);
                    storage.sensorsNumber(sensorNumber);
                    Navigator.of(context).pop();
                  } else {
                    showMessage('Informe um valor válido');
                  }
                },
              ),
            ],
          );
        });
  }
}
