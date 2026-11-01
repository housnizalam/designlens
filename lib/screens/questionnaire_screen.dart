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
import '../widgets/arabic_font_question_widget.dart';
import 'review_screen.dart';
import '../widgets/background_image_question_widget.dart';

const _panelBorder = Color(0xFFD9E3FF);
const _textDark = Color(0xFF24324B);
const _textSoft = Color(0xFF6D7C99);

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

    if (question.id == 'background_image') {
      selected
        ..clear()
        ..add(option);
    } else if (question.type == QuestionType.multiChoice) {
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
    if (question.id == 'background_image') {
      return BackgroundImageQuestionWidget(
        selectedValue: selectedAnswers.firstOrNull,
        onSelected: selectOption,
      );
    }
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

    if (question.id == 'font_personality') {
      return ArabicFontQuestionWidget(
        selectedValue: selectedAnswers.firstOrNull,
        onSelected: selectOption,
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
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                clipBehavior: Clip.antiAlias,
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

      final savedTransitionWidth =
          double.tryParse(
            answers['gradient_transition_width']?.firstOrNull ?? '',
          ) ??
          30.0;

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
        transitionWidth: savedTransitionWidth,
        onTransitionWidthChanged: (value) {
          setState(() {
            answers['gradient_transition_width'] = [value.round().toString()];
          });
        },
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
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.fromLTRB(5, 4, 5, 4),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerRight,
                end: Alignment.centerLeft,
                colors: selected
                    ? const [Color(0xFF4277DD), Color(0xFF9471E4)]
                    : const [Color(0xFFDAE7FF), Color(0xFFE5DAFA)],
              ),
              borderRadius: BorderRadius.circular(19),
              boxShadow: selected
                  ? const [BoxShadow(color: Color(0x333E65D4), blurRadius: 12, offset: Offset(0, 4))]
                  : null,
            ),
            child: VisualChoiceCard(
              questionType: question.type,
              option: option,
              index: index,
              selected: selected,
              onTap: () => selectOption(option),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final question = currentQuestion;

    final compact = MediaQuery.sizeOf(context).width < 650;
    // const navy = Color(0xFF162B57);
    const royal = Color(0xFF3465C5);
    const lavender = Color(0xFF7669D8);

    return Scaffold(
      backgroundColor: const Color(0xFFF2F5FC),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerTop,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(top: 20),
        child: SizedBox(
          width: compact ? 170 : 220,
          height: compact ? 115 : 150,
          child: Image.asset(
            'assets/images/branding/designlens_logo.png',
            fit: BoxFit.contain,
          ),
        ),
      ),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F9FF),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        actions: [
          Padding(
            padding: EdgeInsets.only(
              left: compact ? 10 : 24,
              right: 12,
              top: 6,
              bottom: 6,
            ),
            child: _RestartQuestionnaireButton(
              onPressed: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (dialogContext) => AlertDialog(
                    title: const Text('إعادة الاستبيان'),
                    content: const Text(
                      'هل أنت متأكد أنك تريد العودة إلى البداية؟ '
                      'سيتم حذف جميع إجاباتك الحالية.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(dialogContext, false),
                        child: const Text('إلغاء'),
                      ),
                      FilledButton(
                        onPressed: () => Navigator.pop(dialogContext, true),
                        child: const Text('نعم، ابدأ من جديد'),
                      ),
                    ],
                  ),
                );
                if (confirmed != true || !context.mounted) return;
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFF8F9FF), Color(0xFFEEF3FF), Color(0xFFF4F0FF)],
            ),
          ),
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              compact ? 12 : 20,
              12,
              compact ? 12 : 20,
              compact ? 10 : 14,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Indicator uses the existing question index and remains reactive.
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: SizedBox(
                    height: 8,
                    child: Stack(
                      children: [
                        const ColoredBox(
                          color: Color(0xFFDCE5F8),
                          child: SizedBox.expand(),
                        ),
                        FractionallySizedBox(
                          alignment: AlignmentDirectional.centerStart,
                          widthFactor: (currentIndex + 1) / questions.length,
                          child: const DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [royal, lavender],
                              ),
                            ),
                            child: SizedBox.expand(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: compact ? 14 : 20,
                    vertical: compact ? 13 : 17,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.centerRight,
                      end: Alignment.centerLeft,
                      colors: [
                        Color(0xFFE1EDFF),
                        Color(0xFFF4F7FF),
                        Color(0xFFEADFFF),
                      ],
                      stops: [0.0, 0.55, 1.0],
                    ),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: const Color(0xFFBFD0F9), width: 1.2),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x0F314E91),
                        blurRadius: 20,
                        offset: Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [Color(0xFFFDFEFF), Color(0xFFF4F7FF)],
                              ),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: _panelBorder),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x143155B3),
                                  blurRadius: 18,
                                  offset: Offset(0, 8),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 22,
                              vertical: 18,
                            ),
                            child: Text(
                              'السؤال ${currentIndex + 1} من ${questions.length}',
                              style: const TextStyle(
                                color: royal,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const Spacer(),
                          if (!compact)
                            const Text(
                              'صمّم وفق ذوقك',
                              style: TextStyle(
                                color: Color(0xFF7A87A6),
                                fontSize: 12,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        question.title,
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: _textDark,
                          height: 1.3,
                        ),
                      ),
                      if (question.description.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          question.description,
                          textAlign: TextAlign.right,
                          style: const TextStyle(
                            fontSize: 13.5,
                            color: _textSoft,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final isDesktop = constraints.maxWidth >= 800;
                      final questionArea = _DesignLensPanel(
                        isQuestionPanel: true,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const _DesignLensPanelHeading(
                              icon: Icons.tune_rounded,
                              title: 'اختياراتك',
                            ),
                            const SizedBox(height: 12),
                            Expanded(child: buildQuestionContent(question)),
                          ],
                        ),
                      );

                      final previewArea = _DesignLensPanel(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const _DesignLensPanelHeading(
                              icon: Icons.visibility_outlined,
                              title: 'معاينة تصميمك',
                            ),
                            const SizedBox(height: 12),
                            Expanded(
                              child: LiveDesignPreview(answers: answers),
                            ),
                          ],
                        ),
                      );

                      if (isDesktop) {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(flex: 5, child: questionArea),
                            const SizedBox(width: 16),
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
                            height: constraints.maxHeight * 0.38,
                            child: previewArea,
                          ),
                        ],
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.center,
                  child: TextButton.icon(
                    onPressed: nextQuestion,
                    icon: const Icon(Icons.skip_next_rounded, size: 17),
                    label: const Text('تخطي السؤال دون اختيار'),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF536EA5),
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                ),
                const SizedBox(height: 7),
                Row(
                  children: [
                    Expanded(
                      child: _DesignLensNavigationButton(
                        label: 'السابق',
                        icon: Icons.arrow_back_rounded,
                        filled: false,
                        onPressed: previousQuestion,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _DesignLensNavigationButton(
                        label: currentIndex == questions.length - 1
                            ? 'مراجعة الإجابات'
                            : 'التالي',
                        icon: Icons.arrow_forward_rounded,
                        filled: true,
                        onPressed: nextQuestion,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DesignLensPanel extends StatelessWidget {
  final Widget child;
  final bool isQuestionPanel;

  const _DesignLensPanel({
    required this.child,
    this.isQuestionPanel = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: isQuestionPanel
              ? const [
                  Color(0xFFDDEBFF),
                  Color(0xFFEBF0FF),
                  Color(0xFFE5DCFA),
                ]
              : const [
                  Color(0xFFF8FAFF),
                  Color(0xFFF0F4FF),
                  Color(0xFFF2EEFF),
                ],
          stops: const [0.0, 0.55, 1.0],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isQuestionPanel
              ? const Color(0xFFB4C8F2)
              : const Color(0xFFD5DEFA),
          width: 1.2,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x143B5FAD),
            blurRadius: 22,
            offset: Offset(0, 7),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _DesignLensPanelHeading extends StatelessWidget {
  final IconData icon;
  final String title;

  const _DesignLensPanelHeading({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFDCE9FF), Color(0xFFE9DFFF)],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFCAD8FA)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x183B61BE),
                blurRadius: 9,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Icon(icon, size: 20, color: const Color(0xFF385DC0)),
        ),
        const SizedBox(width: 11),
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            color: Color(0xFF213A68),
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}

class _DesignLensNavigationButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool filled;
  final VoidCallback onPressed;

  const _DesignLensNavigationButton({
    required this.label,
    required this.icon,
    required this.filled,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          height: 48,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: filled
                  ? const [
                      Color(0xFF234BA8),
                      Color(0xFF5276DA),
                      Color(0xFF8173DE),
                    ]
                  : const [Color(0xFFFFFFFF), Color(0xFFEDF2FF)],
            ),
            border: Border.all(
              color: filled ? const Color(0xFF4364C7) : const Color(0xFFC8D7F2),
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x193957A1),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: filled ? Colors.white : const Color(0xFF3156A3),
                size: 19,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: filled ? Colors.white : const Color(0xFF3156A3),
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RestartQuestionnaireButton extends StatelessWidget {
  final Future<void> Function() onPressed;

  const _RestartQuestionnaireButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onPressed,
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 11),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFEAF1FF), Color(0xFFBFD2FF), Color(0xFF8BB6FF)],
            ),
            border: Border.all(color: const Color(0xFF5D8EF7), width: 1.2),
            boxShadow: const [
              BoxShadow(
                color: Color(0x332E5AAC),
                blurRadius: 12,
                offset: Offset(0, 5),
              ),
              BoxShadow(
                color: Color(0x66FFFFFF),
                blurRadius: 0,
                offset: Offset(0, 1),
                spreadRadius: -1,
              ),
            ],
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.restart_alt_rounded,
                size: 25,
                color: Color(0xFF1D4ED8),
              ),
              SizedBox(width: 6),
              Text(
                'ابدأ من جديد',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E3A8A),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
