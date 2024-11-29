import 'package:flutter/material.dart';
import '../models/task.dart';
import '../services/auth_service.dart';
import '../services/task_service.dart';

class AddTaskPage extends StatefulWidget {
  final VoidCallback onTaskAdded;

  const AddTaskPage({super.key, required this.onTaskAdded});

  @override
  State<AddTaskPage> createState() => _AddTaskPageState();
}

class _AddTaskPageState extends State<AddTaskPage> with SingleTickerProviderStateMixin {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TaskService _taskService = TaskService();
  final AuthService authService = AuthService();
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                Text(
                  'Create Your Next Task!',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple[800],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
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
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () async {
                    if (_titleController.text.isNotEmpty) {
                      await _taskService.addTask(
                          _titleController.text,
                          _descriptionController.text,
                          authService.currentUser?.email ?? ''
                      );
                      widget.onTaskAdded(); // Notify parent widget

                      // Clear fields and show a snackbar
                      _titleController.clear();
                      _descriptionController.clear();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Task added successfully!',
                            style: TextStyle(color: Colors.white),
                          ),
                          backgroundColor: Colors.deepPurple[500],
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Title cannot be empty',
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
                    'Add Task',
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
      ),
    );
  }
}