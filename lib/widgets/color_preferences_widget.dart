
import 'package:flutter/material.dart';
import 'color_question_widget.dart';

// الألوان التي لا يريدها العميل.
class AvoidColorsWidget extends StatelessWidget {
  final List<String> selectedValues;
  final ValueChanged<String> onToggle;

  const AvoidColorsWidget({
    super.key,
    required this.selectedValues,
    required this.onToggle,
  });

  String toHex(Color color) {
    final rgb = color.toARGB32() & 0xFFFFFF;
    return '#${rgb.toRadixString(16).padLeft(6, '0').toUpperCase()}';
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        if (selectedValues.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              'تم استبعاد ${selectedValues.length} لون',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate:
              const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 120,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.1,
          ),
          itemCount: ColorQuestionWidget.palette.length,
          itemBuilder: (context, index) {
            final color = ColorQuestionWidget.palette[index];
            final hex = toHex(color);
            final selected = selectedValues.contains(hex);

            return InkWell(
              onTap: () => onToggle(hex),
              borderRadius: BorderRadius.circular(14),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: selected
                      ? const Color(0xFFFFEEEE)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: selected
                        ? Colors.red
                        : Colors.black12,
                    width: selected ? 2 : 1,
                  ),
                ),
                child: Column(
                  children: [
                    Expanded(
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(9),
                          border: Border.all(
                            color: Colors.black12,
                          ),
                        ),
                        child: selected
                            ? const Icon(
                                Icons.block,
                                color: Colors.red,
                                size: 30,
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      hex,
                      textDirection: TextDirection.ltr,
                      style: const TextStyle(fontSize: 11),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

// عرض أمثلة طبيعة الألوان بدل المصطلحات التقنية.
class ColorStyleWidget extends StatelessWidget {
  final List<String> options;
  final String? selectedValue;
  final ValueChanged<String> onSelected;

  const ColorStyleWidget({
    super.key,
    required this.options,
    required this.selectedValue,
    required this.onSelected,
  });

  static const List<List<Color>> examples = [
    [
      Color(0xFF64748B),
      Color(0xFF94A3B8),
      Color(0xFFCBD5E1),
      Color(0xFFE2E8F0),
    ],
    [
      Color(0xFFEF4444),
      Color(0xFFFACC15),
      Color(0xFF22C55E),
      Color(0xFF2563EB),
    ],
    [
      Color(0xFFFBCFE8),
      Color(0xFFDDD6FE),
      Color(0xFFBFDBFE),
      Color(0xFFA7F3D0),
    ],
    [
      Color(0xFF0F172A),
      Color(0xFF1E293B),
      Color(0xFF334155),
      Color(0xFF475569),
    ],
    [
      Color(0xFFFFFFFF),
      Color(0xFFF1F5F9),
      Color(0xFFDBEAFE),
      Color(0xFFE2E8F0),
    ],
    [
      Color(0xFF1E3A8A),
      Color(0xFF2563EB),
      Color(0xFF60A5FA),
      Color(0xFFBFDBFE),
    ],
    [
      Color(0xFF7C3AED),
      Color(0xFFA855F7),
      Color(0xFFEC4899),
      Color(0xFFF97316),
    ],
  ];

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return ListView.builder(
      itemCount: options.length,
      itemBuilder: (context, index) {
        final option = options[index];
        final selected = selectedValue == option;
        final isDesignerChoice = index >= examples.length;

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            onTap: () => onSelected(option),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: selected
                    ? const Color(0xFFE8F0FF)
                    : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: selected ? primary : Colors.black12,
                  width: selected ? 2 : 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Icon(
                        selected
                            ? Icons.check_circle
                            : Icons.radio_button_unchecked,
                        color: selected ? primary : Colors.grey,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          option,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (!isDesignerChoice) ...[
                    const SizedBox(height: 14),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: SizedBox(
                        height: 62,
                        child: Row(
                          children: [
                            for (final color in examples[index])
                              Expanded(
                                child: Container(color: color),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
