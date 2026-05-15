import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as appwrite_models;
import 'package:birdle/core/app_theme.dart';
import 'package:birdle/models/pending_rent_item.dart';
import 'package:birdle/models/rent_collection_model.dart';
import 'package:birdle/screens/rent_collection_form_screen.dart';
import 'package:birdle/services/appwrite_client.dart';
import 'package:birdle/services/pending_rent_service.dart';
import 'package:birdle/widgets/empty_state.dart';
import 'package:birdle/widgets/skeleton_loader.dart';

/// Pending Rent Screen
///
/// Displays pending rent items fetched from the dedicated API endpoint.
/// Design matches the provided HTML reference with:
/// - Sticky search bar with timestamp
/// - Cards grouped by status (Overdue / Due Today / Upcoming)
/// - CALL and COLLECT RENT action buttons per card
/// - Bento mini stat summary section
class PendingRentScreen extends StatefulWidget {
  const PendingRentScreen({super.key});

  @override
  State<PendingRentScreen> createState() => _PendingRentScreenState();
}

class _PendingRentScreenState extends State<PendingRentScreen>
    with AutomaticKeepAliveClientMixin {
  final PendingRentService _service = PendingRentService();
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<PendingRentItem> _allItems = [];
  List<PendingRentItem> _filteredItems = [];
  PendingRentSummary? _summary;
  bool _isLoading = true;
  String? _errorMessage;

  // ── Appwrite Databases instance for direct queries ────────────────
  final Databases _databases = AppwriteClient().databases;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _loadData();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await _service.getPendingRentItems();
      if (mounted) {
        setState(() {
          _allItems = response.data;
          _filteredItems = response.data;
          _summary = response.summary;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  // ───────────────────────────────────────────────────────────────────
  // Appwrite Query Example: Pending Rent List
  // ───────────────────────────────────────────────────────────────────
  //
  // The method below demonstrates how to query the Appwrite rent_cycles
  // collection using `Query.equal('status', 'pending')` to fetch only
  // unpaid/pending rent records.
  //
  // Once a rent collection is processed via
  // [RentCollectionAppwriteService.recordPayment], the status is updated
  // to "paid", so this query will automatically exclude it from results.
  //
  // Usage:
  //   final items = await _fetchPendingRentCycles();
  //
  // ── Appwrite Query Reference ───────────────────────────────────────
  //   Query.equal('status', 'pending')     → status == "pending"
  //   Query.notEqual('status', 'paid')     → status != "paid"
  //   Query.orderDesc('due_date')          → newest due dates first
  //   Query.limit(25)                      → pagination: 25 per page
  //   Query.offset(0)                      → pagination: start at 0
  // ───────────────────────────────────────────────────────────────────
  // ignore: unused_element
  Future<List<appwrite_models.Document>> _fetchPendingRentCycles() async {
    try {
      final response = await _databases.listDocuments(
        databaseId: AppwriteClient.databaseId,
        collectionId: AppwriteClient.rentCyclesCollectionId,
        queries: [
          Query.equal('status', 'pending'),   // ← only pending items
          Query.orderDesc('due_date'),        // ← most urgent first
          Query.limit(50),                    // ← max 50 results
        ],
      );
      return response.documents;
    } catch (e) {
      debugPrint('Failed to fetch pending rent cycles: $e');
      rethrow;
    }
  }

  void _onSearchChanged() {
    final query = _searchController.text;
    setState(() {
      _filteredItems = _service.searchItems(_allItems, query);
    });
  }

  Future<void> _onRefresh() async {
    await _loadData();
  }

  void _onCallTenant(PendingRentItem item) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Calling ${item.tenantName}...'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _onCollectRent(PendingRentItem item) async {
    final collection = _convertToRentCollectionModel(item);
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => RentCollectionFormScreen(collection: collection),
      ),
    );

    // If payment was successfully recorded, refresh the list
    if (result == true && mounted) {
      _loadData();
    }
  }

  /// Converts a [PendingRentItem] to a [RentCollectionModel] for the form screen.
  RentCollectionModel _convertToRentCollectionModel(PendingRentItem item) {
    // Determine daysUntilDue: negative for overdue, positive for upcoming
    final daysUntilDue = item.status == 'overdue'
        ? -item.overdueDays
        : item.remainingDays;

    return RentCollectionModel(
      id: item.tenantId,
      roomNumber: item.roomNumber,
      tenantName: item.tenantName,
      amount: item.monthlyRent,
      status: item.status,
      daysUntilDue: daysUntilDue,
      leaseType: 'Residential',
      phoneNumber: null,
      tenantId: item.tenantId,
      roomId: item.roomId,
      monthlyRent: item.monthlyRent,
      dueDate: item.dueDate,
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ColoredBox(
      color: AppTheme.background,
      child: Column(
        children: [
          _buildHeader(isDark),
          Expanded(child: _buildBody(isDark)),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Container(
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
                // Back button
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    margin: const EdgeInsets.only(right: 4),
                    child: Icon(
                      Icons.arrow_back_rounded,
                      color: isDark
                          ? AppTheme.textSecondaryDark
                          : AppTheme.onSurfaceVariant,
                      size: 22,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  'Pending Rent',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color:
                        isDark ? AppTheme.textPrimaryDark : AppTheme.onSurface,
                  ),
                ),
                const Spacer(),
                // Filter button
                GestureDetector(
                  onTap: () {
                    // TODO: Implement filter
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppTheme.surfaceContainerLow
                          : AppTheme.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.filter_list_rounded,
                      color: isDark
                          ? AppTheme.textSecondaryDark
                          : AppTheme.onSurfaceVariant,
                      size: 22,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Profile avatar
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(9999),
                    color: AppTheme.surfaceContainer,
                  ),
                  child: Center(
                    child: Text(
                      'PM',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(bool isDark) {
    if (_isLoading) {
      return _buildLoadingState(isDark);
    }

    if (_errorMessage != null) {
      return _buildErrorState(isDark);
    }

    return RefreshIndicator(
      onRefresh: _onRefresh,
      color: AppTheme.primary,
      child: CustomScrollView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          // Sticky Search & Timestamp
          SliverToBoxAdapter(child: _buildSearchAndTimestamp(isDark)),

          // Rent List
          if (_filteredItems.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: _buildEmptyState(isDark),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    return _buildRentCard(_filteredItems[index], isDark);
                  },
                  childCount: _filteredItems.length,
                ),
              ),
            ),

          // Bento Mini Stat Section
          if (_filteredItems.isNotEmpty)
            SliverToBoxAdapter(child: _buildMiniStats(isDark)),
        ],
      ),
    );
  }

  Widget _buildLoadingState(bool isDark) {
    return RefreshIndicator(
      onRefresh: _onRefresh,
      color: AppTheme.primary,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(child: _buildSearchAndTimestamp(isDark)),
          const SliverToBoxAdapter(child: CardSkeleton(itemCount: 3)),
        ],
      ),
    );
  }

  Widget _buildErrorState(bool isDark) {
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
              'Failed to Load Data',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color:
                    isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimaryLight,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? 'An unexpected error occurred.',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: isDark
                    ? AppTheme.textSecondaryDark
                    : AppTheme.textSecondaryLight,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: 160,
              child: ElevatedButton.icon(
                onPressed: _loadData,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Try Again'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return EmptyState(
      icon: Icons.check_circle_outline_rounded,
      title: 'All Rent Collected',
      subtitle:
          'All occupied rooms have their rent paid up to date.\nNo pending payments at this time.',
    );
  }

  Widget _buildSearchAndTimestamp(bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search bar
          Container(
            height: 48,
            decoration: BoxDecoration(
              color: isDark
                  ? AppTheme.surfaceContainerLow
                  : AppTheme.surfaceContainerLowest,
              border: Border.all(
                color: isDark ? AppTheme.borderDark : AppTheme.outlineVariant,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              style: GoogleFonts.inter(
                fontSize: 15,
                color:
                    isDark ? AppTheme.textPrimaryDark : AppTheme.onSurface,
              ),
              decoration: InputDecoration(
                hintText: 'Search by Room/Name...',
                hintStyle: GoogleFonts.inter(
                  color: isDark
                      ? AppTheme.textSecondaryDark
                      : AppTheme.onSurfaceVariant,
                  fontSize: 15,
                ),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: isDark
                      ? AppTheme.textSecondaryDark
                      : AppTheme.outline,
                  size: 22,
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? GestureDetector(
                        onTap: () {
                          _searchController.clear();
                        },
                        child: Icon(
                          Icons.close_rounded,
                          color: isDark
                              ? AppTheme.textSecondaryDark
                              : AppTheme.outline,
                          size: 20,
                        ),
                      )
                    : null,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Timestamp
          Row(
            children: [
              Icon(
                Icons.history_rounded,
                size: 16,
                color: isDark
                    ? AppTheme.textSecondaryDark
                    : AppTheme.onSurfaceVariant,
              ),
              const SizedBox(width: 4),
              Text(
                'List updated: Today',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.05,
                  color: isDark
                      ? AppTheme.textSecondaryDark
                      : AppTheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRentCard(PendingRentItem item, bool isDark) {
    final isOverdue = item.status == 'overdue';
    final isDueToday = item.status == 'due_today';

    // Determine card border color based on status
    Color borderColor;
    if (isOverdue) {
      borderColor = AppTheme.errorContainer.withValues(alpha: 0.5);
    } else if (isDueToday) {
      borderColor = AppTheme.tertiaryContainer.withValues(alpha: 0.2);
    } else {
      borderColor = AppTheme.outlineVariant.withValues(alpha: 0.3);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark : AppTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Top row: Status badge + Room info (left) | Amount (right)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left: Status badge + Room + Tenant
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Status badge
                      _buildStatusBadge(item),
                      const SizedBox(height: 8),
                      // Room number
                      Text(
                        'Room ${item.roomNumber}',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? AppTheme.textPrimaryDark
                              : AppTheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      // Tenant name
                      Text(
                        'Tenant: ${item.tenantName}',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: isDark
                              ? AppTheme.textSecondaryDark
                              : AppTheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                // Right: Amount
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'د.إ${_formatAmount(item.monthlyRent)}',
                      style: GoogleFonts.inter(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: isOverdue
                            ? AppTheme.error
                            : isDueToday
                                ? AppTheme.tertiaryContainer
                                : AppTheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.dueDescription,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.05,
                        color: isOverdue
                            ? AppTheme.error
                            : isDueToday
                                ? AppTheme.tertiaryContainer
                                : AppTheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Action buttons: CALL + COLLECT RENT
            Row(
              children: [
                // CALL button
                Expanded(
                  child: SizedBox(
                    height: 44,
                    child: OutlinedButton.icon(
                      onPressed: () => _onCallTenant(item),
                      icon: const Icon(Icons.call_rounded, size: 18),
                      label: Text(
                        'CALL',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.05,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: isDark
                              ? AppTheme.borderDark
                              : AppTheme.outlineVariant,
                        ),
                        foregroundColor: isDark
                            ? AppTheme.textPrimaryDark
                            : AppTheme.onSurface,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // COLLECT RENT button
                Expanded(
                  flex: 2,
                  child: SizedBox(
                    height: 44,
                    child: ElevatedButton.icon(
                      onPressed: () => _onCollectRent(item),
                      icon: const Icon(Icons.payments_rounded, size: 18),
                      label: Text(
                        'COLLECT RENT',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.05,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        foregroundColor: AppTheme.onPrimary,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(PendingRentItem item) {
    // Map status directly from API's payment_status field
    Color bgColor;
    Color textColor;

    switch (item.status) {
      case 'overdue':
        // Red
        bgColor = AppTheme.error.withValues(alpha: 0.1);
        textColor = AppTheme.error;
      case 'due_today':
        // Orange
        bgColor = AppTheme.tertiaryFixed;
        textColor = AppTheme.onTertiaryFixedVariant;
      case 'pending':
        // Yellow
        bgColor = AppTheme.warning.withValues(alpha: 0.15);
        textColor = AppTheme.warning;
      case 'upcoming':
      default:
        // Blue / Orange
        bgColor = AppTheme.primary.withValues(alpha: 0.1);
        textColor = AppTheme.primary;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        item.statusLabel,
        style: GoogleFonts.inter(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.05,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildMiniStats(bool isDark) {
    final totalPending = _summary?.totalCombined ?? 0.0;
    final overdueAmount = _summary?.totalOverdue ?? 0.0;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Total Pending
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppTheme.primary.withValues(alpha: 0.1),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'TOTAL PENDING',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.05,
                      color: AppTheme.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'د.إ${_formatAmount(totalPending)}',
                    style: GoogleFonts.inter(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Across ${_filteredItems.length} units',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppTheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Overdue Amount
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.error.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppTheme.error.withValues(alpha: 0.1),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'OVERDUE AMOUNT',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.05,
                      color: AppTheme.error,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'د.إ${_formatAmount(overdueAmount)}',
                    style: GoogleFonts.inter(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.error,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Requires immediate action',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppTheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatAmount(double amount) {
    return amount.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (match) => '${match[1]},',
        );
  }
}
