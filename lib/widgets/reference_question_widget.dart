import 'dart:convert';

import 'package:flutter/material.dart';

/// Each reference is stored as a JSON string in the existing answers map.
/// This keeps the V1 questionnaire storage model unchanged.
class ReferenceQuestionWidget extends StatefulWidget {
  final List<String> savedReferences;
  final ValueChanged<List<String>> onChanged;
  final bool isLiked;

  const ReferenceQuestionWidget({
    super.key,
    required this.savedReferences,
    required this.onChanged,
    required this.isLiked,
  });

  @override
  State<ReferenceQuestionWidget> createState() => _ReferenceQuestionWidgetState();
}

class _ReferenceQuestionWidgetState extends State<ReferenceQuestionWidget> {
  final List<TextEditingController> _names = [];
  final List<TextEditingController> _reasons = [];

  @override
  void initState() {
    super.initState();
    for (final encoded in widget.savedReferences.take(5)) {
      try {
        final decoded = jsonDecode(encoded);
        if (decoded is Map) {
          _addControllers(
            name: decoded['name']?.toString() ?? '',
            reason: decoded['reason']?.toString() ?? '',
          );
        }
      } on FormatException {
        // Ignore malformed legacy entries; never crash the questionnaire.
      }
    }
    if (_names.isEmpty) _addControllers();
  }

  void _addControllers({String name = '', String reason = ''}) {
    _names.add(TextEditingController(text: name));
    _reasons.add(TextEditingController(text: reason));
  }

  void _notify() {
    final entries = <String>[];
    for (var i = 0; i < _names.length; i++) {
      final name = _names[i].text.trim();
      final reason = _reasons[i].text.trim();
      if (name.isNotEmpty || reason.isNotEmpty) {
        entries.add(jsonEncode({'name': name, 'reason': reason}));
      }
    }
    widget.onChanged(entries);
  }

  void _addReference() {
    if (_names.length >= 5) return;
    setState(_addControllers);
  }

  void _removeReference(int index) {
    final name = _names.removeAt(index);
    final reason = _reasons.removeAt(index);
    setState(() {
      if (_names.isEmpty) _addControllers();
    });
    _notify();
    // Dispose after the frame: the removed TextFields may still unmount.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      name.dispose();
      reason.dispose();
    });
  }

  @override
  void dispose() {
    for (final controller in [..._names, ..._reasons]) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        for (var i = 0; i < _names.length; i++)
          Padding(
            key: ValueKey(_names[i]),
            padding: const EdgeInsets.only(bottom: 14),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'مثال ${i + 1}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        IconButton(
                          tooltip: 'حذف المثال',
                          onPressed: () => _removeReference(i),
                          icon: const Icon(Icons.delete_outline),
                        ),
                      ],
                    ),
                    TextField(
                      controller: _names[i],
                      onChanged: (_) => _notify(),
                      decoration: const InputDecoration(
                        labelText: 'اسم التطبيق أو الموقع',
                        hintText: 'مثل: Spotify',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _reasons[i],
                      onChanged: (_) => _notify(),
                      minLines: 2,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: widget.isLiked
                            ? 'ما الذي أعجبك فيه تحديدًا؟'
                            : 'ما الذي لم يعجبك فيه تحديدًا؟',
                        hintText: widget.isLiked
                            ? 'مثل: ألوانه الداكنة وطريقة عرض البطاقات'
                            : 'مثل: الألوان الصارخة أو ازدحام الشاشة',
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        OutlinedButton.icon(
          onPressed: _names.length < 5 ? _addReference : null,
          icon: const Icon(Icons.add),
          label: Text('إضافة مثال آخر (${_names.length}/5)'),
        ),
        const SizedBox(height: 8),
        const Text(
          'يمكنك كتابة صفر إلى خمسة أمثلة، أو تخطي السؤال بالكامل.',
          style: TextStyle(color: Colors.black54),
        ),
      ],
    );
  }
}
