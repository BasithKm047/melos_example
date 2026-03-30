import 'package:flutter_test/flutter_test.dart';

import '../lib/src/core/utils/app_validators.dart';

void main() {
  group('AppValidators', () {
    test('email validation accepts valid email', () {
      expect(AppValidators.email('john.doe@mail.com'), isNull);
    });

    test('email validation rejects invalid email', () {
      expect(AppValidators.email('john.com'), isNotNull);
    });

    test('password validation enforces uppercase and number', () {
      expect(AppValidators.password('passwordaa'), isNotNull);
      expect(AppValidators.password('Strong123'), isNull);
    });

    test('phone validation requires 10 to 15 digits', () {
      expect(AppValidators.phone('+9199887766'), isNull);
      expect(AppValidators.phone('12345'), isNotNull);
    });

    test('name validation rejects symbols', () {
      expect(AppValidators.name('John@1'), isNotNull);
      expect(AppValidators.name("John D'Souza"), isNull);
    });
  });
}
