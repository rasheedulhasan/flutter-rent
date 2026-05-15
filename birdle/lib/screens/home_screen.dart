import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:birdle/core/app_theme.dart';
import 'package:birdle/screens/dashboard_screen.dart';
import 'package:birdle/screens/tenants_screen.dart';
import 'package:birdle/screens/invoices_screen.dart';
import 'package:birdle/screens/reports_screen.dart';
import 'package:birdle/screens/pending_rent_screen.dart';
import 'package:birdle/screens/room_booking_screen.dart';
import 'package:birdle/services/auth_service.dart';

/// Main home screen with ProManager layout:
/// - TopAppBar with menu + profile (matches HTML)
/// - Bottom navigation (mobile only)
/// - Desktop navigation drawer (hidden on mobile)
class HomeScreen extends StatefulWidget {
  final ValueChanged<bool>? onThemeChanged;

  const HomeScreen({super.key, this.onThemeChanged});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _authService = AuthService();
  int _currentIndex = 0;
  List<Widget> _screens = [];

  /// Logs the user out and navigates back to the login screen.
  Future<void> _handleLogout() async {
    await _authService.logout();
    if (!mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil('/login', (_) => false);
  }

  /// Returns the user's initials from the authenticated user, or '?' if not available.
  String get _userInitials {
    final user = _authService.currentUser;
    if (user != null) {
      return user.initials;
    }
    return '?';
  }

  /// Returns the user's full name from the authenticated user, or a fallback.
  String get _userDisplayName {
    final user = _authService.currentUser;
    if (user != null) {
      return user.fullName.isNotEmpty ? user.fullName : user.name;
    }
    return 'User';
  }

  /// Returns the user's role from the authenticated user, or a fallback.
  String get _userRole {
    final user = _authService.currentUser;
    if (user != null) {
      return user.role;
    }
    return 'User';
  }

  @override
  void initState() {
    super.initState();
    _screens = [
      DashboardScreen(
        onNavigateToOrders: () {
          if (mounted) setState(() => _currentIndex = 3);
        },
        onNavigateToBooking: () {
          // Navigate directly to RoomBookingScreen instead of tenants list
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const RoomBookingScreen(),
            ),
          );
        },
        onNavigateToPendingRent: () {
          if (mounted) setState(() => _currentIndex = 2);
        },
      ),
      const TenantsScreen(),
      const PendingRentScreen(),
      const InvoicesScreen(),
      const ReportsScreen(),
    ];
  }

  // Bottom nav items (mobile)
  final List<_BottomNavItem> _bottomNavItems = [
    _BottomNavItem(Icons.dashboard_rounded, 'Home', true),
    _BottomNavItem(Icons.person_add_rounded, 'Booking', false),
    _BottomNavItem(Icons.error_outline_rounded, 'Pending', false),
    _BottomNavItem(Icons.payments_rounded, 'Payments', false),
    _BottomNavItem(Icons.assessment_rounded, 'Reports', false),
  ];

  // Desktop drawer items
  final List<_DrawerNavItem> _drawerItems = [
    _DrawerNavItem(Icons.home_work_rounded, 'Dashboard', 0),
    _DrawerNavItem(Icons.group_add_rounded, 'Tenant Onboarding', 1),
    _DrawerNavItem(Icons.receipt_long_rounded, 'Rent Collection', 2),
    _DrawerNavItem(Icons.payments_rounded, 'Invoices', 3),
    _DrawerNavItem(Icons.assessment_rounded, 'Reports', 4),
    _DrawerNavItem(Icons.settings_rounded, 'Settings', -1),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 768;

    return Scaffold(
      // ================================================================
      // TopAppBar - matches HTML design
      // ================================================================
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(64),
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? AppTheme.cardDark : Colors.white,
            border: Border(
              bottom: BorderSide(
                color: isDark ? AppTheme.borderDark : AppTheme.outlineVariant,
                width: 0.5,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                height: 64,
                child: Row(
                  children: [
                    // Menu button
                    if (!isDesktop)
                      Builder(
                        builder: (menuContext) => GestureDetector(
                          onTap: () => Scaffold.of(menuContext).openDrawer(),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            margin: const EdgeInsets.only(right: 8),
                            child: Icon(
                              Icons.menu_rounded,
                              color: isDark ? AppTheme.textSecondaryDark : AppTheme.onSurfaceVariant,
                              size: 24,
                            ),
                          ),
                        ),
                      ),
                    // App title
                    Text(
                      'ProManager',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.02,
                        color: AppTheme.primary,
                      ),
                    ),
                    const Spacer(),
                    // Profile avatar
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(9999),
                        border: Border.all(color: Colors.white, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(9999),
                        child: Container(
                          color: AppTheme.primaryFixed,
                          child: Center(
                            child: Text(
                              _userInitials,
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.onPrimaryFixed,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      // ================================================================
      // Body with desktop drawer offset
      // ================================================================
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Desktop Navigation Drawer (hidden on mobile)
          if (isDesktop)
            Container(
              width: 288,
              height: MediaQuery.of(context).size.height - 64,
              decoration: BoxDecoration(
                color: isDark ? AppTheme.cardDark : Colors.white,
                border: Border(
                  right: BorderSide(
                    color: isDark ? AppTheme.borderDark : AppTheme.outlineVariant,
                    width: 0.5,
                  ),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 24,
                    offset: const Offset(4, 0),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Building info header
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Building Admin',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Downtown Plaza',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: AppTheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Navigation items
                    ..._drawerItems.map((item) {
                      final isSelected = item.index == _currentIndex;
                      return GestureDetector(
                        onTap: () {
                          if (item.index >= 0) {
                            setState(() => _currentIndex = item.index);
                          } else {
                            // Items with index -1 navigate via named routes
                            Navigator.of(context).pushNamed('/settings');
                          }
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? (isDark ? AppTheme.primary.withValues(alpha: 0.15) : AppTheme.primaryFixed.withValues(alpha: 0.5))
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                item.icon,
                                size: 20,
                                color: isSelected
                                    ? AppTheme.primary
                                    : (isDark ? AppTheme.textSecondaryDark : AppTheme.onSurfaceVariant),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                item.label,
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                                  color: isSelected
                                      ? AppTheme.primary
                                      : (isDark ? AppTheme.textSecondaryDark : AppTheme.onSurfaceVariant),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: _handleLogout,
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.logout_rounded,
                              size: 20,
                              color: isDark ? AppTheme.textSecondaryDark : AppTheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Logout',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: isDark ? AppTheme.textSecondaryDark : AppTheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          // Main content area
          Expanded(
            child: IndexedStack(
              index: _currentIndex,
              children: _screens,
            ),
          ),
        ],
      ),
      // ================================================================
      // Mobile Bottom Navigation - matches HTML design
      // ================================================================
      bottomNavigationBar: isDesktop
          ? null
          : Container(
              decoration: BoxDecoration(
                color: isDark ? AppTheme.cardDark : Colors.white,
                border: Border(
                  top: BorderSide(
                    color: isDark ? AppTheme.borderDark : AppTheme.outlineVariant,
                    width: 0.5,
                  ),
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: List.generate(_bottomNavItems.length, (index) {
                      final item = _bottomNavItems[index];
                      final isSelected = index == _currentIndex;
                      return GestureDetector(
                        onTap: () => setState(() => _currentIndex = index),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? (isDark
                                    ? AppTheme.primary.withValues(alpha: 0.2)
                                    : AppTheme.primaryFixed.withValues(alpha: 0.5))
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                item.icon,
                                size: 24,
                                color: isSelected
                                    ? AppTheme.primary
                                    : (isDark ? AppTheme.textSecondaryDark : AppTheme.onSurfaceVariant),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                item.label,
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                  color: isSelected
                                      ? AppTheme.primary
                                      : (isDark ? AppTheme.textSecondaryDark : AppTheme.onSurfaceVariant),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ),
            ),
      // ================================================================
      // Mobile Drawer
      // ================================================================
      drawer: isDesktop
          ? null
          : Drawer(
              backgroundColor: isDark ? AppTheme.cardDark : AppTheme.cardLight,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: SafeArea(
                child: Column(
                  children: [
                    // Drawer header
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: const BoxDecoration(
                        gradient: AppTheme.primaryGradient,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Center(
                              child: Text(
                                _userInitials,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 20,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _userDisplayName,
                            style: GoogleFonts.inter(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _userRole,
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: Colors.white.withValues(alpha: 0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Drawer items
                    Expanded(
                      child: ListView(
                        padding: EdgeInsets.zero,
                        children: [
                          _DrawerItem(
                            icon: Icons.home_work_rounded,
                            title: 'Dashboard',
                            isSelected: _currentIndex == 0,
                            isDark: isDark,
                            onTap: () {
                              setState(() => _currentIndex = 0);
                              Navigator.pop(context);
                            },
                          ),
                          _DrawerItem(
                            icon: Icons.group_add_rounded,
                            title: 'Tenant Onboarding',
                            isSelected: _currentIndex == 1,
                            isDark: isDark,
                            onTap: () {
                              setState(() => _currentIndex = 1);
                              Navigator.pop(context);
                            },
                          ),
                          _DrawerItem(
                            icon: Icons.receipt_long_rounded,
                            title: 'Rent Collection',
                            isSelected: _currentIndex == 2,
                            isDark: isDark,
                            onTap: () {
                              setState(() => _currentIndex = 2);
                              Navigator.pop(context);
                            },
                          ),
                          _DrawerItem(
                            icon: Icons.payments_rounded,
                            title: 'Invoices',
                            isSelected: _currentIndex == 3,
                            isDark: isDark,
                            onTap: () {
                              setState(() => _currentIndex = 3);
                              Navigator.pop(context);
                            },
                          ),
                          _DrawerItem(
                            icon: Icons.assessment_rounded,
                            title: 'Reports',
                            isSelected: _currentIndex == 4,
                            isDark: isDark,
                            onTap: () {
                              setState(() => _currentIndex = 4);
                              Navigator.pop(context);
                            },
                          ),
                          _DrawerItem(
                            icon: Icons.settings_rounded,
                            title: 'Settings',
                            isSelected: false,
                            isDark: isDark,
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.of(context).pushNamed('/settings');
                            },
                          ),
                          Divider(color: isDark ? AppTheme.borderDark : AppTheme.outlineVariant),
                          _DrawerItem(
                            icon: Icons.notifications_rounded,
                            title: 'Notifications',
                            isDark: isDark,
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.of(context).pushNamed('/notifications');
                            },
                          ),
                          _DrawerItem(
                            icon: Icons.person_rounded,
                            title: 'Profile',
                            isDark: isDark,
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.of(context).pushNamed('/profile');
                            },
                          ),
                          const SizedBox(height: 8),
                          Divider(color: isDark ? AppTheme.borderDark : AppTheme.outlineVariant),
                          _DrawerItem(
                            icon: Icons.logout_rounded,
                            title: 'Logout',
                            isDark: isDark,
                            onTap: () {
                              Navigator.pop(context);
                              _handleLogout();
                            },
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

class _BottomNavItem {
  final IconData icon;
  final String label;
  final bool isFilled;
  _BottomNavItem(this.icon, this.label, this.isFilled);
}

class _DrawerNavItem {
  final IconData icon;
  final String label;
  final int index;
  _DrawerNavItem(this.icon, this.label, this.index);
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;

  const _DrawerItem({
    required this.icon,
    required this.title,
    this.isSelected = false,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? AppTheme.primary : (isDark ? AppTheme.textSecondaryDark : AppTheme.onSurfaceVariant),
        size: 22,
      ),
      title: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          color: isSelected ? AppTheme.primary : (isDark ? AppTheme.textPrimaryDark : AppTheme.onSurface),
        ),
      ),
      selected: isSelected,
      selectedTileColor: AppTheme.primary.withValues(alpha: 0.08),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onTap: onTap,
    );
  }
}
