import 'package:cloud_firestore/cloud_firestore.dart';

class SeedData {
  static final List<Map<String, dynamic>> exercises = [
    {
      'name': 'Bench Press',
      'muscleGroup': 'Chest',
      'description': 'A fundamental upper-body exercise that targets the chest, shoulders, and triceps.',
      'isCustom': false,
      'createdBy': null
    },
    {
      'name': 'Squats',
      'muscleGroup': 'Legs',
      'description': 'A king of exercises focusing on lower body strength and core stability.',
      'isCustom': false,
      'createdBy': null
    },
    {
      'name': 'Deadlift',
      'muscleGroup': 'Back',
      'description': 'A composite exercise that engages multiple muscle groups including the back, glutes, and hamstrings.',
      'isCustom': false,
      'createdBy': null
    },
    {
      'name': 'Pull Ups',
      'muscleGroup': 'Back',
      'description': 'An effective bodyweight exercise for building upper back and biceps strength.',
      'isCustom': false,
      'createdBy': null
    },
    {
      'name': 'Dumbbell Curls',
      'muscleGroup': 'Arms',
      'description': 'Isolation exercise targeting the biceps for muscle growth and definition.',
      'isCustom': false,
      'createdBy': null
    },
    {
      'name': 'Plank',
      'muscleGroup': 'Core',
      'description': 'Isometric core strength exercise that improves posture and stability.',
      'isCustom': false,
      'createdBy': null
    },
    {
      'name': 'Push Ups',
      'muscleGroup': 'Chest',
      'description': 'Versatile bodyweight exercise for chest, shoulders, and triceps.',
      'isCustom': false,
      'createdBy': null
    },
    {
      'name': 'Lunge',
      'muscleGroup': 'Legs',
      'description': 'Unilateral leg exercise that targets quads, hamstrings, and glutes.',
      'isCustom': false,
      'createdBy': null
    },
    {
      'name': 'Shoulder Press',
      'muscleGroup': 'Shoulders',
      'description': 'Key exercise for developing strong, well-defined shoulders.',
      'isCustom': false,
      'createdBy': null
    },
  ];

  static Future<void> seedDatabase() async {
    final db = FirebaseFirestore.instance;
    final collection = db.collection('exercises');

    final snapshot = await collection.limit(1).get();
    if (snapshot.docs.isNotEmpty) return;

    for (var exercise in exercises) {
      await collection.add(exercise);
    }
    print('Database seeded with exercises.');
  }

  static Future<void> seedUserData(String userId) async {
    final db = FirebaseFirestore.instance;
    
    // Check if user has routines
    final routinesSnapshot = await db.collection('routines')
        .where('userId', isEqualTo: userId)
        .limit(1)
        .get();
        
    if (routinesSnapshot.docs.isNotEmpty) return;

    // Get some exercise IDs
    final exercisesSnapshot = await db.collection('exercises').limit(3).get();
    if (exercisesSnapshot.docs.isEmpty) return;
    
    final ex1 = exercisesSnapshot.docs[0].id;
    final ex2 = exercisesSnapshot.docs[1].id;

    // Add a dummy routine
    await db.collection('routines').add({
      'userId': userId,
      'name': 'Beginner Full Body',
      'day': 'Monday',
      'exercises': [
        {'exerciseId': ex1, 'sets': 3, 'reps': 10},
        {'exerciseId': ex2, 'sets': 3, 'reps': 12},
      ],
      'createdAt': FieldValue.serverTimestamp(),
    });

    // Add a dummy workout log
    await db.collection('workoutLogs').add({
      'userId': userId,
      'routineName': 'Beginner Full Body',
      'durationMinutes': 45,
      'completedAt': FieldValue.serverTimestamp(),
    });
    
    print('Dummy user data seeded.');
  }
}
