/// Rent collection model for the ProManager property management app.
/// Represents a pending rent entry for a tenant unit.
class RentCollectionModel {
  final String id;
  final String roomNumber;
  final String tenantName;
  final double amount;
  final String status; // overdue, due_today, upcoming
  final int daysUntilDue; // negative = overdue days, positive = days remaining
  final String leaseType;
  final String? phoneNumber;

  RentCollectionModel({
    required this.id,
    required this.roomNumber,
    required this.tenantName,
    required this.amount,
    required this.status,
    required this.daysUntilDue,
    this.leaseType = 'Residential',
    this.phoneNumber,
  });

  factory RentCollectionModel.fromJson(Map<String, dynamic> json) {
    return RentCollectionModel(
      id: json['id'] as String? ?? '',
      roomNumber: json['roomNumber'] as String? ?? '',
      tenantName: json['tenantName'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] as String? ?? 'upcoming',
      daysUntilDue: json['daysUntilDue'] as int? ?? 0,
      leaseType: json['leaseType'] as String? ?? 'Residential',
      phoneNumber: json['phoneNumber'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'roomNumber': roomNumber,
        'tenantName': tenantName,
        'amount': amount,
        'status': status,
        'daysUntilDue': daysUntilDue,
        'leaseType': leaseType,
        'phoneNumber': phoneNumber,
      };

  /// Returns a human-readable status label.
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

  /// Returns the overdue/due description string.
  String get dueDescription {
    if (status == 'overdue') {
      return '$daysUntilDue Days Overdue';
    } else if (status == 'due_today') {
      return 'Expires tonight';
    } else {
      return 'Due in $daysUntilDue Days';
    }
  }
}

/// Represents a rent collection transaction record.
class RentCollectionRecord {
  final String id;
  final String rentCollectionId;
  final String roomNumber;
  final String tenantName;
  final double amountPaid;
  final double balanceOwed;
  final DateTime paymentDate;
  final String paymentMethod; // cash, bank_transfer, cheque
  final String? notes;
  final bool sendSmsReceipt;
  final String collectorName;
  final DateTime createdAt;

  RentCollectionRecord({
    required this.id,
    required this.rentCollectionId,
    required this.roomNumber,
    required this.tenantName,
    required this.amountPaid,
    required this.balanceOwed,
    required this.paymentDate,
    required this.paymentMethod,
    this.notes,
    this.sendSmsReceipt = true,
    this.collectorName = 'John Doe',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory RentCollectionRecord.fromJson(Map<String, dynamic> json) {
    return RentCollectionRecord(
      id: json['id'] as String? ?? '',
      rentCollectionId: json['rentCollectionId'] as String? ?? '',
      roomNumber: json['roomNumber'] as String? ?? '',
      tenantName: json['tenantName'] as String? ?? '',
      amountPaid: (json['amountPaid'] as num?)?.toDouble() ?? 0.0,
      balanceOwed: (json['balanceOwed'] as num?)?.toDouble() ?? 0.0,
      paymentDate: DateTime.tryParse(json['paymentDate'] as String? ?? '') ?? DateTime.now(),
      paymentMethod: json['paymentMethod'] as String? ?? 'bank_transfer',
      notes: json['notes'] as String?,
      sendSmsReceipt: json['sendSmsReceipt'] as bool? ?? true,
      collectorName: json['collectorName'] as String? ?? 'John Doe',
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? ''),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'rentCollectionId': rentCollectionId,
        'roomNumber': roomNumber,
        'tenantName': tenantName,
        'amountPaid': amountPaid,
        'balanceOwed': balanceOwed,
        'paymentDate': paymentDate.toIso8601String(),
        'paymentMethod': paymentMethod,
        'notes': notes,
        'sendSmsReceipt': sendSmsReceipt,
        'collectorName': collectorName,
        'createdAt': createdAt.toIso8601String(),
      };
}
