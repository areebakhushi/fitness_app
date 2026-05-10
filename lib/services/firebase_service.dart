import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/models.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<User?> get user => _auth.authStateChanges();

  Future<UserCredential> signInWithEmail(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<UserCredential> signUpWithEmail(String email, String password) async {
    return await _auth.createUserWithEmailAndPassword(email: email, password: password);
  }

  Future<void> signOut() => _auth.signOut();

  // Database Operations
  Stream<List<Exercise>> getExercises() {
    return _db.collection('exercises').snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => Exercise.fromFirestore(doc)).toList());
  }

  Stream<List<Routine>> getRoutines(String userId) {
    return _db.collection('routines')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Routine.fromFirestore(doc)).toList());
  }

  Future<void> addRoutine(String userId, String name, String day, List<RoutineExercise> exercises) {
    return _db.collection('routines').add({
      'userId': userId,
      'name': name,
      'day': day,
      'exercises': exercises.map((e) => e.toMap()).toList(),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> addWorkoutLog(String userId, String routineId, String routineName, int duration) {
    return _db.collection('workoutLogs').add({
      'userId': userId,
      'routineId': routineId,
      'routineName': routineName,
      'durationMinutes': duration,
      'completedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<String> addExercise({
    required String name,
    required String muscleGroup,
    required String description,
    required String userId,
  }) async {
    final docRef = await _db.collection('exercises').add({
      'name': name,
      'muscleGroup': muscleGroup,
      'description': description,
      'isCustom': true,
      'createdBy': userId,
      'createdAt': FieldValue.serverTimestamp(),
    });
    return docRef.id;
  }
}
