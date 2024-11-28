import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:front_flutter/screen/task_details_page.dart';

import '../models/task.dart';
import '../services/task_service.dart';
import 'add_task_page.dart';
import 'edit_task_page.dart';

class TaskListPage extends StatefulWidget {
  const TaskListPage({super.key});

  @override
  State<TaskListPage> createState() => _TaskListPageState();
}

class _TaskListPageState extends State<TaskListPage> {
  final TaskService taskService = TaskService();
  List<Task>? tasks;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task List'),
      ),
      body: StreamBuilder<List<Task>>(
        stream: taskService.streamTasks(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text("Error loading tasks"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No tasks available"));
          } else {
            final tasks = snapshot.data!;
            return ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final task = tasks[index];
                String nextStatutLabel;
                if (task.status == 'pending') {
                  nextStatutLabel = 'end';
                } else if (task.status == 'todo') {
                  nextStatutLabel = 'pending';
                } else {
                  nextStatutLabel = '';
                }

                return Slidable(
                  key: ValueKey(task.id),
                  startActionPane: ActionPane(
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
                      ]),
                  endActionPane: ActionPane(
                    motion: const ScrollMotion(),
                    children: [
                      if (nextStatutLabel.isNotEmpty)
                        SlidableAction(
                          onPressed: (context) async {
                            Task updatedTask = Task(
                              id: task.id,
                              title: task.title,
                              description: task.description,
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
                  ),
                  child: Container(
                    color: nextStatutLabel == '' ? Colors.red.shade100 : Colors.transparent,
                    child: ListTile(
                      title: Text(task.title),
                      subtitle: Text(
                        task.description,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TaskDetailsPage(task: task),
                          ),
                        );
                      },
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