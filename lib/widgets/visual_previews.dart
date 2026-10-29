import 'dart:ui';
import 'package:flutter/material.dart';

class CornerPreview extends StatelessWidget {
  final int index;

  const CornerPreview({super.key, required this.index});

  @override
  Widget build(BuildContext context) {
    const radii = [0.0, 6.0, 14.0, 24.0, 36.0];

    return Center(
      child: Container(
        width: 200,
        height: 82,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: const Color(0xFF2455A4),
          borderRadius: BorderRadius.circular(radii[index]),
        ),
        child: const Text(
          'بطاقة تجريبية',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
      ),
    );
  }
}

// ---------------- SHADOW PREVIEW ----------------

class ShadowPreview extends StatelessWidget {
  final int index;

  const ShadowPreview({super.key, required this.index});

  @override
  Widget build(BuildContext context) {
    const blur = [0.0, 8.0, 18.0, 30.0];
    const offset = [0.0, 3.0, 7.0, 13.0];

    return Container(
      height: 120,
      alignment: Alignment.center,
      color: const Color(0xFFF3F5F9),
      child: Container(
        width: 190,
        height: 76,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE1E5EC)),
          boxShadow: index == 0
              ? []
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12 + index * 0.035),
                    blurRadius: blur[index],
                    offset: Offset(0, offset[index]),
                  ),
                ],
        ),
        child: const Text('بطاقة تجريبية'),
      ),
    );
  }
}

// ---------------- GLASS PREVIEW ----------------

class GlassPreview extends StatelessWidget {
  final int index;

  const GlassPreview({super.key, required this.index});

  @override
  Widget build(BuildContext context) {
    const transparency = [1.0, 0.88, 0.65, 0.38, 0.18];

    const blur = [0.0, 2.0, 5.0, 9.0, 14.0];

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        height: 140,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF2559C9),
                    Color(0xFF9B67D8),
                    Color(0xFFED84AB),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 15,
              top: 12,
              child: Container(
                width: 85,
                height: 85,
                decoration: const BoxDecoration(
                  color: Color(0xAAFFCF50),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              right: 28,
              bottom: 0,
              child: Container(
                width: 95,
                height: 95,
                decoration: const BoxDecoration(
                  color: Color(0xAA36DBD2),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: blur[index],
                  sigmaY: blur[index],
                ),
                child: Container(
                  width: 220,
                  height: 90,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: transparency[index]),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white70),
                  ),
                  child: const Text(
                    'بطاقة تجريبية',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF142D53),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------- REVIEW ----------------

class BorderPreview extends StatelessWidget {
  final int index;

  const BorderPreview({super.key, required this.index});

  @override
  Widget build(BuildContext context) {
    const widths = [0.0, 0.8, 1.8, 3.5];

    return Container(
      height: 100,
      alignment: Alignment.center,
      color: const Color(0xFFF1F3F6),
      child: Container(
        width: 220,
        height: 72,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: widths[index] == 0
              ? null
              : Border.all(
                  color: const Color(0xFF475569),
                  width: widths[index],
                ),
        ),
        child: const Text('بطاقة تجريبية'),
      ),
    );
  }
}

class ShapeOptionPreview extends StatelessWidget {
  final int index;

  const ShapeOptionPreview({
    super.key,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    Widget shape({
      required double width,
      required double height,
      required ShapeBorder border,
    }) {
      return Material(
        color: const Color(0xFF64748B),
        shape: border,
        child: SizedBox(width: width, height: height),
      );
    }

    final Widget preview;

    switch (index) {
      case 0:
        preview = shape(
          width: 135,
          height: 65,
          border: const RoundedRectangleBorder(),
        );
        break;

      case 1:
        preview = shape(
          width: 75,
          height: 75,
          border: const CircleBorder(),
        );
        break;

      case 2:
        preview = Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            shape(
              width: 65,
              height: 65,
              border: const CircleBorder(),
            ),
            const SizedBox(width: 12),
            shape(
              width: 65,
              height: 65,
              border: const BeveledRectangleBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(18),
                ),
              ),
            ),
          ],
        );
        break;

      case 3:
        preview = ClipPath(
          clipper: _OrganicShapeClipper(),
          child: Container(
            width: 125,
            height: 85,
            color: const Color(0xFF64748B),
          ),
        );
        break;

      default:
        preview = Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            shape(
              width: 65,
              height: 65,
              border: const CircleBorder(),
            ),
            const SizedBox(width: 12),
            shape(
              width: 85,
              height: 65,
              border: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
          ],
        );
    }

    return Container(
      height: 110,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFFF1F3F6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: preview,
    );
  }
}

class _OrganicShapeClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    return Path()
      ..moveTo(size.width * 0.18, size.height * 0.05)
      ..cubicTo(
        size.width * 0.70, -size.height * 0.10,
        size.width * 1.10, size.height * 0.25,
        size.width * 0.88, size.height * 0.65,
      )
      ..cubicTo(
        size.width * 0.70, size.height * 1.10,
        size.width * 0.15, size.height * 1.10,
        size.width * 0.05, size.height * 0.65,
      )
      ..cubicTo(
        -size.width * 0.10, size.height * 0.25,
        size.width * 0.05, size.height * 0.12,
        size.width * 0.18, size.height * 0.05,
      )
      ..close();
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return false;
  }
}
