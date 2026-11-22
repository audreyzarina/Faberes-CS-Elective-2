import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/app_order.dart';
import '../../providers/cart_providers.dart';
import '../../providers/order_providers.dart';
import '../../widgets/async_value_view.dart';
import '../../widgets/order_card.dart';

/// The customer's own orders, newest first (RLS also guarantees "own only").
class OrderHistoryPage extends ConsumerWidget {
  const OrderHistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orders = ref.watch(myOrdersProvider);

    return AsyncValueView<List<AppOrder>>(
      value: orders,
      onRetry: () => ref.invalidate(myOrdersProvider),
      data: (list) => RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(myOrdersProvider);
          await ref.read(myOrdersProvider.future);
        },
        child: list.isEmpty
            ? ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  const SizedBox(height: 120),
                  EmptyView(
                    icon: Icons.receipt_long_outlined,
                    title: 'No orders yet',
                    subtitle: 'Your past orders will show up here.',
                    action: FilledButton(
                      onPressed: () => ref.read(customerTabProvider.notifier).select(0),
                      child: const Text('Start shopping'),
                    ),
                  ),
                ],
              )
            : ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: list.length,
                itemBuilder: (context, i) => OrderCard(order: list[i]),
              ),
      ),
    );
  }
}
