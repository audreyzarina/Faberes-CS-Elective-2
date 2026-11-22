import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/app_order.dart';
import 'auth_providers.dart';
import 'core_providers.dart';

/// The signed-in customer's own orders, newest first.
final myOrdersProvider = FutureProvider.autoDispose<List<AppOrder>>((ref) async {
  final uid = ref.watch(currentUserIdProvider);
  if (uid == null) return const <AppOrder>[];
  return ref.watch(orderServiceProvider).fetchMyOrders(uid);
});

/// Every order (admin only; RLS returns nothing useful for customers).
final allOrdersProvider = FutureProvider.autoDispose<List<AppOrder>>((ref) async {
  final uid = ref.watch(currentUserIdProvider);
  if (uid == null) return const <AppOrder>[];
  return ref.watch(orderServiceProvider).fetchAllOrders();
});

class AdminOrderController {
  AdminOrderController(this._ref);
  final Ref _ref;

  Future<void> updateStatus(int orderId, String status) async {
    await _ref.read(orderServiceProvider).updateStatus(orderId, status);
    _ref.invalidate(allOrdersProvider);
  }
}

final adminOrderControllerProvider =
    Provider<AdminOrderController>((ref) => AdminOrderController(ref));
