import 'package:flutter_test/flutter_test.dart';
import 'package:ecommerce_app/core/utils/formatters.dart';

void main() {
  group('Formatters Tests', () {
    test('formatCurrency handles null and amounts', () {
      expect(Formatters.formatCurrency(null), '0₮');
      expect(Formatters.formatCurrency(0), '0₮');
      expect(Formatters.formatCurrency(29000), contains('29,000₮'));
      expect(Formatters.formatCurrency(1500000), contains('1,500,000₮'));
    });

    test('formatDate handles empty strings and valid ISO dates', () {
      expect(Formatters.formatDate(null), '');
      expect(Formatters.formatDate(''), '');
      expect(Formatters.formatDate('invalid-date'), 'invalid-date');
      final formatted = Formatters.formatDate('2026-10-08T02:53:00Z');
      expect(formatted, isNotEmpty);
      expect(formatted, contains('2026-10-08'));
    });
  });
}
