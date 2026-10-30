import '../models/design_question.dart';

const List<DesignQuestion> questions = [
  DesignQuestion(
    id: 'personality',
    title: 'كيف تريد أن يشعر الناس عند فتح تطبيقك؟',
    description: 'اختر حتى ثلاثة أوصاف تناسب فكرتك.',
    type: QuestionType.multiChoice,
    maxSelections: 3,
    options: [
      'جدي واحترافي',
      'فاخر وأنيق',
      'حديث ومتطور',
      'تقني وذكي',
      'بسيط ومريح',
      'ودود وقريب من الناس',
      'شبابي ونشيط',
      'مرح ومسلٍّ',
      'هادئ',
      'قوي وملفت للنظر',
      'رسمي',
      'مستقبلي',
      'طبيعي',
      'طفولي',
    ],
  ),
  DesignQuestion(
    id: 'audience',
    title: 'من سيستخدم هذا التطبيق غالبًا؟',
    description: 'اختر الفئة الأقرب لجمهور المشروع.',
    type: QuestionType.singleChoice,
    options: [
      'أطفال',
      'مراهقون',
      'شباب',
      'بالغون',
      'كبار السن',
      'موظفون وشركات',
      'جميع الفئات',
    ],
  ),
  DesignQuestion(
    id: 'corners',
    title: 'أي شكل للحواف يعجبك أكثر؟',
    description: 'لاحظ زوايا البطاقات الخمس. اختر الشكل الأقرب لذوقك.',
    type: QuestionType.cornerPreview,
    options: [
      'حواف حادة',
      'استدارة خفيفة',
      'استدارة متوسطة',
      'استدارة كبيرة',
      'استدارة كبيرة جدًا',
    ],
  ),
  DesignQuestion(
    id: 'shadows',
    title: 'كيف تفضل أن تظهر البطاقات؟',
    description: 'كل بطاقة تحتوي المحتوى نفسه. الاختلاف في الظل والارتفاع.',
    type: QuestionType.shadowPreview,
    options: ['مسطحة دون ظل', 'ظل خفيف وناعم', 'ظل واضح', 'تبدو مرتفعة كثيرًا'],
  ),
  DesignQuestion(
    id: 'glass',
    title: 'هل يعجبك أن تظهر الخلفية من خلال البطاقات؟',
    description: 'قارن بين البطاقات العادية والشفافة واختر ما يعجبك.',
    type: QuestionType.glassPreview,
    options: [
      'لا، بطاقات عادية',
      'شفافية خفيفة جدًا',
      'شفافية متوسطة',
      'تأثير زجاجي واضح',
      'تأثير زجاجي قوي',
    ],
  ),
  DesignQuestion(
    id: 'primary_color',
    title: 'ما اللون الأساسي الذي يعجبك لتطبيقك؟',
    description:
        'هذا اللون سيعطي التطبيق شخصيته الأساسية. '
        'يمكنك اختيار لون جاهز، أو تحديد لون بنفسك.',
    type: QuestionType.colorChoice,
    options: [],
  ),
  DesignQuestion(
    id: 'accent_color',
    title: 'ما اللون الإضافي الذي تريد استخدامه؟',
    description:
        'لون يستخدم بجانب اللون الأساسي، مثل الأزرار '
        'والعناصر التي نريد لفت الانتباه إليها.',
    type: QuestionType.colorChoice,
    options: [],
  ),

  DesignQuestion(
    id: 'avoided_colors',
    title: 'هل توجد ألوان لا تريد رؤيتها في تطبيقك؟',
    description:
        'اختر أي عدد من الألوان التي لا تحبها. '
        'يمكنك ترك السؤال دون اختيار.',
    type: QuestionType.colorAvoid,
    options: [],
  ),
  DesignQuestion(
    id: 'color_style',
    title: 'أي مجموعة ألوان تعجبك أكثر؟',
    description:
        'انظر إلى الأمثلة واختر الألوان الأقرب لذوقك. '
        'هذه مجرد أمثلة وليست ألوانًا إلزامية.',
    type: QuestionType.colorStylePreview,
    options: [
      'هادئة وغير صارخة',
      'قوية وزاهية',
      'ناعمة وفاتحة',
      'داكنة',
      'فاتحة ومشرقة',
      'درجات من لون واحد',
      'ألوان متدرجة وممزوجة',
      'أترك الاختيار للمصمم',
    ],
  ),
  DesignQuestion(
    id: 'theme',
    title: 'كيف تحب أن تكون خلفية التطبيق عادةً؟',
    description:
        'يمكن أن تكون الخلفية فاتحة أو داكنة، '
        'أو يمكن دعم الشكلين معًا.',
    type: QuestionType.singleChoice,
    options: [
      'فاتحة، مثل التطبيقات ذات الخلفية البيضاء',
      'داكنة، مثل التطبيقات ذات الخلفية السوداء',
      'أريد الوضعين مع إمكانية التبديل',
      'لا فرق لدي',
    ],
  ),

  DesignQuestion(
    id: 'gradient_mode',
    title: 'كيف تريد أن تبدو الخلفيات الملونة؟',
    description:
        'اختر شكل الخلفية وشاهد النتيجة مباشرة. '
        'لا يظهر التدرج إلا عندما تختاره.',
    type: QuestionType.gradientChoice,
    options: ['none', 'primary_accent', 'primary_custom'],
  ),
  DesignQuestion(
    id: 'borders',
    title: 'كيف تفضل أن تكون إطارات البطاقات؟',
    description:
        'شاهد الفرق بين البطاقات دون إطار '
        'والبطاقات ذات الإطار الخفيف أو الواضح.',
    type: QuestionType.borderPreview,
    options: ['دون إطار', 'إطار خفيف', 'إطار متوسط', 'إطار واضح'],
  ),

  DesignQuestion(
    id: 'border_color_mode',
    title: 'ما اللون الذي تفضله لإطارات البطاقات؟',
    description:
        'الإطار هو الخط المحيط بالبطاقة. '
        'اختر طريقة تلوينه وشاهد النتيجة مباشرة.',
    type: QuestionType.borderColorChoice,
    options: [
      'تلقائي ومتناسق مع التصميم',
      'نفس اللون الإضافي الذي اخترته',
      'أريد اختيار لون خاص للإطارات',
    ],
  ),

  DesignQuestion(
    id: 'formality',
    title: 'كيف تريد أن تكون شخصية التطبيق؟',
    description: 'هل تريده مرحًا وشبابيًا أم جديًا ورسميًا؟',
    type: QuestionType.scale,
    options: [
      'مرح جدًا',
      'مرح قليلًا',
      'متوازن',
      'جدي إلى حد ما',
      'رسمي وجدي جدًا',
    ],
  ),
  DesignQuestion(
    id: 'simplicity',
    title: 'ما مقدار التفاصيل الذي تحبه في التصميم؟',
    description:
        'هل تفضل تصميمًا بسيطًا جدًا أم تصميمًا '
        'يحتوي على تفاصيل وعناصر بصرية أكثر؟',
    type: QuestionType.scale,
    options: ['بسيط جدًا', 'بسيط', 'متوازن', 'غني بالتفاصيل', 'كثير التفاصيل'],
  ),
  DesignQuestion(
    id: 'visual_strength',
    title: 'إلى أي درجة تريد أن يلفت التصميم الأنظار؟',
    description:
        'هل تفضل مظهرًا هادئًا ومريحًا '
        'أم مظهرًا قويًا وملفتًا للنظر؟',
    type: QuestionType.scale,
    options: ['هادئ جدًا', 'هادئ', 'متوازن', 'قوي', 'قوي وملفت جدًا'],
  ),
  DesignQuestion(
    id: 'futurism',
    title: 'هل تفضل مظهرًا مألوفًا أم مبتكرًا ومستقبليًا؟',
    description:
        'التصميم المألوف يشبه التطبيقات التقليدية، '
        'أما المستقبلي فيستخدم أشكالًا وأساليب غير معتادة.',
    type: QuestionType.scale,
    options: [
      'تقليدي جدًا',
      'تقليدي قليلًا',
      'متوازن',
      'حديث ومبتكر',
      'مستقبلي جدًا',
    ],
  ),
  DesignQuestion(
    id: 'preferred_shapes',
    title: 'ما نوع الأشكال التي تحب رؤيتها في التطبيق؟',
    description:
        'اختر الشكل الأقرب لذوقك. '
        'سترى تأثيره مباشرة في المعاينة.',
    type: QuestionType.shapePreview,
    options: [
      'مستطيلات',
      'مستطيلات بحواف دائرية',
      'دوائر',
      'أشكال هندسية متنوعة',
      'أشكال ناعمة وغير منتظمة',
      'مزيج من عدة أشكال',
    ],
  ),

  // أسلوب التصميم العام
  DesignQuestion(
    id: 'ui_style',
    title: 'أي شكل من هذه التطبيقات يشبه ما تتخيله؟',
    description: 'قارن النماذج المرسومة، وليس أسماء الأساليب. يمكنك تخطي السؤال.',
    type: QuestionType.uiStylePreview,
    options: [
      'بسيط ومسطح',
      'بطاقات حديثة ومرتبة',
      'شفاف يشبه الزجاج',
      'ناعم وبارز قليلًا',
      'هادئ وقليل العناصر',
      'فاخر وأنيق',
      'رسمي مناسب للشركات',
      'تقني ومستقبلي',
      'مرح وملون',
      'جريء وغير تقليدي',
      'لا أعرف، أترك القرار للمصمم',
    ],
  ),
  DesignQuestion(
    id: 'depth',
    title: 'هل تحب أن تبدو العناصر على مستوى واحد أم بطبقات؟',
    description: 'اختر الدرجة الأقرب لذوقك. المستويات الأعلى تعني عمقًا بصريًا أكبر.',
    type: QuestionType.scale,
    options: [
      'كل شيء مسطح تقريبًا',
      'ارتفاع بسيط',
      'توازن بين المسطح والمرتفع',
      'طبقات واضحة',
      'طبقات وعمق قويان',
    ],
  ),
  // الكثافة والمسافات
  DesignQuestion(
    id: 'density',
    title: 'كم تريد أن تكون الشاشة مزدحمة بالمعلومات؟',
    description: 'فكر في مقدار ما يظهر لك من معلومات دون الحاجة إلى التمرير.',
    type: QuestionType.scale,
    options: [
      'معلومات كثيرة ومتقاربة',
      'معلومات كثيرة مع بعض المسافات',
      'متوازنة',
      'مساحات فارغة مريحة',
      'مساحات فارغة كبيرة جدًا',
    ],
  ),
  DesignQuestion(
    id: 'element_size',
    title: 'ما حجم الأزرار والحقول الذي يريحك؟',
    description: 'هل تحب العناصر الصغيرة أم الكبيرة السهلة اللمس؟',
    type: QuestionType.singleChoice,
    options: ['صغيرة وتوفر المساحة', 'متوسطة', 'كبيرة ومريحة', 'كبيرة جدًا'],
  ),
  DesignQuestion(
    id: 'information_presentation',
    title: 'كيف تحب أن تظهر التفاصيل داخل التطبيق؟',
    description: 'هل تريد رؤية أكبر قدر من المعلومات فورًا أم فتح التفاصيل عند الحاجة؟',
    type: QuestionType.singleChoice,
    options: [
      'كل المعلومات المهمة ظاهرة مباشرة',
      'مزيج متوازن',
      'الواجهة بسيطة والتفاصيل تظهر عند الضغط',
    ],
  ),
  // الخطوط
  DesignQuestion(
    id: 'font_personality',
    title: 'أي خط عربي تفضّل لتطبيقك؟',
    description: 'قارن بين خطوط عربية حقيقية. يمكنك أيضًا كتابة اسم خط آخر تفضّله.',
    type: QuestionType.typographyPreview,
    options: [
      'Cairo',
      'Tajawal',
      'IBM Plex Sans Arabic',
      'Amiri',
      'Reem Kufi',
      'Aref Ruqaa',
      'Changa',
      'Noto Naskh Arabic',
      'خط آخر من اختياري',
      'أترك اختيار الخط للمصمم',
    ],
  ),
  DesignQuestion(
    id: 'heading_style',
    title: 'كيف تحب أن تظهر عناوين الصفحات؟',
    description: 'اختر مدى بروز العنوان مقارنة بالنص العادي.',
    type: QuestionType.singleChoice,
    options: ['صغيرة وهادئة', 'واضحة ومتوسطة', 'كبيرة وبارزة'],
  ),
  DesignQuestion(
    id: 'content_emphasis',
    title: 'ما الذي تفضل أن تعتمد عليه الواجهة أكثر؟',
    description: 'اختر كيف تريد إيصال المعلومات إلى المستخدم.',
    type: QuestionType.singleChoice,
    options: ['الكلمات والنصوص', 'الرموز والأيقونات', 'الصور', 'مزيج متوازن'],
  ),
  DesignQuestion(
    id: 'visual_content',
    title: 'ما نوع الصور والرسومات الذي يعجبك في التطبيقات؟',
    description: 'مثل الصور الواقعية أو الرسوم التوضيحية أو الأشكال المجردة.',
    type: QuestionType.singleChoice,
    options: [
      'صور حقيقية', 'رسوم توضيحية', 'رسومات كرتونية',
      'مجسمات ثلاثية الأبعاد', 'أيقونات فقط',
      'أشكال زخرفية مجردة', 'مزيج من الأنواع',
    ],
  ),
  DesignQuestion(
    id: 'icon_style',
    title: 'أي شكل للأيقونات يعجبك أكثر؟',
    description: 'الأيقونة هي الرمز الصغير مثل المنزل أو البحث. اختر بصريًا.',
    type: QuestionType.iconPreview,
    options: [
      'بسيطة جدًا', 'خطوط رفيعة', 'ممتلئة',
      'ملونة', 'تبدو ثلاثية الأبعاد', 'أترك الاختيار للمصمم',
    ],
  ),
  // الحركة
  DesignQuestion(
    id: 'animation_amount',
    title: 'كم تحب أن تتحرك عناصر التطبيق؟',
    description: 'من واجهة ثابتة تقريبًا إلى حركات انتقال كثيرة.',
    type: QuestionType.scale,
    options: [
      'تقريبًا دون حركات', 'حركات قليلة', 'حركات متوازنة',
      'حركات واضحة', 'كثير من الحركات',
    ],
  ),
  DesignQuestion(
    id: 'interaction_feedback',
    title: 'ماذا يجب أن يحدث عندما تضغط زرًا؟',
    description: 'مثل تغير اللون أو الحركة أو ظهور تأكيد بعد الضغط.',
    type: QuestionType.singleChoice,
    options: [
      'تغيير بسيط جدًا', 'استجابة ناعمة وخفيفة',
      'تغيير واضح يدل على نجاح الضغط', 'استجابة مرحة وقوية',
    ],
  ),
  // مراجع بصرية اختيارية: لا تُطلب معرفة تقنية من العميل.
  DesignQuestion(
    id: 'liked_references',
    title: 'هل هناك تطبيقات أو مواقع تحب شكلها؟',
    description: 'اذكر حتى خمسة أمثلة، وقل لنا ما الذي أعجبك في شكلها. يمكنك تخطي السؤال.',
    type: QuestionType.referenceInput,
    options: [],
  ),
  DesignQuestion(
    id: 'disliked_references',
    title: 'هل هناك تطبيقات أو مواقع لا تحب شكلها؟',
    description: 'اذكر حتى خمسة أمثلة، ووضّح ما الذي تريد تجنبه في تصميمك. يمكنك التخطي.',
    type: QuestionType.referenceInput,
    options: [],
  ),
];
