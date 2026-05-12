import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:birdle/core/app_theme.dart';
import 'package:birdle/models/pending_rent_item.dart';
import 'package:birdle/services/pending_rent_service.dart';
import 'package:birdle/widgets/empty_state.dart';
import 'package:birdle/widgets/skeleton_loader.dart';

/// Pending Rent Screen
///
/// Displays all occupied rooms with pending rent information.
/// Features:
/// - Summary cards (Total Rooms, Occupied, Pending Payments, Total Pending Amount)
/// - Searchable room list with tenant and rent details
/// - Pull to refresh
/// - Loading skeletons
/// - Empty state
/// - Card actions (View Details, Collect Rent, Call, WhatsApp)
class PendingRentScreen extends StatefulWidget {
  const PendingRentScreen({super.key});

  @override
  State<PendingRentScreen> createState() => _PendingRentScreenState();
}

class _PendingRentScreenState extends State<PendingRentScreen> with AutomaticKeepAliveClientMixin {
  final PendingRentService _service = PendingRentService();
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<PendingRentItem> _pendingItems = [];
  List<PendingRentItem> _filteredItems = [];
  bool _isLoading = true;
  String? _errorMessage;
  int _totalRooms = 0;
  int _occupiedRooms = 0;

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
      final items = await _service.getPendingRentItems();
      final allRooms = await _service.getAllRooms();
      final occupiedRooms = allRooms.where((r) => r.isOccupied).toList();
      if (mounted) {
        setState(() {
          _pendingItems = items;
          _filteredItems = items;
          _totalRooms = allRooms.length;
          _occupiedRooms = occupiedRooms.length;
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

  void _onSearchChanged() {
    final query = _searchController.text;
    setState(() {
      _filteredItems = _service.searchItems(_pendingItems, query);
    });
  }

  Future<void> _onRefresh() async {
    await _loadData();
  }

  void _onViewDetails(PendingRentItem item) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Viewing details for ${item.tenant.fullName}'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _onCollectRent(PendingRentItem item) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Collecting rent from ${item.tenant.fullName}...'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _onCallTenant(PendingRentItem item) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Calling ${item.tenant.fullName}...'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _onWhatsAppTenant(PendingRentItem item) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening WhatsApp for ${item.tenant.fullName}...'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
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
                Text(
                  'Pending Rent',
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppTheme.textPrimaryDark : AppTheme.onSurface,
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
          // Search bar
          SliverToBoxAdapter(child: _buildSearchBar(isDark)),

          // Summary cards
          SliverToBoxAdapter(child: _buildSummaryCards(isDark)),

          // Section header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: Row(
                children: [
                  Text(
                    'Pending Rent List',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppTheme.textPrimaryDark : AppTheme.onSurface,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppTheme.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${_filteredItems.length}',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.error,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Room list or empty state
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
                    return _buildRoomCard(_filteredItems[index], isDark);
                  },
                  childCount: _filteredItems.length,
                ),
              ),
            ),
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
          SliverToBoxAdapter(child: _buildSearchBar(isDark)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: List.generate(4, (index) => Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(left: index > 0 ? 8 : 0),
                    child: const StatCardSkeleton(),
                  ),
                )),
              ),
            ),
          ),
          const SliverToBoxAdapter(child: CardSkeleton(itemCount: 4)),
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
                color: isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimaryLight,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? 'An unexpected error occurred.',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight,
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
      subtitle: 'All occupied rooms have their rent paid up to date.\nNo pending payments at this time.',
    );
  }

  Widget _buildSearchBar(bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: isDark ? AppTheme.surfaceContainerLow : AppTheme.surfaceContainerLowest,
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
            color: isDark ? AppTheme.textPrimaryDark : AppTheme.onSurface,
          ),
          decoration: InputDecoration(
            hintText: 'Search by room or tenant name...',
            hintStyle: GoogleFonts.inter(
              color: isDark ? AppTheme.textSecondaryDark : AppTheme.onSurfaceVariant,
              fontSize: 15,
            ),
            prefixIcon: Icon(
              Icons.search_rounded,
              color: isDark ? AppTheme.textSecondaryDark : AppTheme.outline,
              size: 22,
            ),
            suffixIcon: _searchController.text.isNotEmpty
                ? GestureDetector(
                    onTap: () {
                      _searchController.clear();
                    },
                    child: Icon(
                      Icons.close_rounded,
                      color: isDark ? AppTheme.textSecondaryDark : AppTheme.outline,
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
    );
  }

  Widget _buildSummaryCards(bool isDark) {
    final totalPendingAmount =
        _filteredItems.fold(0.0, (sum, item) => sum + item.pendingAmount);
    final pendingCount = _filteredItems.length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Row 1: Total Rooms & Occupied Rooms
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  title: 'Total Rooms',
                  value: '$_totalRooms',
                  icon: Icons.meeting_room_rounded,
                  color: AppTheme.primary,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildSummaryCard(
                  title: 'Occupied Rooms',
                  value: '$_occupiedRooms',
                  icon: Icons.person_pin_rounded,
                  color: AppTheme.info,
                  isDark: isDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Row 2: Pending Payments & Total Pending Amount
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  title: 'Pending Payments',
                  value: '$pendingCount',
                  icon: Icons.pending_actions_rounded,
                  color: AppTheme.warning,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildSummaryCard(
                  title: 'Total Pending',
                  value: 'AED ${_formatAmount(totalPendingAmount)}',
                  icon: Icons.money_off_rounded,
                  color: AppTheme.error,
                  isDark: isDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark : AppTheme.cardLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? AppTheme.borderDark : AppTheme.outlineVariant,
          width: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppTheme.textPrimaryDark : AppTheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: isDark ? AppTheme.textSecondaryDark : AppTheme.onSurfaceVariant,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoomCard(PendingRentItem item, bool isDark) {
    final statusColor = _getStatusColor(item.paymentStatus);
    final statusLabel = _getStatusLabel(item.paymentStatus);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark : AppTheme.cardLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppTheme.borderDark : AppTheme.outlineVariant,
          width: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top section: Room info + Status badge
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Room icon
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      item.room.roomNumber,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Room details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Room ${item.room.roomNumber}',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppTheme.textPrimaryDark : AppTheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.buildingName,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: isDark ? AppTheme.textSecondaryDark : AppTheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          _buildInfoChip(Icons.layers_rounded, 'Floor ${item.room.floor}', isDark),
                          const SizedBox(width: 8),
                          _buildInfoChip(Icons.home_work_rounded, item.room.type, isDark),
                        ],
                      ),
                    ],
                  ),
                ),
                // Status badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: statusColor.withValues(alpha: 0.3),
                      width: 0.5,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: statusColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        statusLabel,
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: statusColor,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Divider
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Divider(
              color: isDark ? AppTheme.borderDark : AppTheme.outlineVariant,
              height: 1,
            ),
          ),

          // Tenant info section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                // Tenant avatar
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryFixed.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      _getInitials(item.tenant.fullName),
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.tenant.fullName,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppTheme.textPrimaryDark : AppTheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(Icons.phone_rounded, size: 12,
                              color: isDark ? AppTheme.textSecondaryDark : AppTheme.onSurfaceVariant),
                          const SizedBox(width: 4),
                          Text(
                            item.tenant.phoneNumber,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: isDark ? AppTheme.textSecondaryDark : AppTheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Check-in date
                if (item.tenant.checkInDate != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Check-in',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: isDark ? AppTheme.textSecondaryDark : AppTheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _formatDate(item.tenant.checkInDate!),
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppTheme.textPrimaryDark : AppTheme.onSurface,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),

          // Divider
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Divider(
              color: isDark ? AppTheme.borderDark : AppTheme.outlineVariant,
              height: 1,
            ),
          ),

          // Rent info section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                // Monthly Rent
                Expanded(
                  child: _buildRentInfoTile(
                    label: 'Monthly Rent',
                    value: 'AED ${_formatAmount(item.tenant.monthlyRent)}',
                    isDark: isDark,
                  ),
                ),
                Container(
                  width: 1,
                  height: 36,
                  color: isDark ? AppTheme.borderDark : AppTheme.outlineVariant,
                ),
                // Pending Amount
                Expanded(
                  child: _buildRentInfoTile(
                    label: 'Pending',
                    value: 'AED ${_formatAmount(item.pendingAmount)}',
                    valueColor: statusColor,
                    isDark: isDark,
                  ),
                ),
                Container(
                  width: 1,
                  height: 36,
                  color: isDark ? AppTheme.borderDark : AppTheme.outlineVariant,
                ),
                // Last Paid
                Expanded(
                  child: _buildRentInfoTile(
                    label: 'Last Paid',
                    value: item.lastPaidLabel,
                    isDark: isDark,
                  ),
                ),
              ],
            ),
          ),

          // Action buttons
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
            child: Row(
              children: [
                // View Details
                Expanded(
                  child: _buildActionButton(
                    label: 'Details',
                    icon: Icons.visibility_rounded,
                    color: AppTheme.primary,
                    isDark: isDark,
                    onTap: () => _onViewDetails(item),
                  ),
                ),
                const SizedBox(width: 8),
                // Collect Rent
                Expanded(
                  child: _buildActionButton(
                    label: 'Collect',
                    icon: Icons.payments_rounded,
                    color: AppTheme.success,
                    isDark: isDark,
                    onTap: () => _onCollectRent(item),
                    isFilled: true,
                  ),
                ),
                const SizedBox(width: 8),
                // Call
                _buildIconButton(
                  icon: Icons.call_rounded,
                  color: AppTheme.info,
                  isDark: isDark,
                  onTap: () => _onCallTenant(item),
                ),
                const SizedBox(width: 8),
                // WhatsApp
                _buildIconButton(
                  icon: Icons.chat_rounded,
                  color: const Color(0xFF25D366),
                  isDark: isDark,
                  onTap: () => _onWhatsAppTenant(item),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label, bool isDark) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12,
            color: isDark ? AppTheme.textSecondaryDark : AppTheme.onSurfaceVariant),
        const SizedBox(width: 3),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 11,
            color: isDark ? AppTheme.textSecondaryDark : AppTheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildRentInfoTile({
    required String label,
    required String value,
    Color? valueColor,
    required bool isDark,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: isDark ? AppTheme.textSecondaryDark : AppTheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: valueColor ??
                (isDark ? AppTheme.textPrimaryDark : AppTheme.onSurface),
          ),
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required Color color,
    required bool isDark,
    required VoidCallback onTap,
    bool isFilled = false,
  }) {
    if (isFilled) {
      return SizedBox(
        height: 38,
        child: ElevatedButton(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16),
              const SizedBox(width: 4),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SizedBox(
      height: 38,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: color.withValues(alpha: 0.4)),
          foregroundColor: color,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16),
            const SizedBox(width: 4),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required Color color,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: 38,
      height: 38,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: color.withValues(alpha: 0.4)),
          foregroundColor: color,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Icon(icon, size: 18),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return AppTheme.success;
      case 'pending':
        return AppTheme.error;
      case 'partial':
        return AppTheme.warning;
      default:
        return AppTheme.error;
    }
  }

  String _getStatusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return 'PAID';
      case 'pending':
        return 'PENDING';
      case 'partial':
        return 'PARTIAL';
      default:
        return status.toUpperCase();
    }
  }

  String _getInitials(String name) {
    if (name.isEmpty) return '?';
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }

  String _formatAmount(double amount) {
    return amount.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (match) => '${match[1]},',
        );
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      final months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return '${date.day} ${months[date.month - 1]} ${date.year}';
    } catch (_) {
      return dateStr;
    }
  }
}
