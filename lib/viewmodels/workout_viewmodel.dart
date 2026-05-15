import 'package:flutter/material.dart';
import 'dart:async';
import '../models/models.dart';
import '../services/firebase_service.dart';

class WorkoutViewModel extends ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  List<Exercise> _exercises = [];
  List<Routine> _routines = [];
  List<WorkoutLog> _workoutLogs = [];
  bool _isLoading = true;
  String? _userId;

  StreamSubscription? _exerciseSub;
  StreamSubscription? _routineSub;
  StreamSubscription? _logSub;

  List<Exercise> get exercises => _exercises;
  List<Routine> get routines => _routines;
  List<WorkoutLog> get workoutLogs => _workoutLogs;
  bool get isLoading => _isLoading;

  void init(String userId) {
    if (_userId == userId) return;
    _userId = userId;
    _isLoading = true;

    _exerciseSub?.cancel();
    _routineSub?.cancel();
    _logSub?.cancel();

    _exerciseSub = _firebaseService.getExercises().listen((data) {
      _exercises = data;
      notifyListeners();
    });

    _routineSub = _firebaseService.getRoutines(userId).listen((data) {
      _routines = data;
      notifyListeners();
    });

    _logSub = _firebaseService.getWorkoutLogs(userId).listen((data) {
      // Sort logs by date descending in memory
      data.sort((a, b) => b.completedAt.compareTo(a.completedAt));
      _workoutLogs = data;
      _isLoading = false;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _exerciseSub?.cancel();
    _routineSub?.cancel();
    _logSub?.cancel();
    super.dispose();
  }

  Future<void> createRoutine(String userId, String name, String day, List<RoutineExercise> exercises) async {
    await _firebaseService.addRoutine(userId, name, day, exercises);
  }

  Future<void> logWorkout({
    required String userId,
    required String routineId,
    required String routineName,
    required int duration,
    required List<LoggedExercise> exercises,
  }) async {
    await _firebaseService.addWorkoutLog(
      userId: userId,
      routineId: routineId,
      routineName: routineName,
      duration: duration,
      exercises: exercises,
    );
  }

  Future<String> addCustomExercise(String userId, String name, String muscleGroup, String description) async {
    return await _firebaseService.addExercise(
      userId: userId,
      name: name,
      muscleGroup: muscleGroup,
      description: description,
    );
  }
}
