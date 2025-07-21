import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/models/task_model.dart';
import '../data/repositories/task_repository.dart';

part 'tasks_event.dart';
part 'tasks_state.dart';
class TasksBloc extends Bloc<TasksEvent, TasksState> {
  final TaskRepository taskRepository;
  List<Task>? _cachedTasks;

  TasksBloc({required this.taskRepository}) : super(TasksInitial()) {
    on<LoadTasks>(_onLoadTasks);
    on<AddTask>(_onAddTask);
    on<UpdateTask>(_onUpdateTask);
    on<DeleteTask>(_onDeleteTask);
  }

  Future<void> _onLoadTasks(LoadTasks event, Emitter<TasksState> emit) async {
    // Emit cache immediately if available
    if (_cachedTasks != null) {
      emit(TasksLoaded(_cachedTasks!));
    } else {
      emit(TasksLoading()); // Show loading only if no cache
    }

    try {
      final tasks = await taskRepository.getTasks();
      _cachedTasks = tasks;
      emit(TasksLoaded(tasks));
    } catch (_) {
      emit(TasksError('Failed to load tasks.'));
    }
  }

  Future<void> _onAddTask(AddTask event, Emitter<TasksState> emit) async {
    try {
      final newTask = await taskRepository.addTask(event.task);
      _cachedTasks = [...?_cachedTasks, newTask];
      emit(TasksLoaded(_cachedTasks!));
    } catch (_) {
      emit(TasksError('Failed to add task.'));
    }
  }

  Future<void> _onUpdateTask(UpdateTask event, Emitter<TasksState> emit) async {
    try {
      await taskRepository.updateTask(event.task);
      _cachedTasks = _cachedTasks?.map((t) {
        return t.id == event.task.id ? event.task : t;
      }).toList();
      emit(TasksLoaded(_cachedTasks!));
    } catch (_) {
      emit(TasksError('Failed to update task.'));
    }
  }

  Future<void> _onDeleteTask(DeleteTask event, Emitter<TasksState> emit) async {
    try {
      await taskRepository.deleteTask(event.taskId);
      _cachedTasks = _cachedTasks?.where((t) => t.id != event.taskId).toList();
      emit(TasksLoaded(_cachedTasks!));
    } catch (_) {
      emit(TasksError('Failed to delete task.'));
    }
  }
}
