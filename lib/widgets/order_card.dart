import 'package:material_ui/material_ui.dart';

import '../core/formatters.dart';
import '../models/app_order.dart';

class OrderCard extends StatelessWidget {
  const OrderCard({
    super.key,
    required this.order,
    this.showCustomer = false,
    this.onStatusChanged,
  });

  final AppOrder order;
  final bool showCustomer;

  /// Provided only on the admin screen.
  final ValueChanged<String>? onStatusChanged;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final customer = order.customerName ?? order.customerEmail;

    final statuses = {...kOrderStatuses, order.status}.toList();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        shape: const Border(),
        collapsedShape: const Border(),
        title: Text('Order #${order.id}', style: text.titleMedium),
        subtitle: Text(
          [
            formatDate(order.createdAt),
            if (showCustomer && customer != null) customer,
            '${order.itemCount} ${order.itemCount == 1 ? 'item' : 'items'}',
          ].join('\n'),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              money(order.total),
              style: text.titleMedium?.copyWith(color: scheme.primary),
            ),
            const SizedBox(height: 4),
            StatusChip(status: order.status),
          ],
        ),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        children: [
          for (final item in order.items)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '${item.quantity} × ${item.productName}',
                      style: text.bodyMedium,
                    ),
                  ),
                  Text(
                    '${money(item.unitPrice)} each',
                    style: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                  ),
                  const SizedBox(width: 12),
                  Text(money(item.lineTotal), style: text.bodyMedium),
                ],
              ),
            ),
          const Divider(),
          Row(
            children: [
              Text('Total', style: text.titleSmall),
              const Spacer(),
              Text(money(order.total), style: text.titleSmall),
            ],
          ),
          if (onStatusChanged != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Text('Status', style: text.titleSmall),
                const Spacer(),
                DropdownButton<String>(
                  value: order.status,
                  items: [
                    for (final s in statuses)
                      DropdownMenuItem(value: s, child: Text(s)),
                  ],
                  onChanged: (v) {
                    if (v != null && v != order.status) onStatusChanged!(v);
                  },
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    Color bg;
    Color fg;
    switch (status) {
      case 'cancelled':
        bg = scheme.errorContainer;
        fg = scheme.onErrorContainer;
        break;
      case 'pending':
        bg = scheme.tertiaryContainer;
        fg = scheme.onTertiaryContainer;
        break;
      default:
        bg = scheme.primaryContainer;
        fg = scheme.onPrimaryContainer;
    }
    return DecoratedBox(
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        child: Text(
          status,
          style: Theme.of(context)
              .textTheme
              .labelSmall
              ?.copyWith(color: fg, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
