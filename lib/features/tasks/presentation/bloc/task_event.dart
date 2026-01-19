part of 'task_bloc.dart';

abstract class TaskEvent extends Equatable {
  const TaskEvent();

  @override
  List<Object?> get props => [];
}

class LoadTasks extends TaskEvent {
  final String userId;

  const LoadTasks({required this.userId});

  @override
  List<Object?> get props => [userId];
}

class SearchTasks extends TaskEvent {
  final String query;

  const SearchTasks({required this.query});

  @override
  List<Object?> get props => [query];
}

class TaskErrorOccurred extends TaskEvent {
  final String message;

  const TaskErrorOccurred({required this.message});

  @override
  List<Object?> get props => [message];
}

class CreateTask extends TaskEvent {
  final TaskEntity task;

  const CreateTask({required this.task});

  @override
  List<Object?> get props => [task];
}

class UpdateTask extends TaskEvent {
  final TaskEntity task;

  const UpdateTask({required this.task});

  @override
  List<Object?> get props => [task];
}

class DeleteTask extends TaskEvent {
  final String taskId;

  const DeleteTask({required this.taskId});

  @override
  List<Object?> get props => [taskId];
}

class ToggleTaskCompletion extends TaskEvent {
  final String taskId;
  final bool isCompleted;

  const ToggleTaskCompletion({required this.taskId, required this.isCompleted});

  @override
  List<Object?> get props => [taskId, isCompleted];
}

class FilterTasks extends TaskEvent {
  final TaskPriority? priority;
  final bool? showCompleted;

  const FilterTasks({this.priority, this.showCompleted});

  @override
  List<Object?> get props => [priority, showCompleted];
}

class TasksUpdated extends TaskEvent {
  final List<TaskEntity> tasks;

  const TasksUpdated({required this.tasks});

  @override
  List<Object?> get props => [tasks];
}
