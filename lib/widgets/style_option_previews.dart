import 'dart:ui';

import 'package:flutter/material.dart';

// These miniature examples deliberately use fixed sample colors.
// They demonstrate style differences; they do not assign project colors.
class StyleOptionPreview extends StatelessWidget {
  final int index;

  const StyleOptionPreview({super.key, required this.index});

  static const List<String> images = [
    'flat.png',
    'material.png',
    'glassmorphism.png',
    'neumorphism.png',
    'minimal.png',
    'luxury.png',
    'corporate.png',
    'futuristic.png',
    'playful.png',
    'brutalist.png',
  ];

  @override
  Widget build(BuildContext context) {
    if (index < 0 || index >= images.length) {
      return const SizedBox.shrink();
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        color: const Color(0xFFF1F3F7),
        child: Image.asset(
          'assets/images/ui_styles/${images[index]}',
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return const Center(child: Text('تعذر تحميل الصورة'));
          },
        ),
      ),
    );
  }
}

class TypographyOptionPreview extends StatelessWidget {
  final int index;
  const TypographyOptionPreview({super.key, required this.index});
  @override
  Widget build(BuildContext context) {
    final weights = <FontWeight>[
      FontWeight.w600,
      FontWeight.w500,
      FontWeight.w700,
      FontWeight.w400,
      FontWeight.w300,
      FontWeight.w900,
      FontWeight.w400,
    ];
    return Container(
      padding: const EdgeInsets.all(12),
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFF1F3F7),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'أهلًا بك في تطبيقنا',
            style: TextStyle(
              fontWeight: weights[index],
              fontSize: index == 4
                  ? 21
                  : index == 5
                  ? 19
                  : 17,
              letterSpacing: index == 2 ? 1 : 0,
              color: const Color(0xFF29364D),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'مثال لطريقة عرض العناوين والنصوص',
            style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
          ),
        ],
      ),
    );
  }
}

class IconOptionPreview extends StatelessWidget {
  final int index;
  const IconOptionPreview({super.key, required this.index});
  @override
  Widget build(BuildContext context) {
    final filled = index == 2 || index == 3 || index == 4;
    final color = index == 3
        ? const Color(0xFFDB2777)
        : const Color(0xFF526780);
    return Container(
      height: 82,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFFF1F3F7),
        borderRadius: BorderRadius.circular(10),
      ),
      child: index == 5
          ? const Text('يختار المصمم أسلوبًا مناسبًا')
          : Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Icon(
                  filled ? Icons.home : Icons.home_outlined,
                  size: index == 4 ? 35 : 29,
                  color: color,
                ),
                Icon(
                  filled ? Icons.favorite : Icons.favorite_border,
                  size: index == 4 ? 35 : 29,
                  color: color,
                ),
                Icon(
                  filled ? Icons.settings : Icons.settings_outlined,
                  size: index == 4 ? 35 : 29,
                  color: color,
                ),
              ],
            ),
    );
  }
}
