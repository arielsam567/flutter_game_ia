import 'dart:core';

import 'package:flutter/material.dart';
import 'package:flutter_game_ia/game_ia/game_m1.dart';
import 'package:flutter_game_ia/game_ia/objects/charts_line.dart';
import 'package:flutter_game_ia/game_ia/word_stl.dart';
import 'package:flutter_game_ia/game_medium/game_m1/game_m1.dart';
import 'package:flutter_game_ia/game_medium/game_m2/game_m2.dart';
import 'package:flutter_game_ia/games_junior/game_1/game_1.dart';
import 'package:flutter_game_ia/games_junior/game_2/game_2.dart';
import 'package:flutter_game_ia/games_junior/game_3/game_3.dart';
import 'package:flutter_game_ia/games_junior/game_4/game_4.dart';
import 'package:flutter_game_ia/games_junior/game_5/game_5.dart';
import 'package:flutter_game_ia/games_junior/game_6/game_6.dart';
import 'package:flutter_game_ia/games_junior/game_7/game_7.dart';
import 'package:flutter_game_ia/settings/menu.dart';
import 'package:flutter_game_ia/settings/storage.dart';
import 'package:flutter_game_ia/settings/word.dart';

class Routes {
  static final navigatorKey = GlobalKey<NavigatorState>();
  static const menu = '/';
  static const lesson01 = '/lesson01';
  static const lesson02 = '/lesson02';
  static const lesson03 = '/lesson03';
  static const lesson04 = '/lesson04';
  static const lesson05 = '/lesson05';
  static const lesson06 = '/lesson06';
  static const lesson07 = '/lesson07';
  static const lesson08 = '/lesson08';
  static const lesson09 = '/lesson09';
  static const lesson10 = '/lesson10';
  static const lesson11 = '/lesson11';

  static Route routes(RouteSettings settings) {
    MaterialPageRoute buildRoute(Widget widget) {
      return MaterialPageRoute(builder: (_) => widget, settings: settings);
    }

    final agrs = settings.arguments;

    switch (settings.name) {
      case menu:
        return buildRoute(LessonMenu());
      case lesson01:
        return buildRoute(MyGameWidget(game: GameLesson01()));
      case lesson02:
        return buildRoute(MyGameWidget(game: GameLesson02()));
      case lesson03:
        return buildRoute(MyGameWidget(game: GameLesson03()));
      case lesson04:
        return buildRoute(MyGameWidget(game: GameLesson04()));
      case lesson05:
        return buildRoute(MyGameWidget(game: GameLesson05()));
      case lesson06:
        return buildRoute(MyGameWidget(game: GameLesson06()));
      case lesson07:
        return buildRoute(MyGameWidget(game: GameLesson07()));
      case lesson08:
        return buildRoute(MyGameWidget(game: GameLesson08()));
      case lesson09:
        return buildRoute(MyGameWidget(game: GameLesson09()));
      case lesson10:
        return buildRoute(MyGameWidgetIa(
          game: GameComIA(),
          generation: getGenerationInfo(),
        ));
      case lesson11:
        return buildRoute(MyGameWidgetIa(
          game: GameComIA(selfDrive: true),
          generation: const [],
          selfDrive: true,
        ));
      default:
        throw Exception('Route does not exists');
    }
  }

  static List<GenerationInfo> getGenerationInfo() {
    return Storage().getGenerationInfo();
  }

  static void generateNewGeneration() {
    navigatorKey.currentState?.pushNamedAndRemoveUntil(
      Routes.lesson10,
      (r) => false,
    );
  }
}
