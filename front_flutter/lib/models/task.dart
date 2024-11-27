import 'package:cloud_firestore/cloud_firestore.dart';

class Task {
  final String id;
  final String title;
  final String description;
  late String status;
  late DateTime date;

  Task({required this.id, required this.title, required this.description, this.status = 'todo', required this.date});

  // Create a Task object from Firestore data
  factory Task.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return Task(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      status: data['status'] ?? 'Todo',
      date: (data['date'] != null) ? (data['date'] as Timestamp).toDate() : DateTime.now(),
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'status': status,
      'date': date,
    };
  }
}
