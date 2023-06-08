import 'package:flutter/material.dart';
import 'package:flutter_game_ia/settings/routes.dart';

void main() {
  runApp(
    MaterialApp(
      title: 'Flutter - Self-driving car',
      navigatorKey: Routes.navigatorKey,
      onGenerateRoute: Routes.routes,
      initialRoute: Routes.menu,
    ),
  );
}
