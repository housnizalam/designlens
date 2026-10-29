enum QuestionType {
  singleChoice,
  multiChoice,
  cornerPreview,
  shadowPreview,
  glassPreview,
  colorChoice,
  colorAvoid,
  colorStylePreview,
  gradientChoice,
  borderPreview,
  borderColorChoice,
  scale,
  shapePreview,
  uiStylePreview,
  typographyPreview,
  iconPreview,
  referenceInput,
}

class DesignQuestion {
  final String id;
  final String title;
  final String description;
  final QuestionType type;
  final List<String> options;
  final int maxSelections;

  const DesignQuestion({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.options,
    this.maxSelections = 1,
  });
}
