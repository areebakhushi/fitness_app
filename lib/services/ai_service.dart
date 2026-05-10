import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class AIService {
  late GenerativeModel _model;
  final String _apiKey;

  AIService(this._apiKey) {
    _model = _createModel('gemini-1.5-flash');
  }

  GenerativeModel _createModel(String modelName) {
    return GenerativeModel(
      model: modelName,
      apiKey: _apiKey,
      safetySettings: [
        SafetySetting(HarmCategory.harassment, HarmBlockThreshold.none),
        SafetySetting(HarmCategory.hateSpeech, HarmBlockThreshold.none),
        SafetySetting(HarmCategory.sexuallyExplicit, HarmBlockThreshold.none),
        SafetySetting(HarmCategory.dangerousContent, HarmBlockThreshold.none),
      ],
    );
  }

  Future<List<dynamic>> generateWorkoutPlan({
    required String goal,
    required double weight,
    required double height,
    required List<String> preferredDays,
  }) async {
    if (preferredDays.isEmpty) {
      throw Exception('Please select at least one workout day.');
    }

    final prompt = '''
    Generate a personalized weekly workout plan for an athlete:
    - Goal: $goal
    - Weight: $weight kg
    - Height: $height cm
    - Preferred Workout Days: ${preferredDays.join(', ')}

    Return a JSON array where each object has "day", "routineName", and "exercises" (an array of objects with "name", "description", "sets", "reps", "muscleGroup").
    Return ONLY the raw JSON array. Do not include markdown formatting.
    ''';

    try {
      return await _generate(prompt);
    } catch (e) {
      debugPrint('Initial AI Error: $e');
      // If the model is not found, try falling back to the most stable Pro model
      if (e.toString().contains('not found') || e.toString().contains('supported')) {
        try {
          _model = _createModel('gemini-pro');
          return await _generate(prompt);
        } catch (fallbackError) {
          debugPrint('Fallback AI Error: $fallbackError');
          return _getFallbackPlan(preferredDays);
        }
      }
      return _getFallbackPlan(preferredDays);
    }
  }

  Future<List<dynamic>> _generate(String prompt) async {
    final response = await _model.generateContent([Content.text(prompt)]);
    String text = response.text ?? '[]';
    
    // Clean JSON formatting
    if (text.contains('```')) {
      final start = text.indexOf('[');
      final end = text.lastIndexOf(']') + 1;
      if (start != -1 && end != -1) {
        text = text.substring(start, end);
      }
    }
    
    final decoded = jsonDecode(text);
    return decoded is List ? decoded : [];
  }

  List<dynamic> _getFallbackPlan(List<String> days) {
    return days.map((day) => {
      "day": day,
      "routineName": "Standard Protocol",
      "exercises": [
        {"name": "Push Ups", "description": "Chest focus", "sets": 3, "reps": 15, "muscleGroup": "Chest"},
        {"name": "Squats", "description": "Lower body", "sets": 3, "reps": 20, "muscleGroup": "Legs"}
      ]
    }).toList();
  }
}
