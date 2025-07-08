import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  /// Estado do login em tempo real
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  User? get currentUser => _firebaseAuth.currentUser;

  Future<UserCredential?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      return await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      print('Erro de autenticação: ${e.code} - ${e.message}');

      switch (e.code) {
        case 'user-not-found':
          throw Exception('Email não cadastrado no sistema.');
        case 'wrong-password':
          throw Exception('Senha incorreta.');
        case 'invalid-email':
          throw Exception('Email inválido.');
        case 'user-disabled':
          throw Exception('Esta conta foi desativada.');
        case 'invalid-credential':
          throw Exception('Email ou senha incorretos.');
        default:
          throw Exception('Erro ao fazer login: ${e.message}');
      }
    } catch (e) {
      print('Erro geral no login: $e');
      throw Exception('Erro inesperado. Tente novamente.');
    }
  }

  Future<UserCredential?> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      return await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      print('Erro no cadastro: ${e.code} - ${e.message}');

      switch (e.code) {
        case 'weak-password':
          throw Exception('Senha fraca. Use pelo menos 6 caracteres.');
        case 'email-already-in-use':
          throw Exception('Este email já está cadastrado.');
        case 'invalid-email':
          throw Exception('Email inválido.');
        default:
          throw Exception('Erro ao criar conta: ${e.message}');
      }
    } catch (e) {
      print('Erro geral no cadastro: $e');
      throw Exception('Erro inesperado ao criar conta.');
    }
  }

  Future<void> updatePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        throw Exception('Usuário não autenticado');
      }

      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );

      await user.reauthenticateWithCredential(credential);

      await user.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      print('Erro ao atualizar senha: ${e.code} - ${e.message}');

      switch (e.code) {
        case 'wrong-password':
          throw Exception('Senha atual incorreta.');
        case 'weak-password':
          throw Exception('A nova senha é muito fraca.');
        case 'requires-recent-login':
          throw Exception(
            'Por segurança, faça login novamente antes de alterar a senha.',
          );
        default:
          throw Exception('Erro ao atualizar senha: ${e.message}');
      }
    } catch (e) {
      print('Erro geral ao atualizar senha: $e');
      throw Exception('Erro inesperado ao atualizar senha.');
    }
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
}
