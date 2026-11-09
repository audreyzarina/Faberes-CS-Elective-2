import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/product_provider.dart';

class PaginationBar extends StatelessWidget {
  const PaginationBar({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProductProvider>();
    if (provider.totalCount == 0) return const SizedBox.shrink();

    final total = provider.totalPages;
    final current = provider.currentPage;

    // Show a window of up to 5 page numbers around the current page.
    final end = math.min(total - 1, math.max(0, current - 2) + 4);
    final start = math.max(0, end - 4);
    final busy = provider.isLoading;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Showing ${provider.firstItemIndex}–${provider.lastItemIndex} '
              'of ${provider.totalCount} products',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  tooltip: 'Previous page',
                  icon: const Icon(Icons.chevron_left),
                  onPressed:
                      provider.hasPrevious && !busy ? provider.previousPage : null,
                ),
                for (var page = start; page <= end; page++)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: page == current
                        ? FilledButton(
                            style: FilledButton.styleFrom(
                              minimumSize: const Size(40, 40),
                              padding: EdgeInsets.zero,
                            ),
                            onPressed: null,
                            child: Text('${page + 1}'),
                          )
                        : TextButton(
                            style: TextButton.styleFrom(
                              minimumSize: const Size(40, 40),
                              padding: EdgeInsets.zero,
                            ),
                            onPressed: busy ? null : () => provider.goToPage(page),
                            child: Text('${page + 1}'),
                          ),
                  ),
                IconButton(
                  tooltip: 'Next page',
                  icon: const Icon(Icons.chevron_right),
                  onPressed: provider.hasNext && !busy ? provider.nextPage : null,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
