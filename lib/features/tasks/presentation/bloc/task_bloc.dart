import 'dart:async';
import 'dart:developer' as developer;
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/task_repository.dart';
import '../../domain/entities/task_entity.dart';

part 'task_event.dart';
part 'task_state.dart';

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final TaskRepository taskRepository;
  StreamSubscription? _tasksSubscription;

  TaskBloc({required this.taskRepository}) : super(TaskInitial()) {
    on<LoadTasks>(_onLoadTasks);
    on<SearchTasks>(_onSearchTasks);
    on<TaskErrorOccurred>(_onTaskErrorOccurred);
    on<CreateTask>(_onCreateTask);
    on<UpdateTask>(_onUpdateTask);
    on<DeleteTask>(_onDeleteTask);
    on<ToggleTaskCompletion>(_onToggleTaskCompletion);
    on<FilterTasks>(_onFilterTasks);
    on<TasksUpdated>(_onTasksUpdated);
  }

  Future<void> _onLoadTasks(LoadTasks event, Emitter<TaskState> emit) async {
    developer.log('Loading tasks for user: ${event.userId}');
    emit(TaskLoading());
    await _tasksSubscription?.cancel();

    try {
      _tasksSubscription = taskRepository
          .getTasks(event.userId)
          .listen(
            (tasks) {
              developer.log('Tasks received: ${tasks.length} tasks');
              add(TasksUpdated(tasks: tasks));
            },
            onError: (error) {
              developer.log('Error loading tasks: $error');
              add(TaskErrorOccurred(message: error.toString()));
            },
          );
    } catch (e) {
      developer.log('Exception loading tasks: $e');
      add(TaskErrorOccurred(message: e.toString()));
    }
  }

  Future<void> _onSearchTasks(
    SearchTasks event,
    Emitter<TaskState> emit,
  ) async {
    final currentState = state;
    if (currentState is TaskLoaded) {
      final allTasks = currentState.tasks;
      List<TaskEntity> filteredTasks;

      if (event.query.isEmpty) {
        filteredTasks = allTasks;
      } else {
        filteredTasks = allTasks.where((task) {
          return task.title.toLowerCase().contains(event.query.toLowerCase()) ||
                 task.description.toLowerCase().contains(event.query.toLowerCase());
        }).toList();
      }

      emit(TaskLoaded(tasks: allTasks, filteredTasks: filteredTasks));
    }
  }

  void _onTasksUpdated(TasksUpdated event, Emitter<TaskState> emit) {
    emit(TaskLoaded(tasks: event.tasks, filteredTasks: event.tasks));
  }

  Future<void> _onTaskErrorOccurred(
    TaskErrorOccurred event,
    Emitter<TaskState> emit,
  ) async {
    emit(TaskError(message: event.message));
  }

  Future<void> _onCreateTask(CreateTask event, Emitter<TaskState> emit) async {
    try {
      await taskRepository.createTask(event.task);
    } catch (e) {
      emit(TaskError(message: e.toString()));
    }
  }

  Future<void> _onUpdateTask(UpdateTask event, Emitter<TaskState> emit) async {
    try {
      await taskRepository.updateTask(event.task);
    } catch (e) {
      emit(TaskError(message: e.toString()));
    }
  }

  Future<void> _onDeleteTask(DeleteTask event, Emitter<TaskState> emit) async {
    try {
      await taskRepository.deleteTask(event.taskId);
    } catch (e) {
      emit(TaskError(message: e.toString()));
    }
  }

  Future<void> _onToggleTaskCompletion(
    ToggleTaskCompletion event,
    Emitter<TaskState> emit,
  ) async {
    try {
      await taskRepository.toggleTaskCompletion(
        event.taskId,
        event.isCompleted,
      );
    } catch (e) {
      emit(TaskError(message: e.toString()));
    }
  }

  void _onFilterTasks(FilterTasks event, Emitter<TaskState> emit) {
    if (state is TaskLoaded) {
      final currentState = state as TaskLoaded;
      List<TaskEntity> filtered = currentState.tasks;

      // Filter by priority
      if (event.priority != null) {
        filtered = filtered
            .where((task) => task.priority == event.priority)
            .toList();
      }

      // Filter by completion status
      if (event.showCompleted != null) {
        filtered = filtered
            .where((task) => task.isCompleted == event.showCompleted)
            .toList();
      }

      emit(TaskLoaded(tasks: currentState.tasks, filteredTasks: filtered));
    }
  }

  @override
  Future<void> close() {
    _tasksSubscription?.cancel();
    return super.close();
  }
}
