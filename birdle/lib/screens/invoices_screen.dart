import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:birdle/core/app_theme.dart';
import 'package:birdle/models/invoice_model.dart';
import 'package:birdle/services/invoice_service.dart';
import 'package:birdle/widgets/status_badge.dart';
import 'package:birdle/widgets/tab_selector.dart';
import 'package:birdle/widgets/skeleton_loader.dart';
import 'package:birdle/widgets/empty_state.dart';
import 'package:birdle/widgets/toast_notification.dart';
import 'package:intl/intl.dart';

/// Invoices screen with status filters and action buttons.
class InvoicesScreen extends StatefulWidget {
  const InvoicesScreen({super.key});

  @override
  State<InvoicesScreen> createState() => _InvoicesScreenState();
}

class _InvoicesScreenState extends State<InvoicesScreen> with AutomaticKeepAliveClientMixin {
  final InvoiceService _invoiceService = InvoiceService();
  List<InvoiceModel> _allInvoices = [];
  List<InvoiceModel> _filteredInvoices = [];
  String _selectedTab = 'all';
  bool _isLoading = true;
  String? _errorMessage;

  final List<String> _tabs = ['all', 'paid', 'unpaid', 'overdue'];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _loadInvoices();
    });
  }

  Future<void> _loadInvoices() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      _allInvoices = await _invoiceService.getInvoices();
      _applyFilter();
    } catch (e) {
      _errorMessage = e.toString();
    }
    if (mounted) setState(() => _isLoading = false);
  }

  void _applyFilter() {
    if (_selectedTab == 'all') {
      _filteredInvoices = List.from(_allInvoices);
    } else {
      _filteredInvoices = _allInvoices.where((i) => i.status == _selectedTab).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Invoices',
                style: GoogleFonts.inter(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimaryLight,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${_allInvoices.length} total',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
        TabSelector(
          tabs: _tabs,
          selectedTab: _selectedTab,
          onTabChanged: (tab) {
            setState(() => _selectedTab = tab);
            _applyFilter();
          },
        ),
        const SizedBox(height: 8),
        Expanded(
          child: _isLoading
              ? const CardSkeleton(itemCount: 4)
              : _errorMessage != null
                  ? _buildErrorState(isDark)
                  : _filteredInvoices.isEmpty
                      ? EmptyState(
                          icon: Icons.receipt_long_outlined,
                          title: 'No invoices found',
                          subtitle: 'Invoices will appear here once created',
                        )
                      : RefreshIndicator(
                          onRefresh: _loadInvoices,
                          child: ListView.builder(
                            padding: const EdgeInsets.only(bottom: 16),
                            itemCount: _filteredInvoices.length,
                            itemBuilder: (context, index) =>
                                _buildInvoiceCard(_filteredInvoices[index], isDark),
                          ),
                        ),
        ),
      ],
    );
  }

  Widget _buildInvoiceCard(InvoiceModel invoice, bool isDark) {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                invoice.invoiceNumber,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimaryLight,
                ),
              ),
              StatusBadge(status: invoice.status),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    invoice.customerName,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimaryLight,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    invoice.customerEmail,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight,
                    ),
                  ),
                ],
              ),
              Text(
                '\$${invoice.total.toStringAsFixed(2)}',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.calendar_today_rounded, size: 12, color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight),
              const SizedBox(width: 4),
              Text(
                'Issued: ${DateFormat('MMM dd, yyyy').format(invoice.issueDate)}',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight,
                ),
              ),
              const SizedBox(width: 16),
              Icon(Icons.event_rounded, size: 12, color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight),
              const SizedBox(width: 4),
              Text(
                'Due: ${DateFormat('MMM dd, yyyy').format(invoice.dueDate)}',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Action buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _ActionButton(
                icon: Icons.download_rounded,
                label: 'PDF',
                color: AppTheme.primary,
                onTap: () {
                  ToastNotification.show(
                    context: context,
                    message: 'Downloading ${invoice.invoiceNumber}.pdf',
                    type: ToastType.info,
                  );
                },
              ),
              const SizedBox(width: 8),
              _ActionButton(
                icon: Icons.share_rounded,
                label: 'WhatsApp',
                color: const Color(0xFF25D366),
                onTap: () {
                  ToastNotification.show(
                    context: context,
                    message: 'Sharing ${invoice.invoiceNumber} via WhatsApp',
                    type: ToastType.success,
                  );
                },
              ),
            ],
          ),
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
              'Failed to Load Invoices',
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
            ElevatedButton.icon(
              onPressed: _loadInvoices,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
