import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/errors/failures.dart';
import '../../data/models/order_model.dart';
import 'cart_provider.dart';
import 'core_providers.dart';

class CheckoutState {
  final bool isSubmitting;
  final String? generalError;
  final Map<String, String> fieldErrors;
  final OrderModel? createdOrder;

  const CheckoutState({
    this.isSubmitting = false,
    this.generalError,
    this.fieldErrors = const {},
    this.createdOrder,
  });

  String? getFieldError(String field) => fieldErrors[field];

  CheckoutState copyWith({
    bool? isSubmitting,
    String? generalError,
    bool clearGeneralError = false,
    Map<String, String>? fieldErrors,
    OrderModel? createdOrder,
  }) {
    return CheckoutState(
      isSubmitting: isSubmitting ?? this.isSubmitting,
      generalError: clearGeneralError ? null : (generalError ?? this.generalError),
      fieldErrors: fieldErrors ?? this.fieldErrors,
      createdOrder: createdOrder ?? this.createdOrder,
    );
  }
}

class CheckoutNotifier extends Notifier<CheckoutState> {
  @override
  CheckoutState build() {
    return const CheckoutState();
  }

  void clearErrors() {
    state = const CheckoutState();
  }

  Future<OrderModel?> submitOrder({
    required String customerName,
    required String customerPhone,
    required String shippingAddress,
    String? note,
  }) async {
    final cartState = ref.read(cartProvider);
    if (cartState.isEmpty) {
      state = state.copyWith(
        generalError: 'Сагс хоосон байна. Бүтээгдэхүүн сонгоно уу.',
      );
      return null;
    }

    state = const CheckoutState(isSubmitting: true);

    try {
      final orderRepo = ref.read(orderRepositoryProvider);
      final order = await orderRepo.createOrder(
        customerName: customerName,
        customerPhone: customerPhone,
        shippingAddress: shippingAddress,
        note: note,
        items: cartState.items,
      );

      // Clear cart on success
      await ref.read(cartProvider.notifier).clearCart();

      state = CheckoutState(
        isSubmitting: false,
        createdOrder: order,
      );
      return order;
    } on Failure catch (f) {
      final mappedFieldErrors = <String, String>{};
      if (f.fieldErrors != null) {
        f.fieldErrors!.forEach((key, list) {
          if (list.isNotEmpty) {
            mappedFieldErrors[key] = list.first;
          }
        });
      }

      state = CheckoutState(
        isSubmitting: false,
        generalError: mappedFieldErrors.isEmpty ? f.message : null,
        fieldErrors: mappedFieldErrors,
      );
      return null;
    } catch (e) {
      state = CheckoutState(
        isSubmitting: false,
        generalError: e.toString(),
      );
      return null;
    }
  }
}

final checkoutProvider =
    NotifierProvider<CheckoutNotifier, CheckoutState>(() {
  return CheckoutNotifier();
});
