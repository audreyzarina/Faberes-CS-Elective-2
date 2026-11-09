import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/product.dart';
import '../providers/product_provider.dart';
import '../widgets/pagination_bar.dart';
import '../widgets/price_filter.dart';
import '../widgets/product_card.dart';
import '../widgets/product_form_dialog.dart';

class ShopScreen extends StatelessWidget {
  const ShopScreen({super.key});

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _add(BuildContext context) async {
    final provider = context.read<ProductProvider>();
    final values = await showProductFormDialog(context);
    if (values == null) return;
    final error = await provider.addProduct(values);
    if (context.mounted) {
      _showMessage(context, error ?? 'Product added');
    }
  }

  Future<void> _edit(BuildContext context, Product product) async {
    final provider = context.read<ProductProvider>();
    final values = await showProductFormDialog(context, product: product);
    if (values == null) return;
    final error = await provider.updateProduct(product.id, values);
    if (context.mounted) {
      _showMessage(context, error ?? 'Product updated');
    }
  }

  Future<void> _delete(BuildContext context, Product product) async {
    final provider = context.read<ProductProvider>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete product?'),
        content: Text('"${product.name}" will be permanently removed.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    final error = await provider.deleteProduct(product.id);
    if (context.mounted) {
      _showMessage(context, error ?? 'Product deleted');
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProductProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shop'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh),
            onPressed: provider.isLoading ? null : provider.fetchProducts,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _add(context),
        tooltip: 'Add product',
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          const PriceFilter(),
          SizedBox(
            height: 3,
            child: provider.isLoading ? const LinearProgressIndicator() : null,
          ),
          Expanded(child: _buildBody(context, provider)),
          const PaginationBar(),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context, ProductProvider provider) {
    if (provider.error != null && provider.products.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48),
              const SizedBox(height: 12),
              Text(provider.error!, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: provider.fetchProducts,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (provider.isLoading && provider.products.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.products.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.search_off, size: 48),
            const SizedBox(height: 12),
            const Text('No products in this price range'),
            if (provider.isFilterActive) ...[
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: provider.resetFilters,
                child: const Text('Reset filter'),
              ),
            ],
          ],
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth > 700 ? 3 : 2;
        return GridView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: provider.products.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: columns == 3 ? 0.95 : 0.7,
          ),
          itemBuilder: (context, index) {
            final product = provider.products[index];
            return ProductCard(
              product: product,
              onEdit: () => _edit(context, product),
              onDelete: () => _delete(context, product),
            );
          },
        );
      },
    );
  }
}
