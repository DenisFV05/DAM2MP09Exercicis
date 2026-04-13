import 'package:flutter/material.dart';
import 'encrypt_screen.dart';
import 'decrypt_screen.dart';

void main() {
  runApp(const EncriptacioApp());
}

class EncriptacioApp extends StatelessWidget {
  const EncriptacioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Encriptació RSA',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1E88E5),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        fontFamily: 'Segoe UI',
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    EncryptScreen(),
    DecryptScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.lock, size: 28),
            SizedBox(width: 12),
            Text(
              'Encriptació RSA',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        centerTitle: false,
        elevation: 2,
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.lock_outline),
            selectedIcon: Icon(Icons.lock),
            label: 'Encriptar',
          ),
          NavigationDestination(
            icon: Icon(Icons.lock_open_outlined),
            selectedIcon: Icon(Icons.lock_open),
            label: 'Desencriptar',
          ),
        ],
      ),
    );
  }
}
