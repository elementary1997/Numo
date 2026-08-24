/// Правило автокатегоризации: подстрока в описании операции →
/// категория. Регистр не важен; побеждает первое совпавшее правило.
class CategoryRule {
  const CategoryRule({
    required this.id,
    required this.pattern,
    required this.categoryId,
  });

  final String id;
  final String pattern;
  final String categoryId;

  bool matches(String note) =>
      pattern.isNotEmpty &&
      note.toLowerCase().contains(pattern.toLowerCase());
}

/// Первая совпавшая категория или null.
String? categorizeByRules(String note, List<CategoryRule> rules) {
  for (final rule in rules) {
    if (rule.matches(note)) return rule.categoryId;
  }
  return null;
}
