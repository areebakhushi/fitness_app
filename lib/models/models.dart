import 'package:cloud_firestore/cloud_firestore.dart';

class Exercise {
  final String id;
  final String name;
  final String muscleGroup;
  final String? description;
  final bool isCustom;

  Exercise({
    required this.id, 
    required this.name, 
    required this.muscleGroup, 
    this.description, 
    this.isCustom = false
  });

  factory Exercise.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map? ?? {};
    return Exercise(
      id: doc.id,
      name: data['name'] ?? '',
      muscleGroup: data['muscleGroup'] ?? '',
      description: data['description'],
      isCustom: data['isCustom'] ?? false,
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
    Map data = doc.data() as Map? ?? {};
    var list = data['exercises'] as List? ?? [];
    return Routine(
      id: doc.id,
      name: data['name'] ?? '',
      day: data['day'] ?? '',
      exercises: list.map((i) => RoutineExercise.fromMap(i as Map)).toList(),
    );
  }
}

class RoutineExercise {
  final String exerciseId;
  final int sets;
  final int reps;

  RoutineExercise({required this.exerciseId, required this.sets, required this.reps});

  factory RoutineExercise.fromMap(Map data) => RoutineExercise(
    exerciseId: data['exerciseId'] ?? '',
    sets: (data['sets'] as num?)?.toInt() ?? 0,
    reps: (data['reps'] as num?)?.toInt() ?? 0,
  );

  Map<String, dynamic> toMap() => {'exerciseId': exerciseId, 'sets': sets, 'reps': reps};
}

class WorkoutLog {
  final String id;
  final String routineId;
  final String routineName;
  final DateTime completedAt;
  final int durationMinutes;
  final List<LoggedExercise> exercises;

  WorkoutLog({required this.id, required this.routineId, required this.routineName, required this.completedAt, required this.durationMinutes, required this.exercises});

  factory WorkoutLog.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map? ?? {};
    DateTime date;
    if (data['completedAt'] is Timestamp) {
      date = (data['completedAt'] as Timestamp).toDate();
    } else {
      date = DateTime.now();
    }
    return WorkoutLog(
      id: doc.id,
      routineId: data['routineId'] ?? '',
      routineName: data['routineName'] ?? '',
      completedAt: date,
      durationMinutes: (data['durationMinutes'] as num?)?.toInt() ?? 0,
      exercises: (data['exercises'] as List? ?? []).map((e) => LoggedExercise.fromMap(e as Map)).toList(),
    );
  }
}

class LoggedExercise {
  final String exerciseId;
  final String name;
  final List<LoggedSet> sets;
  LoggedExercise({required this.exerciseId, required this.name, required this.sets});
  factory LoggedExercise.fromMap(Map data) => LoggedExercise(
    exerciseId: data['exerciseId'] ?? '',
    name: data['name'] ?? '',
    sets: (data['sets'] as List? ?? []).map((s) => LoggedSet.fromMap(s as Map)).toList(),
  );
  Map<String, dynamic> toMap() => {'exerciseId': exerciseId, 'name': name, 'sets': sets.map((s) => s.toMap()).toList()};
}

class LoggedSet {
  final int reps;
  final double weight;
  LoggedSet({required this.reps, required this.weight});
  factory LoggedSet.fromMap(Map data) => LoggedSet(reps: data['reps'] ?? 0, weight: (data['weight'] as num?)?.toDouble() ?? 0.0);
  Map<String, dynamic> toMap() => {'reps': reps, 'weight': weight};
}

class UserProfile {
  final String uid;
  final String name;
  final double weight;
  final double height;
  final String goal;
  final String gender;
  final int streak;
  final List<String> achievements;
  final List<String> diet;
  final List<String> tips;
  final bool onboardingCompleted;

  UserProfile({
    required this.uid,
    this.name = 'Athlete',
    this.weight = 70.0,
    this.height = 170.0,
    this.goal = 'Maintain',
    this.gender = 'Male',
    this.streak = 0,
    this.achievements = const [],
    this.diet = const [],
    this.tips = const [], 
    this.onboardingCompleted = false,
  });

  factory UserProfile.fromFirestore(DocumentSnapshot doc) {
    if (!doc.exists) return UserProfile(uid: doc.id);
    Map data = doc.data() as Map? ?? {};
    return UserProfile(
      uid: doc.id,
      name: data['name'] ?? 'Athlete',
      weight: (data['weight'] as num?)?.toDouble() ?? 70.0,
      height: (data['height'] as num?)?.toDouble() ?? 170.0,
      goal: data['goal'] ?? 'Maintain',
      gender: data['gender'] ?? 'Male',
      streak: data['streak'] ?? 0,
      achievements: List<String>.from(data['achievements'] ?? []),
      diet: List<String>.from(data['diet'] ?? []),
      tips: List<String>.from(data['tips'] ?? []), 
      onboardingCompleted: data['onboardingCompleted'] ?? false,
    );
  }

  Map<String, dynamic> toMap() => {
    'name': name,
    'weight': weight,
    'height': height,
    'goal': goal,
    'gender': gender,
    'streak': streak,
    'achievements': achievements,
    'diet': diet,
    'tips': tips,
    'onboardingCompleted': onboardingCompleted,
  };
}
