import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'package:front_flutter/models/task.dart';


class TaskService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Uuid uuid = Uuid();

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
  Future<void> addTask(String title, String description, String author) async {
    print('Adding task author: $author');
    Task newTask = Task(
        id: uuid.v4(),
        title: title,
        description: description,
        author: author,
        status: 'todo',
        date: DateTime.now()
    );
    print('Adding task: ${newTask.toMap()}');
    try {
      await _firestore.collection('task').doc(newTask.id).set(newTask.toMap());  // Assuming Task has a toMap method
    } catch (e) {
      print("Error adding task: $e");
      throw e;
    }
  }

  getTaskByAuthor(String email) async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('task').where('author', isEqualTo: email).get();
      return snapshot.docs.map((doc) {
        return Task.fromFirestore(doc);
      }).toList();
    } catch (e) {
      print("Error fetching tasks: $e");
      rethrow;  // Propagate the error
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

  Stream<List<Task>> streamTasks() {
    return _firestore.collection('task').orderBy('date', descending: true).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Task.fromFirestore(doc);
      }).toList();
    });
  }

  Stream<List<Task>> streamTasksByAuthor(String author) {
    return _firestore.collection('task')
        .where('author', isEqualTo: author)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Task.fromFirestore(doc);
      }).toList();
    });
  }
}
