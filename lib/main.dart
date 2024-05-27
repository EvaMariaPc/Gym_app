import 'package:flutter/material.dart';
import 'package:gym_tracker/screens/calendar_screen.dart';
import 'screens/login_screen.dart';
// Import your CalendarScreen
import 'screens/todo_screen.dart'; // Import your ToDoScreen

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginScreen(),
        '/calendar': (context) => const CalendarScreen(),
        '/todo': (context) => const ToDoScreen(selectedDay: null),
      },
    );
  }
}
