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
      try {
        _userModel = await _firestoreService.getUserData(firebaseUser.uid);

        // Usuário existe no Auth mas não tem dados no Firestore
        if (_userModel == null) {
          await _authService.signOut();
          _status = AuthStatus.unauthenticated;
          _errorMessage = 'Dados do usuário não encontrados. Entre em contato com o suporte.';
        } else {
          _status = AuthStatus.authenticated;
          _errorMessage = null;
        }
      } catch (e) {
        await _authService.signOut();
        _status = AuthStatus.unauthenticated;
        _errorMessage = 'Erro ao carregar dados do usuário.';
      }
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

      if (result == null) {
        _status = AuthStatus.unauthenticated;
        _errorMessage = 'Email ou senha incorretos.';
        notifyListeners();
        return false;
      }

      return true;

    } catch (e) {
      _status = AuthStatus.unauthenticated;
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
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
    } catch (e) {
      _status = AuthStatus.unauthenticated;
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
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

  Future<bool> updateProfile(UserModel updatedUser) async {
    try {
      _errorMessage = null;
      notifyListeners();

      // Salvar no Firestore
      await _firestoreService.setUserData(updatedUser);

      // Atualizar estado local (reativo)
      _userModel = updatedUser;
      notifyListeners();

      return true;
    } catch (e) {
      _errorMessage = 'Erro ao atualizar perfil: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> updatePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      _errorMessage = null;
      notifyListeners();

      // Atualizar senha via AuthService
      await _authService.updatePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );

      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
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