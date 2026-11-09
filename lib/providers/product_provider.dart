import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/product.dart';

/// State management (Provider + ChangeNotifier) for the shop.
///
/// Pagination and price filtering both happen in the Supabase query:
///   .gte('price', min) .lte('price', max) .order(...) .range(from, to) .count()
/// so the app only ever downloads one page of products at a time.
class ProductProvider extends ChangeNotifier {
  ProductProvider({SupabaseClient? client}) : _injectedClient = client;

  /// 6-8 products per page is required by the activity.
  static const int pageSize = 6;
  static const String _table = 'products';

  final SupabaseClient? _injectedClient;
  SupabaseClient get _client => _injectedClient ?? Supabase.instance.client;

  // ---- state ----
  List<Product> _products = [];
  bool _isLoading = false;
  String? _error;

  int _currentPage = 0; // zero-based
  int _totalCount = 0; // rows matching the current filter (from Supabase)

  double _boundsMin = 0;
  double _boundsMax = 1000;
  RangeValues _priceRange = const RangeValues(0, 1000);

  int _requestId = 0; // ignores stale responses when taps/drags overlap

  // ---- getters ----
  List<Product> get products => _products;
  bool get isLoading => _isLoading;
  String? get error => _error;

  int get currentPage => _currentPage;
  int get totalCount => _totalCount;
  int get totalPages => math.max(1, (_totalCount / pageSize).ceil());
  bool get hasPrevious => _currentPage > 0;
  bool get hasNext => _currentPage < totalPages - 1;
  int get firstItemIndex => _totalCount == 0 ? 0 : _currentPage * pageSize + 1;
  int get lastItemIndex =>
      math.min(_totalCount, (_currentPage + 1) * pageSize);

  RangeValues get priceRange => _priceRange;
  RangeValues get priceBounds => RangeValues(_boundsMin, _boundsMax);
  bool get isFilterActive =>
      _priceRange.start > _boundsMin || _priceRange.end < _boundsMax;

  // ---- loading ----
  Future<void> init() async {
    await loadPriceBounds();
    await fetchProducts();
  }

  /// Reads the cheapest and most expensive product so the slider matches the data.
  Future<void> loadPriceBounds() async {
    try {
      final lowRows = await _client
          .from(_table)
          .select('price')
          .order('price', ascending: true)
          .limit(1);
      final highRows = await _client
          .from(_table)
          .select('price')
          .order('price', ascending: false)
          .limit(1);
      if (lowRows.isEmpty || highRows.isEmpty) return;

      final low = (lowRows.first['price'] as num).floorToDouble();
      var high = (highRows.first['price'] as num).ceilToDouble();
      if (high <= low) high = low + 1; // RangeSlider needs min < max

      final wasFullRange =
          _priceRange.start <= _boundsMin && _priceRange.end >= _boundsMax;
      _boundsMin = low;
      _boundsMax = high;

      if (wasFullRange) {
        _priceRange = RangeValues(low, high);
      } else {
        final start = _priceRange.start.clamp(low, high).toDouble();
        final end = _priceRange.end.clamp(low, high).toDouble();
        _priceRange =
            start <= end ? RangeValues(start, end) : RangeValues(low, high);
      }
    } catch (_) {
      // Keep the default bounds; fetchProducts() will surface real errors.
    }
  }

  /// Fetches ONE page from Supabase using the current price range + page.
  Future<void> fetchProducts() async {
    final requestId = ++_requestId;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final from = _currentPage * pageSize;
      final to = from + pageSize - 1;

      final response = await _client
          .from(_table)
          .select()
          .gte('price', _priceRange.start) // 1. filter
          .lte('price', _priceRange.end)
          .order('price', ascending: true) // 2. order (stable: tie-break by id)
          .order('id', ascending: true)
          .range(from, to) // 3. paginate
          .count(CountOption.exact);

      if (requestId != _requestId) return; // a newer request replaced this one

      _products = response.data.map<Product>(Product.fromMap).toList();
      _totalCount = response.count;

      // e.g. the last item of the last page was deleted -> step back a page.
      if (_products.isEmpty && _totalCount > 0 && _currentPage > 0) {
        _currentPage = totalPages - 1;
        await fetchProducts();
        return;
      }
    } on PostgrestException catch (e) {
      if (requestId != _requestId) return;
      _error = e.message;
    } catch (e) {
      if (requestId != _requestId) return;
      _error = e.toString();
    } finally {
      if (requestId == _requestId) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  // ---- price filter ----
  Future<void> setPriceRange(RangeValues values) async {
    _priceRange = RangeValues(
      values.start.roundToDouble(),
      values.end.roundToDouble(),
    );
    _currentPage = 0; // a new filter always starts from page 1
    await fetchProducts();
  }

  Future<void> resetFilters() async {
    _priceRange = RangeValues(_boundsMin, _boundsMax);
    _currentPage = 0;
    await fetchProducts();
  }

  // ---- pagination ----
  Future<void> goToPage(int page) async {
    final target = page.clamp(0, totalPages - 1);
    if (target == _currentPage) return;
    _currentPage = target;
    await fetchProducts();
  }

  Future<void> nextPage() => goToPage(_currentPage + 1);
  Future<void> previousPage() => goToPage(_currentPage - 1);

  // ---- CRUD (from the update / delete / filter session) ----
  // Each returns null on success, or an error message to show the user.

  Future<String?> addProduct(Map<String, dynamic> values) async {
    try {
      await _client.from(_table).insert(values);
      await _refreshAfterChange();
      return null;
    } on PostgrestException catch (e) {
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> updateProduct(int id, Map<String, dynamic> values) async {
    try {
      // Always target the row with .eq(), otherwise ALL rows would change.
      await _client.from(_table).update(values).eq('id', id);
      await _refreshAfterChange();
      return null;
    } on PostgrestException catch (e) {
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> deleteProduct(int id) async {
    try {
      await _client.from(_table).delete().eq('id', id);
      await _refreshAfterChange();
      return null;
    } on PostgrestException catch (e) {
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }

  Future<void> _refreshAfterChange() async {
    await loadPriceBounds(); // prices may have changed
    await fetchProducts();
  }
}
