import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:front_flutter/models/task.dart';


class TaskService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fetch tasks from Firestore
  Future<List<Task>> getTasks() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('task').get();
      return snapshot.docs.map((doc) {
        return Task.fromFirestore(doc);  // Assuming Task has a fromFirestore method
      }).toList();
    } catch (e) {
      print("Error fetching tasks: $e");
      throw e;  // Propagate the error
    }
  }

  // Add a new task to Firestore
  Future<void> addTask(Task task) async {
    try {
      await _firestore.collection('tasks').add(task.toMap());  // Assuming Task has a toMap method
    } catch (e) {
      print("Error adding task: $e");
      throw e;
    }
  }

  // Update the updateTask method in TaskService to return the updated Task
  Future<Task> updateTask(String taskId, Task task) async {
    try {
      await _firestore.collection('task').doc(taskId).update(task.toMap());
      return task;
    } catch (e) {
      print("Error updating task: $e");
      throw e;
    }
  }

  // Delete a task
  Future<bool> deleteTask(String taskId) async {
    try {
      await _firestore.collection('task').doc(taskId).delete();
      return true;
    } catch (e) {
      print("Error deleting task: $e");
      throw e;
    }
  }
}
