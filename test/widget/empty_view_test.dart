import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ecommerce_app/core/widgets/empty_view.dart';

void main() {
  group('EmptyView Widget Tests', () {
    testWidgets('renders title, subtitle, and action button', (tester) async {
      bool actionTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyView(
              title: 'Empty State Title',
              subtitle: 'This is a descriptive subtitle',
              actionButtonText: 'Action Button',
              onActionPressed: () {
                actionTapped = true;
              },
            ),
          ),
        ),
      );

      expect(find.text('Empty State Title'), findsOneWidget);
      expect(find.text('This is a descriptive subtitle'), findsOneWidget);
      expect(find.text('Action Button'), findsOneWidget);

      await tester.tap(find.text('Action Button'));
      expect(actionTapped, isTrue);
    });
  });
}
