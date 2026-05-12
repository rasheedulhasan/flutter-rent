/// Transaction model mapped from GET /api/transactions/tenant/:tenantId response.
class TransactionModel {
  final String id;
  final double amount;
  final String paymentStatus;
  final String? transactionDate;
  final String? periodMonth;
  final String? periodYear;
  final double monthlyRent;
  final String? remarks;

  TransactionModel({
    required this.id,
    required this.amount,
    required this.paymentStatus,
    this.transactionDate,
    this.periodMonth,
    this.periodYear,
    required this.monthlyRent,
    this.remarks,
  });

  /// Safely converts a dynamic value to String, handling both String and int.
  static String? _safeString(dynamic value) {
    if (value == null) return null;
    if (value is String) return value;
    return value.toString();
  }

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: _safeString(json['\$id']) ?? _safeString(json['id']) ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      paymentStatus: _safeString(json['payment_status']) ?? 'pending',
      transactionDate: _safeString(json['transaction_date']),
      periodMonth: _safeString(json['period_month']),
      periodYear: _safeString(json['period_year']),
      monthlyRent: (json['monthly_rent'] as num?)?.toDouble() ?? 0.0,
      remarks: _safeString(json['remarks']),
    );
  }

  Map<String, dynamic> toJson() => {
        '\$id': id,
        'amount': amount,
        'payment_status': paymentStatus,
        'transaction_date': transactionDate,
        'period_month': periodMonth,
        'period_year': periodYear,
        'monthly_rent': monthlyRent,
        'remarks': remarks,
      };

  bool get isPaid => paymentStatus.toLowerCase() == 'paid';
  bool get isPending => paymentStatus.toLowerCase() == 'pending';
  bool get isPartial => paymentStatus.toLowerCase() == 'partial';
}
