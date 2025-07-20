import 'package:flutter/material.dart';

enum SortBy {
  priority,
  dueDate,
  created,
  updated,
  title;

  String get displayName {
    switch (this) {
      case SortBy.priority:
        return 'Priority';
      case SortBy.dueDate:
        return 'Due Date';
      case SortBy.created:
        return 'Created';
      case SortBy.updated:
        return 'Updated';
      case SortBy.title:
        return 'Title';
    }
  }
}

enum SortOrder { ascending, descending }

class SortBottomSheet extends StatefulWidget {
  final SortBy initialSortBy;
  final SortOrder initialSortOrder;
  final void Function(SortBy sortBy, SortOrder sortOrder) onApply;

  const SortBottomSheet({
    super.key,
    required this.initialSortBy,
    required this.initialSortOrder,
    required this.onApply,
  });

  @override
  State<SortBottomSheet> createState() => _SortBottomSheetState();
}

class _SortBottomSheetState extends State<SortBottomSheet> {
  late SortBy _sortBy;
  late SortOrder _sortOrder;

  @override
  void initState() {
    super.initState();
    _sortBy = widget.initialSortBy;
    _sortOrder = widget.initialSortOrder;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.outline,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          const SizedBox(height: 16),

          Text('Sort Tasks', style: Theme.of(context).textTheme.titleLarge),

          const SizedBox(height: 20),

          Text(
            'Sort by:',
            style: Theme.of(
              context,
            ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
          ),

          const SizedBox(height: 12),

          ...SortBy.values.map(_buildSortOption),

          const SizedBox(height: 20),

          Text(
            'Order:',
            style: Theme.of(
              context,
            ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _buildOrderOption(
                  'Ascending',
                  Icons.arrow_upward,
                  SortOrder.ascending,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildOrderOption(
                  'Descending',
                  Icons.arrow_downward,
                  SortOrder.descending,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                widget.onApply(_sortBy, _sortOrder);
                Navigator.pop(context);
              },
              child: const Text('Apply'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSortOption(SortBy sortBy) {
    final isSelected = _sortBy == sortBy;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => setState(() => _sortBy = sortBy),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected
                  ? Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.08)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.outline,
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _getSortIconForType(sortBy),
                  size: 20,
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).textTheme.bodyMedium?.color,
                ),
                const SizedBox(width: 12),
                Text(
                  _getSortLabel(sortBy),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : null,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
                const Spacer(),
                if (isSelected)
                  Icon(
                    Icons.check,
                    color: Theme.of(context).colorScheme.primary,
                    size: 20,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOrderOption(String label, IconData icon, SortOrder order) {
    final isSelected = _sortOrder == order;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => setState(() => _sortOrder = order),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.08)
                : Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.outline,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).textTheme.bodyMedium?.color,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : null,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getSortIconForType(SortBy sortBy) {
    switch (sortBy) {
      case SortBy.priority:
        return Icons.flag;
      case SortBy.dueDate:
        return Icons.schedule;
      case SortBy.created:
        return Icons.add_circle_outline;
      case SortBy.updated:
        return Icons.edit;
      case SortBy.title:
        return Icons.sort_by_alpha;
    }
  }

  String _getSortLabel(SortBy sortBy) {
    switch (sortBy) {
      case SortBy.priority:
        return 'Priority';
      case SortBy.dueDate:
        return 'Due Date';
      case SortBy.created:
        return 'Created At';
      case SortBy.updated:
        return 'Last Updated';
      case SortBy.title:
        return 'Title';
    }
  }
}
