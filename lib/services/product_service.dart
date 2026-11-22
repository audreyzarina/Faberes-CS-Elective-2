import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/config.dart';
import '../core/errors.dart';
import '../models/product.dart';

class ProductService {
  ProductService(this._client);

  final SupabaseClient _client;

  /// Server-side search + category + price filter + pagination.
  Future<ProductsResult> fetch(ProductFilter f) async {
    var query = _client.from('products').select();

    final search = f.search.trim();
    if (search.isNotEmpty) query = query.ilike('name', '%$search%');
    if (f.categoryId != null) query = query.eq('category_id', f.categoryId!);
    if (f.minPrice != null) query = query.gte('price', f.minPrice!);
    if (f.maxPrice != null) query = query.lte('price', f.maxPrice!);

    final from = f.page * AppConfig.pageSize;
    final to = from + AppConfig.pageSize - 1;

    final res = await query
        .order('created_at', ascending: false)
        .order('id', ascending: false)
        .range(from, to)
        .count(CountOption.exact);

    return ProductsResult(
      items: res.data.map(Product.fromMap).toList(),
      total: res.count,
    );
  }

  /// Highest price in the catalogue, used as the slider's upper bound.
  Future<double> fetchMaxPrice() async {
    final rows = await _client
        .from('products')
        .select('price')
        .order('price', ascending: false)
        .limit(1);
    if (rows.isEmpty) return 0;
    return (rows.first['price'] as num?)?.toDouble() ?? 0;
  }

  Future<void> create(ProductDraft draft) async {
    await _client.from('products').insert(draft.toMap());
  }

  Future<void> update(int id, ProductDraft draft) async {
    // RLS hides rows from non-admins and turns the update into a silent
    // no-op, so we ask for the updated rows back and treat "none" as denied.
    final rows = await _client
        .from('products')
        .update(draft.toMap())
        .eq('id', id)
        .select();
    if (rows.isEmpty) {
      throw const AppException(
        'The product was not updated. It may no longer exist or you may not have permission.',
        permissionDenied: true,
      );
    }
  }

  Future<void> delete(int id) async {
    final rows = await _client.from('products').delete().eq('id', id).select();
    if (rows.isEmpty) {
      throw const AppException(
        'The product was not deleted. It may no longer exist or you may not have permission.',
        permissionDenied: true,
      );
    }
  }
}
