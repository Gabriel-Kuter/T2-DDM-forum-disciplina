import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../models/user_model.dart';

enum AuthStatus {
  uninitialized,
  authenticated,
  authenticating,
  unauthenticated,
}

class AuthProvider with ChangeNotifier {
  final AuthService _authService;
  final FirestoreService _firestoreService;

  AuthStatus _status = AuthStatus.uninitialized;
  UserModel? _userModel;

  // Construtor
  AuthProvider(this._authService, this._firestoreService) {
    _authService.authStateChanges.listen(_onAuthStateChanged);
  }

  AuthStatus get status => _status;
  UserModel? get user => _userModel;

  Future<void> _onAuthStateChanged(User? firebaseUser) async {
    if (firebaseUser == null) {
      _status = AuthStatus.unauthenticated;
      _userModel = null;
    } else {
      _userModel = await _firestoreService.getUserData(firebaseUser.uid);
      _status = AuthStatus.authenticated;
    }
    notifyListeners();
  }

  Future<bool> signIn(String email, String password) async {
    try {
      _status = AuthStatus.authenticating;
      notifyListeners();
      final result = await _authService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result != null;
    } catch (e) {
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
    _status = AuthStatus.unauthenticated;
    _userModel = null;
    notifyListeners();
  }

  //TODO Implementar função de cadastro (signUp)
}
