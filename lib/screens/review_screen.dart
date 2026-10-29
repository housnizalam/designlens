import 'dart:convert';
import 'package:flutter/material.dart';
import '../data/questions.dart';
import '../models/design_question.dart';

class ReviewScreen extends StatelessWidget {
  final Map<String, List<String>> answers;

  const ReviewScreen({super.key, required this.answers});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('مراجعة الاختيارات')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'هذه تفضيلات التصميم التي اخترتها',
            style: Theme.of(context).textTheme.titleLarge,
          ),
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
          const Text(
            'هذه نسخة تجريبية للأسئلة البصرية. '
            'سنضيف لاحقًا توليد الهوية البصرية '
            'والمواصفات الاحترافية.',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
