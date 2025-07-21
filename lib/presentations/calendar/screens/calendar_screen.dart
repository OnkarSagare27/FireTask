import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../../../bloc/tasks_bloc.dart';
import '../../../data/models/task_model.dart';
import '../../widgets/task_tile.dart';
import '../../widgets/task_details_dialog.dart';
import '../../widgets/task_form_dialog.dart';

class CalendarScreen extends StatefulWidget {
  final TextEditingController? searchController;

  const CalendarScreen({super.key, this.searchController});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<Task>> _tasksByDate = {};
  List<Task> _allTasks = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();

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

        _tasksByDate = _groupTasksByDate(_getFilteredTasks());
      });
    }
  }

  List<Task> _getFilteredTasks() {
    if (_searchQuery.isEmpty) {
      return _allTasks;
    }

    return _allTasks
        .where(
          (task) =>
              task.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              task.description.toLowerCase().contains(
                _searchQuery.toLowerCase(),
              ),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
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
              return const Center(child: CircularProgressIndicator());
            }

            if (state is TasksError) {
              return _buildErrorState(state.message);
            }

            if (state is TasksLoaded) {
              _allTasks = state.tasks;
              _tasksByDate = _groupTasksByDate(_getFilteredTasks());

              return Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TableCalendar<Task>(
                      firstDay: DateTime.utc(2020, 1, 1),
                      lastDay: DateTime.utc(2030, 12, 31),
                      focusedDay: _focusedDay,
                      selectedDayPredicate: (day) =>
                          isSameDay(_selectedDay, day),
                      eventLoader: _getTasksForDay,
                      startingDayOfWeek: StartingDayOfWeek.monday,
                      calendarStyle: CalendarStyle(
                        outsideDaysVisible: false,
                        weekendTextStyle: TextStyle(
                          color: theme.textTheme.bodyMedium?.color,
                        ),
                        holidayTextStyle: TextStyle(
                          color: theme.textTheme.bodyMedium?.color,
                        ),
                        defaultTextStyle: TextStyle(
                          color: theme.textTheme.bodyMedium?.color,
                        ),
                        selectedDecoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                        selectedTextStyle: TextStyle(
                          color: theme.colorScheme.onPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                        todayDecoration: BoxDecoration(
                          color: theme.colorScheme.primary.withValues(
                            alpha: 0.3,
                          ),
                          shape: BoxShape.circle,
                        ),
                        todayTextStyle: TextStyle(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                        markerDecoration: BoxDecoration(
                          color: theme.colorScheme.secondary,
                          shape: BoxShape.circle,
                        ),
                        markersMaxCount: 3,
                        canMarkersOverflow: true,
                      ),
                      headerStyle: HeaderStyle(
                        formatButtonVisible: false,
                        titleCentered: true,
                        titleTextStyle:
                            theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ) ??
                            const TextStyle(),
                        leftChevronIcon: Icon(
                          Icons.chevron_left,
                          color: theme.colorScheme.primary,
                        ),
                        rightChevronIcon: Icon(
                          Icons.chevron_right,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      calendarBuilders: CalendarBuilders<Task>(
                        markerBuilder: (context, day, tasks) {
                          if (tasks.isEmpty) return null;

                          final activeTasks = tasks
                              .where((task) => !task.isCompleted)
                              .length;
                          final completedTasks = tasks
                              .where((task) => task.isCompleted)
                              .length;

                          return Positioned(
                            bottom: 1,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (activeTasks > 0) ...[
                                  Container(
                                    width: 16,
                                    height: 16,
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.primary,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Text(
                                        activeTasks.toString(),
                                        style: TextStyle(
                                          color: theme.colorScheme.onPrimary,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 2),
                                ],
                                if (completedTasks > 0) ...[
                                  Container(
                                    width: 16,
                                    height: 16,
                                    decoration: BoxDecoration(
                                      color: Colors.green,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Text(
                                        completedTasks.toString(),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          );
                        },
                      ),
                      onDaySelected: (selectedDay, focusedDay) {
                        setState(() {
                          _selectedDay = selectedDay;
                          _focusedDay = focusedDay;
                        });
                      },
                      onPageChanged: (focusedDay) {
                        setState(() {
                          _focusedDay = focusedDay;
                        });
                      },
                    ),
                  ),

                  if (_selectedDay != null)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.event,
                            color: theme.colorScheme.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _formatSelectedDate(_selectedDay!),
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          _buildTasksSummary(_getTasksForDay(_selectedDay!)),
                        ],
                      ),
                    ),

                  Expanded(
                    child: _selectedDay != null
                        ? _buildTasksListForSelectedDay()
                        : const Center(
                            child: Text('Select a date to view tasks'),
                          ),
                  ),
                ],
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
          ),
          const SizedBox(height: 16),
          Text(
            'Something went wrong',
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.5),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => context.read<TasksBloc>().add(LoadTasks()),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildTasksSummary(List<Task> tasks) {
    final theme = Theme.of(context);
    final activeTasks = tasks.where((task) => !task.isCompleted).length;
    final completedTasks = tasks.where((task) => task.isCompleted).length;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (activeTasks > 0) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.radio_button_unchecked,
                  size: 14,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 4),
                Text(
                  activeTasks.toString(),
                  style: TextStyle(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
        ],
        if (completedTasks > 0) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle, size: 14, color: Colors.green),
                const SizedBox(width: 4),
                Text(
                  completedTasks.toString(),
                  style: const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
        if (tasks.isEmpty) ...[
          Text(
            'No tasks',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.5),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTasksListForSelectedDay() {
    final theme = Theme.of(context);
    final tasksForDay = _getTasksForDay(_selectedDay!);

    if (tasksForDay.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _searchQuery.isNotEmpty
                  ? Icons.search_off
                  : Icons.event_available,
              size: 64,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
            ),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isNotEmpty
                  ? 'No matching tasks found'
                  : 'No tasks for this day',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.textTheme.bodyMedium?.color?.withValues(
                  alpha: 0.6,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _searchQuery.isNotEmpty
                  ? 'Try adjusting your search terms'
                  : 'Tasks scheduled for ${_formatSelectedDate(_selectedDay!)} will appear here',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.textTheme.bodyMedium?.color?.withValues(
                  alpha: 0.5,
                ),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    final activeTasks = tasksForDay.where((task) => !task.isCompleted).toList();
    final completedTasks = tasksForDay
        .where((task) => task.isCompleted)
        .toList();

    return SingleChildScrollView(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        children: [
          const SizedBox(height: 16),
          if (activeTasks.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Icon(
                    Icons.pending_actions,
                    size: 20,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Active Tasks (${activeTasks.length})',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
            ...activeTasks.map(
              (task) => TaskTile(
                task: task,
                onTap: () => _showTaskDetails(context, task),
                onEdit: () => _showTaskDialog(context, task),
                onDelete: () =>
                    context.read<TasksBloc>().add(DeleteTask(task.id)),
                onToggleComplete: () => _toggleTaskCompletion(task),
              ),
            ),

            if (completedTasks.isNotEmpty) const SizedBox(height: 16),
          ],

          if (completedTasks.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, size: 20, color: Colors.green),
                  const SizedBox(width: 8),
                  Text(
                    'Completed Tasks (${completedTasks.length})',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
            ...completedTasks.map(
              (task) => TaskTile(
                task: task,
                onTap: () => _showTaskDetails(context, task),
                onEdit: () => _showTaskDialog(context, task),
                onDelete: () =>
                    context.read<TasksBloc>().add(DeleteTask(task.id)),
                onToggleComplete: () => _toggleTaskCompletion(task),
              ),
            ),
          ],
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Map<DateTime, List<Task>> _groupTasksByDate(List<Task> tasks) {
    final Map<DateTime, List<Task>> groupedTasks = {};

    for (Task task in tasks) {
      final date = DateTime(
        task.dueDate.year,
        task.dueDate.month,
        task.dueDate.day,
      );

      if (!groupedTasks.containsKey(date)) {
        groupedTasks[date] = [];
      }
      groupedTasks[date]!.add(task);
    }

    return groupedTasks;
  }

  List<Task> _getTasksForDay(DateTime day) {
    final normalizedDay = DateTime(day.year, day.month, day.day);
    return _tasksByDate[normalizedDay] ?? [];
  }

  String _formatSelectedDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final selectedDate = DateTime(date.year, date.month, date.day);

    if (selectedDate == today) {
      return 'Today, ${DateFormat('MMM d').format(date)}';
    } else if (selectedDate == tomorrow) {
      return 'Tomorrow, ${DateFormat('MMM d').format(date)}';
    } else {
      return DateFormat('EEEE, MMM d, y').format(date);
    }
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
    super.dispose();
  }
}
