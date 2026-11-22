import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/errors.dart';
import '../../models/app_order.dart';
import '../../providers/order_providers.dart';
import '../../widgets/async_value_view.dart';
import '../../widgets/order_card.dart';
import '../../widgets/ui_helpers.dart';

/// Admin: every customer's orders, with the ability to change the status.
class AdminOrdersPage extends ConsumerWidget {
  const AdminOrdersPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orders = ref.watch(allOrdersProvider);

    return AsyncValueView<List<AppOrder>>(
      value: orders,
      onRetry: () => ref.invalidate(allOrdersProvider),
      data: (list) => RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(allOrdersProvider);
          await ref.read(allOrdersProvider.future);
        },
        child: list.isEmpty
            ? ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 120),
                  EmptyView(
                    icon: Icons.receipt_long_outlined,
                    title: 'No orders yet',
                    subtitle: 'Customer orders will appear here.',
                  ),
                ],
              )
            : ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: list.length,
                itemBuilder: (context, i) {
                  final order = list[i];
                  return OrderCard(
                    order: order,
                    showCustomer: true,
                    onStatusChanged: (status) async {
                      try {
                        await ref
                            .read(adminOrderControllerProvider)
                            .updateStatus(order.id, status);
                        if (context.mounted) {
                          showMessage(context, 'Order #${order.id} marked as $status.');
                        }
                      } catch (e) {
                        if (context.mounted) {
                          showMessage(context, friendlyError(e), error: true);
                        }
                      }
                    },
                  );
                },
              ),
      ),
    );
  }
}
