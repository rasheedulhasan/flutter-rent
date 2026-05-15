import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:birdle/core/app_theme.dart';
import 'package:birdle/models/customer_model.dart';
import 'package:birdle/services/customer_service.dart';
import 'package:birdle/widgets/search_bar_widget.dart';
import 'package:birdle/widgets/status_badge.dart';
import 'package:birdle/widgets/tab_selector.dart';
import 'package:birdle/widgets/pagination_bar.dart';
import 'package:birdle/widgets/skeleton_loader.dart';
import 'package:birdle/widgets/empty_state.dart';
import 'package:birdle/screens/room_booking_screen.dart';
import 'package:intl/intl.dart';

/// Customers screen with search, filter, and pagination.
class CustomersScreen extends StatefulWidget {
  const CustomersScreen({super.key});

  @override
  State<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {
  final CustomerService _customerService = CustomerService();
  final _searchController = TextEditingController();
  List<CustomerModel> _allCustomers = [];
  List<CustomerModel> _filteredCustomers = [];
  String _selectedTab = 'all';
  int _currentPage = 0;
  bool _isLoading = true;
  String? _errorMessage;
  static const int _pageSize = 6;

  final List<String> _tabs = ['all', 'active', 'vip', 'inactive', 'lead'];

  @override
  void initState() {
    super.initState();
    _loadCustomers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCustomers() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      _allCustomers = await _customerService.getCustomers();
      _applyFilters();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _applyFilters() {
    var filtered = List<CustomerModel>.from(_allCustomers);

    // Apply status filter
    if (_selectedTab != 'all') {
      filtered = filtered.where((c) => c.status == _selectedTab).toList();
    }

    // Apply search
    final query = _searchController.text.trim().toLowerCase();
    if (query.isNotEmpty) {
      filtered = filtered.where((c) {
        return c.name.toLowerCase().contains(query) ||
            c.email.toLowerCase().contains(query) ||
            c.company.toLowerCase().contains(query);
      }).toList();
    }

    setState(() {
      _filteredCustomers = filtered;
      _currentPage = 0;
    });
  }

  List<CustomerModel> get _currentPageCustomers {
    final start = _currentPage * _pageSize;
    final end = (start + _pageSize).clamp(0, _filteredCustomers.length);
    return _filteredCustomers.sublist(start, end);
  }

  int get _totalPages => (_filteredCustomers.length / _pageSize).ceil();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: Column(
        children: [
          // Header with Book a Tenant button
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Customers',
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
                        '${_allCustomers.length} total',
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
            hintText: 'Search customers...',
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
                    : _filteredCustomers.isEmpty
                        ? EmptyState(
                            icon: Icons.people_outline_rounded,
                            title: 'No customers found',
                            subtitle: 'Try adjusting your search or filters',
                          )
                        : RefreshIndicator(
                            onRefresh: _loadCustomers,
                            child: ListView.builder(
                              padding: const EdgeInsets.only(bottom: 16),
                              itemCount: _currentPageCustomers.length + 1,
                              itemBuilder: (context, index) {
                                if (index == _currentPageCustomers.length) {
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
                                return _buildCustomerCard(_currentPageCustomers[index], isDark);
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppTheme.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.cloud_off_rounded,
                size: 36,
                color: AppTheme.error.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Failed to Load Customers',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimaryLight,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? 'An unexpected error occurred.',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppTheme.textSecondaryLight,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadCustomers,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerCard(CustomerModel customer, bool isDark) {
    final initials = customer.name.split(' ').map((e) => e[0]).take(2).join();
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
                        customer.name,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimaryLight,
                        ),
                      ),
                    ),
                    StatusBadge(status: customer.status),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  customer.email,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${customer.company} · د.إ${NumberFormat('#,###').format(customer.totalSpent)} spent',
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
              'Filter Customers',
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
