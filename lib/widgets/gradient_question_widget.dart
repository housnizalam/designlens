import 'package:flutter/material.dart';

import 'design_gradient.dart';
import 'color_question_widget.dart';

class GradientQuestionWidget extends StatelessWidget {
  final String? selectedMode;
  final String? customColor;
  final ValueChanged<String> onModeSelected;
  final ValueChanged<String> onCustomColorSelected;
  final String direction;
  final double balance;
  final double transitionWidth;
  final ValueChanged<double> onTransitionWidthChanged;
  final ValueChanged<String> onDirectionChanged;
  final ValueChanged<double> onBalanceChanged;
  final Color firstColor;
  final Color secondColor;

  const GradientQuestionWidget({
    super.key,
    required this.selectedMode,
    required this.customColor,
    required this.onModeSelected,
    required this.onCustomColorSelected,
    required this.direction,
    required this.balance,
    required this.transitionWidth,
    required this.onTransitionWidthChanged,
    required this.onDirectionChanged,
    required this.onBalanceChanged,
    required this.firstColor,
    required this.secondColor,
  });

  @override
  Widget build(BuildContext context) {
    const modes = [
      ('none', 'لون واحد دون تدرج'),
      ('primary_accent', 'مزج اللون الأساسي والإضافي'),
      ('primary_custom', 'مزج اللون الأساسي مع لون أختاره'),
    ];

    final primary = Theme.of(context).colorScheme.primary;

    return ListView(
      children: [
        for (int i = 0; i < modes.length; i++) ...[
          InkWell(
            onTap: () => onModeSelected(modes[i].$1),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: selectedMode == modes[i].$1 ? primary : Colors.black12,
                  width: selectedMode == modes[i].$1 ? 2 : 1,
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        selectedMode == modes[i].$1
                            ? Icons.check_circle
                            : Icons.radio_button_unchecked,
                        color: selectedMode == modes[i].$1
                            ? primary
                            : Colors.grey,
                      ),
                      const SizedBox(width: 10),
                      Expanded(child: Text(modes[i].$2)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    height: 64,
                    decoration: BoxDecoration(
                      color: i == 0 ? const Color(0xFF64748B) : null,
                      gradient: i == 0
                          ? null
                          : LinearGradient(
                              colors: i == 1
                                  ? const [Color(0xFF1E40AF), Color(0xFFDB2777)]
                                  : const [
                                      Color(0xFF1E40AF),
                                      Color(0xFF06B6D4),
                                    ],
                            ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],

        if (selectedMode != null && selectedMode != 'none') ...[
          const Divider(height: 32),

          const Text(
            'كيف تريد أن تمتزج الألوان؟',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 12),

          LayoutBuilder(
            builder: (context, constraints) {
              final itemWidth = (constraints.maxWidth - 12) / 2;

              const directions = [
                ('horizontal', 'من اليمين إلى اليسار'),
                ('vertical', 'من الأعلى إلى الأسفل'),
                ('diagonal', 'بشكل مائل'),
                ('radial', 'من الوسط إلى الأطراف'),
              ];

              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  for (final item in directions)
                    SizedBox(
                      width: itemWidth,
                      child: InkWell(
                        onTap: () => onDirectionChanged(item.$1),
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              width: direction == item.$1 ? 2 : 1,
                              color: direction == item.$1
                                  ? Theme.of(context).colorScheme.primary
                                  : Colors.black12,
                            ),
                          ),
                          child: Column(
                            children: [
                              Container(
                                height: 75,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(9),
                                  gradient: DesignGradient.build(
                                    first: firstColor,
                                    second: secondColor,
                                    direction: item.$1,
                                    balance: balance,
                                    transitionWidthPercent: transitionWidth,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                item.$2,
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 12),
                              ),
                              if (direction == item.$1)
                                const Icon(Icons.check_circle, size: 18),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),

          const SizedBox(height: 24),

          Text(
            'ما مقدار ظهور كل لون؟',
            style: Theme.of(context).textTheme.titleMedium,
          ),

          const SizedBox(height: 6),

          const Text('حرّك المؤشر لتجعل أحد اللونين أكثر ظهورًا.'),

          Slider(
            min: 0,
            max: 100,
            divisions: 20,
            value: balance,
            label: '${balance.round()}%',
            onChanged: onBalanceChanged,
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('اللون الأول أكثر'),
              Text('${balance.round()}%'),
              const Text('اللون الثاني أكثر'),
            ],
          ),

          const SizedBox(height: 22),
          Text('ما مدى اتساع منطقة اندماج اللونين؟',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 6),
          const Text('ضيق: انتقال حاد — واسع: انتقال تدريجي ناعم.'),
          Slider(
            min: 0,
            max: 100,
            divisions: 20,
            value: transitionWidth,
            label: '${transitionWidth.round()}%',
            onChanged: onTransitionWidthChanged,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('انتقال حاد'),
              Text('${transitionWidth.round()}%'),
              const Text('انتقال ناعم'),
            ],
          ),
          const SizedBox(height: 12),

          Container(
            height: 65,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: DesignGradient.build(
                first: firstColor,
                second: secondColor,
                direction: direction,
                balance: balance,
                transitionWidthPercent: transitionWidth,
              ),
            ),
          ),
        ],

        if (selectedMode == 'primary_custom') ...[
          const Divider(),
          const SizedBox(height: 8),
          const Text(
            'اختر اللون الذي تريد مزجه مع اللون الأساسي:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 420,
            child: ColorQuestionWidget(
              selectedValue: customColor,
              onSelected: onCustomColorSelected,
            ),
          ),
        ],

        const SizedBox(height: 8),
        const Text(
          'الصور اللونية أعلاه أمثلة توضيحية فقط. '
          'المعاينة الحية تستخدم الألوان التي اخترتها أنت.',
          style: TextStyle(color: Colors.black54, fontSize: 12),
        ),
      ],
    );
  }
}
