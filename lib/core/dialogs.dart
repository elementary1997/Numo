import 'package:flutter/material.dart';

/// Освобождает контроллер поля после того, как диалог доиграет анимацию
/// закрытия. `showDialog` отдаёт результат в момент `pop`, а виджеты
/// диалога живут ещё несколько кадров — контроллер, освобождённый сразу,
/// падает с «A TextEditingController was used after being disposed».
void disposeAfterDialog(ChangeNotifier controller) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    Future<void>.delayed(
        const Duration(milliseconds: 400), controller.dispose);
  });
}
