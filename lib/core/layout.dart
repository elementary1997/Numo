import 'package:flutter/widgets.dart';

/// Настоящая ширина окна в логических пикселях — независимо от
/// пользовательского масштаба интерфейса. При масштабе ≠ 1
/// MaterialApp.builder подменяет MediaQuery.size на уменьшенный,
/// из-за чего адаптивные брейкпоинты (сайдбар ↔ нижняя навигация)
/// ошибочно переключались в мобильную компоновку.
double windowWidthOf(BuildContext context) {
  // Подписка: при изменении размера окна виджет перестроится.
  MediaQuery.maybeSizeOf(context);
  final view = View.of(context);
  return view.physicalSize.width / view.devicePixelRatio;
}
