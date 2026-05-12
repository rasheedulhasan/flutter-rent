import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:birdle/core/app_theme.dart';
import 'package:birdle/services/pending_rent_service.dart';
import 'package:birdle/services/auth_service.dart';
import 'package:birdle/widgets/skeleton_loader.dart';
import 'package:intl/intl.dart';

/// ProManager Property Management Dashboard
/// Matches the HTML design with KPI bento grid, operational actions, and more.
class DashboardScreen extends StatefulWidget {
  final VoidCallback? onNavigateToOrders;
  final VoidCallback? onNavigateToBooking;
  final VoidCallback? onNavigateToPendingRent;

  const DashboardScreen({
    super.key,
    this.onNavigateToOrders,
    this.onNavigateToBooking,
    this.onNavigateToPendingRent,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with AutomaticKeepAliveClientMixin {
  final PendingRentService _pendingRentService = PendingRentService();
  final AuthService _authService = AuthService();

  bool _isLoading = true;
  final String _buildingName = 'Downtown Plaza';
  double _rentDueThisWeek = 0;
  int _pendingRooms = 0;
  int _totalRooms = 0;
  double _occupancyRate = 0;
  String _userName = '';
  String _userRole = '';

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    // Defer data loading to after the first frame to avoid layout issues
    // when this screen is used inside IndexedStack
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _loadData();
    });
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      // Load dashboard stats from the pending rent API
      final response = await _pendingRentService.getPendingRentItems();

      if (!mounted) return;
      setState(() {
        _totalRooms = response.total;
        _pendingRooms = response.summary.totalItems;
        _rentDueThisWeek = response.summary.totalPendingAmount;
        _occupancyRate = 0; // Occupancy rate not available from this endpoint

        // Use authenticated user info from the singleton AuthService
        // The user's full_name comes from the /users/validate endpoint response
        if (_authService.currentUser != null) {
          _userName = _authService.currentUser!.fullName.isNotEmpty
              ? _authService.currentUser!.fullName
              : _authService.currentUser!.name;
          _userRole = _authService.currentUser!.role;
        }

        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_isLoading) ...[
              _buildLoadingState(),
            ] else ...[
              // Personalized Greeting
              _buildGreetingSection(),
              const SizedBox(height: 24),

              // KPI Bento Grid
              _buildKpiBentoGrid(isDark),
              const SizedBox(height: 24),

              // Operational Actions
              _buildOperationalActions(isDark),
              const SizedBox(height: 24),

              // Utility Section (Profile & Logout)
              _buildUtilitySection(isDark),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CardSkeleton(itemCount: 1),
          const SizedBox(height: 16),
          const CardSkeleton(itemCount: 2),
          const SizedBox(height: 16),
          const CardSkeleton(itemCount: 3),
        ],
      ),
    );
  }

  Widget _buildGreetingSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome, $_userName ($_userRole)',
            style: GoogleFonts.inter(
              fontSize: 30,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.02,
              color: AppTheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Here is your daily building overview for $_buildingName.',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              height: 1.5,
              color: AppTheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKpiBentoGrid(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 600;
          if (isWide) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Main KPI Card - Rent Due This Week
                Expanded(
                  flex: 2,
                  child: _buildRentDueCard(isDark),
                ),
                const SizedBox(width: 16),
                // Side KPI - Occupancy Rate
                Expanded(
                  flex: 1,
                  child: _buildOccupancyCard(),
                ),
              ],
            );
          }
          return Column(
            children: [
              _buildRentDueCard(isDark),
              const SizedBox(height: 16),
              _buildOccupancyCard(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildRentDueCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.cardLight,
        border: Border.all(color: AppTheme.outlineVariant),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(9999),
                ),
                child: Text(
                  'RENT DUE THIS WEEK',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.05,
                    color: AppTheme.onSurfaceVariant,
                  ),
                ),
              ),
              Icon(Icons.payments_rounded, color: AppTheme.primary, size: 24),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '\$${NumberFormat('#,###').format(_rentDueThisWeek.toInt())}',
            style: GoogleFonts.inter(
              fontSize: 30,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.02,
              color: AppTheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.error_outline, color: AppTheme.error, size: 16),
              const SizedBox(width: 4),
              Text(
                '($_pendingRooms/$_totalRooms Rooms Pending)',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: AppTheme.error,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOccupancyCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.primaryContainer,
        border: Border.all(color: AppTheme.primary),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withValues(alpha: 0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.apartment_rounded,
            size: 40,
            color: AppTheme.onPrimaryContainer,
          ),
          const SizedBox(height: 12),
          Text(
            'OCCUPANCY RATE',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.05,
              color: AppTheme.onPrimaryContainer.withValues(alpha: 0.9),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${_occupancyRate.toStringAsFixed(0)}%',
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.01,
              color: AppTheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(9999),
            child: Container(
              height: 4,
              width: double.infinity,
              color: Colors.white.withValues(alpha: 0.2),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: _occupancyRate / 100,
                child: Container(
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOperationalActions(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Operational Actions',
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppTheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 600;
              if (isWide) {
                return Row(
                  children: [
                    Expanded(child: _buildCollectRentButton()),
                    const SizedBox(width: 16),
                    Expanded(child: _buildPendingRentButton()),
                    const SizedBox(width: 16),
                    Expanded(child: _buildNewBookingButton()),
                  ],
                );
              }
              return Column(
                children: [
                  _buildCollectRentButton(),
                  const SizedBox(height: 16),
                  _buildPendingRentButton(),
                  const SizedBox(height: 16),
                  _buildNewBookingButton(),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCollectRentButton() {
    return GestureDetector(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppTheme.primary,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primary.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.request_quote_rounded,
                color: Colors.white,
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'COLLECT RENT',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Process payments and send digital receipts instantly.',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Colors.white.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPendingRentButton() {
    return GestureDetector(
      onTap: widget.onNavigateToPendingRent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppTheme.cardLight,
          border: Border.all(color: AppTheme.outlineVariant),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.format_list_bulleted_rounded,
                    color: AppTheme.primary,
                    size: 32,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.error,
                    borderRadius: BorderRadius.circular(9999),
                  ),
                  child: Text(
                    'ALERT',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.05,
                      color: AppTheme.onError,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'PENDING RENT LIST',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppTheme.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'View $_pendingRooms overdue payments and send reminders.',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: AppTheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNewBookingButton() {
    return GestureDetector(
      onTap: widget.onNavigateToBooking,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppTheme.cardLight,
          border: Border.all(color: AppTheme.outlineVariant),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.surfaceContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.add_home_rounded,
                color: AppTheme.primary,
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'NEW ROOM BOOKING',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppTheme.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Onboard new tenants and manage unit availability.',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: AppTheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUtilitySection(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          const Divider(color: AppTheme.outlineVariant, thickness: 0.5),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 600;
              if (isWide) {
                return Row(
                  children: [
                    Expanded(child: _buildProfileButton()),
                    const SizedBox(width: 16),
                    Expanded(child: _buildLogoutButton()),
                  ],
                );
              }
              return Column(
                children: [
                  _buildProfileButton(),
                  const SizedBox(height: 12),
                  _buildLogoutButton(),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProfileButton() {
    return GestureDetector(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.cardLight,
          border: Border.all(color: AppTheme.outlineVariant),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.surfaceContainer,
                borderRadius: BorderRadius.circular(9999),
              ),
              child: const Icon(
                Icons.account_circle_rounded,
                color: AppTheme.onSurfaceVariant,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'MY PROFILE',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.onSurface,
                    ),
                  ),
                  Text(
                    'Settings & Account Security',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: AppTheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return GestureDetector(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.cardLight,
          border: Border.all(color: AppTheme.outlineVariant),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.errorContainer,
                borderRadius: BorderRadius.circular(9999),
              ),
              child: const Icon(
                Icons.logout_rounded,
                color: AppTheme.error,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'LOGOUT',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.onSurface,
                    ),
                  ),
                  Text(
                    'Securely exit the management system',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: AppTheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
