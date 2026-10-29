
import 'package:flutter/material.dart';

class ScaleQuestionWidget extends StatelessWidget {
  final List<String> options;
  final String? selectedValue;
  final ValueChanged<String> onSelected;

  const ScaleQuestionWidget({
    super.key,
    required this.options,
    required this.selectedValue,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return ListView(
      children: [
        const SizedBox(height: 12),
        for (int i = 0; i < options.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: InkWell(
              onTap: () => onSelected(options[i]),
              borderRadius: BorderRadius.circular(14),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 17,
                ),
                decoration: BoxDecoration(
                  color: selectedValue == options[i]
                      ? const Color(0xFFE8F0FF)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: selectedValue == options[i]
                        ? primary
                        : Colors.black12,
                    width: selectedValue == options[i]
                        ? 2
                        : 1,
                  ),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor:
                          selectedValue == options[i]
                              ? primary
                              : const Color(0xFFE5E7EB),
                      child: Text(
                        '${i + 1}',
                        style: TextStyle(
                          color: selectedValue == options[i]
                              ? Colors.white
                              : Colors.black87,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        options[i],
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                    if (selectedValue == options[i])
                      Icon(
                        Icons.check_circle,
                        color: primary,
                      ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
