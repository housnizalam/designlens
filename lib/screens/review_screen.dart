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
  final GlobalKey _previewKey = GlobalKey();
  bool _exporting = false;

  Future<void> _exportPdf() async {
    if (_exporting) return;
    setState(() => _exporting = true);
    try {
      final boundary =
          _previewKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;
      if (boundary == null) {
        throw StateError('تعذر الوصول إلى المعاينة.');
      }
      await WidgetsBinding.instance.endOfFrame;
      final image = await boundary.toImage(pixelRatio: 2.5);
      try {
        final data = await image.toByteData(format: ui.ImageByteFormat.png);
        if (data == null) throw StateError('تعذر تحويل المعاينة إلى صورة.');
        await DesignPdfExport.export(
          previewPng: data.buffer.asUint8List(),
          arabicReport: DesignDnaReport.generate(widget.answers, arabic: true),
          englishReport: DesignDnaReport.generate(
            widget.answers,
            arabic: false,
          ),
        );
      } finally {
        image.dispose();
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('تعذر تصدير PDF: $error')));
      }
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final answers = widget.answers;
    final arabicReport = DesignDnaReport.generate(answers, arabic: true);
    final englishReport = DesignDnaReport.generate(answers, arabic: false);
    return Scaffold(
      appBar: AppBar(title: const Text('مراجعة الاختيارات')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'هذه تفضيلات التصميم التي اخترتها',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Text(
              'المعاينة البصرية المرفقة بالتقرير',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Center(
              child: SizedBox(
                width: 440,
                height: 850,
                child: RepaintBoundary(
                  key: _previewKey,
                  child: TickerMode(
                    enabled: false,
                    child: LiveDesignPreview(answers: answers),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: _exporting ? null : _exportPdf,
              icon: _exporting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.picture_as_pdf_outlined),
              label: Text(
                _exporting
                    ? 'جارٍ إنشاء الملف...'
                    : 'تصدير PDF (الصورة + العربية + الإنجليزية)',
              ),
            ),
            const SizedBox(height: 22),
            ...questions.map((question) {
              final selected = answers[question.id] ?? [];
              return Card(
                child: ListTile(
                  title: Text(question.title),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      selected.isEmpty
                          ? 'لم يحدد العميل تفضيلًا'
                          : question.type == QuestionType.referenceInput
                          ? selected
                                .map((encoded) {
                                  try {
                                    final data = jsonDecode(encoded) as Map;
                                    final name = data['name']?.toString() ?? '';
                                    final reason =
                                        data['reason']?.toString() ?? '';
                                    return reason.isEmpty
                                        ? name
                                        : '$name — $reason';
                                  } on FormatException {
                                    return encoded;
                                  }
                                })
                                .join('\n')
                          : selected.join('، '),
                    ),
                  ),
                ),
              );
            }),
            const SizedBox(height: 20),
            Text(
              'Design DNA — معاينة التقريرين',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            const Text(
              'يمكن معاينة التقريرين ونسخهما، أو تصديرهما مع الصورة في ملف PDF واحد.',
            ),
            const SizedBox(height: 12),
            _ReportPreview(
              label: 'التقرير العربي',
              text: arabicReport,
              arabic: true,
            ),
            _ReportPreview(
              label: 'English report',
              text: englishReport,
              arabic: false,
            ),
          ],
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
    return Card(
      child: ExpansionTile(
        title: Text(label),
        trailing: const Icon(Icons.description_outlined),
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
