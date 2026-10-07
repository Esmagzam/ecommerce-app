import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/errors/failures.dart';
import '../../data/models/order_model.dart';
import 'core_providers.dart';

class OrdersState {
  final List<OrderModel> orders;
  final int currentPage;
  final bool hasMore;
  final bool isLoading;
  final bool isLoadingMore;
  final Failure? error;

  const OrdersState({
    this.orders = const [],
    this.currentPage = 1,
    this.hasMore = true,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
  });

  OrdersState copyWith({
    List<OrderModel>? orders,
    int? currentPage,
    bool? hasMore,
    bool? isLoading,
    bool? isLoadingMore,
    Failure? error,
    bool clearError = false,
  }) {
    return OrdersState(
      orders: orders ?? this.orders,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class OrdersNotifier extends Notifier<OrdersState> {
  @override
  OrdersState build() {
    state = const OrdersState(isLoading: true);
    loadInitial();
    return state;
  }

  Future<void> loadInitial() async {
    state = state.copyWith(isLoading: true, clearError: true);
    final orderRepo = ref.read(orderRepositoryProvider);

    try {
      final pagination = await orderRepo.getOrders(page: 1);
      state = state.copyWith(
        orders: pagination.data,
        currentPage: 1,
        hasMore: pagination.hasMore,
        isLoading: false,
        clearError: true,
      );
    } on Failure catch (f) {
      state = state.copyWith(isLoading: false, error: f);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: ServerFailure(message: e.toString()),
      );
    }
  }

  Future<void> loadMore() async {
    if (state.isLoading || state.isLoadingMore || !state.hasMore) return;

    state = state.copyWith(isLoadingMore: true);
    final nextPage = state.currentPage + 1;
    final orderRepo = ref.read(orderRepositoryProvider);

    try {
      final pagination = await orderRepo.getOrders(page: nextPage);
      state = state.copyWith(
        orders: [...state.orders, ...pagination.data],
        currentPage: nextPage,
        hasMore: pagination.hasMore,
        isLoadingMore: false,
      );
    } catch (_) {
      state = state.copyWith(isLoadingMore: false);
    }
  }

  Future<bool> cancelOrder(int orderId) async {
    final orderRepo = ref.read(orderRepositoryProvider);
    try {
      final updatedOrder = await orderRepo.cancelOrder(orderId);
      final updatedList = state.orders.map((o) {
        if (o.id == orderId) return updatedOrder;
        return o;
      }).toList();
      state = state.copyWith(orders: updatedList);
      ref.invalidate(orderDetailProvider(orderId));
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> refresh() async {
    await loadInitial();
  }
}

final ordersProvider = NotifierProvider<OrdersNotifier, OrdersState>(() {
  return OrdersNotifier();
});

final orderDetailProvider =
    FutureProvider.family<OrderModel, int>((ref, orderId) async {
  final orderRepo = ref.watch(orderRepositoryProvider);
  return await orderRepo.getOrderDetail(orderId);
});
