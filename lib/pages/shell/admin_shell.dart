import 'package:material_ui/material_ui.dart';

import '../../models/user_profile.dart';
import '../../widgets/account_menu.dart';
import '../categories/category_manage_page.dart';
import '../orders/admin_orders_page.dart';
import '../products/product_list_page.dart';

class AdminShell extends StatefulWidget {
  const AdminShell({super.key, required this.profile});

  final UserProfile profile;

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  int _index = 0;
  static const _titles = ['Products', 'Categories', 'Orders'];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_index]),
        actions: [
          Chip(
            label: const Text('Admin'),
            backgroundColor: scheme.tertiaryContainer,
            side: BorderSide.none,
            visualDensity: VisualDensity.compact,
          ),
          AccountMenu(profile: widget.profile),
          const SizedBox(width: 8),
        ],
      ),
      body: IndexedStack(
        index: _index,
        children: const [
          ProductListPage(isAdmin: true),
          CategoryManagePage(),
          AdminOrdersPage(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.inventory_2_outlined),
            selectedIcon: Icon(Icons.inventory_2),
            label: 'Products',
          ),
          NavigationDestination(
            icon: Icon(Icons.category_outlined),
            selectedIcon: Icon(Icons.category),
            label: 'Categories',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long),
            label: 'Orders',
          ),
        ],
      ),
    );
  }
}
