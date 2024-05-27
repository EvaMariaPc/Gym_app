import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ToDoScreen extends StatefulWidget {
  final DateTime? selectedDay;

  const ToDoScreen({super.key, this.selectedDay});

  @override
  // ignore: library_private_types_in_public_api
  _ToDoScreenState createState() => _ToDoScreenState();
}

class _ToDoScreenState extends State<ToDoScreen> {
  List<Map<String, dynamic>> _workouts = [];
  double _progress = 0.0;
  bool _isDayCompleted = false;

  final List<String> _exerciseList = [
    'Incline dumbbell press',
    'Incline machine press',
    'Cable chest fly',
    'Overhead triceps extensions',
    'Triceps extensions',
    'Cable lateral raises',
    "Lat pulldown",
    'Pullups',
    'Machine row',
    'Lat row',
    'Scott curl',
    'One hand cable curl',
    'Cable rear fly',
    'Chinups',
    'Low row machine'
  ];

  @override
  void initState() {
    super.initState();
    _loadProgress();
    _loadWorkouts();
    _loadDayCompletionStatus();
  }

  void _addWorkout(String exercise, int sets, int reps, double weights, int duration) {
    setState(() {
      _workouts.add({
        'name': exercise,
        'reps': reps,
        'sets': sets,
        'weights': weights,
        'duration': duration,
        'completed': false,
      });
      _updateProgress();
      _saveWorkouts();
    });
  }

  void _toggleCompletion(int index) {
    setState(() {
      _workouts[index]['completed'] = !_workouts[index]['completed'];
      _updateProgress();
      _saveWorkouts();
    });
  }

  void _updateProgress() {
    int totalExercises = _workouts.length;
    int completedExercises = _workouts.where((workout) => workout['completed']).length;
    setState(() {
      _progress = totalExercises > 0 ? completedExercises / totalExercises : 0.0;
    });
  }

  void _saveProgress() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String formattedDate = "${widget.selectedDay!.year}-${widget.selectedDay!.month}-${widget.selectedDay!.day}";
    await prefs.setDouble(formattedDate, _progress);
  }

  void _loadProgress() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String formattedDate = "${widget.selectedDay!.year}-${widget.selectedDay!.month}-${widget.selectedDay!.day}";
    setState(() {
      _progress = prefs.getDouble(formattedDate) ?? 0.0;
    });
  }

  void _saveWorkouts() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String formattedDate = "${widget.selectedDay!.year}-${widget.selectedDay!.month}-${widget.selectedDay!.day}";
    String workoutsJson = jsonEncode(_workouts);
    await prefs.setString('${formattedDate}_workouts', workoutsJson);
  }

  void _loadWorkouts() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String formattedDate = "${widget.selectedDay!.year}-${widget.selectedDay!.month}-${widget.selectedDay!.day}";
    String? workoutsJson = prefs.getString('${formattedDate}_workouts');
    if (workoutsJson != null) {
      setState(() {
        _workouts = List<Map<String, dynamic>>.from(jsonDecode(workoutsJson));
        _updateProgress();
      });
    }
  }

  void _saveDayCompletionStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String formattedDate = "${widget.selectedDay!.year}-${widget.selectedDay!.month}-${widget.selectedDay!.day}";
    await prefs.setBool('${formattedDate}_completed', true);
  }

  void _loadDayCompletionStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String formattedDate = "${widget.selectedDay!.year}-${widget.selectedDay!.month}-${widget.selectedDay!.day}";
    setState(() {
      _isDayCompleted = prefs.getBool('${formattedDate}_completed') ?? false;
    });
  }

  Future<void> _showExerciseDialog() async {
    String selectedExercise = _exerciseList[0];
    int sets = 0;
    int reps = 0;
    double weights = 0.0;
    int duration = 0;

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Exercise'),
          content: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                DropdownButtonFormField<String>(
                  value: selectedExercise,
                  onChanged: (String? value) {
                    setState(() {
                      selectedExercise = value!;
                    });
                  },
                  items: _exerciseList
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
                TextFormField(
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Sets'),
                  onChanged: (value) {
                    sets = int.tryParse(value) ?? 0;
                  },
                ),
                TextFormField(
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Reps'),
                  onChanged: (value) {
                    reps = int.tryParse(value) ?? 0;
                  },
                ),
                TextFormField(
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Weights'),
                  onChanged: (value) {
                    weights = double.tryParse(value) ?? 0.0;
                  },
                ),
                TextFormField(
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Duration (mins)'),
                  onChanged: (value) {
                    duration = int.tryParse(value) ?? 0;
                  },
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Add'),
              onPressed: () {
                _addWorkout(selectedExercise, sets, reps, weights, duration);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('To-Do List'),
      ),
      body: Column(
        children: <Widget>[
          CircularPercentIndicator(
            radius: 60.0,
            lineWidth: 5.0,
            percent: _progress,
            center: Text('${(_progress * 100).toStringAsFixed(1)}%'),
            progressColor: Colors.green,
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _workouts.length,
              itemBuilder: (context, index) {
                final workout = _workouts[index];
                return ListTile(
                  title: Text(workout['name']),
                  subtitle: Text('Sets: ${workout['sets']}, Reps: ${workout['reps']}, Weights: ${workout['weights']} kg, Duration: ${workout['duration']} mins'),
                  trailing: Checkbox(
                    value: workout['completed'],
                    onChanged: (bool? value) {
                      _toggleCompletion(index);
                    },
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {
                _saveProgress();
                _saveDayCompletionStatus();
                setState(() {
                  _isDayCompleted = true;
                });
              },
              child: const Text("I'm Done for Today"),
            ),
          ),
        ],
      ),
      floatingActionButton: _isDayCompleted
          ? null
          : FloatingActionButton(
              onPressed: _showExerciseDialog,
              tooltip: 'Add Workout',
              child: const Icon(Icons.add),
            ),
    );
  }
}
