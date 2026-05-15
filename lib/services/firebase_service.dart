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

  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  Future<void> updatePassword(String newPassword) async {
    final user = _auth.currentUser;
    if (user != null) {
      await user.updatePassword(newPassword);
    } else {
      throw Exception('No user currently logged in');
    }
  }

  // Profile Operations
  Future<UserProfile?> getUserProfile(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (doc.exists) {
      return UserProfile.fromFirestore(doc);
    }
    return null;
  }

  Future<void> saveUserProfile(UserProfile profile) {
    return _db.collection('users').doc(profile.uid).set(profile.toMap(), SetOptions(merge: true));
  }

  Future<void> updateStreak(String uid, int newStreak) {
    return _db.collection('users').doc(uid).update({'streak': newStreak});
  }

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

  Future<void> addWorkoutLog({
    required String userId,
    required String routineId,
    required String routineName,
    required int duration,
    required List<LoggedExercise> exercises,
  }) async {
    await _db.collection('workoutLogs').add({
      'userId': userId,
      'routineId': routineId,
      'routineName': routineName,
      'durationMinutes': duration,
      'exercises': exercises.map((e) => e.toMap()).toList(),
      'completedAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<WorkoutLog>> getWorkoutLogs(String userId) {
    return _db.collection('workoutLogs')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => WorkoutLog.fromFirestore(doc)).toList());
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
