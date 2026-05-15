import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firebase_service.dart';
import '../models/models.dart';

class AuthViewModel extends ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  User? _user;
  UserProfile? _userProfile;
  bool _isLoading = false;
  String? _error;

  User? get user => _user;
  UserProfile? get userProfile => _userProfile;
  bool get isLoading => _isLoading;
  String? get error => _error;

  AuthViewModel() {
    _firebaseService.user.listen((user) async {
      _user = user;
      if (user != null) {
        await fetchProfile(user.uid);
      } else {
        _userProfile = null;
      }
      notifyListeners();
    });
  }

  Future<void> fetchProfile(String uid) async {
    try {
      _userProfile = await _firebaseService.getUserProfile(uid);
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching profile: $e');
    }
  }

  Future<void> signIn(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _firebaseService.signInWithEmail(email, password);
    } catch (e) {
      _error = _getFirebaseErrorMessage(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signUp(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _firebaseService.signUpWithEmail(email, password);
    } catch (e) {
      _error = _getFirebaseErrorMessage(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> resetPassword(String email) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _firebaseService.sendPasswordResetEmail(email);
    } catch (e) {
      _error = _getFirebaseErrorMessage(e);
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updatePassword(String newPassword) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _firebaseService.updatePassword(newPassword);
    } catch (e) {
      _error = _getFirebaseErrorMessage(e);
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  String _getFirebaseErrorMessage(dynamic e) {
    if (e is FirebaseAuthException) {
      switch (e.code) {
        case 'user-not-found':
          return 'Account not found. Please sign up.';
        case 'wrong-password':
          return 'Incorrect password. Try again.';
        case 'email-already-in-use':
          return 'This email is already registered.';
        case 'invalid-email':
          return 'Invalid email format.';
        case 'weak-password':
          return 'Password should be at least 6 characters.';
        case 'user-disabled':
          return 'This account has been disabled.';
        case 'too-many-requests':
          return 'Too many attempts. Try again later.';
        default:
          return e.message ?? 'Authentication failed.';
      }
    }
    if (e is FirebaseException) {
      return e.message ?? 'Database synchronization error.';
    }
    // Return the error string directly if it's not a known exception type
    return e.toString().replaceFirst('Exception: ', '').replaceFirst('FirebaseException: ', '');
  }

  Future<void> completeOnboarding(UserProfile profile) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _firebaseService.saveUserProfile(profile);
      _userProfile = profile;
    } catch (e) {
      _error = _getFirebaseErrorMessage(e);
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateGoal(String goal) async {
    if (_userProfile == null) return;
    _isLoading = true;
    _error = null;
    notifyListeners();

    final updatedProfile = UserProfile(
      uid: _userProfile!.uid,
      name: _userProfile!.name,
      weight: _userProfile!.weight,
      height: _userProfile!.height,
      goal: goal,
      gender: _userProfile!.gender,
      streak: _userProfile!.streak,
      achievements: _userProfile!.achievements,
      diet: _userProfile!.diet,
      tips: _userProfile!.tips,
      onboardingCompleted: true,
    );

    try {
      await _firebaseService.saveUserProfile(updatedProfile);
      _userProfile = updatedProfile;
    } catch (e) {
      _error = _getFirebaseErrorMessage(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateWeight(double weight) async {
    if (_userProfile == null) return;
    _isLoading = true;
    _error = null;
    notifyListeners();

    final updatedProfile = UserProfile(
      uid: _userProfile!.uid,
      name: _userProfile!.name,
      weight: weight,
      height: _userProfile!.height,
      goal: _userProfile!.goal,
      gender: _userProfile!.gender,
      streak: _userProfile!.streak,
      achievements: _userProfile!.achievements,
      diet: _userProfile!.diet,
      tips: _userProfile!.tips,
      onboardingCompleted: true,
    );

    try {
      await _firebaseService.saveUserProfile(updatedProfile);
      _userProfile = updatedProfile;
    } catch (e) {
      _error = _getFirebaseErrorMessage(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() => _firebaseService.signOut();

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
