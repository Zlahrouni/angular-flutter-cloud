import 'package:flutter/material.dart';
import '../models/task.dart';
import '../services/task_service.dart';

class EditTaskPage extends StatefulWidget {
  final Task task;

  const EditTaskPage({super.key, required this.task});

  @override
  State<EditTaskPage> createState() => _EditTaskPageState();
}

class _EditTaskPageState extends State<EditTaskPage> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  final TaskService _taskService = TaskService();
  late String _selectedStatus;
  final List<String> _statuses = ['todo', 'pending', 'done'];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task.title);
    _descriptionController =
        TextEditingController(text: widget.task.description);
    _selectedStatus = widget.task.status;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.deepPurple[800],
        title: const Text(
          'Edit Task',
          style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 8,
                shadowColor: Colors.black26,
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      TextField(
                        controller: _titleController,
                        decoration: InputDecoration(
                          labelText: 'Title',
                          labelStyle: TextStyle(color: Colors.deepPurple[700]),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.deepPurple[700]!),
                          ),
                          prefixIcon: Icon(
                            Icons.title,
                            color: Colors.deepPurple[300],
                          ),
                        ),
                        style: TextStyle(color: Colors.grey[800]),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _descriptionController,
                        maxLines: null,
                        keyboardType: TextInputType.multiline,
                        decoration: InputDecoration(
                          labelText: 'Description',
                          labelStyle: TextStyle(color: Colors.deepPurple[700]),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.deepPurple[700]!),
                          ),
                          prefixIcon: Icon(
                            Icons.description,
                            color: Colors.deepPurple[300],
                          ),
                          alignLabelWithHint: true,
                        ),
                        style: TextStyle(
                          color: Colors.grey[800],
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 20),
                      DropdownButtonFormField<String>(
                        value: _selectedStatus,
                        items: _statuses.map((String status) {
                          return DropdownMenuItem<String>(
                            value: status,
                            child: Text(
                              status.toUpperCase(),
                              style: TextStyle(color: Colors.grey[800]),
                            ),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          setState(() {
                            _selectedStatus = newValue!;
                          });
                        },
                        decoration: InputDecoration(
                          labelText: 'Status',
                          labelStyle: TextStyle(color: Colors.deepPurple[700]),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.deepPurple[700]!),
                          ),
                          prefixIcon: Icon(
                            Icons.check_circle_outline,
                            color: Colors.deepPurple[300],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () async {
                  final title = _titleController.text.trim();
                  final description = _descriptionController.text.trim();

                  if (title.isNotEmpty && description.isNotEmpty) {
                    // Create an updated task object
                    Task updatedTask = Task(
                      id: widget.task.id,
                      title: title,
                      description: description,
                      author: widget.task.author,
                      status: _selectedStatus,
                      date: widget.task.date,
                    );

                    try {
                      await _taskService.updateTask(widget.task.id, updatedTask);
                      Navigator.pop(context, updatedTask);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Task updated successfully!',
                            style: TextStyle(color: Colors.white),
                          ),
                          backgroundColor: Colors.deepPurple[500],
                        ),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Failed to update task: ${e.toString()}',
                            style: TextStyle(color: Colors.white),
                          ),
                          backgroundColor: Colors.red[400],
                        ),
                      );
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Please fill in all fields',
                          style: TextStyle(color: Colors.white),
                        ),
                        backgroundColor: Colors.red[400],
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple[500],
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Update Task',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}