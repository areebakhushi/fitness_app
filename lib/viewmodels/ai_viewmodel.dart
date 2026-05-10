import 'package:flutter/material.dart';
import '../services/ai_service.dart';
import '../models/models.dart';

class AIViewModel extends ChangeNotifier {
  AIService? _aiService;
  List<dynamic>? _generatedPlans;
  bool _isLoading = false;
  String? _errorMessage;

  List<dynamic>? get generatedPlans => _generatedPlans;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void init(String apiKey) {
    if (_aiService != null) return;
    _aiService = AIService(apiKey);
  }

  Future<void> generatePlan({
    required String goal,
    required double weight,
    required double height,
    required List<String> preferredDays,
  }) async {
    if (_aiService == null) return;
    if (preferredDays.isEmpty) {
      _errorMessage = 'Please select at least one workout day.';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _generatedPlans = null;
    _errorMessage = null;
    notifyListeners();

    try {
      _generatedPlans = await _aiService!.generateWorkoutPlan(
        goal: goal,
        weight: weight,
        height: height,
        preferredDays: preferredDays,
      );
    } catch (e) {
      _errorMessage = e.toString().contains('API_KEY_INVALID') 
          ? 'Invalid API Key. Please check your Google AI Studio key.'
          : 'AI Error: $e';
      debugPrint('AI Generation Error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> commitRoutine({
    required dynamic plan,
    required String userId,
    required List<Exercise> library,
    required Function(String, String, String, List<RoutineExercise>) addRoutine,
    required Future<String> Function(String, String, String) addCustomExercise,
  }) async {
    final List<RoutineExercise> routineExercises = [];

    for (var ex in plan['exercises']) {
      final match = library.firstWhere(
            (e) => e.name.toLowerCase() == ex['name'].toString().toLowerCase(),
        orElse: () => Exercise(id: '', name: '', muscleGroup: ''),
      );

      String exerciseId = match.id;
      if (exerciseId.isEmpty) {
        exerciseId = await addCustomExercise(
          ex['name'].toString(),
          ex['muscleGroup'].toString(),
          ex['description']?.toString() ?? '',
        );
      }

      routineExercises.add(RoutineExercise(
        exerciseId: exerciseId,
        sets: (ex['sets'] as num).toInt(),
        reps: (ex['reps'] as num).toInt(),
      ));
    }

    await addRoutine(
      userId,
      plan['routineName'].toString(),
      plan['day'].toString(),
      routineExercises,
    );
  }

  void reset() {
    _generatedPlans = null;
    _errorMessage = null;
    notifyListeners();
  }
}
