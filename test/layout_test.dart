import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numo/core/layout.dart';
import 'package:numo/core/ui_scale.dart';

void main() {
  testWidgets(
      'UiScaler: контент раскладывается в уменьшенном размере, '
      'а не продавливается до окна', (tester) async {
    tester.view.physicalSize = const Size(2000, 1200);
    tester.view.devicePixelRatio = 2.0; // окно 1000×600 логических
    addTearDown(tester.view.reset);

    BoxConstraints? constraints;
    Size? mqSize;
    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) =>
            UiScaler(scale: 1.25, child: child ?? const SizedBox()),
        home: LayoutBuilder(
          builder: (context, c) {
            constraints = c;
            mqSize = MediaQuery.sizeOf(context);
            return const SizedBox();
          },
        ),
      ),
    );

    // 1000 ÷ 1.25 = 800: жёсткие оконные констрейнты не должны
    // продавить контент до 1000 — иначе после масштабирования
    // интерфейс обрезается справа и снизу.
    expect(constraints!.maxWidth, closeTo(800, 0.1));
    expect(constraints!.maxHeight, closeTo(480, 0.1));
    expect(mqSize!.width, closeTo(800, 0.1));
  });

  testWidgets(
      'windowWidthOf игнорирует уменьшенный масштабом MediaQuery.size',
      (tester) async {
    tester.view.physicalSize = const Size(2000, 1200);
    tester.view.devicePixelRatio = 2.0; // окно 1000×600 логических
    addTearDown(tester.view.reset);

    double? measured;
    await tester.pumpWidget(
      MaterialApp(
        // Имитация масштаба 1.3: builder подменяет size на уменьшенный —
        // так делает NumoApp при uiScale ≠ 1.
        builder: (context, child) {
          final mq = MediaQuery.of(context);
          return MediaQuery(
            data: mq.copyWith(
                size: Size(mq.size.width / 1.3, mq.size.height / 1.3)),
            child: child!,
          );
        },
        home: Builder(
          builder: (context) {
            measured = windowWidthOf(context);
            expect(MediaQuery.sizeOf(context).width, lessThan(840));
            return const SizedBox();
          },
        ),
      ),
    );

    // Реальная ширина окна — 1000, брейкпоint 840 остаётся «широким».
    expect(measured, 1000);
  });
}
