import 'package:flutter/material.dart';
import 'package:flutter_game_ia/settings/routes.dart';

void main() {
  runApp(
    MaterialApp(
      navigatorKey: Routes.navigatorKey,
      debugShowCheckedModeBanner: false,
      onGenerateRoute: Routes.routes,
      initialRoute: Routes.menu,
    ),
  );
}
