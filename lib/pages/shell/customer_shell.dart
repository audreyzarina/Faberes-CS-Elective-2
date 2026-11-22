import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/config.dart';
import '../../models/user_profile.dart';
import '../../providers/cart_providers.dart';
import '../../widgets/account_menu.dart';
import '../cart/cart_page.dart';
import '../orders/order_history_page.dart';
import '../products/product_list_page.dart';

class CustomerShell extends ConsumerWidget {
  const CustomerShell({super.key, required this.profile});

  final UserProfile profile;

  static const _titles = [AppConfig.appName, 'Your cart', 'My orders'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final index = ref.watch(customerTabProvider);
    final cartCount = ref.watch(cartCountProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[index]),
        actions: [
          AccountMenu(profile: profile),
          const SizedBox(width: 8),
        ],
      ),
      body: IndexedStack(
        index: index,
        children: const [
          ProductListPage(isAdmin: false),
          CartPage(),
          OrderHistoryPage(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: ref.read(customerTabProvider.notifier).select,
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.storefront_outlined),
            selectedIcon: Icon(Icons.storefront),
            label: 'Shop',
          ),
          NavigationDestination(
            icon: Badge(
              label: Text('$cartCount'),
              isLabelVisible: cartCount > 0,
              child: const Icon(Icons.shopping_cart_outlined),
            ),
            selectedIcon: Badge(
              label: Text('$cartCount'),
              isLabelVisible: cartCount > 0,
              child: const Icon(Icons.shopping_cart),
            ),
            label: 'Cart',
          ),
          const NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long),
            label: 'Orders',
          ),
        ],
      ),
    );
  }
}
