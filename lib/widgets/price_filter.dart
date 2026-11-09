import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/product_provider.dart';

/// Price range slider. Dragging only updates the local draft; the Supabase
/// query runs when the user lets go (onChangeEnd) to avoid a request per tick.
class PriceFilter extends StatefulWidget {
  const PriceFilter({super.key});

  @override
  State<PriceFilter> createState() => _PriceFilterState();
}

class _PriceFilterState extends State<PriceFilter> {
  RangeValues? _draft;

  String _peso(double value) => '₱${value.round()}';

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProductProvider>();
    final bounds = provider.priceBounds;
    final applied = provider.priceRange;
    final shown = _draft ?? applied;

    final values = RangeValues(
      shown.start.clamp(bounds.start, bounds.end).toDouble(),
      shown.end.clamp(bounds.start, bounds.end).toDouble(),
    );

    return Card(
      margin: const EdgeInsets.fromLTRB(12, 12, 12, 4),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 8, 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.tune, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Price: ${_peso(values.start)} – ${_peso(values.end)}',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const Spacer(),
                TextButton(
                  onPressed: provider.isFilterActive
                      ? () {
                          setState(() => _draft = null);
                          provider.resetFilters();
                        }
                      : null,
                  child: const Text('Reset'),
                ),
              ],
            ),
            RangeSlider(
              values: values,
              min: bounds.start,
              max: bounds.end,
              labels: RangeLabels(_peso(values.start), _peso(values.end)),
              onChanged: (v) => setState(() => _draft = v),
              onChangeEnd: (v) {
                setState(() => _draft = null);
                provider.setPriceRange(v);
              },
            ),
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(_peso(bounds.start),
                      style: Theme.of(context).textTheme.bodySmall),
                  Text(_peso(bounds.end),
                      style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
