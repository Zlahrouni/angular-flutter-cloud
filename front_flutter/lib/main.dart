import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:front_flutter/screen/add_task_page.dart';
import 'package:front_flutter/screen/task_list_page.dart';
import 'package:front_flutter/services/task_service.dart';

import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, // Use the generated configuration
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Homef Page'),
      routes: {
        'addTask': (context) => const AddTaskPage(),
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TaskService taskService = TaskService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () {
              // Navigate to profile page
            },
          ),
        ],
      ),
      body: const TaskListPage(),
      bottomNavigationBar: ConvexAppBar(
        backgroundColor: Colors.grey,

        items: const [
          TabItem(icon: Icons.add, title: 'Add'),
        ],
        initialActiveIndex: 0, //optional, default as 0
        onTap: (int i) => {
          if (i == 0) {
            Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddTaskPage()),
          )
          }
        }
      )
    );
  }
}