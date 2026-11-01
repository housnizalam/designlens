import 'dart:convert';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/questions.dart';
import '../models/design_question.dart';
import '../services/design_dna_report.dart';
import '../services/design_pdf_export.dart';
import '../widgets/live_design_preview.dart';

class ReviewScreen extends StatefulWidget {
  final Map<String, List<String>> answers;

  const ReviewScreen({super.key, required this.answers});

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  final GlobalKey _mobilePreviewKey = GlobalKey();
  final GlobalKey _desktopPreviewKey = GlobalKey();
  bool _exporting = false;

  // Scroll each preview into the viewport before rasterizing: an offscreen
  // RepaintBoundary might not have been painted yet.
  Future<Uint8List> _capturePreview(
    GlobalKey key, {
    required double pixelRatio,
  }) async {
    final previewContext = key.currentContext;
    if (previewContext == null) {
      throw StateError('تعذر الوصول إلى إحدى المعاينتين.');
    }
    await Scrollable.ensureVisible(
      previewContext,
      duration: const Duration(milliseconds: 180),
      alignment: 0.12,
    );
    await WidgetsBinding.instance.endOfFrame;
    if (!mounted || !previewContext.mounted) {
      throw StateError('لم تعد المعاينة متاحة للتصدير.');
    }
    final boundary =
        previewContext.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null) {
      throw StateError('تعذر تصوير إحدى المعاينتين.');
    }
    final image = await boundary.toImage(pixelRatio: pixelRatio);
    try {
      final data = await image.toByteData(format: ui.ImageByteFormat.png);
      if (data == null) throw StateError('تعذر تحويل المعاينة إلى صورة.');
      return data.buffer.asUint8List();
    } finally {
      image.dispose();
    }
  }

  Future<void> _exportPdf() async {
    if (_exporting) return;
    setState(() => _exporting = true);
    try {
      final desktopPng = await _capturePreview(
        _desktopPreviewKey,
        pixelRatio: 1.6,
      );
      final mobilePng = await _capturePreview(
        _mobilePreviewKey,
        pixelRatio: 2.0,
      );
      await DesignPdfExport.export(
        desktopPreviewPng: desktopPng,
        mobilePreviewPng: mobilePng,
        arabicReport: DesignDnaReport.generate(widget.answers, arabic: true),
        englishReport: DesignDnaReport.generate(widget.answers, arabic: false),
      );
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('تعذر تصدير PDF: $error')));
      }
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  Future<void> _restart() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('بدء تصميم جديد'),
        content: const Text(
          'هل تريد العودة إلى البداية؟ ستفقد جميع اختياراتك الحالية.',
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
    if (confirmed != true || !mounted) return;
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  String _displayAnswer(DesignQuestion question, List<String> selected) {
    if (selected.isEmpty) return 'لم يحدد العميل تفضيلًا';
    if (question.id == 'background_image') {
      final value = selected.first;
      const labels = {
        'none': 'بدون صورة خلفية',
        'asset:future': 'تكنولوجيا ومستقبل',
        'asset:nature': 'طبيعة ومناظر خلابة',
        'asset:space': 'فضاء وكواكب',
        'asset:city': 'مدينة عصرية فاخرة',
      };
      if (value.startsWith('file:')) return 'صورة خاصة من جهاز العميل';
      return labels[value] ?? value;
    }
    if (question.type != QuestionType.referenceInput) {
      return selected.join('، ');
    }
    return selected
        .map((encoded) {
          try {
            final data = jsonDecode(encoded) as Map;
            final name = data['name']?.toString() ?? '';
            final reason = data['reason']?.toString() ?? '';
            return reason.isEmpty ? name : '$name — $reason';
          } on FormatException {
            return encoded;
          }
        })
        .join('\n');
  }

  @override
  Widget build(BuildContext context) {
    final answers = widget.answers;
    final arabicReport = DesignDnaReport.generate(answers, arabic: true);
    final englishReport = DesignDnaReport.generate(answers, arabic: false);
    final compact = MediaQuery.sizeOf(context).width < 650;
    const navy = Color(0xFF162B57);
    const royal = Color(0xFF3465C5);

    return Scaffold(
      backgroundColor: const Color(0xFFF2F5FC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F9FF),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'مراجعة الاختيارات',
          style: TextStyle(color: navy, fontWeight: FontWeight.w700),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(
              left: compact ? 10 : 24,
              right: 12,
              top: 6,
              bottom: 6,
            ),
            child: _RestartReviewButton(onPressed: _restart),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF8F9FF), Color(0xFFEEF3FF), Color(0xFFF4F0FF)],
          ),
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 12 : 24,
            vertical: 20,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1080),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _ReviewPanel(
                    padding: EdgeInsets.all(compact ? 18 : 24),
                    child: Row(
                      children: [
                        Container(
                          width: compact ? 46 : 58,
                          height: compact ? 46 : 58,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFDDE9FF), Color(0xFFEBE3FF)],
                            ),
                            borderRadius: BorderRadius.circular(17),
                          ),
                          child: const Icon(
                            Icons.verified_outlined,
                            color: royal,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'تصميمك أصبح جاهزًا للمراجعة',
                                style: TextStyle(
                                  color: navy,
                                  fontWeight: FontWeight.w800,
                                  fontSize: compact ? 18 : 24,
                                ),
                              ),
                              const SizedBox(height: 7),
                              const Text(
                                'راجع اختياراتك، وشاهد النتيجة المرئية، ثم صدّر ملف Design DNA للمصمم.',
                                style: TextStyle(
                                  color: Color(0xFF657391),
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  _ReviewPanel(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const _ReviewHeading(
                          icon: Icons.visibility_outlined,
                          title: 'المعاينات البصرية النهائية',
                          subtitle: 'معاينتان مستقلتان للكمبيوتر والموبايل؛ تُرفقان معًا في PDF.',
                        ),
                        const SizedBox(height: 20),
                        const _ReviewHeading(
                          icon: Icons.desktop_windows_outlined,
                          title: 'معاينة الكمبيوتر — شاشة عرضية',
                          subtitle: 'تصميم بسطح واسع بنسبة 16:10.',
                        ),
                        const SizedBox(height: 12),
                        // The full-size screenshot is rendered at 1000 x 625.
                        // FittedBox scales the display only, not the capture.
                        LayoutBuilder(
                          builder: (context, constraints) => SizedBox(
                            width: constraints.maxWidth,
                            height: constraints.maxWidth * 0.625,
                            child: FittedBox(
                              fit: BoxFit.contain,
                              alignment: Alignment.topCenter,
                              child: SizedBox(
                                width: 1000,
                                height: 625,
                                child: RepaintBoundary(
                                  key: _desktopPreviewKey,
                                  child: TickerMode(
                                    enabled: false,
                                    child: LiveDesignPreview(answers: answers),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        const _ReviewHeading(
                          icon: Icons.smartphone_outlined,
                          title: 'معاينة الموبايل — شاشة طولية',
                          subtitle: 'معاينة الهاتف بالقياس المعتمد سابقًا.',
                        ),
                        const SizedBox(height: 12),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final displayWidth = constraints.maxWidth < 440
                                ? constraints.maxWidth
                                : 440.0;
                            return Center(
                              child: SizedBox(
                                width: displayWidth,
                                height: displayWidth * 850 / 440,
                                child: FittedBox(
                                  fit: BoxFit.contain,
                                  child: SizedBox(
                                    width: 440,
                                    height: 850,
                                    child: RepaintBoundary(
                                      key: _mobilePreviewKey,
                                      child: TickerMode(
                                        enabled: false,
                                        child: LiveDesignPreview(
                                          answers: answers,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 20),
                        DecoratedBox(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x29365CC1),
                                blurRadius: 18,
                                offset: Offset(0, 7),
                              ),
                            ],
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFF234BA8),
                                Color(0xFF5276DA),
                                Color(0xFF8173DE),
                              ],
                            ),
                          ),
                          child: FilledButton.icon(
                            onPressed: _exporting ? null : _exportPdf,
                            icon: _exporting
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(Icons.picture_as_pdf_outlined),
                            label: Text(
                              _exporting ? 'جارٍ إنشاء الملف...' : 'تصدير PDF (معاينة الكمبيوتر + الموبايل + التقريرين)',
                              textAlign: TextAlign.center,
                            ),
                            style: FilledButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              foregroundColor: Colors.white,
                              disabledForegroundColor: Colors.white70,
                              disabledBackgroundColor: Colors.transparent,
                              minimumSize: const Size.fromHeight(54),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  _ReviewPanel(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const _ReviewHeading(
                          icon: Icons.fact_check_outlined,
                          title: 'تفاصيل اختياراتك',
                          subtitle: 'جميع إجابات الاستبيان في مكان واحد.',
                        ),
                        const SizedBox(height: 16),
                        for (var i = 0; i < questions.length; i++) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 15,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: i.isEven
                                  ? const Color(0xFFF4F7FF)
                                  : Colors.white.withValues(alpha: 0.65),
                              borderRadius: BorderRadius.circular(13),
                              border: Border.all(
                                color: const Color(0xFFE2E8F5),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 9,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFE6EDFF),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        '${i + 1}',
                                        style: const TextStyle(
                                          color: royal,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        questions[i].title,
                                        style: const TextStyle(
                                          color: navy,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _displayAnswer(
                                    questions[i],
                                    answers[questions[i].id] ?? [],
                                  ),
                                  style: TextStyle(
                                    color:
                                        (answers[questions[i].id] ?? []).isEmpty
                                        ? const Color(0xFF8A96AE)
                                        : const Color(0xFF4C5E7E),
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (i < questions.length - 1)
                            const SizedBox(height: 8),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  _ReviewPanel(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const _ReviewHeading(
                          icon: Icons.description_outlined,
                          title: 'Design DNA — معاينة التقريرين',
                          subtitle: 'يمكنك قراءة التقريرين ونسخهما، أو تصديرهما مع الصورة داخل PDF واحد.',
                        ),
                        const SizedBox(height: 14),
                        _ReportPreview(
                          label: 'التقرير العربي',
                          text: arabicReport,
                          arabic: true,
                        ),
                        const SizedBox(height: 10),
                        _ReportPreview(
                          label: 'English report',
                          text: englishReport,
                          arabic: false,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ReviewPanel extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const _ReviewPanel({
    required this.child,
    this.padding = const EdgeInsets.all(18),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFDDE5F5)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10344D87),
            blurRadius: 20,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _ReviewHeading extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _ReviewHeading({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFDEE9FF), Color(0xFFEDE6FF)],
            ),
            borderRadius: BorderRadius.circular(11),
          ),
          child: Icon(icon, size: 19, color: const Color(0xFF385DC0)),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF213A68),
                  fontSize: 17,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  color: Color(0xFF657391),
                  fontSize: 12,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RestartReviewButton extends StatelessWidget {
  final Future<void> Function() onPressed;

  const _RestartReviewButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onPressed,
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
            ],
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.restart_alt_rounded,
                size: 23,
                color: Color(0xFF1D4ED8),
              ),
              SizedBox(width: 6),
              Text(
                'ابدأ من جديد',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E3A8A),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReportPreview extends StatelessWidget {
  final String label;
  final String text;
  final bool arabic;

  const _ReportPreview({
    required this.label,
    required this.text,
    required this.arabic,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFDDE5F5)),
        borderRadius: BorderRadius.circular(15),
        color: const Color(0xFFF8FAFF),
      ),
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        title: Text(
          label,
          style: const TextStyle(
            color: Color(0xFF3156A3),
            fontWeight: FontWeight.w700,
          ),
        ),
        leading: const Icon(
          Icons.description_outlined,
          color: Color(0xFF7669D8),
        ),
        children: [
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: TextButton.icon(
                onPressed: () async {
                  await Clipboard.setData(ClipboardData(text: text));
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        arabic
                            ? 'تم نسخ التقرير العربي'
                            : 'English report copied',
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.copy),
                label: Text(
                  arabic ? 'نسخ التقرير العربي' : 'Copy English report',
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Directionality(
              textDirection: arabic ? TextDirection.rtl : TextDirection.ltr,
              child: SelectableText(
                text,
                textAlign: arabic ? TextAlign.right : TextAlign.left,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
