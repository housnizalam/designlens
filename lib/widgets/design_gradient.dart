import 'package:flutter/material.dart';

class DesignGradient {
  static Gradient build({
    required Color first,
    required Color second,
    required String direction,
    required double balance,
    double transitionWidthPercent = 30,
  }) {
    final center = (balance / 100).clamp(0.0, 1.0);

    // مجال الانتقال الناعم بين اللونين.
    final transitionWidth = transitionWidthPercent.clamp(0.0, 100.0) / 100.0;

    final start = (center - transitionWidth / 2).clamp(0.0, 1.0);

    final end = (center + transitionWidth / 2).clamp(0.0, 1.0);

    final colors = [first, first, second, second];
    final stops = [0.0, start, end, 1.0];

    if (direction == 'radial') {
      return RadialGradient(
        center: Alignment.center,
        radius: 0.85,
        colors: colors,
        stops: stops,
      );
    }

    final Alignment begin;
    final Alignment endAlignment;

    switch (direction) {
      case 'horizontal':
        begin = Alignment.centerRight;
        endAlignment = Alignment.centerLeft;
        break;
      case 'vertical':
        begin = Alignment.topCenter;
        endAlignment = Alignment.bottomCenter;
        break;
      default:
        begin = Alignment.topRight;
        endAlignment = Alignment.bottomLeft;
    }

    return LinearGradient(
      begin: begin,
      end: endAlignment,
      colors: colors,
      stops: stops,
    );
  }
}
