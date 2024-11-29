import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:front_flutter/screen/task_details_page.dart';

import '../models/task.dart';
import '../services/task_service.dart';
import '../services/auth_service.dart';
import 'edit_task_page.dart';

class TaskListPage extends StatefulWidget {
  final String? byAuthor;

  const TaskListPage({super.key, required this.byAuthor});

  @override
  State<TaskListPage> createState() => _TaskListPageState();
}

class _TaskListPageState extends State<TaskListPage> with SingleTickerProviderStateMixin {
  final TaskService taskService = TaskService();
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
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: StreamBuilder<List<Task>>(
        stream: widget.byAuthor != null
            ? taskService.streamTasksByAuthor(widget.byAuthor!)
            : taskService.streamTasks(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                color: Colors.deepPurple[300],
              ),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                "Error loading tasks",
                style: TextStyle(color: Colors.red[300]),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.checklist_rounded,
                    size: 100,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "No tasks available",
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            );
          } else {
            final tasks = snapshot.data!;
            final currentUserEmail = authService.currentUser?.email;

            return ListView.builder(
              physics: const BouncingScrollPhysics(),
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final task = tasks[index];

                // Status color mapping
                final statusColorMap = {
                  'pending': Colors.orange[300],
                  'todo': Colors.blue[300],
                  'done': Colors.green[300],
                };
                final statusColor = statusColorMap[task.status] ?? Colors.grey;

                // Next status logic
                String nextStatusLabel = '';
                if (task.status == 'pending') {
                  nextStatusLabel = 'end';
                } else if (task.status == 'todo') {
                  nextStatusLabel = 'pending';
                }

                return FadeTransition(
                  opacity: _animation,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 4,
                      shadowColor: Colors.black26,
                      child: Slidable(
                        key: ValueKey(task.id),
                        startActionPane: task.author == currentUserEmail
                            ? ActionPane(
                          motion: const ScrollMotion(),
                          children: [
                            SlidableAction(
                              onPressed: (context) => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EditTaskPage(task: task),
                                ),
                              ),
                              backgroundColor: Colors.grey[600]!,
                              foregroundColor: Colors.white,
                              icon: Icons.edit,
                              label: 'Edit',
                            )
                          ],
                        )
                            : null,
                        endActionPane: task.author == currentUserEmail
                            ? ActionPane(
                          motion: const ScrollMotion(),
                          children: [
                            if (nextStatusLabel.isNotEmpty)
                              SlidableAction(
                                onPressed: (context) async {
                                  Task updatedTask = Task(
                                    id: task.id,
                                    title: task.title,
                                    description: task.description,
                                    author: task.author,
                                    date: task.date,
                                  );
                                  updatedTask.status = nextStatusLabel == 'end' ? 'done' : 'pending';

                                  Task returnedTask = await taskService.updateTask(task.id, updatedTask);
                                  setState(() {
                                    tasks[index] = returnedTask;
                                  });
                                },
                                backgroundColor: nextStatusLabel == 'end' ? Colors.green : Colors.blue,
                                foregroundColor: Colors.white,
                                icon: nextStatusLabel == 'end' ? Icons.done : Icons.pending_actions,
                                label: nextStatusLabel,
                              ),
                            SlidableAction(
                              onPressed: (context) {
                                taskService.deleteTask(task.id);
                                setState(() {
                                  tasks.removeAt(index);
                                });
                              },
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              icon: Icons.delete,
                              label: 'Delete',
                            ),
                          ],
                        )
                            : null,
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TaskDetailsPage(task: task),
                            ),
                          ),
                          title: Text(
                            task.title,
                            style: TextStyle(
                              color: Colors.deepPurple[800],
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 8),
                              Text(
                                task.description,
                                style: TextStyle(
                                  color: Colors.grey[700],
                                  overflow: TextOverflow.ellipsis,
                                ),
                                maxLines: 2,
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(
                                    Icons.person_outline,
                                    size: 16,
                                    color: Colors.grey[600],
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    task.author.isEmpty
                                        ? "Unknown"
                                        : task.author == currentUserEmail
                                        ? 'You'
                                        : task.author,
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(
                                    Icons.calendar_today,
                                    size: 16,
                                    color: Colors.grey[600],
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    DateFormat("EEE. dd MMM yy - HH:mm").format(task.date),
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          trailing: Container(
                            width: 10,
                            decoration: BoxDecoration(
                              color: statusColor,
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}