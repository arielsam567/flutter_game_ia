import 'dart:math';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

double radians(double degrees) {
  return degrees * pi / 180;
}

double lerp(double a, double b, double t) {
  return a + (b - a) * t;
}

Map<String, dynamic> getIntersection(Vector2 A, Vector2 B, Vector2 C, Vector2 D) {
  final double tTop = (D.x - C.x) * (A.y - C.y) - (D.y - C.y) * (A.x - C.x);
  final double uTop = (C.y - A.y) * (A.x - B.x) - (C.x - A.x) * (A.y - B.y);
  final double bottom = (D.y - C.y) * (B.x - A.x) - (D.x - C.x) * (B.y - A.y);

  if (bottom != 0) {
    final t = tTop / bottom;
    final u = uTop / bottom;

    if (t >= 0 && t <= 1 && u >= 0 && u <= 1) {
      return {
        'x': lerp(A.x, B.x, t),
        'y ': lerp(A.y, B.y, t),
        'offset': t,
      };
    }
  }

  return {};
}

Map polysIntersect(List<Vector2> poly1, List<Vector2> poly2) {
  for (var i = 0; i < poly1.length; i++) {
    for (var j = 0; j < poly2.length; j++) {
      final touch = getIntersection(
        poly1[i],
        poly1[(i + 1) % poly1.length],
        poly2[j],
        poly2[(j + 1) % poly2.length],
      );
      if (touch.isNotEmpty) {
        return touch;
      }
    }
  }
  return {};
}

void showMessage(String message, {String color = '#000000'}) {
  Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 3,
      backgroundColor: Colors.red,
      webPosition: 'center',
      webBgColor: color,
      webShowClose: true,
      textColor: Colors.white,
      fontSize: 16.0);
}
