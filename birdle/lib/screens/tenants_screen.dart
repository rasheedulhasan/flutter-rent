import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:birdle/core/app_theme.dart';
import 'package:birdle/models/tenant_model.dart';
import 'package:birdle/services/tenant_service.dart';
import 'package:birdle/widgets/search_bar_widget.dart';
import 'package:birdle/widgets/status_badge.dart';
import 'package:birdle/widgets/tab_selector.dart';
import 'package:birdle/widgets/pagination_bar.dart';
import 'package:birdle/widgets/skeleton_loader.dart';
import 'package:birdle/widgets/empty_state.dart';
import 'package:birdle/screens/room_booking_screen.dart';
import 'package:intl/intl.dart';

/// Tenants screen that fetches data from the live API.
/// Supports search, status filtering, and pagination.
class TenantsScreen extends StatefulWidget {
  const TenantsScreen({super.key});

  @override
  State<TenantsScreen> createState() => _TenantsScreenState();
}

class _TenantsScreenState extends State<TenantsScreen> with AutomaticKeepAliveClientMixin {
  final _searchController = TextEditingController();
  final TenantService _tenantService = TenantService();

  List<TenantModel> _allTenants = [];
  List<TenantModel> _filteredTenants = [];
  String _selectedTab = 'all';
  int _currentPage = 0;
  bool _isLoading = true;
  String? _errorMessage;
  static const int _pageSize = 6;

  final List<String> _tabs = ['all', 'active', 'inactive', 'moved_out'];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _loadTenants();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadTenants() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final tenants = await _tenantService.getTenants();
      if (!mounted) return;
      setState(() {
        _allTenants = tenants;
        _isLoading = false;
      });
      _applyFilters();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load tenants. Pull to retry.';
      });
    }
  }

  void _applyFilters() {
    var filtered = List<TenantModel>.from(_allTenants);

    // Apply status filter
    if (_selectedTab != 'all') {
      filtered = filtered.where((t) => t.status == _selectedTab).toList();
    }

    // Apply search
    final query = _searchController.text.trim().toLowerCase();
    if (query.isNotEmpty) {
      filtered = filtered.where((t) {
        return t.fullName.toLowerCase().contains(query) ||
            t.email.toLowerCase().contains(query) ||
            t.phoneNumber.toLowerCase().contains(query);
      }).toList();
    }

    setState(() {
      _filteredTenants = filtered;
      _currentPage = 0;
    });
  }

  List<TenantModel> get _currentPageTenants {
    final start = _currentPage * _pageSize;
    final end = (start + _pageSize).clamp(0, _filteredTenants.length);
    return _filteredTenants.sublist(start, end);
  }

  int get _totalPages => (_filteredTenants.length / _pageSize).ceil();

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      children: [
        // Header with Book a Tenant button
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tenants',
                style: GoogleFonts.inter(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimaryLight,
                ),
              ),
              Row(
                children: [
                  // Book a Tenant button
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const RoomBookingScreen(),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: AppTheme.primaryGradient,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primary.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.person_add_rounded,
                            size: 18,
                            color: AppTheme.onPrimary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Book a Tenant',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.onPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${_allTenants.length} total',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Search bar
        SearchBarWidget(
          controller: _searchController,
          hintText: 'Search tenants...',
          onChanged: (_) => _applyFilters(),
          onFilterTap: () => _showFilterDialog(),
        ),

        // Tabs
        TabSelector(
          tabs: _tabs,
          selectedTab: _selectedTab,
          onTabChanged: (tab) {
            setState(() => _selectedTab = tab);
            _applyFilters();
          },
        ),
        const SizedBox(height: 8),

        // Content
        Expanded(
          child: _isLoading
              ? const CardSkeleton(itemCount: 4)
              : _errorMessage != null
                  ? _buildErrorState()
                  : _filteredTenants.isEmpty
                      ? EmptyState(
                          icon: Icons.people_outline_rounded,
                          title: 'No tenants found',
                          subtitle: 'Try adjusting your search or filters',
                        )
                      : RefreshIndicator(
                          onRefresh: _loadTenants,
                          child: ListView.builder(
                            padding: const EdgeInsets.only(bottom: 16),
                            itemCount: _currentPageTenants.length + 1,
                            itemBuilder: (context, index) {
                              if (index == _currentPageTenants.length) {
                                if (_totalPages > 1) {
                                  return PaginationBar(
                                    currentPage: _currentPage,
                                    totalPages: _totalPages,
                                    onPageChanged: (page) {
                                      setState(() => _currentPage = page);
                                    },
                                  );
                                }
                                return const SizedBox.shrink();
                              }
                              return _buildTenantCard(_currentPageTenants[index], isDark);
                            },
                          ),
                        ),
        ),
      ],
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.cloud_off_rounded,
              size: 64,
              color: AppTheme.error.withValues(alpha: 0.6),
            ),
            const SizedBox(height: 16),
            Text(
              'Connection Error',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppTheme.error,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? 'Unable to reach the server.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppTheme.textSecondaryLight,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadTenants,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: AppTheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTenantCard(TenantModel tenant, bool isDark) {
    final initials = tenant.fullName.split(' ').map((e) => e[0]).take(2).join();
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark : AppTheme.cardLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(
                initials,
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  fontSize: 15,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        tenant.fullName,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimaryLight,
                        ),
                      ),
                    ),
                    StatusBadge(status: tenant.status),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  tenant.email,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${tenant.phoneNumber} · د.إ${NumberFormat('#,###').format(tenant.monthlyRent)}/mo',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),
          // Arrow
          Icon(
            Icons.chevron_right_rounded,
            color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight,
            size: 20,
          ),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Filter Tenants',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _tabs.map((tab) {
                final isSelected = tab == _selectedTab;
                return ChoiceChip(
                  label: Text(tab[0].toUpperCase() + tab.substring(1)),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() => _selectedTab = tab);
                    _applyFilters();
                    Navigator.pop(context);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
