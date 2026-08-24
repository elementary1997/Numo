import 'package:flutter/widgets.dart';

/// Масштаб интерфейса: контент раскладывается в уменьшенном логическом
/// размере (окно ÷ масштаб) и растягивается на всё окно — растёт всё,
/// включая иконки и отступы.
///
/// Именно FittedBox, а не Transform.scale: корень приложения получает
/// жёсткие констрейнты размера окна, и SizedBox внутри Transform они
/// продавливали до полного размера — контент раскладывался как без
/// масштаба, а после трансформации обрезался справа и снизу. FittedBox
/// даёт ребёнку собственные констрейнты и сам вписывает его в окно.
class UiScaler extends StatelessWidget {
  const UiScaler({super.key, required this.scale, required this.child});

  final double scale;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (scale == 1.0) return child;
    final mq = MediaQuery.of(context);
    final scaledSize =
        Size(mq.size.width / scale, mq.size.height / scale);
    return MediaQuery(
      data: mq.copyWith(size: scaledSize),
      child: FittedBox(
        fit: BoxFit.fill,
        alignment: Alignment.topLeft,
        child: SizedBox(
          width: scaledSize.width,
          height: scaledSize.height,
          child: child,
        ),
      ),
    );
  }
}
