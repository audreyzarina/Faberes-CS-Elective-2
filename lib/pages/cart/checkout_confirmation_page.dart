import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/formatters.dart';
import '../../models/app_order.dart';
import '../../providers/cart_providers.dart';

class CheckoutConfirmationPage extends ConsumerWidget {
  const CheckoutConfirmationPage({super.key, required this.order});

  final PlacedOrder order;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    void goTo(int tab) {
      ref.read(customerTabProvider.notifier).select(tab);
      Navigator.of(context).pop();
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) goTo(0);
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Order confirmed'),
          automaticallyImplyLeading: false,
        ),
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Icon(Icons.check_circle, size: 88, color: scheme.primary),
                    const SizedBox(height: 16),
                    Text('Thank you!', textAlign: TextAlign.center, style: text.headlineMedium),
                    const SizedBox(height: 8),
                    Text(
                      'Your order has been placed.',
                      textAlign: TextAlign.center,
                      style: text.bodyLarge?.copyWith(color: scheme.onSurfaceVariant),
                    ),
                    const SizedBox(height: 24),
                    Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                const Text('Order number'),
                                const Spacer(),
                                Text('#${order.orderId}', style: text.titleMedium),
                              ],
                            ),
                            const Divider(height: 24),
                            Row(
                              children: [
                                const Text('Total'),
                                const Spacer(),
                                Text(
                                  money(order.total),
                                  style: text.titleLarge?.copyWith(color: scheme.primary),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: () => goTo(2),
                      child: const Text('View my orders'),
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton(
                      onPressed: () => goTo(0),
                      child: const Text('Keep shopping'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
