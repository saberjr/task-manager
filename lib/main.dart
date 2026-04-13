// main.dart
// This is where the app starts.
// We check if the user is already logged in:
//   - If yes  → go straight to the Task List screen
//   - If no   → show the Login screen

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/auth_service.dart';
import 'services/api_service.dart';
import 'screens/login_screen.dart';
import 'screens/task_list_screen.dart';

void main() async {
  // Required before using any async code before runApp
  WidgetsFlutterBinding.ensureInitialized();

  // Create the auth service and load any saved token from the device
  final authService = AuthService();
  await authService.loadToken();

  runApp(
    // MultiProvider lets us inject services into the widget tree
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => authService),
        // ApiService depends on AuthService, so we pass it in
        ProxyProvider<AuthService, ApiService>(
          update: (_, auth, __) => ApiService(auth),
        ),
      ],
      child: const TaskManagerApp(),
    ),
  );
}

class TaskManagerApp extends StatelessWidget {
  const TaskManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Task Manager',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6366F1), // Indigo
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            minimumSize: const Size.fromHeight(50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
      // Choose the starting screen based on login state
      home: Consumer<AuthService>(
        builder: (context, auth, _) {
          if (auth.isLoggedIn) {
            return const TaskListScreen();
          } else {
            return const LoginScreen();
          }
        },
      ),
    );
  }
}
