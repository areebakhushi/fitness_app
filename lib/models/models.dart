import 'package:cloud_firestore/cloud_firestore.dart';

class Exercise {
  final String id;
  final String name;
  final String muscleGroup;
  final String? description;
  final String? details; // Added for architectural consistency
  final bool isCustom;
  final String? createdBy;

  Exercise({
    required this.id,
    required this.name,
    required this.muscleGroup,
    this.description,
    this.details,
    this.isCustom = false,
    this.createdBy,
  });

  factory Exercise.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    final desc = data['description'] as String?;
    return Exercise(
      id: doc.id,
      name: data['name'] ?? '',
      muscleGroup: data['muscleGroup'] ?? '',
      description: desc,
      details: desc, // Mapping description to details field
      isCustom: data['isCustom'] ?? false,
      createdBy: data['createdBy'],
    );
  }
}

class Routine {
  final String id;
  final String name;
  final String day;
  final List<RoutineExercise> exercises;

  Routine({required this.id, required this.name, required this.day, required this.exercises});

  factory Routine.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    var list = data['exercises'] as List? ?? [];
    return Routine(
      id: doc.id,
      name: data['name'] ?? '',
      day: data['day'] ?? '',
      exercises: list.map((i) => RoutineExercise.fromMap(i)).toList(),
    );
  }
}

class RoutineExercise {
  final String exerciseId;
  final int sets;
  final int reps;

  RoutineExercise({required this.exerciseId, required this.sets, required this.reps});

  factory RoutineExercise.fromMap(Map data) {
    return RoutineExercise(
      exerciseId: data['exerciseId'] ?? '',
      sets: data['sets'] ?? 0,
      reps: data['reps'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() => {
    'exerciseId': exerciseId,
    'sets': sets,
    'reps': reps,
  };
}

class WorkoutLog {
  final String id;
  final String routineId;
  final String routineName;
  final DateTime completedAt;
  final int durationMinutes;

  WorkoutLog({
    required this.id,
    required this.routineId,
    required this.routineName,
    required this.completedAt,
    required this.durationMinutes,
  });

  factory WorkoutLog.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return WorkoutLog(
      id: doc.id,
      routineId: data['routineId'] ?? '',
      routineName: data['routineName'] ?? '',
      completedAt: (data['completedAt'] as Timestamp).toDate(),
      durationMinutes: data['durationMinutes'] ?? 0,
    );
  }
}

class UserProfile {
  final String uid;
  final String? name;
  final double? weight;
  final double? height;
  final String? goal;

  UserProfile({required this.uid, this.name, this.weight, this.height, this.goal});

  factory UserProfile.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return UserProfile(
      uid: doc.id,
      name: data['name'],
      weight: data['weight']?.toDouble(),
      height: data['height']?.toDouble(),
      goal: data['goal'],
    );
  }
}
