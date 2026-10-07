import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ecommerce_app/core/errors/failures.dart';
import 'package:ecommerce_app/core/widgets/error_view.dart';

void main() {
  group('ErrorView Widget Tests', () {
    testWidgets('renders network error with retry button', (tester) async {
      bool retried = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ErrorView(
              error: const NetworkFailure(),
              onRetry: () {
                retried = true;
              },
            ),
          ),
        ),
      );

      expect(find.text('Интернэт холболтгүй байна'), findsOneWidget);
      expect(find.byIcon(Icons.wifi_off_rounded), findsOneWidget);
      expect(find.text('Дахин оролдох'), findsOneWidget);

      await tester.tap(find.text('Дахин оролдох'));
      expect(retried, isTrue);
    });

    testWidgets('renders server error message', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ErrorView(
              error: const ServerFailure(message: 'Серверийн алдаа гарлаа'),
              onRetry: () {},
            ),
          ),
        ),
      );

      expect(find.text('Алдаа гарлаа'), findsOneWidget);
      expect(find.text('Серверийн алдаа гарлаа'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline_rounded), findsOneWidget);
    });
  });
}
