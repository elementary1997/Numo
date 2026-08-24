import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numo/core/layout.dart';

void main() {
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
