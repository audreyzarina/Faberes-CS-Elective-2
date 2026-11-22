import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/errors.dart';
import '../models/shop_category.dart';

class CategoryService {
  CategoryService(this._client);

  final SupabaseClient _client;

  Future<List<ShopCategory>> fetchAll() async {
    final rows = await _client.from('categories').select().order('name');
    return rows.map(ShopCategory.fromMap).toList();
  }

  Future<void> create(String name) async {
    await _client.from('categories').insert({'name': name});
  }

  Future<void> rename(int id, String name) async {
    final rows = await _client
        .from('categories')
        .update({'name': name})
        .eq('id', id)
        .select();
    if (rows.isEmpty) {
      throw const AppException(
        'Category was not updated. It may not exist or you may not have permission.',
        permissionDenied: true,
      );
    }
  }

  Future<void> delete(int id) async {
    try {
      final rows =
          await _client.from('categories').delete().eq('id', id).select();
      if (rows.isEmpty) {
        throw const AppException(
          'Category was not deleted. It may not exist or you may not have permission.',
          permissionDenied: true,
        );
      }
    } on PostgrestException catch (e) {
      if (e.code == '23503') {
        throw const AppException(
          'This category still has products. Move or delete them first.',
        );
      }
      rethrow;
    }
  }
}
