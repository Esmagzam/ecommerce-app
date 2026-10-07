import 'package:flutter_test/flutter_test.dart';
import 'package:ecommerce_app/core/utils/validator.dart';

void main() {
  group('Validator Tests', () {
    test('required validator validates empty and non-empty strings', () {
      expect(Validator.required(null), isNotNull);
      expect(Validator.required(''), isNotNull);
      expect(Validator.required('   '), isNotNull);
      expect(Validator.required('Hello'), isNull);
    });

    test('email validator validates email formats', () {
      expect(Validator.email(null), isNotNull);
      expect(Validator.email(''), isNotNull);
      expect(Validator.email('invalid-email'), isNotNull);
      expect(Validator.email('test@'), isNotNull);
      expect(Validator.email('test@example'), isNotNull);
      expect(Validator.email('test@example.com'), isNull);
    });

    test('password validator enforces minimum length', () {
      expect(Validator.password(null), isNotNull);
      expect(Validator.password('12345'), isNotNull);
      expect(Validator.password('123456'), isNull);
      expect(Validator.password('secure_password_123'), isNull);
    });

    test('confirmPassword matches passwords', () {
      expect(Validator.confirmPassword(null, 'password123'), isNotNull);
      expect(Validator.confirmPassword('different', 'password123'), isNotNull);
      expect(Validator.confirmPassword('password123', 'password123'), isNull);
    });

    test('phone validator validates 8-digit Mongolian phone numbers', () {
      expect(Validator.phone(null), isNotNull);
      expect(Validator.phone(''), isNotNull);
      expect(Validator.phone('9911'), isNotNull);
      expect(Validator.phone('991122334'), isNotNull);
      expect(Validator.phone('abc12345'), isNotNull);
      expect(Validator.phone('99112233'), isNull);
      expect(Validator.phone('8811 2233'), isNull); // with whitespace
    });
  });
}
