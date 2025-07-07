import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/utils/constants.dart';
import '../announcements/create_announcement_screen.dart';
import '../profile/profile_screen.dart';
import 'feed_page.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    FeedPage(),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;

    return Scaffold(
      appBar: AppBar(
        title: Text(_selectedIndex == 0 ? AppConstants.appName : 'Meu Perfil'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sair',
            onPressed: () {
              context.read<AuthProvider>().signOut();
            },
          )
        ],
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Início',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: AppConstants.primaryColor,
        unselectedItemColor: AppConstants.textSecondaryColor,
        backgroundColor: AppConstants.cardColor,
        type: BottomNavigationBarType.fixed,
        onTap: _onItemTapped,
      ),
      floatingActionButton: _selectedIndex == 0 && user?.role == AppConstants.roleProfessor
          ? FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => const CreateAnnouncementScreen(),
          ));
        },
        backgroundColor: AppConstants.accentColor,
        child: const Icon(Icons.add),
        tooltip: 'Novo Aviso',
      )
          : null,
    );
  }
}