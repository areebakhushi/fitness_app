import 'package:flutter/material.dart';
import '../services/ai_service.dart';
import '../models/models.dart';

class AIViewModel extends ChangeNotifier {
  AIService? _aiService;
  Map<String, dynamic>? _generatedResponse;
  bool _isLoading = false;
  String? _errorMessage;

  Map<String, dynamic>? _insights;
  bool _isFetchingInsights = false;

  List<dynamic>? get generatedPlans => _generatedResponse?['plans'];
  List<dynamic>? get generatedDiet => _generatedResponse?['diet'];
  List<dynamic>? get generatedTips => _generatedResponse?['tips'];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Map<String, dynamic>? get insights => _insights;
  bool get isFetchingInsights => _isFetchingInsights;

  void init(String apiKey) {
    if (_aiService != null) return;
    _aiService = AIService(apiKey);
  }

  Future<void> fetchInsights(UserProfile profile, List<WorkoutLog> logs) async {
    if (_aiService == null) return;
    _isFetchingInsights = true;
    notifyListeners();

    try {
      _insights = await _aiService!.getInsights(profile: profile, logs: logs);
    } catch (e) {
      debugPrint('Error fetching insights: $e');
    } finally {
      _isFetchingInsights = false;
      notifyListeners();
    }
  }

  Future<void> generatePlan({
    required String goal,
    required double weight,
    required double height,
    required String gender,
    required List<String> preferredDays,
    required String timeframe,
  }) async {
    if (_aiService == null) return;
    if (preferredDays.isEmpty) {
      _errorMessage = 'Please select at least one workout day.';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _generatedResponse = null;
    _errorMessage = null;
    notifyListeners();

    try {
      _generatedResponse = await _aiService!.generateWorkoutPlan(
        goal: goal,
        weight: weight,
        height: height,
        gender: gender,
        preferredDays: preferredDays,
        timeframe: timeframe,
      );
    } catch (e) {
      _errorMessage = 'AI Engine Error: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> commitFullArchitecture({
    required String userId,
    required UserProfile profile,
    required String newGoal,
    required List<Exercise> library,
    required Function(String, String, String, List<RoutineExercise>) addRoutine,
    required Future<String> Function(String, String, String) addCustomExercise,
    required Future<void> Function(UserProfile) saveProfile,
    required VoidCallback onSuccess,
  }) async {
    if (_generatedResponse == null || generatedPlans == null) {
      _errorMessage = 'No architecture found to commit.';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // 1. Process and save each routine
      for (var plan in generatedPlans!) {
        final List<RoutineExercise> routineExercises = [];
        final List<dynamic> exercisesData = plan['exercises'] ?? [];

        for (var ex in exercisesData) {
          final String exName = ex['name']?.toString() ?? 'Unnamed Movement';
          final String muscleGroup = ex['muscleGroup']?.toString() ?? 'General';
          final String description = ex['description']?.toString() ?? 'No description provided.';

          // Match against existing exercise library
          final match = library.firstWhere(
            (e) => e.name.toLowerCase() == exName.toLowerCase(),
            orElse: () => Exercise(
              id: '',
              name: '',
              muscleGroup: '',
              description: '',
            ),
          );

          // If not found in library, create a custom exercise
          String exerciseId = match.id;
          if (exerciseId.isEmpty) {
            try {
              exerciseId = await addCustomExercise(exName, muscleGroup, description);
            } catch (e) {
              debugPrint('Failed to add custom exercise: $exName, error: $e');
              exerciseId = exName; // fallback
            }
          }

          // Robust parsing of sets and reps
          int sets = int.tryParse(ex['sets']?.toString() ?? '3') ?? 3;
          int reps = int.tryParse(ex['reps']?.toString() ?? '10') ?? 10;

          routineExercises.add(RoutineExercise(
            exerciseId: exerciseId,
            sets: sets,
            reps: reps,
          ));
        }

        if (routineExercises.isNotEmpty) {
          await addRoutine(
            userId,
            plan['routineName']?.toString() ?? 'AI Routine',
            plan['day']?.toString() ?? 'Monday',
            routineExercises,
          );
        }
      }

      // 2. Update user profile with architecture metadata
      final updatedProfile = UserProfile(
        uid: profile.uid,
        name: profile.name,
        weight: profile.weight,
        height: profile.height,
        goal: newGoal,
        gender: profile.gender,
        streak: profile.streak,
        achievements: profile.achievements,
        diet: List<String>.from(generatedDiet ?? profile.diet),
        tips: List<String>.from(generatedTips ?? profile.tips),
        onboardingCompleted: true,
      );
      
      await saveProfile(updatedProfile);

      // 3. Clear generated data and notify success
      _generatedResponse = null;
      _isLoading = false;
      notifyListeners();
      onSuccess();
    } catch (e) {
      _errorMessage = 'Commit Failed: ${e.toString().replaceFirst('Exception: ', '')}';
      _isLoading = false;
      debugPrint('Architecture Commit Error: $e');
      notifyListeners();
    }
  }

  void reset() {
    _generatedResponse = null;
    _errorMessage = null;
    notifyListeners();
  }
}
