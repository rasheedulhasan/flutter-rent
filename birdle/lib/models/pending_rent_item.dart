import 'package:birdle/models/room_model.dart';
import 'package:birdle/models/transaction_model.dart';

/// Combined model representing a room with tenant and pending rent info.
/// This is the core data model for the Pending Rent screen.
class PendingRentItem {
  final RoomModel room;
  final TenantInfo tenant;
  final List<TransactionModel> transactions;
  final double pendingAmount;
  final String lastPaidMonth;
  final String lastPaidYear;
  final String? lastPaymentDate;
  final String paymentStatus; // paid, pending, partial

  PendingRentItem({
    required this.room,
    required this.tenant,
    required this.transactions,
    required this.pendingAmount,
    required this.lastPaidMonth,
    required this.lastPaidYear,
    this.lastPaymentDate,
    required this.paymentStatus,
  });

  /// Calculates pending rent and status from transactions.
  static PendingRentItem fromRoomWithTenantAndTransactions({
    required RoomModel room,
    required Map<String, dynamic> tenantData,
    required List<TransactionModel> transactions,
  }) {
    final tenant = TenantInfo.fromJson(tenantData);

    // Determine last paid month and pending amount
    String lastPaidMonth = '';
    String lastPaidYear = '';
    String? lastPaymentDate;
    double pendingAmount = 0.0;
    bool hasPartial = false;
    bool hasPending = false;
    bool hasPaid = false;

    // Sort transactions by date descending (newest first)
    final sortedTx = List<TransactionModel>.from(transactions)
      ..sort((a, b) {
        final aDate = a.transactionDate ?? '';
        final bDate = b.transactionDate ?? '';
        return bDate.compareTo(aDate);
      });

    for (final tx in sortedTx) {
      if (tx.isPaid) {
        hasPaid = true;
        if (lastPaidMonth.isEmpty && tx.periodMonth != null) {
          lastPaidMonth = tx.periodMonth!;
          lastPaidYear = tx.periodYear ?? '';
          lastPaymentDate = tx.transactionDate;
        }
      } else if (tx.isPartial) {
        hasPartial = true;
        pendingAmount += tx.amount;
      } else if (tx.isPending) {
        hasPending = true;
        pendingAmount += tx.amount;
      }
    }

    // If no transactions, use monthly rent as pending
    if (transactions.isEmpty) {
      pendingAmount = tenant.monthlyRent;
    }

    // Determine overall payment status
    String status;
    if (hasPending && !hasPartial && !hasPaid) {
      status = 'pending';
    } else if (hasPartial) {
      status = 'partial';
    } else if (hasPending || hasPartial) {
      status = 'pending';
    } else if (hasPaid && !hasPending && !hasPartial) {
      status = 'paid';
    } else {
      status = 'pending';
    }

    return PendingRentItem(
      room: room,
      tenant: tenant,
      transactions: transactions,
      pendingAmount: pendingAmount,
      lastPaidMonth: lastPaidMonth,
      lastPaidYear: lastPaidYear,
      lastPaymentDate: lastPaymentDate,
      paymentStatus: status,
    );
  }

  /// Returns a human-readable last paid label.
  String get lastPaidLabel {
    if (lastPaidMonth.isEmpty) return 'No payments yet';
    final months = {
      '01': 'Jan', '02': 'Feb', '03': 'Mar', '04': 'Apr',
      '05': 'May', '06': 'Jun', '07': 'Jul', '08': 'Aug',
      '09': 'Sep', '10': 'Oct', '11': 'Nov', '12': 'Dec',
    };
    final monthName = months[lastPaidMonth] ?? lastPaidMonth;
    return '$monthName $lastPaidYear';
  }

  /// Returns the building name (extracted from room data or default).
  String get buildingName => room.buildingId ?? 'Building A';
}

/// Tenant info extracted from the room-with-tenant API response.
class TenantInfo {
  final String fullName;
  final String phoneNumber;
  final String email;
  final double monthlyRent;
  final String status;
  final String? checkInDate;

  TenantInfo({
    required this.fullName,
    required this.phoneNumber,
    required this.email,
    required this.monthlyRent,
    required this.status,
    this.checkInDate,
  });

  /// Safely converts a dynamic value to String, handling both String and int.
  static String? _safeString(dynamic value) {
    if (value == null) return null;
    if (value is String) return value;
    return value.toString();
  }

  factory TenantInfo.fromJson(Map<String, dynamic> json) {
    return TenantInfo(
      fullName: _safeString(json['full_name']) ?? '',
      phoneNumber: _safeString(json['phone_number']) ?? '',
      email: _safeString(json['email']) ?? '',
      monthlyRent: (json['monthly_rent'] as num?)?.toDouble() ?? 0.0,
      status: _safeString(json['status']) ?? 'active',
      checkInDate: _safeString(json['check_in_date']),
    );
  }

  Map<String, dynamic> toJson() => {
        'full_name': fullName,
        'phone_number': phoneNumber,
        'email': email,
        'monthly_rent': monthlyRent,
        'status': status,
        'check_in_date': checkInDate,
      };
}
