import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/errors.dart';
import '../../core/formatters.dart';
import '../../models/cart_item.dart';
import '../../providers/cart_providers.dart';
import '../../widgets/async_value_view.dart';
import '../../widgets/product_card.dart';
import '../../widgets/ui_helpers.dart';
import 'checkout_confirmation_page.dart';

class CartPage extends ConsumerWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(cartProvider);
    final count = ref.watch(cartCountProvider);
    final total = ref.watch(cartTotalProvider);
    final placing = ref.watch(checkoutControllerProvider).isLoading;

    if (items.isEmpty) {
      return EmptyView(
        icon: Icons.shopping_cart_outlined,
        title: 'Your cart is empty',
        subtitle: 'Browse the shop and add something you like.',
        action: FilledButton(
          onPressed: () => ref.read(customerTabProvider.notifier).select(0),
          child: const Text('Start shopping'),
        ),
      );
    }

    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Column(
      children: [
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, i) => _CartTile(item: items[i]),
          ),
        ),
        Material(
          color: scheme.surfaceContainer,
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Text('$count ${count == 1 ? 'item' : 'items'}', style: text.bodyLarge),
                      const Spacer(),
                      Text('Total', style: text.bodyLarge),
                      const SizedBox(width: 12),
                      Text(
                        money(total),
                        style: text.titleLarge?.copyWith(color: scheme.primary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: placing ? null : () => _checkout(context, ref),
                      icon: placing
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.lock_outline),
                      label: Text(placing ? 'Placing order…' : 'Checkout'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _checkout(BuildContext context, WidgetRef ref) async {
    try {
      final placed = await ref.read(checkoutControllerProvider.notifier).checkout();
      if (placed == null || !context.mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => CheckoutConfirmationPage(order: placed)),
      );
    } catch (e) {
      if (context.mounted) showMessage(context, friendlyError(e), error: true);
    }
  }
}

class _CartTile extends ConsumerWidget {
  const _CartTile({required this.item});

  final CartItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(cartProvider.notifier);
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final p = item.product;
    final atMax = item.quantity >= p.stock;

    void setQty(int qty) {
      final error = notifier.setQuantity(p.id, qty);
      if (error != null) showMessage(context, error, error: true);
    }

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            SizedBox(
              width: 68,
              height: 68,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: ProductImage(url: p.imageUrl),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(p.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: text.titleMedium),
                  Text(
                    '${money(p.price)} each',
                    style: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      IconButton.outlined(
                        visualDensity: VisualDensity.compact,
                        tooltip: 'Decrease',
                        onPressed: () => setQty(item.quantity - 1),
                        icon: const Icon(Icons.remove, size: 18),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text('${item.quantity}', style: text.titleMedium),
                      ),
                      IconButton.outlined(
                        visualDensity: VisualDensity.compact,
                        tooltip: atMax ? 'No more stock' : 'Increase',
                        onPressed: atMax ? null : () => setQty(item.quantity + 1),
                        icon: const Icon(Icons.add, size: 18),
                      ),
                      if (atMax)
                        Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: Text('Max', style: text.labelSmall?.copyWith(color: scheme.error)),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                IconButton(
                  tooltip: 'Remove',
                  onPressed: () => notifier.remove(p.id),
                  icon: Icon(Icons.delete_outline, color: scheme.error),
                ),
                Text(money(item.lineTotal), style: text.titleSmall),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
