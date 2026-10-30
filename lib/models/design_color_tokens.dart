import 'package:flutter/material.dart';

import '../widgets/design_gradient.dart';

/// Resolved color values shared by Live Design and Design DNA exports.
/// Null selected colors mean the client did not make that choice.
class DesignColorTokens {
  final Color? selectedPrimary;
  final Color? selectedAccent;
  final Color? selectedGradientEnd;
  final Color? selectedBorderColor;
  final Color primary;
  final Color accent;
  final Color background;
  final Color neutralBackground;
  final Color neutralSurface;
  final Color effectiveBorderColor;
  final Color glassBackdrop;
  final bool darkMode;
  final double backgroundStrengthPercent;
  final String? gradientMode;
  final String gradientDirection;
  final double gradientBalancePercent;
  final double gradientTransitionWidthPercent;
  final Gradient? gradient;
  final String? borderColorMode;

  const DesignColorTokens._({
    required this.selectedPrimary,
    required this.selectedAccent,
    required this.selectedGradientEnd,
    required this.selectedBorderColor,
    required this.primary,
    required this.accent,
    required this.background,
    required this.neutralBackground,
    required this.neutralSurface,
    required this.effectiveBorderColor,
    required this.glassBackdrop,
    required this.darkMode,
    required this.backgroundStrengthPercent,
    required this.gradientMode,
    required this.gradientDirection,
    required this.gradientBalancePercent,
    required this.gradientTransitionWidthPercent,
    required this.gradient,
    required this.borderColorMode,
  });

  static String? _first(Map<String, List<String>> answers, String key) {
    final values = answers[key];
    return values == null || values.isEmpty ? null : values.first;
  }

  static Color? _parseColor(String? hex) {
    if (hex == null || !RegExp(r'^#[0-9a-fA-F]{6}$').hasMatch(hex)) {
      return null;
    }
    return Color(int.parse(hex.substring(1), radix: 16) | 0xFF000000);
  }

  static Color _mix(Color a, Color b, double amount) => Color.lerp(a, b, amount)!;

  factory DesignColorTokens.fromAnswers(Map<String, List<String>> answers) {
    final chosenPrimary = _parseColor(_first(answers, 'primary_color'));
    final chosenAccent = _parseColor(_first(answers, 'accent_color'));
    final primary = chosenPrimary ?? const Color(0xFF64748B);
    final accent = chosenAccent ?? const Color(0xFF94A3B8);
    final darkMode = (_first(answers, 'theme') ?? '').startsWith('داكنة');
    final neutralBackground = darkMode
        ? const Color(0xFF131820)
        : const Color(0xFFF1F3F6);
    final neutralSurface = darkMode
        ? const Color(0xFF242B35)
        : Colors.white;

    final strength = (double.tryParse(
              _first(answers, 'primary_color_strength') ?? '',
            ) ?? 60.0)
        .clamp(0.0, 100.0)
        .toDouble();
    // Keep the exact existing preview calculation (including its 5% baseline).
    final background = chosenPrimary != null
        ? _mix(neutralBackground, primary, 0.05 + (strength / 100.0) * 0.95)
        : neutralBackground;

    final gradientMode = _first(answers, 'gradient_mode');
    final gradientEnd = switch (gradientMode) {
      'primary_accent' => chosenAccent,
      'primary_custom' => _parseColor(_first(answers, 'gradient_custom_color')),
      _ => null,
    };
    final direction = _first(answers, 'gradient_direction') ?? 'diagonal';
    final balance = (double.tryParse(
              _first(answers, 'gradient_balance') ?? '',
            ) ?? 50.0)
        .clamp(0.0, 100.0)
        .toDouble();
    final transitionWidth = (double.tryParse(
              _first(answers, 'gradient_transition_width') ?? '',
            ) ?? 30.0)
        .clamp(0.0, 100.0)
        .toDouble();
    final gradient = chosenPrimary != null && gradientEnd != null
        ? DesignGradient.build(
            first: chosenPrimary,
            second: gradientEnd,
            direction: direction,
            balance: balance,
            transitionWidthPercent: transitionWidth,
          )
        : null;

    final borderColorMode = _first(answers, 'border_color_mode');
    final chosenBorder = _parseColor(_first(answers, 'border_custom_color'));
    final derivedBorder = _mix(
      primary,
      neutralSurface,
      darkMode ? 0.50 : 0.65,
    );
    final effectiveBorder = switch (borderColorMode) {
      'نفس اللون الإضافي الذي اخترته' when chosenAccent != null => chosenAccent,
      'أريد اختيار لون خاص للإطارات' when chosenBorder != null => chosenBorder,
      _ => derivedBorder,
    };
    final glassBackdrop = chosenPrimary != null
        ? _mix(
            _mix(background, primary, 0.50),
            darkMode ? Colors.white : Colors.black,
            0.12,
          )
        : _mix(background, neutralSurface, 0.50);

    return DesignColorTokens._(
      selectedPrimary: chosenPrimary,
      selectedAccent: chosenAccent,
      selectedGradientEnd: gradientEnd,
      selectedBorderColor: chosenBorder,
      primary: primary,
      accent: accent,
      background: background,
      neutralBackground: neutralBackground,
      neutralSurface: neutralSurface,
      effectiveBorderColor: effectiveBorder,
      glassBackdrop: glassBackdrop,
      darkMode: darkMode,
      backgroundStrengthPercent: strength,
      gradientMode: gradientMode,
      gradientDirection: direction,
      gradientBalancePercent: balance,
      gradientTransitionWidthPercent: transitionWidth,
      gradient: gradient,
      borderColorMode: borderColorMode,
    );
  }

  static String hex(Color color) {
    final argb = color.toARGB32();
    return '#${(argb & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}';
  }

  /// Gradient stop fractions (0..1); mirrors DesignGradient.build.
  List<double>? get gradientStops {
    if (gradient == null) return null;
    final center = gradientBalancePercent / 100.0;
    final transitionWidth = gradientTransitionWidthPercent / 100.0;
    final start = (center - transitionWidth / 2).clamp(0.0, 1.0).toDouble();
    final end = (center + transitionWidth / 2).clamp(0.0, 1.0).toDouble();
    return [0.0, start, end, 1.0];
  }
}
