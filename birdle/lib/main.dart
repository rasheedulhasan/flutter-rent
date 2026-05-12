import 'package:flutter/material.dart';
import 'package:birdle/core/app_theme.dart';
import 'package:birdle/screens/login_screen.dart';
import 'package:birdle/screens/home_screen.dart';
import 'package:birdle/screens/notifications_screen.dart';
import 'package:birdle/screens/settings_screen.dart';
import 'package:birdle/screens/profile_screen.dart';

void main() {
  runApp(const BizManagerApp());
}

/// Root application widget for BizManager.
/// Handles theme switching and routing.
class BizManagerApp extends StatefulWidget {
  const BizManagerApp({super.key});

  @override
  State<BizManagerApp> createState() => _BizManagerAppState();
}

class _BizManagerAppState extends State<BizManagerApp> {
  bool _isDarkMode = false;

  void _toggleTheme(bool isDark) {
    setState(() => _isDarkMode = isDark);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BizManager',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => HomeScreen(onThemeChanged: _toggleTheme),
        '/notifications': (context) => const NotificationsScreen(),
        '/settings': (context) => SettingsScreen(onThemeChanged: _toggleTheme),
        '/profile': (context) => const ProfileScreen(),
      },
    );
  }
}
