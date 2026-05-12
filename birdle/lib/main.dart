import 'package:flutter/material.dart';
import 'package:birdle/core/app_theme.dart';
import 'package:birdle/services/auth_service.dart';
import 'package:birdle/screens/login_screen.dart';
import 'package:birdle/screens/home_screen.dart';
import 'package:birdle/screens/notifications_screen.dart';
import 'package:birdle/screens/settings_screen.dart';
import 'package:birdle/screens/profile_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const BizManagerApp());
}

/// Root application widget for BizManager.
/// Handles theme switching, routing, and auth state restoration.
class BizManagerApp extends StatefulWidget {
  const BizManagerApp({super.key});

  @override
  State<BizManagerApp> createState() => _BizManagerAppState();
}

class _BizManagerAppState extends State<BizManagerApp> {
  final AuthService _authService = AuthService();
  bool _isDarkMode = false;
  bool _isCheckingAuth = true;

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    await _authService.tryRestoreSession();
    if (mounted) {
      setState(() => _isCheckingAuth = false);
    }
  }

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
      home: _isCheckingAuth
          ? const _SplashScreen()
          : (_authService.isAuthenticated
              ? HomeScreen(onThemeChanged: _toggleTheme)
              : const LoginScreen()),
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

/// A brief splash screen shown while restoring a previous auth session.
class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.primary,
              AppTheme.primaryDark,
              Color(0xFF2D1B69),
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.business_center_rounded,
                  size: 40,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 24),
              const SizedBox(
                width: 32,
                height: 32,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
