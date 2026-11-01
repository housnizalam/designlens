import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

/// Stored answer values:
///   none
///   asset:future | asset:nature | asset:space | asset:city
///   `file:<absolute or platform cache path>`
class BackgroundImageQuestionWidget extends StatefulWidget {
  final String? selectedValue;
  final ValueChanged<String> onSelected;

  const BackgroundImageQuestionWidget({
    super.key,
    required this.selectedValue,
    required this.onSelected,
  });

  @override
  State<BackgroundImageQuestionWidget> createState() =>
      _BackgroundImageQuestionWidgetState();
}

class _BackgroundImageQuestionWidgetState
    extends State<BackgroundImageQuestionWidget> {
  bool _showChoices = false;
  bool _picking = false;

  static const _samples = <({String id, String name, String asset})>[
    (id: 'future', name: 'تكنولوجيا ومستقبل', asset: 'assets/images/backgrounds/future.png'),
    (id: 'nature', name: 'طبيعة ومناظر خلابة', asset: 'assets/images/backgrounds/nature.png'),
    (id: 'space', name: 'فضاء وكواكب', asset: 'assets/images/backgrounds/space.png'),
    (id: 'city', name: 'مدينة عصرية فاخرة', asset: 'assets/images/backgrounds/city.png'),
  ];

  bool get _hasImage =>
      widget.selectedValue?.startsWith('asset:') == true ||
      widget.selectedValue?.startsWith('file:') == true;

  bool get _showGallery => _showChoices || _hasImage;

  Future<void> _pickCustomImage() async {
    if (_picking) return;
    setState(() => _picking = true);
    try {
      final file = await FilePicker.pickFile(
        type: FileType.custom,
        allowedExtensions: ['png', 'jpg', 'jpeg', 'webp'],
      );
      if (!mounted || file == null) return;
      final path = file.path;
      if (path == null || path.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تعذر الوصول إلى ملف الصورة المختارة.')),
        );
        return;
      }
      widget.onSelected('file:$path');
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تعذر فتح الصورة. حاول مرة أخرى.')),
      );
    } finally {
      if (mounted) setState(() => _picking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final selected = widget.selectedValue;
    final selectedCustom = selected?.startsWith('file:') == true;
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.only(bottom: 20),
      children: [
        RadioGroup<bool>(
          groupValue: selected == 'none'
              ? false
              : (_showGallery ? true : null),
          onChanged: (value) {
            if (value == false) {
              setState(() => _showChoices = false);
              widget.onSelected('none');
            } else if (value == true) {
              setState(() => _showChoices = true);
            }
          },
          child: Column(
            children: [
              Card(
                child: RadioListTile<bool>(
                  title: const Text('لا، أفضل خلفية بالألوان والتدرجات فقط'),
                  value: false,
                ),
              ),
              Card(
                child: RadioListTile<bool>(
                  title: const Text('نعم، أريد صورة كخلفية'),
                  value: true,
                ),
              ),
            ],
          ),
        ),
        if (_showGallery) ...[
          const SizedBox(height: 14),
          Text('اختر صورة واحدة، أو أضف صورتك الخاصة:',
              style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),
          LayoutBuilder(builder: (context, constraints) {
            final columns = constraints.maxWidth >= 650 ? 2 : 1;
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columns,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: columns == 2 ? 1.55 : 1.9,
              ),
              itemCount: _samples.length,
              itemBuilder: (context, index) {
                final item = _samples[index];
                final isSelected = selected == 'asset:${item.id}';
                return InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => widget.onSelected('asset:${item.id}'),
                  child: Container(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected ? theme.colorScheme.primary : theme.dividerColor,
                        width: isSelected ? 2.5 : 1,
                      ),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      children: [
                        Expanded(
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Image.asset(item.asset, fit: BoxFit.cover),
                              if (isSelected)
                                const Positioned(
                                  top: 8,
                                  right: 8,
                                  child: CircleAvatar(
                                    radius: 14,
                                    child: Icon(Icons.check, size: 17),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(9),
                          child: Text(item.name, textAlign: TextAlign.center),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _picking ? null : _pickCustomImage,
            icon: const Icon(Icons.add_photo_alternate_outlined),
            label: Text(_picking ? 'جاري اختيار الصورة...' : 'اختيار صورة من جهازي'),
          ),
          if (selectedCustom)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: theme.colorScheme.primary),
                  const SizedBox(width: 8),
                  const Expanded(child: Text('تم اختيار صورة خاصة من جهازك.')),
                ],
              ),
            ),
          const SizedBox(height: 8),
          Text(
            'ستظهر الصورة المختارة في معاينة تصميمك وفي صورة PDF. '
            'الصور المضافة من الجهاز تعتمد مؤقتًا على بقاء ملفها متاحًا.',
            style: theme.textTheme.bodySmall,
          ),
        ],
      ],
    );
  }
}
