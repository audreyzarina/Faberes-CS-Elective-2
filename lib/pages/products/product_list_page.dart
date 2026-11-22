import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/config.dart';
import '../../core/errors.dart';
import '../../models/product.dart';
import '../../providers/cart_providers.dart';
import '../../providers/product_providers.dart';
import '../../widgets/async_value_view.dart';
import '../../widgets/filter_bar.dart';
import '../../widgets/pagination_bar.dart';
import '../../widgets/product_card.dart';
import '../../widgets/ui_helpers.dart';
import 'product_form_page.dart';

/// One screen for both roles. Admins get the FAB and edit/delete buttons;
/// customers get "Add to cart". The database enforces the difference too.
class ProductListPage extends ConsumerWidget {
  const ProductListPage({super.key, required this.isAdmin});

  final bool isAdmin;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(productFilterProvider);
    final products = ref.watch(productsProvider);

    return Scaffold(
      floatingActionButton: isAdmin
          ? Padding(
              padding: const EdgeInsets.only(bottom: 56),
              child: FloatingActionButton.extended(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ProductFormPage()),
                ),
                icon: const Icon(Icons.add),
                label: const Text('Add product'),
              ),
            )
          : null,
      body: Column(
        children: [
          const ProductFilterBar(),
          Expanded(
            child: AsyncValueView<ProductsResult>(
              value: products,
              onRetry: () => ref.invalidate(productsProvider),
              data: (result) => _buildResult(context, ref, filter, result),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResult(
    BuildContext context,
    WidgetRef ref,
    ProductFilter filter,
    ProductsResult result,
  ) {
    final totalPages = result.totalPages(AppConfig.pageSize);

    // After deleting the last item on the last page, step back one page.
    if (filter.page > 0 && filter.page >= totalPages) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(productFilterProvider.notifier).setPage(totalPages - 1);
      });
    }

    if (result.items.isEmpty) {
      return EmptyView(
        icon: Icons.search_off,
        title: filter.isActive
            ? 'No products match your filters'
            : 'No products yet',
        subtitle: filter.isActive
            ? 'Try a different search, category or price range.'
            : (isAdmin
                ? 'Tap "Add product" to create the first one.'
                : 'Please check back soon.'),
        action: filter.isActive
            ? OutlinedButton(
                onPressed: () =>
                    ref.read(productFilterProvider.notifier).reset(),
                child: const Text('Clear filters'),
              )
            : null,
      );
    }

    return Column(
      children: [
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(productsProvider);
              await ref.read(productsProvider.future);
            },
            child: GridView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.fromLTRB(12, 8, 12, isAdmin ? 88 : 12),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 260,
                mainAxisExtent: 330,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
              ),
              itemCount: result.items.length,
              itemBuilder: (context, i) {
                final p = result.items[i];
                return ProductCard(
                  key: ValueKey(p.id),
                  product: p,
                  isAdmin: isAdmin,
                  onEdit: () => Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (_) => ProductFormPage(product: p)),
                  ),
                  onDelete: () => _confirmDelete(context, ref, p),
                  onAddToCart: () {
                    final error = ref.read(cartProvider.notifier).add(p);
                    showMessage(
                      context,
                      error ?? 'Added ${p.name} to your cart',
                      error: error != null,
                      duration:
                          error == null ? const Duration(seconds: 2) : null,
                    );
                  },
                );
              },
            ),
          ),
        ),
        PaginationBar(
          page: filter.page,
          totalPages: totalPages,
          total: result.total,
          onPageChanged: (p) =>
              ref.read(productFilterProvider.notifier).setPage(p),
        ),
      ],
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    Product product,
  ) async {
    final scheme = Theme.of(context).colorScheme;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete product?'),
        content: Text(
          'Are you sure you want to delete "${product.name}"? '
          'Past orders keep their saved name and price.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: scheme.error,
              foregroundColor: scheme.onError,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await ref.read(productControllerProvider).delete(product.id);
      if (context.mounted) showMessage(context, 'Deleted "${product.name}".');
    } catch (e) {
      if (context.mounted) showMessage(context, friendlyError(e), error: true);
    }
  }
}
