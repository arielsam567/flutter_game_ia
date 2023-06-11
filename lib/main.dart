import 'package:flutter/material.dart';
import 'package:flutter_game_ia/settings/routes.dart';
import 'package:flutter_game_ia/settings/storage.dart';

Future<void> main() async {
  await Storage.init();
  runApp(
    MaterialApp(
      title: 'Flutter - Self-driving car',
      navigatorKey: Routes.navigatorKey,
      onGenerateRoute: Routes.routes,
      initialRoute: Routes.menu,
    ),
  );
}
