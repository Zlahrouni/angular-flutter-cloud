import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';

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
    return StreamBuilder<List<Task>>(
      stream: widget.byAuthor != null ? taskService.streamTasksByAuthor(widget.byAuthor!) : taskService.streamTasks(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(child: Text("Error loading tasks"));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("No tasks available"));
        } else {
          final tasks = snapshot.data!;
          final currentUserEmail = authService.currentUser?.email;

          return ListView.builder(
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
              String nextStatutLabel;
              Color statusColor;

              if (task.status == 'pending') {
                nextStatutLabel = 'end';
                statusColor = Colors.yellow;
              } else if (task.status == 'todo') {
                nextStatutLabel = 'pending';
                statusColor = Colors.blue;
              } else {
                nextStatutLabel = '';
                statusColor = Colors.green;
              }

              return FadeTransition(
                opacity: _animation,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  child: Card(
                    elevation: 4,
                    child: Slidable(
                      key: ValueKey(task.id),
                      startActionPane: task.author == currentUserEmail ? ActionPane(
                          motion: const ScrollMotion(),
                          children: [
                            SlidableAction(
                              onPressed: (context) async {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => EditTaskPage(task: task),
                                  ),
                                );
                              },
                              backgroundColor: Colors.grey,
                              icon: Icons.edit,
                            )
                          ]) : null,
                      endActionPane: task.author == currentUserEmail ? ActionPane(
                        motion: const ScrollMotion(),
                        children: [
                          if (nextStatutLabel.isNotEmpty)
                            SlidableAction(
                              onPressed: (context) async {
                                Task updatedTask = Task(
                                  id: task.id,
                                  title: task.title,
                                  description: task.description,
                                  author: task.author,
                                  date: task.date,
                                );
                                if (nextStatutLabel == 'end') {
                                  updatedTask.status = 'done';
                                } else {
                                  updatedTask.status = 'pending';
                                }

                                Task returnedTask = await taskService.updateTask(task.id, updatedTask);
                                setState(() {
                                  tasks[index] = returnedTask;
                                });
                              },
                              backgroundColor: nextStatutLabel == 'end' ? Colors.green : Colors.blue,
                              foregroundColor: Colors.white,
                              icon: nextStatutLabel == 'end' ? Icons.done : Icons.pending_actions,
                              label: nextStatutLabel,
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
                      ) : null,
                      child: Container(
                        decoration: BoxDecoration(
                          color: task.author == currentUserEmail && widget.byAuthor == null ? Colors.lightBlueAccent  : Colors.white,
                          border: const Border(
                            bottom: BorderSide(
                              color: Colors.grey,
                              width: 1,
                            ),
                          ),
                        ),
                        child: ListTile(
                          title: Text(
                              task.title,
                              style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w800,
                              )),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                task.description.length > 40
                                    ? '${task.description.substring(0, 40)}...'
                                    : task.description,
                              ),
                              Text('Author: ${task.author.isEmpty ? "Unknown" : task.author == currentUserEmail ? 'You' : task.author}'),
                              Text('Date: ${DateFormat("EEE. dd MMM yy - HH:mm").format(task.date)}'),
                            ],
                          ),
                          trailing: Container(
                            width: 10,
                            color: statusColor,
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
    );
  }
}