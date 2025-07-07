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
  String? _errorMessage;

  AuthProvider(this._authService, this._firestoreService) {
    _authService.authStateChanges.listen(_onAuthStateChanged);
  }

  AuthStatus get status => _status;
  UserModel? get user => _userModel;
  String? get errorMessage => _errorMessage;

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
      _errorMessage = null;
      notifyListeners();

      final result = await _authService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result != null;
    } catch (e) {
      _status = AuthStatus.unauthenticated;
      _errorMessage = 'Erro ao fazer login. Verifique suas credenciais.';
      notifyListeners();
      return false;
    }
  }

  Future<bool> signUp({
    required String email,
    required String password,
    required String matricula, // CPF
    String? nickname,
  }) async {
    try {
      _status = AuthStatus.authenticating;
      _errorMessage = null;
      notifyListeners();

      // Validar matrícula com cpf e email
      final enrollmentData = await _validateEnrollment(matricula, email);
      if (enrollmentData == null) {
        _status = AuthStatus.unauthenticated;
        _errorMessage = 'CPF e email não encontrados ou não coincidem. Verifique os dados.';
        notifyListeners();
        return false;
      }

      // Cria Firebase Auth user
      final result = await _authService.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (result != null) {
        // Cria user document no Firestore usando dados da matrícula
        final userModel = UserModel(
          uid: result.user!.uid,
          email: email,
          nome: enrollmentData['nome'],
          nickname: nickname,
          avatarUrl: null,
          role: enrollmentData['role'],
          matricula: matricula,
        );

        await _firestoreService.setUserData(userModel);
        return true;
      }
      return false;
    } on FirebaseAuthException catch (e) {
      //TODO exceção de usuário já criado
      _status = AuthStatus.unauthenticated;
      if (e.code == 'email-already-in-use') {
        _errorMessage = 'Este email já está cadastrado.';
      } else if (e.code == 'weak-password') {
        _errorMessage = 'A senha é muito fraca. Use pelo menos 6 caracteres.';
      } else {
        _errorMessage = 'Ocorreu um erro inesperado no cadastro.';
      }
      notifyListeners();
      return false;
    }
  }

  Future<Map<String, dynamic>?> _validateEnrollment(String cpf, String email) async {
    try {
      final enrollmentData = await _firestoreService.validateEnrollment(cpf, email);
      return enrollmentData;
    } catch (e) {
      print('Erro ao validar matrícula: $e');
      return null;
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
    _status = AuthStatus.unauthenticated;
    _userModel = null;
    _errorMessage = null;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}