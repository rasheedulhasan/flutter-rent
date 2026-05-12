/// Model representing a single pending rent entry from the API.
///
/// Maps directly to the JSON objects in the `data` array from:
/// `GET /rent/pending/`
class PendingRentItem {
  final String tenantId;
  final String tenantName;
  final String roomId;
  final String roomName;
  final String roomNumber;
  final double monthlyRent;
  final String dueDate;
  final int overdueDays;
  final int remainingDays;
  final String status; // "overdue", "due_today", "upcoming"

  PendingRentItem({
    required this.tenantId,
    required this.tenantName,
    required this.roomId,
    required this.roomName,
    required this.roomNumber,
    required this.monthlyRent,
    required this.dueDate,
    required this.overdueDays,
    required this.remainingDays,
    required this.status,
  });

  factory PendingRentItem.fromJson(Map<String, dynamic> json) {
    return PendingRentItem(
      tenantId: json['tenant_id'] as String? ?? '',
      tenantName: json['tenant_name'] as String? ?? '',
      roomId: json['room_id'] as String? ?? '',
      roomName: json['room_name'] as String? ?? '',
      roomNumber: json['room_number'] as String? ?? '',
      monthlyRent: (json['monthly_rent'] as num?)?.toDouble() ?? 0.0,
      dueDate: json['due_date'] as String? ?? '',
      overdueDays: json['overdue_days'] as int? ?? 0,
      remainingDays: json['remaining_days'] as int? ?? 0,
      status: json['status'] as String? ?? 'upcoming',
    );
  }

  /// Human-readable status label.
  String get statusLabel {
    switch (status) {
      case 'overdue':
        return 'Overdue';
      case 'due_today':
        return 'Due Today';
      case 'upcoming':
        return 'Upcoming';
      default:
        return status;
    }
  }

  /// Description of the due/overdue state.
  String get dueDescription {
    if (status == 'overdue') {
      return '$overdueDays Days Overdue';
    } else if (status == 'due_today') {
      return 'Expires tonight';
    } else {
      return 'Due in $remainingDays Days';
    }
  }
}

/// Summary statistics from the pending rent API.
class PendingRentSummary {
  final int dueToday;
  final int upcoming;
  final int overdue;
  final double totalPendingAmount;

  PendingRentSummary({
    required this.dueToday,
    required this.upcoming,
    required this.overdue,
    required this.totalPendingAmount,
  });

  factory PendingRentSummary.fromJson(Map<String, dynamic> json) {
    return PendingRentSummary(
      dueToday: json['due_today'] as int? ?? 0,
      upcoming: json['upcoming'] as int? ?? 0,
      overdue: json['overdue'] as int? ?? 0,
      totalPendingAmount:
          (json['total_pending_amount'] as num?)?.toDouble() ?? 0.0,
    );
  }

  int get totalItems => dueToday + upcoming + overdue;
}

/// Top-level response from `GET /rent/pending/`.
class PendingRentApiResponse {
  final PendingRentSummary summary;
  final List<PendingRentItem> data;
  final int total;
  final int page;
  final int limit;
  final int totalPages;

  PendingRentApiResponse({
    required this.summary,
    required this.data,
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
  });

  factory PendingRentApiResponse.fromJson(Map<String, dynamic> json) {
    return PendingRentApiResponse(
      summary: PendingRentSummary.fromJson(
          json['summary'] as Map<String, dynamic>? ?? {}),
      data: (json['data'] as List<dynamic>?)
              ?.map((e) =>
                  PendingRentItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      total: json['total'] as int? ?? 0,
      page: json['page'] as int? ?? 1,
      limit: json['limit'] as int? ?? 20,
      totalPages: json['total_pages'] as int? ?? 1,
    );
  }
}
