import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/shop_category.dart';
import 'auth_providers.dart';
import 'core_providers.dart';
import 'product_providers.dart';

final categoriesProvider = FutureProvider<List<ShopCategory>>((ref) async {
  final uid = ref.watch(currentUserIdProvider);
  if (uid == null) return const <ShopCategory>[];
  return ref.watch(categoryServiceProvider).fetchAll();
});

/// id -> name lookup for product cards.
final categoryNamesProvider = Provider<Map<int, String>>((ref) {
  final cats = ref.watch(categoriesProvider).valueOrNull ?? const <ShopCategory>[];
  return {for (final c in cats) c.id: c.name};
});

/// Admin category actions. Errors are thrown so the screen can show them.
class CategoryController {
  CategoryController(this._ref);
  final Ref _ref;

  Future<void> create(String name) async {
    await _ref.read(categoryServiceProvider).create(name);
    _ref.invalidate(categoriesProvider);
  }

  Future<void> rename(int id, String name) async {
    await _ref.read(categoryServiceProvider).rename(id, name);
    _ref.invalidate(categoriesProvider);
  }

  Future<void> delete(int id) async {
    await _ref.read(categoryServiceProvider).delete(id);
    if (_ref.read(productFilterProvider).categoryId == id) {
      _ref.read(productFilterProvider.notifier).setCategory(null);
    }
    _ref.invalidate(categoriesProvider);
    _ref.invalidate(productsProvider);
  }
}

final categoryControllerProvider =
    Provider<CategoryController>((ref) => CategoryController(ref));
