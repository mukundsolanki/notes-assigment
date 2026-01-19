import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/task_model.dart';
import '../../domain/entities/task_entity.dart';

class TaskRepository {
  final FirebaseFirestore _firestore;
  static const String _tasksCollection = 'tasks';

  TaskRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  // Get tasks for a user (real-time stream)
  Stream<List<TaskModel>> getTasks(String userId) {
    return _firestore
        .collection(_tasksCollection)
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => TaskModel.fromJson(doc.data(), doc.id))
              .toList()
            ..sort((a, b) => a.dueDate.compareTo(b.dueDate)); // Sort in memory instead of query
        });
  }

  // Create a new task
  Future<void> createTask(TaskEntity task) async {
    try {
      final taskModel = TaskModel.fromEntity(task);
      await _firestore
          .collection(_tasksCollection)
          .doc(task.id)
          .set(taskModel.toJson());
    } catch (e) {
      throw Exception('Failed to create task: $e');
    }
  }

  // Update an existing task
  Future<void> updateTask(TaskEntity task) async {
    try {
      final taskModel = TaskModel.fromEntity(task);
      await _firestore
          .collection(_tasksCollection)
          .doc(task.id)
          .update(taskModel.toJson());
    } catch (e) {
      throw Exception('Failed to update task: $e');
    }
  }

  // Delete a task
  Future<void> deleteTask(String taskId) async {
    try {
      await _firestore.collection(_tasksCollection).doc(taskId).delete();
    } catch (e) {
      throw Exception('Failed to delete task: $e');
    }
  }

  // Toggle task completion
  Future<void> toggleTaskCompletion(String taskId, bool isCompleted) async {
    try {
      await _firestore.collection(_tasksCollection).doc(taskId).update({
        'isCompleted': !isCompleted,
      });
    } catch (e) {
      throw Exception('Failed to toggle task completion: $e');
    }
  }
}
