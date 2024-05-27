import 'package:flutter/material.dart';
import 'package:gym_tracker/screens/todo_screen.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar'),
      ),
      body: TableCalendar(
        firstDay: DateTime.utc(2024, 1, 1), // Set a default first day
        lastDay: DateTime.utc(2025, 12, 31), // Set a default last day
        focusedDay: DateTime.now(), // Set focus to current day
        selectedDayPredicate: (day) => true, // Required parameter
        onDaySelected: (selectedDay, focusedDay) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ToDoScreen(selectedDay: selectedDay),
            ),
          );
        },
        // Other TableCalendar properties...
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Logout logic here
          Navigator.pushReplacementNamed(context, '/'); // Navigate to login screen
        },
        child: const Icon(Icons.logout),
      ),
    );
  }
}
