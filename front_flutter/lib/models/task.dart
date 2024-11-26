import 'package:cloud_firestore/cloud_firestore.dart';

class Task {
  final String id;
  final String title;
  final String description;
  late String status;

  Task({required this.id, required this.title, required this.description, this.status = 'todo'});

  // Create a Task object from Firestore data
  factory Task.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return Task(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      status: data['status'] ?? 'Todo',
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'status': status
    };
  }
}
