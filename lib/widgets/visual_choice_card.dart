import 'package:flutter/material.dart';
import '../models/design_question.dart';
import 'visual_previews.dart';
import 'style_option_previews.dart';

class VisualChoiceCard extends StatelessWidget {
  final QuestionType questionType;
  final String option;
  final int index;
  final bool selected;
  final VoidCallback onTap;

  const VisualChoiceCard({
    super.key,
    required this.questionType,
    required this.option,
    required this.index,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final hasPreview =
        questionType == QuestionType.cornerPreview ||
        questionType == QuestionType.shadowPreview ||
        questionType == QuestionType.glassPreview ||
        questionType == QuestionType.borderPreview ||
        questionType == QuestionType.shapePreview ||
        questionType == QuestionType.uiStylePreview ||
        questionType == QuestionType.typographyPreview ||
        questionType == QuestionType.iconPreview;

    return Material(
      color: selected ? const Color(0xFFE8F0FF) : Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? primary : const Color(0xFFE0E5ED),
              width: selected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(
                    selected
                        ? Icons.check_circle
                        : Icons.radio_button_unchecked,
                    color: selected ? primary : Colors.grey,
                  ),
                  const SizedBox(width: 12),
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
              if (hasPreview) ...[
                const SizedBox(height: 16),
                if (questionType == QuestionType.cornerPreview)
                  CornerPreview(index: index),
                if (questionType == QuestionType.shadowPreview)
                  ShadowPreview(index: index),
                if (questionType == QuestionType.glassPreview)
                  GlassPreview(index: index),
                if (questionType == QuestionType.borderPreview)
                  BorderPreview(index: index),
                if (questionType == QuestionType.shapePreview)
                  ShapeOptionPreview(index: index),
                if (questionType == QuestionType.uiStylePreview && index < 10)
                  StyleOptionPreview(index: index),
                if (questionType == QuestionType.typographyPreview)
                  TypographyOptionPreview(index: index),
                if (questionType == QuestionType.iconPreview)
                  IconOptionPreview(index: index),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------- CORNER PREVIEW ----------------
