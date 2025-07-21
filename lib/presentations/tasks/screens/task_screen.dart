import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../bloc/tasks_bloc.dart';
import '../../../data/models/task_model.dart';
import '../../widgets/sort_bottom_sheet.dart';
import '../../widgets/task_details_dialog.dart';
import '../../widgets/task_form_dialog.dart';
import '../../widgets/task_tile.dart';

class TasksScreen extends StatefulWidget {
  final TextEditingController? searchController;

  const TasksScreen({super.key, this.searchController});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  TaskPriority? _filterPriority;
  String _searchQuery = '';
  SortBy _sortBy = SortBy.dueDate;
  SortOrder _sortOrder = SortOrder.ascending;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    if (widget.searchController != null) {
      widget.searchController!.addListener(_onSearchChanged);
      _searchQuery = widget.searchController!.text;
    }

    context.read<TasksBloc>().add(LoadTasks());
  }

  void _onSearchChanged() {
    if (widget.searchController != null) {
      setState(() {
        _searchQuery = widget.searchController!.text;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Container(
                    height: 48,
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.outline,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      indicator: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      indicatorSize: TabBarIndicatorSize.tab,
                      labelColor: Theme.of(context).colorScheme.onPrimary,
                      unselectedLabelColor: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.color,
                      labelStyle: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                      unselectedLabelStyle: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                      dividerColor: Colors.transparent,
                      splashFactory: NoSplash.splashFactory,
                      overlayColor: WidgetStateProperty.all(Colors.transparent),
                      tabs: const [
                        Tab(text: 'All Tasks'),
                        Tab(text: 'Active'),
                        Tab(text: 'Completed'),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Container(
                        height: 40,
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Theme.of(
                              context,
                            ).colorScheme.outline,
                            width: 1,
                          ),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: _showSortBottomSheet,
                            borderRadius: BorderRadius.circular(8),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 6,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const SizedBox(width: 6),
                                  Text(
                                    _sortBy.displayName,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Icon(
                                    _sortOrder == SortOrder.ascending
                                        ? Icons.keyboard_arrow_up
                                        : Icons.keyboard_arrow_down,
                                    size: 16,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 16),

                      Text(
                        'Priority:',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.only(right: 16),
                          child: Row(
                            children: [
                              _buildPriorityChip('All', null),
                              const SizedBox(width: 8),
                              ...TaskPriority.values.map(
                                (priority) => Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: _buildPriorityChip(
                                    priority.displayName,
                                    priority,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          Expanded(
            child: BlocConsumer<TasksBloc, TasksState>(
              listener: (context, state) {
                if (state is TasksError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              builder: (context, state) {
                if (state is TasksLoading) {
                  return const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Color(0xFF6C5CE7),
                      ),
                    ),
                  );
                }

                if (state is TasksError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Something went wrong',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          state.message,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () =>
                              context.read<TasksBloc>().add(LoadTasks()),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                if (state is TasksLoaded) {
                  return TabBarView(
                    controller: _tabController,
                    children: [
                      _buildTasksList(state.tasks, TaskFilter.all),
                      _buildTasksList(state.tasks, TaskFilter.active),
                      _buildTasksList(state.tasks, TaskFilter.completed),
                    ],
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showSortBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SortBottomSheet(
        initialSortBy: _sortBy,
        initialSortOrder: _sortOrder,
        onApply: (sortBy, sortOrder) {
          setState(() {
            _sortBy = sortBy;
            _sortOrder = sortOrder;
          });
        },
      ),
    );
  }

  Widget _buildPriorityChip(String label, TaskPriority? priority) {
    final isSelected = _filterPriority == priority;
    final theme = Theme.of(context);
    final chipColor = priority?.color ?? theme.colorScheme.primary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => setState(() => _filterPriority = priority),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected
                ? chipColor.withValues(alpha: 0.12)
                : theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected
                  ? chipColor
                  : theme.colorScheme.outline,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (priority != null) ...[
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: priority.color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isSelected
                      ? chipColor
                      : theme.textTheme.bodyMedium?.color?.withValues(
                          alpha: 0.8,
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTasksList(List<Task> allTasks, TaskFilter filter) {
    List<Task> filteredTasks = _filterAndSortTasks(allTasks, filter);

    if (filteredTasks.isEmpty) {
      return _buildEmptyState(filter);
    }

    return RefreshIndicator(
      onRefresh: () async {
        context.read<TasksBloc>().add(LoadTasks());
      },
      color: Theme.of(context).colorScheme.primary,
      child: _sortBy == SortBy.dueDate
          ? _buildGroupedTasksList(filteredTasks)
          : _buildSimpleTasksList(filteredTasks),
    );
  }

  Widget _buildSimpleTasksList(List<Task> tasks) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 16),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return TaskTile(
          task: task,
          onTap: () => _showTaskDetails(context, task),
          onEdit: () => _showTaskDialog(context, task),
          onDelete: () => context.read<TasksBloc>().add(DeleteTask(task.id)),
          onToggleComplete: () => _toggleTaskCompletion(task),
        );
      },
    );
  }
Map<String, List<Task>> _groupTasksByDate(List<Task> tasks) {
  final Map<String, List<Task>> grouped = {};

  for (Task task in tasks) {
    final String dateKey = _getDateGroupKey(task.dueDate);
    if (!grouped.containsKey(dateKey)) {
      grouped[dateKey] = [];
    }
    grouped[dateKey]!.add(task);
  }

  
  final sortedEntries = grouped.entries.toList()
    ..sort((a, b) {
      final DateTime dateA = _parseDateKey(a.key);
      final DateTime dateB = _parseDateKey(b.key);
      
      
      return dateA.compareTo(dateB);
    });

  return Map.fromEntries(sortedEntries);
}

DateTime _parseDateKey(String key) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);

  switch (key) {
    case 'Today':
      return today;
    case 'Tomorrow':
      return today.add(const Duration(days: 1));
    case 'Yesterday':
      return today.subtract(const Duration(days: 1));
    case 'Overdue':
      
      return DateTime(1900, 1, 1);
    default:
      try {
        final parts = key.split(' ');
        final day = int.parse(parts[0]);
        final month = _getMonthNumber(parts[1].replaceAll(',', ''));
        final year = int.parse(parts[2]);
        return DateTime(year, month, day);
      } catch (e) {
        return today;
      }
  }
}

Widget _buildGroupedTasksList(List<Task> tasks) {
  final Map<String, List<Task>> groupedTasks = _groupTasksByDate(tasks);
  final List<String> sortedKeys = groupedTasks.keys.toList();

  
  int todayIndex = 0;
  int currentIndex = 0;
  
  for (String dateKey in sortedKeys) {
    if (dateKey == 'Today') {
      todayIndex = currentIndex;
      break;
    }
    currentIndex += 1 + (groupedTasks[dateKey]?.length ?? 0);
  }

  return ListView.builder(
    padding: const EdgeInsets.symmetric(vertical: 16),
    itemCount: _calculateTotalItems(groupedTasks),
    
    controller: ScrollController(
      initialScrollOffset: todayIndex > 0 ? todayIndex * 80.0 : 0.0,
    ),
    itemBuilder: (context, index) {
      int currentIndex = 0;

      for (String dateKey in sortedKeys) {
        if (currentIndex == index) {
          return _buildDateHeader(dateKey);
        }
        currentIndex++;

        final tasksInGroup = groupedTasks[dateKey]!;
        if (index < currentIndex + tasksInGroup.length) {
          final taskIndex = index - currentIndex;
          final task = tasksInGroup[taskIndex];
          return TaskTile(
            task: task,
            onTap: () => _showTaskDetails(context, task),
            onEdit: () => _showTaskDialog(context, task),
            onDelete: () =>
                context.read<TasksBloc>().add(DeleteTask(task.id)),
            onToggleComplete: () => _toggleTaskCompletion(task),
          );
        }
        currentIndex += tasksInGroup.length;
      }

      return const SizedBox.shrink();
    },
  );
}

String _getDateGroupKey(DateTime date) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final tomorrow = today.add(const Duration(days: 1));
  final yesterday = today.subtract(const Duration(days: 1));
  final taskDate = DateTime(date.year, date.month, date.day);

  if (taskDate == today) {
    return 'Today';
  } else if (taskDate == tomorrow) {
    return 'Tomorrow';
  } else if (taskDate == yesterday) {
    return 'Yesterday';
  } else if (taskDate.isBefore(today)) {
    
    return 'Overdue';
  } else {
    return '${date.day} ${_getMonthName(date.month)}, ${date.year}';
  }
}

  String _getMonthName(int month) {
    const months = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month];
  }

  int _getMonthNumber(String monthName) {
    const months = {
      'Jan': 1,
      'Feb': 2,
      'Mar': 3,
      'Apr': 4,
      'May': 5,
      'Jun': 6,
      'Jul': 7,
      'Aug': 8,
      'Sep': 9,
      'Oct': 10,
      'Nov': 11,
      'Dec': 12,
    };
    return months[monthName] ?? 1;
  }

  int _calculateTotalItems(Map<String, List<Task>> groupedTasks) {
    int total = 0;
    for (String key in groupedTasks.keys) {
      total += 1;
      total += groupedTasks[key]!.length;
    }
    return total;
  }

  Widget _buildDateHeader(String dateKey) {
    final theme = Theme.of(context);
    final isOverdue = dateKey == 'Overdue';
    final isToday = dateKey == 'Today';

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isOverdue
            ? Colors.red.withValues(alpha: 0.05)
            : isToday
            ? theme.colorScheme.primary.withValues(alpha: 0.05)
            : theme.colorScheme.outline,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isOverdue
              ? Colors.red.withValues(alpha: 0.2)
              : isToday
              ? theme.colorScheme.primary.withValues(alpha: 0.2)
              : theme.colorScheme.outline,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isOverdue
                ? Icons.warning_outlined
                : isToday
                ? Icons.today_outlined
                : Icons.event_outlined,
            size: 20,
            color: isOverdue
                ? Colors.red
                : isToday
                ? theme.colorScheme.primary
                : theme.textTheme.titleMedium?.color?.withValues(alpha: 0.7),
          ),
          const SizedBox(width: 12),
          Text(
            dateKey,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: isOverdue
                  ? Colors.red
                  : isToday
                  ? theme.colorScheme.primary
                  : theme.textTheme.titleMedium?.color,
            ),
          ),
          const Spacer(),
          if (isOverdue) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'OVERDUE',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyState(TaskFilter filter) {
    String message;
    IconData icon;

    switch (filter) {
      case TaskFilter.active:
        message = 'No active tasks.\nGreat job staying organized!';
        icon = Icons.check_circle_outline;
        break;
      case TaskFilter.completed:
        message = 'No completed tasks yet.\nStart completing some tasks!';
        icon = Icons.assignment_turned_in;
        break;
      default:
        message = 'No tasks yet.\nCreate your first task to get started!';
        icon = Icons.assignment;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 80,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.2),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(
                context,
              ).textTheme.bodyMedium?.color?.withValues(alpha: 0.6),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  List<Task> _filterAndSortTasks(List<Task> tasks, TaskFilter filter) {
    List<Task> filtered = List.from(tasks);

    switch (filter) {
      case TaskFilter.active:
        filtered = filtered.where((task) => !task.isCompleted).toList();
        break;
      case TaskFilter.completed:
        filtered = filtered.where((task) => task.isCompleted).toList();
        break;
      case TaskFilter.all:
        break;
    }

    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where(
            (task) =>
                task.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                task.description.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ),
          )
          .toList();
    }

    if (_filterPriority != null) {
      filtered = filtered
          .where((task) => task.priority == _filterPriority)
          .toList();
    }

    if (_sortBy != SortBy.dueDate) {
      filtered.sort((a, b) {
        int comparison;

        switch (_sortBy) {
          case SortBy.priority:
            comparison = a.priority.index.compareTo(b.priority.index);
            break;
          case SortBy.dueDate:
            comparison = a.dueDate.compareTo(b.dueDate);
            break;
          case SortBy.created:
            comparison = a.createdAt.compareTo(b.createdAt);
            break;
          case SortBy.updated:
            comparison = a.updatedAt.compareTo(b.updatedAt);
            break;
          case SortBy.title:
            comparison = a.title.toLowerCase().compareTo(b.title.toLowerCase());
            break;
        }

        return _sortOrder == SortOrder.ascending ? comparison : -comparison;
      });
    }

    return filtered;
  }

  void _showTaskDetails(BuildContext context, Task task) {
    showDialog(
      context: context,
      builder: (context) => TaskDetailsDialog(task: task),
    );
  }

  void _showTaskDialog(BuildContext context, Task? task) async {
    final result = await showDialog<Task>(
      context: context,
      builder: (context) => TaskFormDialog(task: task),
    );

    if (result != null) {
      if (task == null && context.mounted) {
        context.read<TasksBloc>().add(AddTask(result));
      } else if (context.mounted) {
        context.read<TasksBloc>().add(UpdateTask(result));
      }
    }
  }

  void _toggleTaskCompletion(Task task) {
    final updatedTask = task.copyWith(
      isCompleted: !task.isCompleted,
      updatedAt: DateTime.now(),
    );
    context.read<TasksBloc>().add(UpdateTask(updatedTask));
  }

  @override
  void dispose() {
    if (widget.searchController != null) {
      widget.searchController!.removeListener(_onSearchChanged);
    }
    _tabController.dispose();
    super.dispose();
  }
}

enum TaskFilter { all, active, completed }
