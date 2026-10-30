import 'package:flutter/material.dart';

class ColorQuestionWidget extends StatelessWidget {
  final String? selectedValue;
  final ValueChanged<String> onSelected;

  const ColorQuestionWidget({
    super.key,
    required this.selectedValue,
    required this.onSelected,
  });

  static const List<Color> palette = [
    // الأزرق والسماوي
    Color(0xFF1E40AF), // أزرق ملكي
    Color(0xFF0E7490), // أزرق بترولي
    Color(0xFF0284C7), // أزرق سماوي
    Color(0xFF38BDF8), // سماوي فاتح
    // الأخضر
    Color(0xFF0F766E), // أخضر مزرق
    Color(0xFF15803D), // أخضر
    Color(0xFF84CC16), // أخضر ليموني
    // البنفسجي والوردي
    Color(0xFF9333EA), // بنفسجي
    Color(0xFF7C3AED), // بنفسجي داكن
    Color(0xFFDB2777), // وردي غامق
    Color(0xFFF9A8D4), // وردي فاتح
    // الأحمر والبرتقالي
    Color(0xFFDC2626), // أحمر
    Color(0xFFEA580C), // برتقالي
    Color(0xFFF97316), // برتقالي فاتح
    // الأصفر والذهبي
    Color(0xFFCA8A04), // ذهبي غامق
    Color(0xFFFACC15), // أصفر واضح
    Color(0xFFFDE68A), // أصفر فاتح
    // البني
    Color(0xFF92400E), // بني غامق
    Color(0xFFA16207), // بني ذهبي
    Color(0xFFD6A77A), // بني فاتح
    // الرمادي والمحايد
    Color(0xFF111827), // أسود مائل للرمادي
    Color(0xFF374151), // رمادي غامق
    Color(0xFF6B7280), // رمادي متوسط
    Color(0xFF9CA3AF), // رمادي فاتح
    Color(0xFFF8FAFC), // أبيض مائل للرمادي
  ];

  String toHex(Color color) {
    final rgb = color.toARGB32() & 0xFFFFFF;
    return '#${rgb.toRadixString(16).padLeft(6, '0').toUpperCase()}';
  }

  Future<void> openCustomPicker(BuildContext context) async {
    HSVColor hsv = HSVColor.fromColor(
      selectedValue != null && selectedValue!.startsWith('#')
          ? Color(
              int.parse(selectedValue!.substring(1), radix: 16) | 0xFF000000,
            )
          : const Color(0xFF2455A4),
    );

    final hexController = TextEditingController(text: toHex(hsv.toColor()));
    String? hexError;
    void updateFromSlider(HSVColor next, StateSetter setDialogState) {
      setDialogState(() {
        hsv = next;
        hexController.text = toHex(hsv.toColor());
        hexError = null;
      });
    }

    final result = await showDialog<Color>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('اختر لونك المفضل'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      height: 90,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: hsv.toColor(),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.black12),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      toHex(hsv.toColor()),
                      textDirection: TextDirection.ltr,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: hexController,
                      textDirection: TextDirection.ltr,
                      textCapitalization: TextCapitalization.characters,
                      maxLength: 7,
                      decoration: InputDecoration(
                        labelText: 'رمز اللون HEX',
                        hintText: '#38BDF8',
                        errorText: hexError,
                        border: const OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        final normalized = value.trim().replaceFirst(RegExp(r'^#'), '');
                        final valid = RegExp(r'^[0-9a-fA-F]{6}$').hasMatch(normalized);
                        setDialogState(() {
                          if (valid) {
                            hsv = HSVColor.fromColor(Color(
                              int.parse(normalized, radix: 16) | 0xFF000000,
                            ));
                            hexError = null;
                          } else {
                            hexError = 'اكتب 6 خانات HEX، مثل #38BDF8';
                          }
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    const Text('تغيير اللون'),
                    Slider(
                      min: 0,
                      max: 360,
                      value: hsv.hue,
                      onChanged: (value) {
                        updateFromSlider(hsv.withHue(value), setDialogState);
                      },
                    ),
                    const Text('قوة اللون'),
                    Slider(
                      min: 0,
                      max: 1,
                      value: hsv.saturation,
                      onChanged: (value) {
                        updateFromSlider(hsv.withSaturation(value), setDialogState);
                      },
                    ),
                    const Text('درجة الإضاءة'),
                    Slider(
                      min: 0,
                      max: 1,
                      value: hsv.value,
                      onChanged: (value) {
                        updateFromSlider(hsv.withValue(value), setDialogState);
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('إلغاء'),
                ),
                FilledButton(
                  onPressed: hexError == null
                      ? () => Navigator.pop(dialogContext, hsv.toColor())
                      : null,
                  child: const Text('اعتماد اللون'),
                ),
              ],
            );
          },
        );
      },
    );
    hexController.dispose();

    if (result != null) {
      onSelected(toHex(result));
    }
  }

  @override
  Widget build(BuildContext context) {
    final customSelected =
        selectedValue != null &&
        selectedValue!.startsWith('#') &&
        !palette.any((color) => toHex(color) == selectedValue);

    return ListView(
      children: [
        const Text(
          'اضغط على اللون الذي يعجبك:',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),

        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 120,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.05,
          ),
          itemCount: palette.length,
          itemBuilder: (context, index) {
            final color = palette[index];
            final hex = toHex(color);
            final selected = selectedValue == hex;

            return InkWell(
              onTap: () => onSelected(hex),
              borderRadius: BorderRadius.circular(14),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: selected
                        ? Theme.of(context).colorScheme.primary
                        : Colors.black12,
                    width: selected ? 3 : 1,
                  ),
                ),
                padding: const EdgeInsets.all(6),
                child: Column(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(9),
                          border: Border.all(color: Colors.black12),
                        ),
                        child: selected
                            ? const Center(
                                child: Icon(
                                  Icons.check_circle,
                                  color: Colors.white,
                                ),
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      hex,
                      textDirection: TextDirection.ltr,
                      style: const TextStyle(fontSize: 11),
                    ),
                  ],
                ),
              ),
            );
          },
        ),

        const SizedBox(height: 18),

        OutlinedButton.icon(
          onPressed: () => openCustomPicker(context),
          icon: const Icon(Icons.colorize),
          label: const Text('اختيار لون مخصص'),
        ),

        if (customSelected) ...[
          const SizedBox(height: 12),
          ListTile(
            leading: CircleAvatar(
              backgroundColor: Color(
                int.parse(selectedValue!.substring(1), radix: 16) | 0xFF000000,
              ),
            ),
            title: const Text('اللون المخصص الحالي'),
            subtitle: Text(selectedValue!),
            trailing: const Icon(Icons.check_circle),
          ),
        ],

        const SizedBox(height: 12),

        OutlinedButton.icon(
          onPressed: () => onSelected('designer_choice'),
          icon: Icon(
            selectedValue == 'designer_choice'
                ? Icons.check_circle
                : Icons.auto_awesome_outlined,
          ),
          label: const Text('لا أعرف، أترك الاختيار للمصمم'),
        ),
      ],
    );
  }
}
