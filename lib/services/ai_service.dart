import 'dart:convert';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/models.dart';

class AIService {
  final String _apiKey;

  AIService(this._apiKey);

  Future<Map<String, dynamic>> generateWorkoutPlan({
    required String goal,
    required double weight,
    required double height,
    required String gender,
    required List<String> preferredDays,
    required String timeframe,
  }) async {
    if (preferredDays.isEmpty) throw Exception('Please select training days.');

    final prompt = '''
    As an elite fitness architect, generate a personalized training and nutrition protocol.
    CRITICAL: Adhere strictly to the objective: $goal. 
    Scale for athlete: $gender, $weight kg, $height cm. Timeframe: $timeframe.

    Return ONLY raw JSON with these exact keys:
    {
      "plans": [{"day": "...", "routineName": "...", "exercises": [{"name": "...", "sets": 3, "reps": 10, "muscleGroup": "..."}]}],
      "diet": ["suggestion 1", "suggestion 2"],
      "tips": ["tip 1", "tip 2"]
    }
    ''';

    try {
      final result = await _generate(prompt);
      if (result != null && result['plans'] != null) return result;
      throw Exception('Invalid AI Response');
    } catch (e) {
      debugPrint('AI Gen Error: $e');
      return {
        'plans': _getFallbackPlan(preferredDays, goal),
        'diet': ['High protein intake', 'Stay hydrated'],
        'tips': ['Prioritize form', '7-8h sleep']
      };
    }
  }

  Future<Map<String, dynamic>> getInsights({
    required UserProfile profile,
    required List<WorkoutLog> logs,
  }) async {
    final summary = logs.take(5).map((l) => {'date': l.completedAt.toIso8601String(), 'routine': l.routineName}).toList();

    final prompt = '''
    As AI Fitness Analyst, provide neural feedback for: ${profile.goal}.
    Data: ${jsonEncode(summary)}

    Return JSON:
    {
      "smartInsight": "...", "plateauStatus": "...", "personalizedSuggestion": "...",
      "injuryAlert": "...", "dailyTip": "...", "dietInsight": "..."
    }
    ''';

    try {
      final response = await _generate(prompt);
      if (response != null) return response;
    } catch (_) {}

    return {
      "smartInsight": "System active. Analyzing data...",
      "plateauStatus": "Progression is optimal.",
      "personalizedSuggestion": "Focus on eccentric control today.",
      "injuryAlert": "No immediate risks.",
      "dailyTip": "Consistency is the key to architecture.",
      "dietInsight": "Maintain nutrient timing post-workout."
    };
  }

  Future<dynamic> _generate(String prompt) async {
    try {
      final response = await http.post(
        Uri.parse('https://openrouter.ai/api/v1/chat/completions'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
          'HTTP-Referer': 'https://fitgenie.app',
        },
        body: jsonEncode({
          'model': 'nvidia/nemotron-3-nano-30b-a3b:free',
          'messages': [
            {'role': 'system', 'content': 'You are a professional fitness architect. Respond ONLY with raw JSON.'},
            {'role': 'user', 'content': prompt}
          ],
          'temperature': 0.7,
        }),
      ).timeout(const Duration(seconds: 45));

      if (response.statusCode == 200) {
        String text = jsonDecode(response.body)['choices'][0]['message']['content'];
        
        // Smart JSON Extraction (Fixes the "Commit" issue)
        final start = text.indexOf('{');
        final end = text.lastIndexOf('}') + 1;
        if (start != -1 && end > start) {
          return jsonDecode(text.substring(start, end));
        }
      }
    } catch (e) {
      debugPrint('AI Engine Exception: $e');
    }
    return null;
  }

  List<dynamic> _getFallbackPlan(List<String> days, String goal) {
    return days.map((day) => {"day": day, "routineName": "Core Routine", "exercises": [{"name": "Compound Lift", "sets": 3, "reps": 10, "muscleGroup": "Full Body"}]}).toList();
  }
}
