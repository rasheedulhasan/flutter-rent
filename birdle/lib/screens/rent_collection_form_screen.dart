import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:birdle/core/app_theme.dart';
import 'package:birdle/models/rent_collection_model.dart';
import 'package:birdle/services/rent_collection_service.dart';
import 'package:intl/intl.dart';

/// Rent Collection Form Screen
/// Matches the ProManager HTML design with:
/// - TopAppBar with back button + title + profile
/// - Tenant Status Section (Bento Card)
/// - Transaction Details (Balance Owed, Amount Paid, Payment Date)
/// - Payment Method selector (Cash / Bank Transfer / Cheque)
/// - Notes / Reference textarea
/// - SMS Receipt toggle
/// - Staff Information section
/// - Fixed bottom SUBMIT COLLECTION button
class RentCollectionFormScreen extends StatefulWidget {
  final RentCollectionModel collection;

  const RentCollectionFormScreen({
    super.key,
    required this.collection,
  });

  @override
  State<RentCollectionFormScreen> createState() =>
      _RentCollectionFormScreenState();
}

class _RentCollectionFormScreenState extends State<RentCollectionFormScreen> {
  final RentCollectionService _service = RentCollectionService();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _pendingReasonController = TextEditingController();
  late DateTime _paymentDate;
  late DateTime _rentDueDate;
  String _selectedMethod = 'bank_transfer';
  bool _sendSmsReceipt = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _amountController.text = widget.collection.amount.toStringAsFixed(0);
    _paymentDate = DateTime.now();
    // Parse due date from the collection's dueDate string or calculate from daysUntilDue
    _rentDueDate = _parseDueDate();
  }

  DateTime _parseDueDate() {
    if (widget.collection.dueDate.isNotEmpty) {
      final parsed = DateTime.tryParse(widget.collection.dueDate);
      if (parsed != null) return parsed;
    }
    // Fallback: calculate from daysUntilDue
    return DateTime.now().add(Duration(days: widget.collection.daysUntilDue));
  }

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    _pendingReasonController.dispose();
    super.dispose();
  }

  Future<void> _onSubmit() async {
    final amountText = _amountController.text.trim();
    if (amountText.isEmpty) {
      _showError('Please enter the amount paid');
      return;
    }

    final amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) {
      _showError('Please enter a valid amount');
      return;
    }

    // Determine if this is a pending/partial payment
    final isPendingPayment = amount < widget.collection.monthlyRent;
    final pendingReason = _pendingReasonController.text.trim();

    if (isPendingPayment && pendingReason.isEmpty) {
      _showError('Pending reason is required for partial/pending payments');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final now = DateTime.now();
      await _service.recordPayment(
        tenantId: widget.collection.tenantId,
        roomId: widget.collection.roomId,
        collectedBy: 'staff_001',
        amount: amount,
        monthlyRent: widget.collection.monthlyRent,
        transactionDate: _paymentDate,
        rentDueDate: _rentDueDate,
        periodMonth: now.month,
        periodYear: now.year,
        paymentMethod: _selectedMethod,
        pendingReason: pendingReason,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Payment of \$${_formatAmount(amount)} recorded for ${widget.collection.roomNumber}',
            ),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            backgroundColor: AppTheme.success,
          ),
        );

        // Pop with true to signal success and trigger refresh
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: AppTheme.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final collection = widget.collection;
    final isOverdue = collection.status == 'overdue';

    return Scaffold(
      backgroundColor: AppTheme.background,
      // ================================================================
      // TopAppBar
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
                    // Back button
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        margin: const EdgeInsets.only(right: 8),
                        child: Icon(
                          Icons.arrow_back_rounded,
                          color: isDark
                              ? AppTheme.textSecondaryDark
                              : AppTheme.onSurfaceVariant,
                          size: 24,
                        ),
                      ),
                    ),
                    // Title
                    Expanded(
                      child: Text(
                        'Rent Collection: ${collection.roomNumber}',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.02,
                          color: isDark
                              ? AppTheme.textPrimaryDark
                              : AppTheme.onSurface,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // Profile avatar
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(9999),
                        border: Border.all(color: AppTheme.outlineVariant),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(9999),
                        child: Container(
                          color: AppTheme.surfaceContainer,
                          child: Center(
                            child: Text(
                              'JD',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.onSurfaceVariant,
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
      // Body
      // ================================================================
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Tenant Status Section (Bento Card)
          _buildTenantStatusCard(collection, isOverdue),
          const SizedBox(height: 24),

          // TRANSACTION DETAILS
          _buildSectionLabel('TRANSACTION DETAILS'),
          const SizedBox(height: 12),

          // Balance Owed
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.surfaceContainerLow,
              border: Border.all(color: AppTheme.outlineVariant),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Balance Owed (AED)',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.05,
                    color: AppTheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '\$${_formatAmount(collection.amount)}',
                  style: GoogleFonts.inter(
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.02,
                    color: AppTheme.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Amount Paid Input
          _buildInputLabel('Amount Paid (AED)'),
          const SizedBox(height: 6),
          Container(
            height: 48,
            decoration: BoxDecoration(
              color: AppTheme.surfaceContainerLowest,
              border: Border.all(color: AppTheme.outlineVariant),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              style: GoogleFonts.inter(
                fontSize: 16,
                color: AppTheme.onSurface,
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Payment Date Picker
          _buildInputLabel('Payment Date'),
          const SizedBox(height: 6),
          GestureDetector(
            onTap: _pickDate,
            child: Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppTheme.surfaceContainerLowest,
                border: Border.all(color: AppTheme.outlineVariant),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      DateFormat('yyyy-MM-dd').format(_paymentDate),
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        color: AppTheme.onSurface,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.calendar_today_rounded,
                    color: AppTheme.onSurfaceVariant,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // PAYMENT METHOD
          _buildSectionLabel('PAYMENT METHOD'),
          const SizedBox(height: 12),
          _buildPaymentMethodSelector(),
          const SizedBox(height: 24),

          // Pending Reason (shown when amount < monthly rent)
          _buildSectionLabel('PENDING REASON'),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.warning.withValues(alpha: 0.08),
              border: Border.all(
                color: AppTheme.warning.withValues(alpha: 0.3),
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      size: 18,
                      color: AppTheme.warning,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'If the amount paid is less than the full monthly rent (AED ${_formatAmount(widget.collection.monthlyRent)}), a pending reason is required.',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppTheme.warning,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceContainerLowest,
                    border: Border.all(color: AppTheme.outlineVariant),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    controller: _pendingReasonController,
                    maxLines: 2,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      color: AppTheme.onSurface,
                    ),
                    decoration: const InputDecoration(
                      hintText: 'e.g. Partial payment, awaiting balance...',
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: EdgeInsets.all(16),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Notes / Reference
          _buildInputLabel('Notes / Reference (Optional)'),
          const SizedBox(height: 6),
          Container(
            decoration: BoxDecoration(
              color: AppTheme.surfaceContainerLowest,
              border: Border.all(color: AppTheme.outlineVariant),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextField(
              controller: _notesController,
              maxLines: 3,
              style: GoogleFonts.inter(
                fontSize: 16,
                color: AppTheme.onSurface,
              ),
              decoration: const InputDecoration(
                hintText: 'Enter bank reference or collection notes...',
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.all(16),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // SMS Receipt Toggle
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.surfaceContainerLowest,
              border: Border.all(color: AppTheme.outlineVariant),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(
                  Icons.sms_rounded,
                  color: AppTheme.primary,
                  size: 22,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Send SMS Receipt to Tenant',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      color: AppTheme.onSurface,
                    ),
                  ),
                ),
                // Custom toggle
                GestureDetector(
                  onTap: () => setState(() => _sendSmsReceipt = !_sendSmsReceipt),
                  child: Container(
                    width: 44,
                    height: 24,
                    decoration: BoxDecoration(
                      color: _sendSmsReceipt
                          ? AppTheme.primary
                          : AppTheme.outlineVariant,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: AnimatedAlign(
                      duration: const Duration(milliseconds: 200),
                      alignment: _sendSmsReceipt
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        width: 20,
                        height: 20,
                        margin: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 2,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // STAFF INFORMATION
          _buildSectionLabel('STAFF INFORMATION'),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.outlineVariant.withValues(alpha: 0.4),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppTheme.outlineVariant),
                  ),
                  child: Icon(
                    Icons.badge_rounded,
                    color: AppTheme.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'COLLECTOR',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.05,
                        color: AppTheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'John Doe',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.onSurface,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'Verified',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.05,
                      color: AppTheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 100), // Space for bottom button
        ],
      ),
      // ================================================================
      // Fixed Bottom Submit Button
      // ================================================================
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: (isDark ? AppTheme.cardDark : Colors.white).withValues(alpha: 0.8),
          border: Border(
            top: BorderSide(
              color: isDark ? AppTheme.borderDark : AppTheme.outlineVariant,
              width: 0.5,
            ),
          ),
        ),
        child: SafeArea(
          child: SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              onPressed: _isSubmitting ? null : _onSubmit,
              icon: _isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.check_circle_rounded, size: 24),
              label: Text(
                _isSubmitting ? 'SUBMITTING...' : 'SUBMIT COLLECTION',
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.onPrimary,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: AppTheme.onPrimary,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                shadowColor: AppTheme.primary.withValues(alpha: 0.2),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Builds the tenant status bento card.
  Widget _buildTenantStatusCard(RentCollectionModel collection, bool isOverdue) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLowest,
        border: Border.all(color: AppTheme.outlineVariant),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Top row: Tenant name + Overdue badge
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TENANT',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.05,
                        color: AppTheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      collection.tenantName,
                      style: GoogleFonts.inter(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.01,
                        color: AppTheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
              if (isOverdue)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.errorContainer,
                    borderRadius: BorderRadius.circular(9999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.error_outline_rounded,
                        size: 18,
                        color: AppTheme.onErrorContainer,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '(${collection.daysUntilDue.abs()} Days Overdue)',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.05,
                          color: AppTheme.onErrorContainer,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          // Divider + Unit / Lease Type
          Container(
            padding: const EdgeInsets.only(top: 16),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: AppTheme.outlineVariant.withValues(alpha: 0.3),
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'UNIT',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.05,
                          color: AppTheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Room ${collection.roomNumber}',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'LEASE TYPE',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.05,
                          color: AppTheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        collection.leaseType,
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Builds a section label.
  Widget _buildSectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.05,
          color: AppTheme.onSurfaceVariant,
        ),
      ),
    );
  }

  /// Builds an input field label.
  Widget _buildInputLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppTheme.onSurface,
        ),
      ),
    );
  }

  /// Builds the payment method selector.
  Widget _buildPaymentMethodSelector() {
    final methods = [
      ('cash', 'Cash'),
      ('bank_transfer', 'Bank Transfer'),
      ('cheque', 'Cheque'),
    ];

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: methods.map((method) {
          final isSelected = _selectedMethod == method.$1;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedMethod = method.$1),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppTheme.surfaceContainerLowest
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  border: isSelected
                      ? Border.all(
                          color: AppTheme.outlineVariant.withValues(alpha: 0.2))
                      : null,
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  method.$2,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                    color: isSelected
                        ? AppTheme.primary
                        : AppTheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  /// Shows date picker.
  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _paymentDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: AppTheme.primary,
                ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _paymentDate = picked);
    }
  }

  /// Formats amount with commas.
  String _formatAmount(double amount) {
    return amount.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (match) => '${match[1]},',
        );
  }
}
