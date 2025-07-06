import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'core/providers/auth_provider.dart';
import 'core/providers/topics_provider.dart';
import 'core/providers/announcement_provider.dart';
import 'core/services/auth_service.dart';
import 'core/services/firestore_service.dart';
import 'core/services/auto_seed_service.dart';

import 'ui/screens/auth/login_screen.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final autoSeedService = AutoSeedService(); // Popula dados iniciais automaticamente se o banco estiver vazio
  await autoSeedService.ensureInitialData(); // Em produção a integração viria do SIGA/Moodle

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
          create: (context) => AuthProvider(
            context.read<AuthService>(),
            context.read<FirestoreService>(),
          ),
        ),

        ChangeNotifierProvider(
          create: (context) => TopicsProvider(
            context.read<FirestoreService>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => AnnouncementsProvider(
            context.read<FirestoreService>(),
          ),
        ),
        // Adicionar outros providers aqui
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

    print('🔍 Auth status: ${authProvider.status}');
    print('🔍 User: ${authProvider.user?.email ?? 'null'}');

    switch (authProvider.status) {
      case AuthStatus.authenticated:
        print('✅ Showing HomeScreen');
        return const HomeScreen();
      case AuthStatus.unauthenticated:
        print('📝 Showing LoginScreen');
        return const LoginScreen();
      default:
        print('⏳ Showing Loading');
        return const Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Carregando...', style: TextStyle(fontSize: 16)),
              ],
            ),
          ),
        );
    }
  }
}

// --- TELA DE TESTE  ---
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