// Update the SlidableAction in TaskListPage to update the task in the list
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../models/task.dart';
import '../services/task_service.dart';

class TaskListPage extends StatefulWidget {
  const TaskListPage({super.key});

  @override
  State<TaskListPage> createState() => _TaskListPageState();
}

class _TaskListPageState extends State<TaskListPage> {
  final TaskService taskService = TaskService();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Task>>(
      future: taskService.getTasks(),  // Fetch tasks
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("No tasks available"));
        }

        return ListView.builder(
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            final task = snapshot.data![index];
            String nextStatutLabel;
            if (task.status == 'pending') {
              nextStatutLabel = 'end';
            } else if (task.status == 'todo') {
              nextStatutLabel = 'pending';
            } else {
              nextStatutLabel = '';
            }

            // Debug print statements
            print('Task: ${task.title}, Status: ${task.status}, NextStatutLabel: $nextStatutLabel');

            return Slidable(
              key: ValueKey(task.id),
              startActionPane: ActionPane(
                  motion: const ScrollMotion(),
                  children: [
                    SlidableAction(
                        onPressed: (context) async {

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
                        );
                        if (nextStatutLabel == 'end') {
                          updatedTask.status = 'done';
                        } else {
                          updatedTask.status = 'pending';
                        }

                        Task returnedTask = await taskService.updateTask(task.id, updatedTask);
                        setState(() {
                          snapshot.data![index] = returnedTask;
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
                        snapshot.data!.removeAt(index);
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
                  subtitle: Text(task.description),
                ),
              ),
            );
          },
        );
      },
    );
  }
}