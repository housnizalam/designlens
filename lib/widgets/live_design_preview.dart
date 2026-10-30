import 'dart:ui';
import 'dart:math' as math;

import '../models/design_color_tokens.dart';

import 'package:flutter/material.dart';

class LiveDesignPreview extends StatefulWidget {
  final Map<String, List<String>> answers;

  const LiveDesignPreview({super.key, required this.answers});

  @override
  State<LiveDesignPreview> createState() => _LiveDesignPreviewState();
}

class _LiveDesignPreviewState extends State<LiveDesignPreview>
    with SingleTickerProviderStateMixin {
  late final AnimationController _motion;
  String? _lastMotionChoice;

  int get _motionLevel {
    const values = [
      'تقريبًا دون حركات',
      'حركات قليلة',
      'حركات متوازنة',
      'حركات واضحة',
      'كثير من الحركات',
    ];
    final index = values.indexOf(answer('animation_amount') ?? '');
    return index < 0 ? 0 : index;
  }

  @override
  void initState() {
    super.initState();
    _motion = AnimationController(vsync: this);
    _configureMotion();
  }

  void _configureMotion() {
    final level = _motionLevel;
    _lastMotionChoice = answer('animation_amount');
    _motion.stop();
    _motion.value = 0;
    if (level > 0) {
      _motion.duration = Duration(
        milliseconds: switch (level) {
          1 => 1650,
          2 => 1400,
          3 => 1120,
          _ => 900,
        },
      );
      _motion.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant LiveDesignPreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_lastMotionChoice != answer('animation_amount')) {
      _configureMotion();
    }
  }

  @override
  void dispose() {
    _motion.dispose();
    super.dispose();
  }

  String? answer(String id) {
    final values = widget.answers[id];
    return values == null || values.isEmpty ? null : values.first;
  }

  Color? selectedColor(String id) {
    final value = answer(id);

    if (value == null || !RegExp(r'^#[0-9a-fA-F]{6}$').hasMatch(value)) {
      return null;
    }

    return Color(int.parse(value.substring(1), radix: 16) | 0xFF000000);
  }

  int optionIndex(String id, List<String> options) {
    return options.indexOf(answer(id) ?? '');
  }

  Color mix(Color first, Color second, double amount) {
    return Color.lerp(first, second, amount)!;
  }

  Color readableText(Color background) {
    return background.computeLuminance() > 0.45
        ? const Color(0xFF17202E)
        : Colors.white;
  }

  List<BoxShadow> makeShadows(int level, Color color, {bool darkMode = false}) {
    if (level == 0) return [];

    return [
      BoxShadow(
        color: mix(color, Colors.black, 0.45).withValues(
          alpha: darkMode ? 0.30 + level * 0.07 : 0.18 + level * 0.07,
        ),
        blurRadius: 7.0 + level * 8,
        spreadRadius: level * 0.4,
        offset: Offset(0, 2.0 + level * 3),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final tokens = DesignColorTokens.fromAnswers(widget.answers);

    final primary = tokens.primary;
    final accent = tokens.accent;

    final hasAccent = tokens.selectedAccent != null;

    final previewGradient = tokens.gradient;

    final radiusIndex = optionIndex('corners', [
      'حواف حادة',
      'استدارة خفيفة',
      'استدارة متوسطة',
      'استدارة كبيرة',
      'استدارة كبيرة جدًا',
    ]);

    final radius = <double>[
      0,
      6,
      14,
      24,
      36,
    ][radiusIndex < 0 ? 2 : radiusIndex];

    final shadowIndex = optionIndex('shadows', [
      'مسطحة دون ظل',
      'ظل خفيف وناعم',
      'ظل واضح',
      'تبدو مرتفعة كثيرًا',
    ]);

    final shadowLevel = shadowIndex < 0 ? 0 : shadowIndex;

    final glassIndex = optionIndex('glass', [
      'لا، بطاقات عادية',
      'شفافية خفيفة جدًا',
      'شفافية متوسطة',
      'تأثير زجاجي واضح',
      'تأثير زجاجي قوي',
    ]);

    final glassLevel = glassIndex < 0 ? 0 : glassIndex;

    final preferredShape = answer('preferred_shapes') ?? 'مستطيلات';
    final headingChoice = answer('heading_style');
    final headingSize = headingChoice == 'صغيرة وهادئة'
        ? 16.0
        : headingChoice == 'كبيرة وبارزة'
        ? 29.0
        : 21.0;
    final headingWeight = headingChoice == 'صغيرة وهادئة'
        ? FontWeight.w500
        : FontWeight.bold;
    final darkMode = tokens.darkMode;

    final background = tokens.background;
    final effectiveBorderColor = tokens.effectiveBorderColor;
    final glassBackdrop = tokens.glassBackdrop;

    final featureCardBackground = primary;
    final demoCardColor = primary;
    final glassAlpha = <double>[1, 0.88, 0.65, 0.38, 0.18][glassLevel];

    final glassBlur = <double>[0, 2, 5, 9, 14][glassLevel];

    final shadows = makeShadows(shadowLevel, primary, darkMode: darkMode);

    final borderIndex = optionIndex('borders', [
      'دون إطار',
      'إطار خفيف',
      'إطار متوسط',
      'إطار واضح',
    ]);

    final borderWidth = <double>[
      0,
      0.8,
      1.8,
      3.5,
    ][borderIndex < 0 ? 1 : borderIndex];

    const availableFonts = [
      'Cairo',
      'Tajawal',
      'IBM Plex Sans Arabic',
      'Amiri',
      'Reem Kufi',
      'Aref Ruqaa',
      'Changa',
      'Noto Naskh Arabic',
    ];

    final preferredFont = answer('font_personality');

    final String? previewFont = availableFonts.contains(preferredFont)
        ? preferredFont
        : null;

    return Theme(
      data: Theme.of(context).copyWith(
        textTheme: Theme.of(context).textTheme.apply(fontFamily: previewFont),
      ),
      child: Container(
        clipBehavior: Clip.antiAlias,

        decoration: BoxDecoration(
          color: previewGradient == null ? background : null,
          gradient: previewGradient,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: effectiveBorderColor),
        ),

        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ----- الشريط العلوي -----

              Container(
                color: primary,
                padding: const EdgeInsets.all(17),
                child: Row(
                  children: [
                    Icon(Icons.dashboard_outlined, color: accent),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'تطبيقي',
                        style: TextStyle(
                          fontFamily: previewFont,
                          color: readableText(primary),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Icon(Icons.menu, color: accent),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ----- العناوين -----

                    Text(
                      'مرحبًا بك',
                      style: TextStyle(
                        fontFamily: previewFont,
                        color: readableText(background),
                        fontSize: headingSize,
                        fontWeight: headingWeight,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'اكتشف الخدمات المتاحة',
                      style: TextStyle(
                        fontFamily: previewFont,
                        color: readableText(background).withValues(alpha: 0.85),
                        fontSize: 13,
                      ),
                    ),

                    const SizedBox(height: 23),

                    // ----- البطاقات الثلاث -----
                    AnimatedBuilder(
                      animation: _motion,
                      builder: (context, _) {
                        final intensity = _motionLevel / 4.0;
                        Widget card(int index, IconData icon, String label) {
                          final phase =
                              _motion.value * 2 * math.pi + index * 0.7;
                          final wave = math.sin(phase);

                          final scaleAmount = 0.065 * intensity;
                          final rotationAmount = 0.13 * intensity;
                          final movementAmount = 14.0 * intensity;

                          return Expanded(
                            child: Transform.translate(
                              offset: Offset(
                                math.cos(phase) * movementAmount * 0.35,
                                -wave * movementAmount,
                              ),
                              child: Transform.rotate(
                                angle: wave * rotationAmount,
                                child: Transform.scale(
                                  scale: 1 + wave * scaleAmount,
                                  child: _PreviewFeatureCard(
                                    fontFamily: previewFont,
                                    icon: icon,
                                    label: label,
                                    color: accent,
                                    background: featureCardBackground,
                                    textColor: readableText(primary),
                                    borderColor: effectiveBorderColor,
                                    radius: radius,
                                    shadow: shadows,
                                    borderWidth: borderWidth,
                                    shapeStyle: preferredShape,
                                    index: index,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }

                        return Row(
                          children: [
                            card(0, Icons.home_outlined, 'الرئيسية'),
                            const SizedBox(width: 16),
                            card(1, Icons.star_outline, 'المميزات'),
                            const SizedBox(width: 16),
                            card(2, Icons.person_outline, 'الحساب'),
                          ],
                        );
                      },
                    ),

                    const SizedBox(height: 28),

                    // ----- البطاقة التجريبية -----
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: glassBackdrop,
                        borderRadius: BorderRadius.circular(radius),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(radius),
                          boxShadow: shadows,
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(radius),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(
                              sigmaX: glassBlur,
                              sigmaY: glassBlur,
                            ),
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: demoCardColor.withValues(
                                  alpha: glassAlpha,
                                ),
                                border: borderWidth == 0
                                    ? null
                                    : Border.all(
                                        color: effectiveBorderColor,
                                        width: borderWidth,
                                      ),
                                borderRadius: BorderRadius.circular(radius),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.widgets_outlined,
                                        color: accent,
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          'بطاقة تجريبية',
                                          style: TextStyle(
                                            fontFamily: previewFont,
                                            color: readableText(demoCardColor),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'هنا يظهر شكل البطاقة والألوان '
                                    'والظل الذي اخترته.',
                                    style: TextStyle(
                                      fontFamily: previewFont,
                                      color: readableText(demoCardColor),
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(height: 16),

                                  // عنصر ملون داخل البطاقة.
                                  Container(
                                    height: 9,
                                    decoration: BoxDecoration(
                                      color: hasAccent ? accent : primary,
                                      borderRadius: BorderRadius.circular(
                                        radius,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ----- زر رئيسي -----
                    DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(radius),
                        boxShadow: shadows,
                      ),
                      child: FilledButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.arrow_forward),
                        label: Text(
                          'ابدأ الآن',
                          style: TextStyle(fontFamily: previewFont),
                        ),
                        style: FilledButton.styleFrom(
                          textStyle: TextStyle(fontFamily: previewFont),
                          backgroundColor: hasAccent ? accent : primary,
                          foregroundColor: readableText(
                            hasAccent ? accent : primary,
                          ),
                          elevation: 0,
                          minimumSize: const Size.fromHeight(50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(radius),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // ----- عنصر ثانوي -----
                    Container(
                      padding: const EdgeInsets.all(13),
                      decoration: BoxDecoration(
                        color: primary,
                        borderRadius: BorderRadius.circular(radius),
                        border: borderWidth == 0
                            ? null
                            : Border.all(
                                color: effectiveBorderColor,
                                width: borderWidth,
                              ),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: accent),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'عنصر إضافي من تصميمك',
                              style: TextStyle(
                                fontFamily: previewFont,
                                color: readableText(primary),
                                fontSize: 13,
                              ),
                            ),
                          ),
                          Icon(
                            Icons.chevron_left,
                            color: hasAccent ? accent : primary,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PreviewFeatureCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? fontFamily;
  final Color color;
  final Color background;
  final Color textColor;
  final Color borderColor;
  final double radius;
  final List<BoxShadow> shadow;
  final double borderWidth;
  final String shapeStyle;
  final int index;

  const _PreviewFeatureCard({
    required this.icon,
    required this.label,
    required this.fontFamily,
    required this.color,
    required this.background,
    required this.textColor,
    required this.borderColor,
    required this.radius,
    required this.shadow,
    required this.borderWidth,
    required this.shapeStyle,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final style = shapeStyle == 'مزيج من عدة أشكال'
        ? ['مستطيلات', 'دوائر', 'أشكال هندسية متنوعة'][index]
        : shapeStyle;
    final content = Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: color, size: 27),
        const SizedBox(height: 8),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            label,
            style: TextStyle(
              fontFamily: fontFamily,
              color: textColor,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );

    if (style == 'مستطيلات') {
      return Container(
        constraints: const BoxConstraints(minHeight: 85),
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 14),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(radius),
          border: borderWidth == 0
              ? null
              : Border.all(
                  color: borderColor.withValues(alpha: 0.70),
                  width: borderWidth,
                ),
          boxShadow: shadow,
        ),
        child: content,
      );
    }

    // Shapes are intentionally applied only to these three example cards.
    final clipper = _FeatureShapeClipper(style);
    final elevation = shadow.isEmpty ? 0.0 : shadow.first.blurRadius / 4;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 140),
        child: AspectRatio(
          aspectRatio: 1.25,
          child: PhysicalShape(
            clipper: clipper,
            color: background,
            elevation: elevation,
            shadowColor: shadow.isEmpty
                ? Colors.transparent
                : shadow.first.color,
            child: CustomPaint(
              foregroundPainter: _FeatureShapeBorderPainter(
                clipper: clipper,
                color: borderColor.withValues(alpha: 0.70),
                width: borderWidth,
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Center(child: content),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FeatureShapeClipper extends CustomClipper<Path> {
  final String style;
  const _FeatureShapeClipper(this.style);

  @override
  Path getClip(Size size) {
    final rect = Offset.zero & size;
    if (style == 'دوائر') {
      return Path()..addOval(
        Rect.fromCircle(
          center: rect.center,
          radius: math.min(size.width, size.height) / 2,
        ),
      );
    }
    if (style == 'أشكال هندسية متنوعة') {
      return Path()
        ..moveTo(size.width * .18, 0)
        ..lineTo(size.width * .82, 0)
        ..lineTo(size.width, size.height * .25)
        ..lineTo(size.width, size.height * .75)
        ..lineTo(size.width * .82, size.height)
        ..lineTo(size.width * .18, size.height)
        ..lineTo(0, size.height * .75)
        ..lineTo(0, size.height * .25)
        ..close();
    }
    // An asymmetric, smooth organic contour.
    return Path()
      ..moveTo(size.width * .14, size.height * .12)
      ..cubicTo(
        size.width * .45,
        -size.height * .06,
        size.width * .94,
        0,
        size.width * .98,
        size.height * .32,
      )
      ..cubicTo(
        size.width * 1.08,
        size.height * .73,
        size.width * .76,
        size.height * 1.05,
        size.width * .42,
        size.height * .98,
      )
      ..cubicTo(
        -size.width * .10,
        size.height * 1.04,
        -size.width * .06,
        size.height * .42,
        size.width * .14,
        size.height * .12,
      )
      ..close();
  }

  @override
  bool shouldReclip(covariant _FeatureShapeClipper oldClipper) =>
      oldClipper.style != style;
}

class _FeatureShapeBorderPainter extends CustomPainter {
  final _FeatureShapeClipper clipper;
  final Color color;
  final double width;
  const _FeatureShapeBorderPainter({
    required this.clipper,
    required this.color,
    required this.width,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (width <= 0) return;
    canvas.drawPath(
      clipper.getClip(size),
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = width,
    );
  }

  @override
  bool shouldRepaint(covariant _FeatureShapeBorderPainter old) =>
      old.color != color ||
      old.width != width ||
      old.clipper.style != clipper.style;
}
