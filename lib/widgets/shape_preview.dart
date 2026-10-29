
import 'package:flutter/material.dart';

class ShapePreview extends StatelessWidget {
  final Map<String, List<String>> answers;

  const ShapePreview({
    super.key,
    required this.answers,
  });

  String? answer(String id) {
    final values = answers[id];
    return values == null || values.isEmpty
        ? null
        : values.first;
  }

  int selectedIndex(String id, List<String> options) {
    return options.indexOf(answer(id) ?? '');
  }

  @override
  Widget build(BuildContext context) {
    final radiusIndex = selectedIndex('corners', [
      'حواف حادة',
      'استدارة خفيفة',
      'استدارة متوسطة',
      'استدارة كبيرة',
      'استدارة كبيرة جدًا',
    ]);

    final radius = <double>[
      0, 6, 14, 24, 36,
    ][radiusIndex < 0 ? 2 : radiusIndex];

    final shadowIndex = selectedIndex('shadows', [
      'مسطحة دون ظل',
      'ظل خفيف وناعم',
      'ظل واضح',
      'تبدو مرتفعة كثيرًا',
    ]);

    final shadowLevel =
        shadowIndex < 0 ? 0 : shadowIndex;

    final borderIndex = selectedIndex('borders', [
      'دون إطار',
      'إطار خفيف',
      'إطار متوسط',
      'إطار واضح',
    ]);

    final borderWidth = <double>[
      0, 0.8, 1.8, 3.5,
    ][borderIndex < 0 ? 1 : borderIndex];

    final shadows = shadowLevel == 0
        ? <BoxShadow>[]
        : [
            BoxShadow(
              color: Colors.black.withValues(
                alpha: 0.12 + shadowLevel * 0.06,
              ),
              blurRadius: 5 + shadowLevel * 8,
              offset: Offset(0, shadowLevel * 3.0),
            ),
          ];

    final border = borderWidth == 0
        ? null
        : Border.all(
            color: const Color(0xFF64748B),
            width: borderWidth,
          );

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF0F2F5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black12),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'معاينة أشكال العناصر',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'تتغير الحواف والظلال والإطارات '
              'حسب اختياراتك.',
              style: TextStyle(
                color: Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 32),

            // البطاقة الرئيسية
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(radius),
                border: border,
                boxShadow: shadows,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(
                    Icons.dashboard_customize_outlined,
                    size: 35,
                    color: Color(0xFF475569),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'بطاقة تجريبية',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ),
                  ),
                  const SizedBox(height: 7),
                  const Text(
                    'لاحظ شكل الحواف والإطارات '
                    'ودرجة ارتفاع البطاقة.',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 34),

            // بطاقتان صغيرتان
            Row(
              children: [
                for (final item in [
                  (Icons.star_outline, 'الخدمات'),
                  (Icons.person_outline, 'الحساب'),
                ]) ...[
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 19,
                        horizontal: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.circular(radius),
                        border: border,
                        boxShadow: shadows,
                      ),
                      child: Column(
                        children: [
                          Icon(
                            item.$1,
                            color: const Color(0xFF475569),
                          ),
                          const SizedBox(height: 8),
                          Text(item.$2),
                        ],
                      ),
                    ),
                  ),
                  if (item.$2 == 'الخدمات')
                    const SizedBox(width: 22),
                ],
              ],
            ),

            const SizedBox(height: 34),

            // زر تجريبي
            Container(
              padding: const EdgeInsets.all(16),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xFF475569),
                borderRadius: BorderRadius.circular(radius),
                border: border,
                boxShadow: shadows,
              ),
              child: const Text(
                'زر تجريبي',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 30),

            Text(
              'استدارة الحواف: ${radius.round()}',
              style: const TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 6),
            Text(
              'مستوى الظل: $shadowLevel',
              style: const TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 6),
            Text(
              'سماكة الإطار: $borderWidth',
              style: const TextStyle(color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}
