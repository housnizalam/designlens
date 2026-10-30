import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../data/questions.dart';
import '../models/design_question.dart';
import '../services/design_dna_report.dart';

class ReviewScreen extends StatelessWidget {
  final Map<String, List<String>> answers;

  const ReviewScreen({super.key, required this.answers});

  @override
  Widget build(BuildContext context) {
    final arabicReport = DesignDnaReport.generate(answers, arabic: true);
    final englishReport = DesignDnaReport.generate(answers, arabic: false);
    return Scaffold(
      appBar: AppBar(title: const Text('مراجعة الاختيارات')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('هذه تفضيلات التصميم التي اخترتها',
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
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
                            ? selected.map((encoded) {
                                try {
                                  final data = jsonDecode(encoded) as Map;
                                  final name = data['name']?.toString() ?? '';
                                  final reason = data['reason']?.toString() ?? '';
                                  return reason.isEmpty ? name : '$name — $reason';
                                } on FormatException {
                                  return encoded;
                                }
                              }).join('\n')
                            : selected.join('، '),
                  ),
                ),
              ),
            );
          }),
          const SizedBox(height: 20),
          Text('Design DNA — معاينة التقريرين',
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          const Text('هذه مرحلة معاينة ونسخ التقرير. إضافة حفظ ملفي Markdown منفصلين هي الخطوة التالية.'),
          const SizedBox(height: 12),
          _ReportPreview(label: 'التقرير العربي', text: arabicReport, arabic: true),
          _ReportPreview(label: 'English report', text: englishReport, arabic: false),
        ],
      ),
    );
  }
}

class _ReportPreview extends StatelessWidget {
  final String label;
  final String text;
  final bool arabic;

  const _ReportPreview({required this.label, required this.text, required this.arabic});

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
                    SnackBar(content: Text(arabic ? 'تم نسخ التقرير العربي' : 'English report copied')),
                  );
                },
                icon: const Icon(Icons.copy),
                label: Text(arabic ? 'نسخ التقرير العربي' : 'Copy English report'),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Directionality(
              textDirection: arabic ? TextDirection.rtl : TextDirection.ltr,
              child: SelectableText(text, textAlign: arabic ? TextAlign.right : TextAlign.left),
            ),
          ),
        ],
      ),
    );
  }
}
