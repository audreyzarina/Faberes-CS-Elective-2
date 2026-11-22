import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../models/product.dart';
import 'auth_providers.dart';
import 'core_providers.dart';

/// Search, category, price range and page. Reset whenever the user changes.
class ProductFilterNotifier extends Notifier<ProductFilter> {
  @override
  ProductFilter build() {
    ref.watch(currentUserIdProvider);
    return const ProductFilter();
  }

  void setSearch(String value) =>
      state = state.copyWith(search: value, page: 0);

  void setCategory(int? id) => state = id == null
      ? state.copyWith(clearCategory: true, page: 0)
      : state.copyWith(categoryId: id, page: 0);

  void setPriceRange(double min, double max) =>
      state = state.copyWith(minPrice: min, maxPrice: max, page: 0);

  void clearPrice() => state = state.copyWith(clearPrice: true, page: 0);

  void setPage(int page) => state = state.copyWith(page: page);

  void reset() => state = const ProductFilter();
}

final productFilterProvider =
    NotifierProvider<ProductFilterNotifier, ProductFilter>(
  ProductFilterNotifier.new,
);

/// One page of products, filtered on the server.
final productsProvider = FutureProvider.autoDispose<ProductsResult>((ref) {
  final uid = ref.watch(currentUserIdProvider);
  if (uid == null) return const ProductsResult(items: [], total: 0);
  final filter = ref.watch(productFilterProvider);
  return ref.watch(productServiceProvider).fetch(filter);
});

/// Upper bound for the price slider (highest price rounded up to the next 50).
final priceCeilingProvider = FutureProvider.autoDispose<double>((ref) async {
  final uid = ref.watch(currentUserIdProvider);
  if (uid == null) return 0;
  final max = await ref.watch(productServiceProvider).fetchMaxPrice();
  if (max <= 0) return 0;
  return ((max / 50).ceil() * 50).toDouble();
});

/// Admin product actions. Errors are thrown so the screen can show them.
class ProductController {
  ProductController(this._ref);
  final Ref _ref;

  void _refresh() {
    _ref.invalidate(productsProvider);
    _ref.invalidate(priceCeilingProvider);
  }

  Future<String> uploadImage(XFile file) =>
      _ref.read(storageServiceProvider).uploadProductImage(file);

  Future<void> create(ProductDraft draft) async {
    await _ref.read(productServiceProvider).create(draft);
    _refresh();
  }

  Future<void> update(int id, ProductDraft draft) async {
    await _ref.read(productServiceProvider).update(id, draft);
    _refresh();
  }

  Future<void> delete(int id) async {
    await _ref.read(productServiceProvider).delete(id);
    _refresh();
  }
}

final productControllerProvider =
    Provider<ProductController>((ref) => ProductController(ref));
