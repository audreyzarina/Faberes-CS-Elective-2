import 'package:material_ui/material_ui.dart';

class PaginationBar extends StatelessWidget {
  const PaginationBar({
    super.key,
    required this.page,
    required this.totalPages,
    required this.total,
    required this.onPageChanged,
  });

  final int page; // zero-based
  final int totalPages;
  final int total;
  final ValueChanged<int> onPageChanged;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.surfaceContainer,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              tooltip: 'Previous page',
              onPressed: page > 0 ? () => onPageChanged(page - 1) : null,
              icon: const Icon(Icons.chevron_left),
            ),
            Text(
              'Page ${page + 1} of $totalPages  •  $total ${total == 1 ? 'item' : 'items'}',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            IconButton(
              tooltip: 'Next page',
              onPressed:
                  page < totalPages - 1 ? () => onPageChanged(page + 1) : null,
              icon: const Icon(Icons.chevron_right),
            ),
          ],
        ),
      ),
    );
  }
}
