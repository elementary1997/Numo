import 'dart:ui' show Color;

/// Брендовые пресеты для счетов: буквенный бейдж в фирменном цвете.
/// Сознательно без чужих растровых логотипов — аккуратные монограммы
/// в узнаваемых цветах банков и сервисов.
class Brand {
  const Brand(this.key, this.title, this.label, this.background,
      [this.foreground = const Color(0xFFFFFFFF)]);

  final String key;
  final String title;

  /// Короткая монограмма на бейдже (1–3 символа).
  final String label;
  final Color background;
  final Color foreground;
}

const brands = <Brand>[
  Brand('sber', 'Сбер', 'С', Color(0xFF21A038)),
  Brand('tbank', 'Т-Банк', 'Т', Color(0xFFFFDD2D), Color(0xFF1F1F1F)),
  Brand('alfa', 'Альфа-Банк', 'А', Color(0xFFEF3124)),
  Brand('vtb', 'ВТБ', 'ВТБ', Color(0xFF0A2896)),
  Brand('gazprom', 'Газпромбанк', 'ГПБ', Color(0xFF0079C2)),
  Brand('raif', 'Райффайзен', 'R', Color(0xFFFFE600), Color(0xFF1F1F1F)),
  Brand('ozon', 'Озон Банк', 'О', Color(0xFF005BFF)),
  Brand('yandex', 'Яндекс', 'Я', Color(0xFFFC3F1D)),
  Brand('wb', 'Вайлдберриз', 'WB', Color(0xFFCB11AB)),
  Brand('mts', 'МТС Банк', 'МТС', Color(0xFFE30611)),
  Brand('sovcom', 'Совкомбанк', 'СКБ', Color(0xFF00348D)),
  Brand('usdt', 'Крипто', '₮', Color(0xFF26A17B)),
];

/// Бренд по ключу иконки вида `brand:<key>`; null для обычных иконок.
Brand? brandFromIconKey(String iconKey) {
  if (!iconKey.startsWith('brand:')) return null;
  final key = iconKey.substring(6);
  for (final brand in brands) {
    if (brand.key == key) return brand;
  }
  return null;
}
