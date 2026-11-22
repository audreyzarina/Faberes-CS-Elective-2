import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/errors.dart';
import '../models/app_order.dart';
import '../models/cart_item.dart';
import '../models/user_profile.dart';

class OrderService {
  OrderService(this._client);

  final SupabaseClient _client;

  /// Checkout. Only product ids and quantities are sent: names, prices and
  /// stock checks happen inside the `place_order` database function, which
  /// saves the order, its items and the stock change in one transaction.
  Future<PlacedOrder> placeOrder(List<CartItem> items) async {
    final payload = items
        .map((i) => {'product_id': i.product.id, 'quantity': i.quantity})
        .toList();
    final res = await _client.rpc('place_order', params: {'p_items': payload});
    final map = Map<String, dynamic>.from(res as Map);
    return PlacedOrder(
      orderId: (map['order_id'] as num).toInt(),
      total: (map['total'] as num).toDouble(),
    );
  }

  Future<List<AppOrder>> fetchMyOrders(String userId) async {
    final rows = await _client
        .from('orders')
        .select('*, order_items(*)')
        .eq('user_id', userId)
        .order('created_at', ascending: false);
    return rows.map(AppOrder.fromMap).toList();
  }

  /// Admin only (RLS returns nothing for customers' other orders).
  Future<List<AppOrder>> fetchAllOrders() async {
    final rows = await _client
        .from('orders')
        .select('*, order_items(*)')
        .order('created_at', ascending: false);
    final orders = rows.map(AppOrder.fromMap).toList();
    final ids = orders.map((o) => o.userId).toSet().toList();
    if (ids.isEmpty) return orders;

    final profiles = await _client
        .from('profiles')
        .select('id, email, firstname, lastname')
        .inFilter('id', ids);
    final byId = {
      for (final p in profiles)
        p['id'] as String: UserProfile.fromMap(p, 'customer'),
    };
    return orders.map((o) {
      final p = byId[o.userId];
      return p == null ? o : o.withCustomer(name: p.fullName, email: p.email);
    }).toList();
  }

  Future<void> updateStatus(int orderId, String status) async {
    final rows = await _client
        .from('orders')
        .update({'status': status})
        .eq('id', orderId)
        .select();
    if (rows.isEmpty) {
      throw const AppException(
        'The order status was not changed. Only admins can update orders.',
        permissionDenied: true,
      );
    }
  }
}
