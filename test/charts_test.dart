import 'dart:math' show pi;

import 'package:flutter_test/flutter_test.dart';
import 'package:numo/widgets/charts.dart';

/// Пончик: доли в один-два процента должны быть видны, а круг —
/// оставаться полным.
void main() {
  const fullCircle = 2 * pi;

  double sum(List<double> values) => values.fold(0.0, (a, b) => a + b);

  test('сектора всегда складываются в полный круг', () {
    for (final values in <List<double>>[
      [82, 10, 3, 2, 1],
      [50, 50],
      [1, 1, 1, 98],
      [100],
    ]) {
      expect(sum(donutSweeps(values)), closeTo(fullCircle, 0.0001),
          reason: 'для $values');
    }
  });

  test('однопроцентная доля получает заметную дугу', () {
    // 1 % — это 3,6°, почти невидимая царапина на пончике.
    final sweeps = donutSweeps(<double>[82, 10, 3, 2, 1]);
    expect(sweeps.last, greaterThanOrEqualTo(minDonutSweep));
    // И при этом крупный сектор остаётся крупным.
    expect(sweeps.first, greaterThan(fullCircle * 0.7));
  });

  test('крупные доли ужимаются, а не растут', () {
    final values = <double>[90, 1, 1, 1];
    final sweeps = donutSweeps(values);
    final proportional = values.first / sum(values) * fullCircle;
    expect(sweeps.first, lessThan(proportional));
  });

  test('пропорции между крупными секторами сохраняются', () {
    final sweeps = donutSweeps(<double>[60, 30, 1]);
    expect(sweeps[0] / sweeps[1], closeTo(2, 0.0001));
  });

  test('много мелких секторов делят круг поровну', () {
    final sweeps = donutSweeps(List.filled(80, 1.0));
    expect(sum(sweeps), closeTo(fullCircle, 0.0001));
    expect(sweeps.toSet(), hasLength(1));
  });

  test('пустые и отрицательные значения не ломают расчёт', () {
    expect(donutSweeps(const <double>[]), isEmpty);
    expect(donutSweeps(const <double>[0, 0]), isEmpty);
    expect(sum(donutSweeps(const <double>[-5, 10])),
        closeTo(fullCircle, 0.0001));
  });
}
