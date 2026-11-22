import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/formatters.dart';
import '../providers/category_providers.dart';
import '../providers/product_providers.dart';
import 'ui_helpers.dart';

/// Search + category chips + price range slider (the filters from the
/// Price Filter & Pagination activity, plus search and category).
class ProductFilterBar extends ConsumerStatefulWidget {
  const ProductFilterBar({super.key});

  @override
  ConsumerState<ProductFilterBar> createState() => _ProductFilterBarState();
}

class _ProductFilterBarState extends ConsumerState<ProductFilterBar> {
  late final TextEditingController _search;
  Timer? _debounce;
  RangeValues? _dragging; // slider position while the thumb is moving

  @override
  void initState() {
    super.initState();
    _search = TextEditingController(text: ref.read(productFilterProvider).search);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _search.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      ref.read(productFilterProvider.notifier).setSearch(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(productFilterProvider, (prev, next) {
      if (next.minPrice == null && next.maxPrice == null && _dragging != null) {
        setState(() => _dragging = null);
      }
      if (next.search.isEmpty && (prev?.search.isNotEmpty ?? false)) {
        _search.clear();
      }
    });

    final filter = ref.watch(productFilterProvider);
    final notifier = ref.read(productFilterProvider.notifier);
    final categories = ref.watch(categoriesProvider);
    final double ceiling = ref.watch(priceCeilingProvider).valueOrNull ?? 0;

    double lo = _dragging?.start ?? filter.minPrice ?? 0;
    double hi = _dragging?.end ?? filter.maxPrice ?? ceiling;
    lo = lo.clamp(0, ceiling).toDouble();
    hi = hi.clamp(0, ceiling).toDouble();
    if (lo > hi) lo = hi;
    final priceActive = filter.minPrice != null || filter.maxPrice != null;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      child: Column(
        children: [
          TextField(
            controller: _search,
            onChanged: _onSearchChanged,
            textInputAction: TextInputAction.search,
            decoration: fieldDecoration(
              'Search products',
              icon: Icons.search,
              suffix: ListenableBuilder(
                listenable: _search,
                builder: (context, _) => _search.text.isEmpty
                    ? const SizedBox.shrink()
                    : IconButton(
                        tooltip: 'Clear search',
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          _search.clear();
                          _debounce?.cancel();
                          notifier.setSearch('');
                        },
                      ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 42,
            child: categories.when(
              data: (list) => ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: const Text('All'),
                      selected: filter.categoryId == null,
                      onSelected: (_) => notifier.setCategory(null),
                    ),
                  ),
                  for (final c in list)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(c.name),
                        selected: filter.categoryId == c.id,
                        onSelected: (_) => notifier.setCategory(c.id),
                      ),
                    ),
                ],
              ),
              loading: () => const Align(
                alignment: Alignment.centerLeft,
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
              error: (e, _) => Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () => ref.invalidate(categoriesProvider),
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text("Couldn't load categories. Retry"),
                ),
              ),
            ),
          ),
          ExpansionTile(
            tilePadding: EdgeInsets.zero,
            dense: true,
            shape: const Border(),
            collapsedShape: const Border(),
            title: Text(
              priceActive || _dragging != null
                  ? 'Price: ${moneyWhole(lo)} – ${moneyWhole(hi)}'
                  : 'Price range',
            ),
            trailing: filter.isActive
                ? TextButton(
                    onPressed: () {
                      _debounce?.cancel();
                      _search.clear();
                      setState(() => _dragging = null);
                      notifier.reset();
                    },
                    child: const Text('Clear filters'),
                  )
                : null,
            children: [
              if (ceiling <= 0)
                const Padding(
                  padding: EdgeInsets.only(bottom: 12),
                  child: Text('Add products with a price to use this filter.'),
                )
              else
                RangeSlider(
                  min: 0,
                  max: ceiling,
                  divisions: (ceiling / 10).round().clamp(1, 200),
                  values: RangeValues(lo, hi),
                  labels: RangeLabels(moneyWhole(lo), moneyWhole(hi)),
                  onChanged: (v) => setState(() => _dragging = v),
                  onChangeEnd: (v) {
                    setState(() => _dragging = null);
                    if (v.start <= 0 && v.end >= ceiling) {
                      notifier.clearPrice();
                    } else {
                      notifier.setPriceRange(v.start, v.end);
                    }
                  },
                ),
            ],
          ),
        ],
      ),
    );
  }
}
