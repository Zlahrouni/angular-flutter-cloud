import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:front_flutter/screen/add_task_page.dart';
import 'package:front_flutter/screen/auth.dart';
import 'package:front_flutter/screen/register.dart';
import 'package:front_flutter/screen/task_list_page.dart';
import 'package:front_flutter/services/auth_service.dart';
import 'package:front_flutter/services/task_service.dart';

import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TaskMan',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.grey[100],
      ),
      home: const MyHomePage(title: 'TaskMan'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  final TaskService taskService = TaskService();
  final AuthService authService = AuthService();
  bool showLogin = true;
  int pagination = 0;
  late PageController _pageController = PageController(initialPage: pagination);
  late TabController paginationController = TabController(length: 3, initialIndex: pagination, vsync: this);

  void _onTaskAdded() {
    setState(() {
      pagination = 2;
      paginationController.animateTo(pagination);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(
          widget.title,
          style: TextStyle(
            color: Colors.deepPurple[800],
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        centerTitle: true,
        actions: [
          StreamBuilder<User?>(
            stream: authService.authStateChanges,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return IconButton(
                  icon: Icon(
                    Icons.logout,
                    color: Colors.deepPurple[800],
                  ),
                  onPressed: () async {
                    try {
                      await authService.logout();
                    } catch (e) {
                      print('Erreur de déconnexion: $e');
                    }
                  },
                  tooltip: 'Déconnexion',
                );
              } else {
                return IconButton(
                  icon: Icon(
                    Icons.account_circle,
                    color: Colors.deepPurple[800],
                  ),
                  onPressed: () {
                    // Navigation vers la page de profil ou de connexion
                  },
                );
              }
            },
          ),
        ],
      ),
      body: StreamBuilder<User?>(
        stream: authService.authStateChanges,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                color: Colors.deepPurple[300],
              ),
            );
          }
          if (snapshot.hasData) {
            return PageView(
              controller: _pageController,
              onPageChanged: (index) {
                pagination = index;
                paginationController.animateTo(index);
              },
              children: [
                TaskListPage(byAuthor: null),
                AddTaskPage(onTaskAdded: _onTaskAdded),
                TaskListPage(byAuthor: authService.currentUser?.email),
              ],
            );
          }

          return showLogin
              ? LoginScreen(
            onRegisterTap: () => setState(() => showLogin = false),
          )
              : RegisterScreen(
            onLoginTap: () => setState(() => showLogin = true),
          );
        },
      ),
      bottomNavigationBar: StreamBuilder<User?>(
        stream: authService.authStateChanges,
        builder: (context, snapshot) => snapshot.hasData
            ? ConvexAppBar(
          backgroundColor: Colors.deepPurple[500],
          color: Colors.white,
          activeColor: Colors.white,
          controller: paginationController,
          items: const [
            TabItem(icon: Icons.home, title: 'Home'),
            TabItem(icon: Icons.add, title: 'Add'),
            TabItem(icon: Icons.person, title: 'My tasks'),
          ],
          initialActiveIndex: 0,
          onTap: (int i) {
            pagination = i;
            _pageController.animateToPage(i,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut);
          },
        )
            : const SizedBox.shrink(),
      ),
    );
  }
}