import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ecommerce_app/data/repositories/cart_repository.dart';
import 'package:ecommerce_app/main.dart';
import 'package:ecommerce_app/presentation/providers/core_providers.dart';

class MockCartRepository extends Mock implements CartRepository {}

void main() {
  testWidgets('EcommerceApp smoke test loads MaterialApp', (WidgetTester tester) async {
    final mockCartRepo = MockCartRepository();
    when(() => mockCartRepo.getCartItems()).thenReturn([]);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          cartRepositoryProvider.overrideWithValue(mockCartRepo),
        ],
        child: const EcommerceApp(),
      ),
    );

    // Эхний фреймд splash дэлгэц дүрслэгдэнэ
    expect(find.byType(EcommerceApp), findsOneWidget);

    // Splash дэлгэцийн саатлын таймерыг дуусгана
    await tester.pump(const Duration(seconds: 1));
  });
}
