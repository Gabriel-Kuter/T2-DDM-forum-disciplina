import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'core/providers/auth_provider.dart';
import 'core/services/auth_service.dart';
import 'core/services/firestore_service.dart';

//importação das configs do projeto do firebase
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Fornece providers para toda a árvore de widgets
    return MultiProvider(
      providers: [
        // Instâncias dos services
        Provider(create: (_) => AuthService()),
        Provider(create: (_) => FirestoreService()),

        ChangeNotifierProvider(
          create:
              (context) => AuthProvider(
                context.read<AuthService>(),
                context.read<FirestoreService>(),
              ),
        ),
        // Adicionar outros providers aqui mais tarde (Topics, Announcements)
      ],
      child: MaterialApp(
        title: 'Fórum 65DDM',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: const AuthWrapper(),
      ),
    );
  }
}

/// Decide qual tela mostrar com base no status de autenticação
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    switch (authProvider.status) {
      case AuthStatus.authenticated:
        return const HomeScreen();
      case AuthStatus.unauthenticated:
        return const LoginScreen();
      default:
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
  }
}

// --- TELAS DE TESTE  ---
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('Tela de Login')));
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userNickname = authProvider.user?.nickname ?? 'Usuário';

    return Scaffold(
      appBar: AppBar(
        title: Text('Bem-vindo, $userNickname!'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<AuthProvider>().signOut();
            },
          ),
        ],
      ),
      body: const Center(child: Text('Tela Principal (Home)')),
    );
  }
}
