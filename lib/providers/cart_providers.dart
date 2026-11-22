import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/app_order.dart';
import '../models/cart_item.dart';
import '../models/product.dart';
import 'auth_providers.dart';
import 'core_providers.dart';
import 'order_providers.dart';
import 'product_providers.dart';

/// The cart lives in app state: it survives screen changes, and because build()
/// watches the user id it is emptied on logout (and on login as someone else).
class CartNotifier extends Notifier<List<CartItem>> {
  @override
  List<CartItem> build() {
    ref.watch(currentUserIdProvider);
    return const <CartItem>[];
  }

  /// Each method returns an error message, or null on success.
  String? add(Product product) {
    if (product.stock <= 0) return '${product.name} is out of stock.';
    final index = state.indexWhere((i) => i.product.id == product.id);
    if (index == -1) {
      state = [...state, CartItem(product: product, quantity: 1)];
      return null;
    }
    final current = state[index];
    if (current.quantity + 1 > product.stock) {
      return 'Only ${product.stock} of ${product.name} in stock.';
    }
    final updated = [...state];
    updated[index] = CartItem(product: product, quantity: current.quantity + 1);
    state = updated;
    return null;
  }

  String? setQuantity(int productId, int quantity) {
    final index = state.indexWhere((i) => i.product.id == productId);
    if (index == -1) return null;
    if (quantity <= 0) {
      remove(productId);
      return null;
    }
    final item = state[index];
    if (quantity > item.product.stock) {
      return 'Only ${item.product.stock} of ${item.product.name} in stock.';
    }
    final updated = [...state];
    updated[index] = CartItem(product: item.product, quantity: quantity);
    state = updated;
    return null;
  }

  void remove(int productId) {
    state = state.where((i) => i.product.id != productId).toList();
  }

  void clear() => state = const <CartItem>[];
}

final cartProvider =
    NotifierProvider<CartNotifier, List<CartItem>>(CartNotifier.new);

final cartCountProvider = Provider<int>(
  (ref) => ref.watch(cartProvider).fold(0, (sum, i) => sum + i.quantity),
);

final cartTotalProvider = Provider<double>(
  (ref) => ref.watch(cartProvider).fold(0.0, (sum, i) => sum + i.lineTotal),
);

/// Places the order through the database function, then empties the cart.
class CheckoutController extends AsyncNotifier<PlacedOrder?> {
  @override
  Future<PlacedOrder?> build() async => null;

  Future<PlacedOrder?> checkout() async {
    final items = ref.read(cartProvider);
    if (items.isEmpty) return null;
    state = const AsyncLoading();
    try {
      final placed = await ref.read(orderServiceProvider).placeOrder(items);
      ref.read(cartProvider.notifier).clear();
      ref.invalidate(myOrdersProvider);
      ref.invalidate(productsProvider); // stock changed
      state = AsyncData(placed);
      return placed;
    } catch (e, st) {
      ref.invalidate(productsProvider); // refresh stock after a failed attempt
      state = AsyncError(e, st);
      rethrow;
    }
  }
}

final checkoutControllerProvider =
    AsyncNotifierProvider<CheckoutController, PlacedOrder?>(
  CheckoutController.new,
);

/// Selected tab of the customer shell (so other screens can switch tabs).
class CustomerTabNotifier extends Notifier<int> {
  @override
  int build() {
    ref.watch(currentUserIdProvider);
    return 0;
  }

  void select(int index) => state = index;
}

final customerTabProvider =
    NotifierProvider<CustomerTabNotifier, int>(CustomerTabNotifier.new);
