import 'package:flutter/material.dart';

import '../models/design_question.dart';
import '../data/questions.dart';
import '../widgets/scale_question_widget.dart';
import '../widgets/live_design_preview.dart';
import '../widgets/color_question_widget.dart';
import '../widgets/color_preferences_widget.dart';
import '../widgets/gradient_question_widget.dart';
import '../widgets/visual_choice_card.dart';
import '../widgets/reference_question_widget.dart';
import 'review_screen.dart';

class QuestionnaireScreen extends StatefulWidget {
  const QuestionnaireScreen({super.key});

  @override
  State<QuestionnaireScreen> createState() => _QuestionnaireScreenState();
}

class _QuestionnaireScreenState extends State<QuestionnaireScreen> {
  int currentIndex = 0;

  final Map<String, List<String>> answers = {};

  DesignQuestion get currentQuestion => questions[currentIndex];

  List<String> get selectedAnswers => answers[currentQuestion.id] ?? [];

  void selectOption(String option) {
    final question = currentQuestion;
    final selected = List<String>.from(answers[question.id] ?? []);

    if (question.type == QuestionType.multiChoice) {
      if (selected.contains(option)) {
        selected.remove(option);
      } else if (selected.length < question.maxSelections) {
        selected.add(option);
      }
    } else {
      selected
        ..clear()
        ..add(option);
    }

    setState(() {
      answers[question.id] = selected;
    });
  }

  void toggleAvoidedColor(String hex) {
    const questionId = 'avoided_colors';

    final selected = List<String>.from(answers[questionId] ?? []);

    if (selected.contains(hex)) {
      selected.remove(hex);
    } else {
      selected.add(hex);
    }

    setState(() {
      answers[questionId] = selected;
    });
  }

  void nextQuestion() {
    if (currentIndex < questions.length - 1) {
      setState(() => currentIndex++);
    } else {
      Navigator.push(
        context,
        MaterialPageRoute<void>(builder: (_) => ReviewScreen(answers: answers)),
      );
    }
  }

  void previousQuestion() {
    if (currentIndex > 0) {
      setState(() => currentIndex--);
    } else {
      Navigator.pop(context);
    }
  }

  Widget buildQuestionContent(DesignQuestion question) {
    if (question.type == QuestionType.referenceInput) {
      return ReferenceQuestionWidget(
        key: ValueKey(question.id),
        savedReferences: answers[question.id] ?? [],
        isLiked: question.id == 'liked_references',
        onChanged: (entries) {
          setState(() {
            answers[question.id] = entries;
          });
        },
      );
    }

    if (question.type == QuestionType.scale) {
      return ScaleQuestionWidget(
        options: question.options,
        selectedValue: selectedAnswers.firstOrNull,
        onSelected: selectOption,
      );
    }
    if (question.type == QuestionType.borderColorChoice) {
      final customColors = answers['border_custom_color'] ?? [];

      return ListView(
        children: [
          for (final option in question.options)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                title: Text(option),
                leading: Icon(
                  selectedAnswers.contains(option)
                      ? Icons.check_circle
                      : Icons.radio_button_unchecked,
                ),
                onTap: () => selectOption(option),
                tileColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          if (selectedAnswers.contains('أريد اختيار لون خاص للإطارات'))
            SizedBox(
              height: 420,
              child: ColorQuestionWidget(
                selectedValue: customColors.isEmpty ? null : customColors.first,
                onSelected: (value) {
                  setState(() {
                    answers['border_custom_color'] = [value];
                  });
                },
              ),
            ),
        ],
      );
    }

    if (question.type == QuestionType.colorChoice) {
      final isPrimary = question.id == 'primary_color';

      final savedStrength = answers['primary_color_strength']?.firstOrNull;

      final strength = double.tryParse(savedStrength ?? '') ?? 60.0;

      final colorPicker = ColorQuestionWidget(
        selectedValue: selectedAnswers.isEmpty ? null : selectedAnswers.first,
        onSelected: selectOption,
      );

      if (!isPrimary) {
        return colorPicker;
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: colorPicker),

          const SizedBox(height: 12),

          Text(
            'ما مدى ظهور اللون الأساسي في التصميم؟',
            style: Theme.of(context).textTheme.titleMedium,
          ),

          const SizedBox(height: 6),

          Text(
            'اسحب المؤشر لترى كيف تتغير ألوان '
            'الخلفيات والبطاقات.',
            style: Theme.of(context).textTheme.bodySmall,
          ),

          Slider(
            min: 0,
            max: 100,
            divisions: 20,
            value: strength,
            label: '${strength.round()}%',
            onChanged: (value) {
              setState(() {
                answers['primary_color_strength'] = [value.round().toString()];
              });
            },
          ),

          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [Text('تأثير خفيف'), Text('تأثير قوي')],
          ),

          const SizedBox(height: 8),
        ],
      );
    }

    if (question.type == QuestionType.colorAvoid) {
      return AvoidColorsWidget(
        selectedValues: selectedAnswers,
        onToggle: toggleAvoidedColor,
      );
    }

    if (question.type == QuestionType.colorStylePreview) {
      return ColorStyleWidget(
        options: question.options,
        selectedValue: selectedAnswers.isEmpty ? null : selectedAnswers.first,
        onSelected: selectOption,
      );
    }

    if (question.type == QuestionType.gradientChoice) {
      final customColors = answers['gradient_custom_color'] ?? [];

      final savedDirection =
          answers['gradient_direction']?.firstOrNull ?? 'diagonal';

      final savedBalance =
          double.tryParse(answers['gradient_balance']?.firstOrNull ?? '') ??
          50.0;

      Color parseColor(String? hex) {
        if (hex == null || !RegExp(r'^#[0-9a-fA-F]{6}$').hasMatch(hex)) {
          return const Color(0xFF64748B);
        }

        return Color(int.parse(hex.substring(1), radix: 16) | 0xFF000000);
      }

      final mode = selectedAnswers.firstOrNull;

      final firstColor = parseColor(answers['primary_color']?.firstOrNull);

      final secondColor = parseColor(
        mode == 'primary_custom'
            ? customColors.firstOrNull
            : answers['accent_color']?.firstOrNull,
      );

      return GradientQuestionWidget(
        selectedMode: mode,
        customColor: customColors.firstOrNull,
        firstColor: firstColor,
        secondColor: secondColor,
        direction: savedDirection,
        balance: savedBalance,
        onModeSelected: selectOption,
        onCustomColorSelected: (value) {
          setState(() {
            answers['gradient_custom_color'] = [value];
          });
        },
        onDirectionChanged: (value) {
          setState(() {
            answers['gradient_direction'] = [value];
          });
        },
        onBalanceChanged: (value) {
          setState(() {
            answers['gradient_balance'] = [value.round().toString()];
          });
        },
      );
    }

    return ListView.builder(
      itemCount: question.options.length,
      itemBuilder: (context, index) {
        final option = question.options[index];
        final selected = selectedAnswers.contains(option);

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: VisualChoiceCard(
            questionType: question.type,
            option: option,
            index: index,
            selected: selected,
            onTap: () => selectOption(option),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final question = currentQuestion;

    return Scaffold(
      appBar: AppBar(title: const Text('اكتشف ذوقك في التصميم')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              LinearProgressIndicator(
                value: (currentIndex + 1) / questions.length,
                minHeight: 7,
                borderRadius: BorderRadius.circular(10),
              ),
              const SizedBox(height: 14),
              Text(
                'السؤال ${currentIndex + 1} '
                'من ${questions.length}',
                style: TextStyle(color: Theme.of(context).colorScheme.primary),
              ),
              const SizedBox(height: 20),
              Text(
                question.title,
                style: Theme.of(context).textTheme.headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                question.description,
                style: const TextStyle(color: Colors.black54),
              ),
              const SizedBox(height: 18),

              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isDesktop = constraints.maxWidth >= 800;

                    final questionArea = Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(child: buildQuestionContent(question)),
                      ],
                    );

                    final previewArea = Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              Icon(Icons.visibility_outlined, size: 20),
                              SizedBox(width: 8),
                              Text(
                                'معاينة تصميمك',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                        Expanded(child: LiveDesignPreview(answers: answers)),
                      ],
                    );

                    if (isDesktop) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(flex: 5, child: questionArea),
                          const SizedBox(width: 20),
                          Expanded(flex: 4, child: previewArea),
                        ],
                      );
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(child: questionArea),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: constraints.maxHeight * 0.42,
                          child: previewArea,
                        ),
                      ],
                    );
                  },
                ),
              ),

              TextButton(
                onPressed: nextQuestion,
                child: const Text('تخطي السؤال دون اختيار'),
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: previousQuestion,
                      child: const Text('السابق'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: nextQuestion,
                      child: Text(
                        currentIndex == questions.length - 1
                            ? 'مراجعة الإجابات'
                            : 'التالي',
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
