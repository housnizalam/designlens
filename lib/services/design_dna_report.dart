import 'dart:convert';
import '../data/questions.dart';
import '../models/design_question.dart';
import '../models/design_color_tokens.dart';

/// Generates matching Arabic and English professional design briefs offline.
/// Does not make up client preferences for unanswered questions.
class DesignDnaReport {
  static const Map<String, String> _titlesEn = {
    'personality': 'Brand personality and emotional positioning',
    'audience': 'Target audience',
    'corners': 'Corner geometry',
    'shadows': 'Elevation and shadows',
    'glass': 'Translucency and backdrop treatment',
    'primary_color': 'Primary brand color',
    'accent_color': 'Accent / action color',
    'avoided_colors': 'Excluded colors',
    'color_style': 'Color palette character',
    'theme': 'Appearance mode',
    'gradient_mode': 'Gradient system',
    'borders': 'Surface stroke weight',
    'border_color_mode': 'Border color strategy',
    'formality': 'Brand formality',
    'simplicity': 'Visual complexity',
    'visual_strength': 'Visual emphasis',
    'futurism': 'Conventionality versus experimentation',
    'preferred_shapes': 'Shape language',
    'ui_style': 'Visual design direction',
    'depth': 'Layering and spatial depth',
    'density': 'Information density and whitespace',
    'element_size': 'Interactive component sizing',
    'information_presentation': 'Progressive disclosure strategy',
    'font_personality': 'Typographic personality',
    'heading_style': 'Heading hierarchy',
    'content_emphasis': 'Content communication hierarchy',
    'visual_content': 'Imagery and illustration direction',
    'icon_style': 'Iconographic system',
    'animation_amount': 'Motion intensity',
    'interaction_feedback': 'Interaction feedback',
    'liked_references': 'Positive design references',
    'disliked_references': 'Negative design references and anti-patterns',
  };

  /// Each item is indexed against the corresponding question option.
  /// These are domain terms, never machine translations of Arabic UI labels.
  static const Map<String, List<String>> _termsEn = {
    'personality': ['Professional and credible', 'Premium and refined', 'Contemporary', 'Technology-forward', 'Minimal and comfortable', 'Approachable and human-centered', 'Youthful and energetic', 'Playful and entertaining', 'Calm', 'Bold and attention-grabbing', 'Formal', 'Futuristic', 'Nature-inspired', 'Child-oriented'],
    'audience': ['Children', 'Adolescents', 'Young adults', 'Adults', 'Older adults', 'Enterprise users and employees', 'Cross-generational audience'],
    'corners': ['Sharp rectangular corners', 'Subtle corner rounding', 'Moderate corner rounding', 'Generously rounded corners', 'Highly rounded corners'],
    'shadows': ['Flat surfaces without elevation', 'Subtle soft elevation', 'Distinct surface elevation', 'Pronounced elevated surfaces'],
    'glass': ['Opaque surfaces', 'Very subtle translucency', 'Moderate translucency', 'Distinct glassmorphic treatment', 'Strong glassmorphic treatment'],
    'color_style': ['Muted and restrained palette', 'Vivid and saturated palette', 'Soft pastel palette', 'Dark-toned palette', 'Light and airy palette', 'Monochromatic palette', 'Gradient-oriented palette', 'Palette at designer discretion'],
    'theme': ['Light appearance', 'Dark appearance', 'Light and dark appearances with manual switching', 'No appearance preference'],
    'borders': ['Borderless components', 'Hairline strokes', 'Medium-weight strokes', 'Pronounced strokes'],
    'border_color_mode': ['Automatically harmonized stroke color', 'Accent-color strokes', 'Custom stroke color'],
    'formality': ['Very informal and playful', 'Somewhat informal', 'Balanced formality', 'Predominantly serious', 'Highly formal and restrained'],
    'simplicity': ['Ultra-minimal visual complexity', 'Minimal visual complexity', 'Balanced visual complexity', 'Detail-rich interface', 'Highly ornamented interface'],
    'visual_strength': ['Very restrained emphasis', 'Subtle emphasis', 'Balanced emphasis', 'Bold emphasis', 'High-impact visual expression'],
    'futurism': ['Conventional interface conventions', 'Mostly familiar conventions', 'Balanced familiar and experimental elements', 'Modern and experimental direction', 'Strongly futuristic aesthetic'],
    'preferred_shapes': ['Rectilinear geometric language', 'Rounded-rectangle geometry', 'Circular geometry', 'Mixed geometric primitives', 'Organic and freeform geometry', 'Hybrid shape language'],
    'ui_style': ['Flat Design', 'Material-inspired design system', 'Glassmorphism', 'Neumorphism / Soft UI', 'Minimalist UI', 'Luxury / premium visual design', 'Corporate / enterprise UI', 'Futuristic / sci-fi UI', 'Playful visual design', 'Neo-brutalism / brutalist UI', 'Visual direction at designer discretion'],
    'depth': ['Predominantly flat visual hierarchy', 'Subtle layering', 'Balanced flat and elevated composition', 'Clearly differentiated layers', 'High-depth layered composition'],
    'density': ['Compact, high-density layout', 'Relatively dense layout', 'Balanced density', 'Generous whitespace', 'Very spacious / airy layout'],
    'element_size': ['Compact controls', 'Medium-sized controls', 'Comfortably sized touch targets', 'Extra-large interactive controls'],
    'information_presentation': ['High information visibility', 'Balanced information disclosure', 'Progressive disclosure and reduced initial complexity'],
    'font_personality': ['Professional and legible typography', 'Contemporary editorial typography', 'Geometric / technical typography', 'Soft and approachable typography', 'Luxury editorial typography', 'Expressive / playful typography', 'Neutral minimalist typography'],
    'heading_style': ['Understated heading hierarchy', 'Moderately prominent headings', 'Strong display-style heading hierarchy'],
    'content_emphasis': ['Text-led information architecture', 'Icon-led communication', 'Image-led communication', 'Balanced multimodal communication'],
    'visual_content': ['Photography-led visuals', 'Illustrative graphics', 'Cartoon-style illustrations', 'Three-dimensional renders', 'Icon-only graphical language', 'Abstract decorative graphics', 'Mixed-media visual system'],
    'icon_style': ['Minimal icons', 'Thin-stroke outline icons', 'Solid / filled icons', 'Multicolor icons', 'Dimensional / 3D icons', 'Icon style at designer discretion'],
    'animation_amount': ['Near-static interface', 'Subtle motion', 'Balanced interaction motion', 'Prominent interface animation', 'High-motion expressive interface'],
    'interaction_feedback': ['Minimal state feedback', 'Soft micro-interactions', 'Explicit interactive feedback', 'Expressive and playful feedback'],
  };

  static const Map<String, String> _styleEn = {
    'بسيط ومسطح': 'Use Flat Design: clean solid-color surfaces, limited elevation, and direct visual hierarchy.',
    'بطاقات حديثة ومرتبة': 'Apply a Material-inspired component system with coherent surface elevation, clearly structured cards, and disciplined spacing.',
    'شفاف يشبه الزجاج': 'Apply Glassmorphism with translucent layers, backdrop blur, restrained edge highlights, and legible foreground contrast. Respect the separately specified translucency intensity.',
    'ناعم وبارز قليلًا': 'Use Neumorphism / Soft UI with restrained highlights, low-contrast surface elevation, and clearly accessible controls.',
    'هادئ وقليل العناصر': 'Adopt a minimalist visual system with a limited decorative vocabulary, clear hierarchy, and purposeful whitespace.',
    'فاخر وأنيق': 'Develop a premium visual identity with refined typography, deliberate composition, and restrained ornamental details.',
    'رسمي مناسب للشركات': 'Use a corporate / enterprise design language with consistent components, strong information hierarchy, and reliable interaction patterns.',
    'تقني ومستقبلي': 'Adopt a futuristic design language with precise geometric motifs and technology-oriented visual cues, without compromising usability.',
    'مرح وملون': 'Use a playful visual language with expressive shapes, energetic accents, and friendly interaction patterns.',
    'جريء وغير تقليدي': 'Apply a neo-brutalist direction using assertive composition, high-contrast component boundaries, and deliberately unconventional visual hierarchy.',
  };
  static const Map<String, String> _styleAr = {
    'بسيط ومسطح': 'اعتماد التصميم المسطح (Flat Design) بأسطح لونية صلبة وتسلسل بصري مباشر وارتفاعات محدودة للعناصر.',
    'بطاقات حديثة ومرتبة': 'اعتماد نظام تصميم مستلهم من Material Design، يرتكز على بطاقات منظمة ومستويات ارتفاع متسقة ومسافات مدروسة.',
    'شفاف يشبه الزجاج': 'اعتماد التصميم الزجاجي (Glassmorphism) بطبقات شبه شفافة وتمويه للخلفية (Backdrop Blur) وإبراز دقيق للحواف، مع مراعاة المقروئية ومستوى الشفافية المحدد في السؤال المستقل.',
    'ناعم وبارز قليلًا': 'اعتماد التصميم النيومورفي (Neumorphism / Soft UI) باستخدام إبرازات خفيفة وظلال منخفضة التباين مع الحفاظ على وضوح عناصر التفاعل.',
    'هادئ وقليل العناصر': 'اعتماد الحد الأدنى البصري (Minimalist UI) بتفاصيل زخرفية محدودة وهرمية واضحة ومساحات بيضاء وظيفية.',
    'فاخر وأنيق': 'بناء هوية بصرية فاخرة (Luxury UI) بطباعة راقية وتكوينات متوازنة وتفاصيل زخرفية منضبطة.',
    'رسمي مناسب للشركات': 'اعتماد لغة واجهات مؤسسية (Corporate / Enterprise UI) بمكوّنات متسقة وتسلسل معلوماتي واضح وأنماط تفاعل موثوقة.',
    'تقني ومستقبلي': 'اعتماد توجه مستقبلي (Futuristic UI) بإشارات تقنية وهندسة دقيقة دون التضحية بسهولة الاستخدام.',
    'مرح وملون': 'اعتماد لغة بصرية مرحة (Playful UI) بأشكال معبّرة ولمسات لونية حيوية وتفاعلات ودودة.',
    'جريء وغير تقليدي': 'اعتماد التوجه النيو-بروتالي (Neo-brutalism) بتراكيب جريئة وحدود بارزة وتسلسل بصري غير تقليدي.',
  };

  static String? _first(Map<String, List<String>> a, String k) => a[k]?.isNotEmpty == true ? a[k]!.first : null;
  static int _index(String id, String? selected) {
    if (selected == null) return -1;
    for (final q in questions) {
      if (q.id == id) return q.options.indexOf(selected);
    }
    return -1;
  }

  static String _fmt(num n) => n.toStringAsFixed(n.toDouble() == n.toDouble().roundToDouble() ? 0 : 2);

  static String _reference(String raw, bool arabic) {
    try {
      final data = jsonDecode(raw);
      if (data is Map) {
        final name = (data['name'] ?? '').toString().trim();
        final reason = (data['reason'] ?? '').toString().trim();
        if (name.isEmpty && reason.isEmpty) return '';
        return reason.isEmpty ? name : '$name — $reason';
      }
    } catch (_) { /* Safely preserve legacy free-text references. */ }
    return raw;
  }

  static String _englishTerm(DesignQuestion question, String answer) {
    if (question.id == 'preferred_shapes') {
      const shapes = {
        'مستطيلات': 'Rectilinear geometric language',
        'مستطيلات بحواف دائرية': 'Rounded-rectangle geometry',
        'دوائر': 'Circular geometry',
        'أشكال هندسية متنوعة': 'Mixed geometric primitives',
        'أشكال ناعمة وغير منتظمة': 'Organic and freeform geometry',
        'مزيج من عدة أشكال': 'Hybrid shape language',
      };
      return shapes[answer] ?? answer;
    }
    final index = question.options.indexOf(answer);
    final terms = _termsEn[question.id];
    if (index >= 0 && terms != null && index < terms.length) return terms[index];
    // A technical value or custom user note must not be fabricated or translated.
    return answer;
  }

  // Professional interpretations are keyed by stable question IDs and option order.
  // UI question wording never enters the exported document.
  static const Map<String, List<String>> _termsAr = {
    'personality': ['هوية موثوقة واحترافية', 'هوية راقية وفاخرة', 'هوية معاصرة', 'هوية تقنية متقدمة', 'تجربة بسيطة ومريحة', 'لغة بصرية ودودة تتمحور حول المستخدم', 'هوية شبابية حيوية', 'تجربة مرحة وتفاعلية', 'طابع بصري هادئ', 'حضور بصري جريء', 'هوية رسمية', 'هوية مستقبلية', 'لغة بصرية مستوحاة من الطبيعة', 'هوية مناسبة للأطفال'],
    'audience': ['الأطفال', 'المراهقون', 'الشباب', 'البالغون', 'كبار السن', 'مستخدمو بيئات العمل والمؤسسات', 'شرائح عمرية متنوعة'],
    'color_style': ['لوحة ألوان منخفضة التشبع وهادئة', 'لوحة حيوية عالية التشبع', 'لوحة ألوان باستيلية ناعمة', 'لوحة داكنة النغمات', 'لوحة فاتحة ومنفتحة', 'لوحة أحادية اللون', 'لوحة تميل إلى التدرجات اللونية', 'تُترك هوية اللوحة لتقدير المصمم'],
    'theme': ['وضع العرض الفاتح', 'وضع العرض الداكن', 'دعم الوضعين الفاتح والداكن مع إمكانية التبديل', 'تُترك آلية وضع العرض لتقدير المصمم'],
    'formality': ['طابع مرح وغير رسمي', 'طابع غير رسمي نسبيًا', 'توازن بين الرسمية والود', 'طابع جاد غالبًا', 'رسمية عالية وانضباط بصري'],
    'simplicity': ['حد أدنى شديد من التعقيد الزخرفي', 'تعقيد بصري منخفض', 'تعقيد بصري متوازن', 'تكوين غني بالتفاصيل', 'كثافة زخرفية مرتفعة'],
    'visual_strength': ['تأكيد بصري شديد التحفظ', 'تأكيد بصري خفيف', 'تأكيد بصري متوازن', 'تباين وتأكيد قويان', 'هوية بصرية عالية التأثير'],
    'futurism': ['أنماط واجهات تقليدية ومألوفة', 'أنماط تفاعل مألوفة مع تحديث محدود', 'توازن بين الأنماط المألوفة والتجريبية', 'توجه معاصر تجريبي', 'توجه مستقبلي واضح'],
    'preferred_shapes': ['هندسة مستطيلة', 'هندسة دائرية', 'مفردات هندسية متنوعة', 'هندسة عضوية حرة', 'نظام أشكال هجين'],
    'ui_style': ['Flat Design', 'Material-inspired UI', 'Glassmorphism', 'Neumorphism / Soft UI', 'Minimalist UI', 'Luxury UI', 'Corporate / Enterprise UI', 'Futuristic UI', 'Playful UI', 'Neo-brutalism', 'يُترك الأسلوب البصري لتقدير المصمم'],
    'depth': ['تسلسل بصري مسطح', 'طبقات بارتفاع محدود', 'تكوين متوازن بين الأسطح والطبقات', 'تدرج واضح للطبقات', 'عمق بصري مرتفع'],
    'density': ['تخطيط عالي الكثافة المعلوماتية', 'تخطيط مدمج نسبيًا', 'كثافة معلوماتية متوازنة', 'مساحات سلبية مريحة', 'تكوين واسع بمساحات سلبية كبيرة'],
    'element_size': ['عناصر تفاعل مدمجة', 'عناصر تفاعل متوسطة الحجم', 'عناصر تفاعل كبيرة ومريحة', 'عناصر تفاعل كبيرة جدًا'],
    'information_presentation': ['إظهار المعلومات الأساسية مباشرة', 'إفصاح معلوماتي متوازن', 'إظهار التفاصيل تدريجيًا عند الحاجة (Progressive Disclosure)'],
    'font_personality': ['طباعة احترافية واضحة', 'طباعة معاصرة وأنيقة', 'طباعة هندسية وتقنية', 'طباعة ناعمة وودودة', 'طباعة تحريرية فاخرة', 'طباعة تعبيرية مرحة', 'طباعة محايدة شديدة البساطة'],
    'heading_style': ['هرمية عناوين منخفضة التأكيد', 'هرمية عناوين متوسطة التأكيد', 'هرمية عناوين بارزة بأسلوب Display'],
    'content_emphasis': ['تواصل تقوده النصوص', 'تواصل تقوده الأيقونات', 'تواصل تقوده الصور', 'تواصل متعدد الوسائط ومتوازن'],
    'visual_content': ['صور فوتوغرافية', 'رسوم توضيحية (Illustrations)', 'رسوم كرتونية', 'نماذج مرئية ثلاثية الأبعاد (3D Renders)', 'لغة رسومية تعتمد الأيقونات', 'رسوم زخرفية تجريدية', 'نظام محتوى بصري مختلط'],
    'icon_style': ['أيقونات مبسطة', 'أيقونات خطية رفيعة (Thin-stroke Outline)', 'أيقونات ممتلئة (Filled)', 'أيقونات متعددة الألوان', 'أيقونات مجسّمة (3D)', 'يُترك نظام الأيقونات لتقدير المصمم'],
    'animation_amount': ['واجهة شبه ثابتة', 'حركة دقيقة ومحدودة', 'حركة تفاعلية متوازنة', 'حركة واجهة واضحة', 'واجهة عالية الحيوية الحركية'],
    'interaction_feedback': ['تغذية راجعة بصرية محدودة', 'تفاعلات دقيقة ناعمة (Micro-interactions)', 'حالات تفاعل واضحة وملحوظة', 'تغذية راجعة تعبيرية ومرحة'],
  };

  static const Map<String, List<String>> _sectionGroups = {
    '01': ['personality', 'audience', 'formality', 'simplicity', 'visual_strength', 'futurism', 'ui_style', 'color_style', 'theme'],
    '02': ['preferred_shapes', 'depth', 'density', 'element_size', 'information_presentation'],
    '03': ['font_personality', 'heading_style', 'content_emphasis'],
    '04': ['visual_content', 'icon_style'],
    '05': ['animation_amount', 'interaction_feedback'],
    '06': ['liked_references', 'disliked_references'],
  };
  static const Map<String, List<String>> _sectionNames = {
    '01': ['التوجه البصري والجمهور', 'Visual direction and audience'],
    '02': ['التكوين والهندسة وكثافة الواجهة', 'Composition, geometry and density'],
    '03': ['الطباعة والهرمية البصرية', 'Typography and information hierarchy'],
    '04': ['الرسوم والأيقونات', 'Imagery and iconography'],
    '05': ['الحركة والتفاعل', 'Motion and interaction'],
    '06': ['المراجع البصرية والمحاذير', 'Visual references and anti-patterns'],
  };

  static bool _delegated(String id, String value) =>
      (id == 'ui_style' && value.contains('أترك القرار')) ||
      (id == 'color_style' && value.contains('أترك الاختيار')) ||
      (id == 'icon_style' && value.contains('أترك الاختيار')) ||
      (id == 'theme' && value == 'لا فرق لدي');

  static String _interpret(String id, String value, bool ar) {
    final question = questions.firstWhere((q) => q.id == id);
    if (id == 'preferred_shapes' && !ar) {
      return 'Preferred component geometry: ${_englishTerm(question, value)}.';
    }
    final index = question.options.indexOf(value);
    final alternatives = ar ? _termsAr[id] : _termsEn[id];
    final term = index >= 0 && alternatives != null && index < alternatives.length
        ? alternatives[index] : (ar ? value : _englishTerm(question, value));
    final prefix = <String, List<String>>{
      'personality': ['تستهدف الهوية إيصال', 'The brand experience should convey'],
      'audience': ['الجمهور المستهدف:', 'Target user group:'],
      'formality': ['درجة الرسمية المطلوبة:', 'Target formality:'],
      'simplicity': ['مستوى التعقيد البصري:', 'Visual complexity target:'],
      'visual_strength': ['مستوى التأكيد البصري:', 'Visual emphasis:'],
      'futurism': ['مرجعية أنماط التفاعل:', 'Interaction convention:'],
      'color_style': ['طابع لوحة الألوان:', 'Palette character:'],
      'theme': ['نمط العرض:', 'Appearance mode:'],
      'preferred_shapes': ['هندسة العناصر المفضلة:', 'Preferred component geometry:'],
      'depth': ['عمق الواجهة:', 'Surface depth:'],
      'density': ['كثافة التخطيط:', 'Layout density:'],
      'element_size': ['قياس عناصر التفاعل:', 'Interactive control sizing:'],
      'information_presentation': ['نمط عرض البيانات:', 'Information disclosure strategy:'],
      'font_personality': ['شخصية النظام الطباعي:', 'Typographic personality:'],
      'heading_style': ['نظام العناوين:', 'Heading hierarchy:'],
      'content_emphasis': ['القناة البصرية المهيمنة:', 'Communication priority:'],
      'visual_content': ['اتجاه المحتوى المرئي:', 'Imagery direction:'],
      'icon_style': ['نظام الأيقونات:', 'Iconography:'],
      'animation_amount': ['شدة الحركة:', 'Motion intensity:'],
      'interaction_feedback': ['مستوى التغذية الراجعة:', 'Interactive feedback:'],
    };
    if (id == 'ui_style') {
      final directive = ar ? _styleAr[value] : _styleEn[value];
      if (directive != null) return directive;
      return ar ? 'يُترك تحديد المدرسة البصرية للمصمم.' : 'The visual design school is left to designer discretion.';
    }
    final lead = prefix[id];
    return lead == null ? term : '${lead[ar ? 0 : 1]} $term.';
  }

  static void _writeInterpretation(StringBuffer b, Map<String, List<String>> answers, bool ar) {
    b.writeln(ar ? '## 1. التوجيه التصميمي الاحترافي' : '## 1. Professional design directives');
    b.writeln();
    var emitted = false;
    for (final group in _sectionGroups.entries) {
      final lines = <String>[];
      for (final id in group.value) {
        final selected = answers[id]?.where((x) => x.trim().isNotEmpty).toList() ?? [];
        for (final value in selected) {
          if (_delegated(id, value)) continue;
          if (id == 'liked_references' || id == 'disliked_references') {
            final source = _reference(value, ar);
            if (source.isNotEmpty) lines.add(id == 'liked_references'
                ? (ar ? 'مرجع إيجابي للاستلهام (وليس للنسخ): $source' : 'Positive inspiration reference (not a replication mandate): $source')
                : (ar ? 'مرجع لتحديد الأنماط الواجب تجنبها: $source' : 'Negative reference / patterns to avoid: $source'));
          } else {
            lines.add(_interpret(id, value, ar));
          }
        }
      }
      if (lines.isEmpty) continue;
      emitted = true;
      b.writeln('### ${_sectionNames[group.key]![ar ? 0 : 1]}');
      b.writeln();
      for (final line in lines) { b.writeln('- $line'); }
      b.writeln();
    }
    if (!emitted) b.writeln(ar ? 'لا تتوفر تفضيلات وصفية صريحة.' : 'No explicit descriptive preferences were provided.');
  }

  /// A short editorial synthesis of selected preferences only; no new design decisions.
  static void _writeConcept(StringBuffer b, Map<String, List<String>> answers, bool ar) {
    String? term(String id) {
      final chosen = _first(answers, id);
      if (chosen == null || chosen.trim().isEmpty || _delegated(id, chosen)) return null;
      final q = questions.firstWhere((q) => q.id == id);
      final idx = q.options.indexOf(chosen);
      final options = ar ? _termsAr[id] : _termsEn[id];
      if (idx >= 0 && options != null && idx < options.length) return options[idx];
      return null;
    }

    final statements = <String>[];
    final personality = (answers['personality'] ?? [])
        .where((value) => value.trim().isNotEmpty)
        .map((value) {
          final q = questions.firstWhere((q) => q.id == 'personality');
          final idx = q.options.indexOf(value);
          final list = ar ? _termsAr['personality'] : _termsEn['personality'];
          return idx >= 0 && list != null && idx < list.length ? list[idx] : null;
        })
        .whereType<String>()
        .toList();
    final audience = term('audience');
    if (personality.isNotEmpty || audience != null) {
      final parts = <String>[];
      if (personality.isNotEmpty) parts.add(personality.join(ar ? '، ' : ', '));
      if (audience != null) parts.add(ar ? 'للجمهور المستهدف: $audience' : 'for the selected audience: $audience');
      statements.add(ar
          ? 'يرتكز التوجه العام على ${parts.join('، ')}.'
          : 'The overall direction targets ${parts.join(' ')}.');
    }
    final style = term('ui_style');
    final formality = term('formality');
    final complexity = term('simplicity');
    if (style != null || formality != null || complexity != null) {
      final parts = [style, formality, complexity].whereType<String>().toList();
      statements.add(ar
          ? 'يجمع التكوين البصري بين: ${parts.join('، ')}.'
          : 'The visual composition brings together ${parts.join(', ')}.');
    }
    final palette = term('color_style');
    final theme = term('theme');
    if (palette != null || theme != null) {
      final parts = [palette, theme].whereType<String>().toList();
      statements.add(ar
          ? 'وتتحدد الشخصية اللونية وفق: ${parts.join('، ')}.'
          : 'The color direction follows ${parts.join(', ')}.');
    }
    final density = term('density');
    final elements = term('element_size');
    final content = term('content_emphasis');
    if (density != null || elements != null || content != null) {
      final parts = [density, elements, content].whereType<String>().toList();
      statements.add(ar
          ? 'أما بنية الواجهة فتراعي: ${parts.join('، ')}.'
          : 'Interface composition reflects ${parts.join(', ')}.');
    }
    final motion = term('animation_amount');
    final feedback = term('interaction_feedback');
    if (motion != null || feedback != null) {
      final parts = [motion, feedback].whereType<String>().toList();
      statements.add(ar
          ? 'ويُعبَّر عن التفاعل من خلال: ${parts.join('، ')}.'
          : 'Interaction behavior is characterized by ${parts.join(', ')}.');
    }
    if (statements.isEmpty) return;
    b.writeln(ar ? '## المفهوم التصميمي — Design Concept' : '## Design Concept');
    b.writeln();
    b.writeln(statements.join(' '));
    b.writeln();
    b.writeln(ar
        ? '> هذا الوصف يجمع التفضيلات كما اختارها العميل؛ ولا يفترض اتساقها أو يغيّر أيًّا منها. تُناقَش التعارضات المحتملة بين العميل والمصمم.'
        : '> This concept records the client’s choices without presuming they are mutually compatible or altering them. Any tensions should be discussed by the client and designer.');
    b.writeln();
  }

  static void _writeGradientDetails(StringBuffer b, DesignColorTokens tokens, bool ar) {
    final positions = tokens.gradientStops;
    final first = tokens.selectedPrimary;
    final last = tokens.selectedGradientEnd;
    if (positions == null || first == null || last == null) return;
    final a = DesignColorTokens.hex(first);
    final z = DesignColorTokens.hex(last);
    b.writeln(ar
        ? '- توزيع الألوان حسب نقاط التوقف (الموضع → اللون):'
        : '- Color-stop mapping (position → color):');
    for (var i = 0; i < positions.length; i++) {
      final color = i < 2 ? a : z;
      b.writeln('  - `${_fmt(positions[i])}` → `$color`');
    }
    b.writeln(ar
        ? '- ينتقل اللون تدريجيًا بين نقطتي التوقف الوسطيتين فقط؛ قبل ذلك يبقى اللون الرئيسي ثابتًا، وبعده يبقى لون النهاية ثابتًا.'
        : '- Color interpolation occurs between the two middle stops only; the primary color stays constant before the transition and the end color stays constant after it.');
    switch (tokens.gradientDirection) {
      case 'radial':
        b.writeln(ar
            ? '- هندسة التدرج الشعاعي: المركز `Alignment.center`، ونصف القطر النسبي `0.85`، وتمتد المواضع من المركز نحو الخارج.'
            : '- Radial geometry: `Alignment.center`, relative `radius: 0.85`; stop positions proceed from the center outward.');
        break;
      case 'horizontal':
        b.writeln(ar
            ? '- اتجاه التدرج الخطي: من `Alignment.centerRight` إلى `Alignment.centerLeft` (من اليمين إلى اليسار).'
            : '- Linear direction: `Alignment.centerRight` → `Alignment.centerLeft` (right to left).');
        break;
      case 'vertical':
        b.writeln(ar
            ? '- اتجاه التدرج الخطي: من `Alignment.topCenter` إلى `Alignment.bottomCenter` (من الأعلى إلى الأسفل).'
            : '- Linear direction: `Alignment.topCenter` → `Alignment.bottomCenter` (top to bottom).');
        break;
      default:
        b.writeln(ar
            ? '- اتجاه التدرج الخطي المائل: من `Alignment.topRight` إلى `Alignment.bottomLeft` (من أعلى اليمين إلى أسفل اليسار).'
            : '- Diagonal linear direction: `Alignment.topRight` → `Alignment.bottomLeft` (top-right to bottom-left).');
    }
  }

  static void _writeConflicts(StringBuffer b, Map<String, List<String>> answers, bool ar) {
    final audience = _first(answers, 'audience');
    final size = _index('element_size', _first(answers, 'element_size'));
    final density = _index('density', _first(answers, 'density'));
    final style = _first(answers, 'ui_style');
    final glass = _index('glass', _first(answers, 'glass'));
    final shadows = _index('shadows', _first(answers, 'shadows'));
    final motion = _index('animation_amount', _first(answers, 'animation_amount'));
    final simp = _index('simplicity', _first(answers, 'simplicity'));
    final warnings = <String>[];
    if ((audience == 'أطفال' || audience == 'كبار السن') && (size == 0 || density == 0)) {
      warnings.add(ar
        ? 'توازن قابلية الاستخدام: الجمهور المختار مع عناصر صغيرة أو واجهة شديدة الكثافة. يُناقش أثر ذلك على سهولة الاستخدام مع العميل، دون تعديل خياراته تلقائيًا.'
        : 'Usability tension: the chosen audience combined with compact controls or high-density layout. Discuss usability implications with the client without automatically changing their choices.');
    }
    if (style == 'شفاف يشبه الزجاج' && glass == 0) {
      warnings.add(ar
        ? 'تعارض صريح: اختير Glassmorphism مع أسطح معتمة. يحتاج هذا التعارض إلى مراجعة بين العميل والمصمم، دون تغيير أي اختيار تلقائيًا.'
        : 'Explicit conflict: Glassmorphism is selected alongside fully opaque surfaces. Flag this for client–designer review; do not automatically modify either selected preference.');
    }
    if (style == 'بسيط ومسطح' && shadows > 1) {
      warnings.add(ar
        ? 'تعارض بين التوجه المسطح والظلال القوية: يجب مناقشة هذا التعارض مع العميل دون تعديل مستوى الظلال أو الأسلوب تلقائيًا.'
        : 'Flat Design conflicts with strong explicit shadows: discuss the discrepancy with the client without automatically changing either selection.');
    }
    if (simp == 0 && motion >= 3) {
      warnings.add(ar
        ? 'توتر بصري محتمل: بساطة شديدة مع حركة بارزة؛ يُراجع هذا التوتر مع العميل والمصمم دون استنتاج مستوى حركة بديل.'
        : 'Potential visual tension: ultra-minimal styling with prominent motion. Review the tension with the client; do not infer a replacement motion preference.');
    }
    if (warnings.isEmpty) return;
    b.writeln(ar ? '## ملاحظات الاتساق وقابلية الاستخدام' : '## Consistency and usability considerations');
    b.writeln();
    for (final w in warnings) { b.writeln('- $w'); }
    b.writeln();
  }

  static String generate(Map<String, List<String>> answers, {required bool arabic}) {
    final b = StringBuffer();
    final tokens = DesignColorTokens.fromAnswers(answers);
    final ar = arabic;
    b.writeln(ar ? '# مواصفات الهوية البصرية — Design DNA' : '# Design DNA — Professional UI/UX Specification');
    b.writeln();
    b.writeln(ar
        ? '> وثيقة مواصفات تستند إلى إجابات العميل. القيم المحسوبة مشتقة من معادلات المعاينة الحية، وليست قرارات إضافية من العميل.'
        : '> A specification based on the client’s selections. Computed values are derived from live-preview formulas, not additional client decisions.');
    b.writeln();
    _writeConcept(b, answers, ar);
    _writeInterpretation(b, answers, ar);
    _writeConflicts(b, answers, ar);

    b.writeln(ar ? '## 2. المواصفات اللونية الرقمية' : '## 2. Numeric color specification');
    b.writeln();
    void line(String arLabel, String enLabel, Object value) => b.writeln('- ${ar ? arLabel : enLabel}: `$value`');
    if (tokens.selectedPrimary != null) {
      line('اللون الرئيسي — Primary', 'Primary color', DesignColorTokens.hex(tokens.selectedPrimary!));
      line('قوة تأثير اللون على الخلفية', 'Background color influence', '${_fmt(tokens.backgroundStrengthPercent)}%');
      line('لون الخلفية المحسوب في وضع المعاينة', 'Preview-computed background color', DesignColorTokens.hex(tokens.background));
      line('الخلفية المحايدة المرجعية', 'Reference neutral background', DesignColorTokens.hex(tokens.neutralBackground));
      b.writeln(ar
          ? '- ملاحظة حسابية: المعاينة الحالية تستخدم عامل مزج `0.05 + 0.95 × (strength/100)`؛ لذلك لا يعني الاختيار `0%` اختفاء اللون تمامًا.'
          : '- Formula note: the current preview uses `0.05 + 0.95 × (strength/100)`; therefore `0%` still retains 5% of the primary color.');
    }
    if (tokens.selectedAccent != null) line('اللون الثانوي — Accent', 'Accent color', DesignColorTokens.hex(tokens.selectedAccent!));
    final avoided = answers['avoided_colors'] ?? [];
    if (avoided.isNotEmpty) line('الألوان المستبعدة', 'Excluded colors', avoided.join(', '));
    final theme = _first(answers, 'theme');
    if (theme != null) {
      line('وضع العرض المختار', 'Requested appearance', ar ? theme : _englishTerm(questions.firstWhere((q) => q.id == 'theme'), theme));
      if (theme.startsWith('أريد الوضعين')) b.writeln(ar
        ? '- تنبيه: وضع المعاينة الفاتح هو المعروض حاليًا؛ لم تُحسب لوحة داكنة مستقلة بعد. يجب إنشاء قيم الوضعين قبل اعتماد التسليم النهائي.'
        : '- Note: only the current light-mode preview palette is calculated. A distinct dark-mode palette must be resolved before final implementation.');
    }
    if (tokens.selectedPrimary != null) {
      line('خلفية البطاقات الرئيسية', 'Feature-card background', DesignColorTokens.hex(tokens.primary));
    }
    if (tokens.gradientMode == 'none') {
      line('التدرج اللوني', 'Gradient', ar ? 'معطّل باختيار العميل' : 'Explicitly disabled');
    } else if (tokens.gradientMode == 'primary_accent' || tokens.gradientMode == 'primary_custom') {
      if (tokens.gradient != null && tokens.selectedGradientEnd != null) {
        line('بداية التدرج', 'Gradient start color', DesignColorTokens.hex(tokens.selectedPrimary!));
        line('نهاية التدرج', 'Gradient end color', DesignColorTokens.hex(tokens.selectedGradientEnd!));
        line('نوع التدرج', 'Gradient type', tokens.gradientDirection == 'radial' ? 'Radial' : 'Linear');
        line('اتجاه التدرج', 'Gradient direction', tokens.gradientDirection);
        line('توزيع التدرج', 'Gradient balance', '${_fmt(tokens.gradientBalancePercent)}%');
        line('نقاط التوقف (0–1)', 'Gradient stops (0–1)', tokens.gradientStops!.map(_fmt).join(', '));
        _writeGradientDetails(b, tokens, ar);
      } else {
        b.writeln(ar ? '- التدرج مطلوب، لكن أحد لونيه لم يُحدَّد؛ لا يجوز اختراع لون بديل.' : '- A gradient is requested, but a required endpoint color is missing; do not invent a substitute.');
      }
    }
    b.writeln();
    b.writeln(ar ? '## 3. خصائص الأسطح والأبعاد' : '## 3. Surface geometry and numeric treatments');
    b.writeln();
    final corners = _index('corners', _first(answers, 'corners'));
    if (corners >= 0) line('نصف قطر زوايا البطاقات في المعاينة', 'Preview card corner radius', '${[0, 6, 14, 24, 36][corners]} logical px');
    final borders = _index('borders', _first(answers, 'borders'));
    if (borders >= 0) {
      line('سماكة الإطار', 'Component border width', '${_fmt([0.0, 0.8, 1.8, 3.5][borders])} logical px');
      if (borders > 0) line('لون الإطار الفعلي', 'Effective component border color', DesignColorTokens.hex(tokens.effectiveBorderColor));
    }
    final glass = _index('glass', _first(answers, 'glass'));
    if (glass >= 0) {
      line('عتامة سطح البطاقة', 'Card surface opacity', _fmt([1.0, 0.88, 0.65, 0.38, 0.18][glass]));
      line('شدة تمويه الخلفية', 'Backdrop blur sigma', _fmt([0.0, 2, 5, 9, 14][glass]));
      if (glass > 0) line('لون خلفية المنطقة الزجاجية', 'Glass backdrop color', DesignColorTokens.hex(tokens.glassBackdrop));
    }
    final shadow = _index('shadows', _first(answers, 'shadows'));
    if (shadow >= 0) {
      final blur = shadow == 0 ? 0 : 7 + shadow * 8;
      final offset = shadow == 0 ? 0 : 2 + shadow * 3;
      final spread = shadow * 0.4;
      line('مستوى الظل', 'Shadow level', shadow);
      line('نصف قطر تمويه الظل', 'Shadow blur radius', '$blur logical px');
      line('إزاحة الظل العمودية', 'Shadow vertical offset', '$offset logical px');
      line('انتشار الظل', 'Shadow spread', '${_fmt(spread)} logical px');
    }
    b.writeln();
    b.writeln(ar ? '## 4. قيود التنفيذ والتسليم' : '## 4. Delivery and implementation constraints');
    b.writeln();
    b.writeln(ar
        ? '- الخيارات المتروكة دون إجابة ليست قرارات تصميمية؛ تُترك لاجتهاد المصمم.\n- عند وجود اختيارات متعارضة، تُحفظ جميعها ويُوثَّق التعارض ليحسمه المصمم مع العميل؛ ولا تُغيَّر أي إجابة تلقائيًا.\n- لا يُعدّ المظهر التجريبي الافتراضي اختيارًا من العميل.\n- يجب اختبار التباين وسهولة القراءة وإمكانية الوصول، مع احترام هوية الألوان المختارة.'
        : '- Unanswered questions are not client decisions; leave them to designer discretion.\n- When selections conflict, preserve and document all of them for client–designer resolution; do not override any selection automatically.\n- Preview fallback defaults are not client selections.\n- Verify contrast, legibility, and accessibility while respecting the selected palette.');
    return b.toString().trimRight() + '\n';
  }
}
