import 'package:flutter/material.dart';

/// Uses the selected font family names exactly as registered in pubspec.yaml.
class ArabicFontQuestionWidget extends StatefulWidget {
  final String? selectedValue;
  final ValueChanged<String> onSelected;
  const ArabicFontQuestionWidget({super.key, this.selectedValue, required this.onSelected});

  @override
  State<ArabicFontQuestionWidget> createState() => _ArabicFontQuestionWidgetState();
}

class _ArabicFontQuestionWidgetState extends State<ArabicFontQuestionWidget> {
  static const customPrefix = 'custom_font:';
  static const families = [
    ('Cairo', 'عصري وواضح'),
    ('Tajawal', 'أنيق وخفيف'),
    ('IBM Plex Sans Arabic', 'رسمي واحترافي'),
    ('Amiri', 'كلاسيكي وأصيل'),
    ('Reem Kufi', 'كوفي هندسي'),
    ('Aref Ruqaa', 'رقعة تقليدي'),
    ('Changa', 'قوي وملفت'),
    ('Noto Naskh Arabic', 'نسخي مريح للقراءة'),
  ];
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _editingCustom = false;

  @override
  void initState() {
    super.initState();
    _syncCustom();
  }

  @override
  void didUpdateWidget(covariant ArabicFontQuestionWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedValue != oldWidget.selectedValue && !_focusNode.hasFocus) {
      _syncCustom();
    }
  }

  void _syncCustom() {
    final value = widget.selectedValue ?? '';
    _editingCustom = value.startsWith(customPrefix) ||
        (value.isNotEmpty && value != 'أترك اختيار الخط للمصمم' && !families.any((f) => f.$1 == value));
    if (_editingCustom) {
      final text = value.startsWith(customPrefix) ? value.substring(customPrefix.length) : value;
      _controller.value = TextEditingValue(text: text, selection: TextSelection.collapsed(offset: text.length));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selected = widget.selectedValue;
    return ListView(
      padding: const EdgeInsets.only(bottom: 12),
      children: [
        for (final family in families)
          Card(
            color: selected == family.$1 ? Theme.of(context).colorScheme.primaryContainer : null,
            margin: const EdgeInsets.only(bottom: 10),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () { setState(() => _editingCustom = false); widget.onSelected(family.$1); },
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                  Row(children: [
                    Icon(selected == family.$1 ? Icons.check_circle : Icons.radio_button_unchecked),
                    const SizedBox(width: 8),
                    Expanded(child: Text('${family.$1} — ${family.$2}', style: const TextStyle(fontWeight: FontWeight.w600))),
                  ]),
                  const SizedBox(height: 12),
                  Text('مرحبًا بك في تطبيقي', textAlign: TextAlign.center,
                    style: TextStyle(fontFamily: family.$1, fontSize: 28)),
                  Text('اكتشف تجربة جميلة وسهلة الاستخدام', textAlign: TextAlign.center,
                    style: TextStyle(fontFamily: family.$1, fontSize: 17)),
                ]),
              ),
            ),
          ),
        Card(child: Padding(padding: const EdgeInsets.all(14), child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            InkWell(
              onTap: () => setState(() => _editingCustom = true),
              child: Row(children: [
                Icon(_editingCustom || (selected?.startsWith(customPrefix) ?? false)
                    ? Icons.check_circle : Icons.radio_button_unchecked),
                const SizedBox(width: 8),
                const Expanded(child: Text('خط آخر من اختياري', style: TextStyle(fontWeight: FontWeight.w600))),
              ]),
            ),
            if (_editingCustom) ...[
              const SizedBox(height: 12),
              TextField(
                controller: _controller, focusNode: _focusNode,
                decoration: const InputDecoration(labelText: 'اسم الخط الذي تريده',
                  hintText: 'مثال: Dubai Font', border: OutlineInputBorder()),
                onChanged: (value) {
                  if (value.trim().isNotEmpty) widget.onSelected('$customPrefix${value.trim()}');
                },
              ),
              const SizedBox(height: 6),
              const Text('سيظهر اسم الخط في التقرير؛ لن تُعرض معاينة لخط غير مثبت.',
                style: TextStyle(fontSize: 12)),
            ],
          ],
        ))),
        Card(child: ListTile(
          title: const Text('أترك اختيار الخط للمصمم'),
          leading: Icon(selected == 'أترك اختيار الخط للمصمم'
              ? Icons.check_circle : Icons.radio_button_unchecked),
          onTap: () { setState(() => _editingCustom = false); widget.onSelected('أترك اختيار الخط للمصمم'); },
        )),
      ],
    );
  }
}
