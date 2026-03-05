import 'package:flutter_test/flutter_test.dart';
import 'package:core/core.dart';

void main() {
  test('exports shared theme and colors', () {
    expect(AppColors.blue, isNotNull);
    expect(AppTheme.light.useMaterial3, isTrue);
  });
}
