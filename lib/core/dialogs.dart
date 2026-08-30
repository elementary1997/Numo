import 'package:flutter/material.dart';

/// Держит контроллер поля ровно столько, сколько живёт сам диалог.
///
/// `showDialog` отдаёт результат в момент `pop`, а виджеты диалога
/// существуют ещё несколько кадров, пока доигрывает анимация закрытия.
/// Контроллер, освобождённый сразу после `await showDialog`, роняет
/// TextField с «A TextEditingController was used after being disposed»,
/// а отложенное освобождение по таймеру оставляет висящий таймер и
/// ломает тесты. Владеть контроллером должен сам диалог.
class DialogTextField extends StatefulWidget {
  const DialogTextField({
    super.key,
    required this.builder,
    this.initialText,
  });

  final String? initialText;

  /// Строит содержимое диалога с готовым контроллером.
  final Widget Function(BuildContext context, TextEditingController controller)
      builder;

  @override
  State<DialogTextField> createState() => _DialogTextFieldState();
}

class _DialogTextFieldState extends State<DialogTextField> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.initialText);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.builder(context, _controller);
}
