/// Tenant model mapped from the backend API response.
/// Fields match the GET /api/tenants response schema.
class TenantModel {
  final String id;
  final String? roomId;
  final String fullName;
  final String phoneNumber;
  final String email;
  final double monthlyRent;
  final double securityDeposit;
  final String status; // active, inactive, moved_out
  final String? checkInDate;
  final String? checkOutDate;
  final String? notes;

  TenantModel({
    required this.id,
    this.roomId,
    required this.fullName,
    required this.phoneNumber,
    required this.email,
    required this.monthlyRent,
    required this.securityDeposit,
    required this.status,
    this.checkInDate,
    this.checkOutDate,
    this.notes,
  });

  /// Safely converts a dynamic value to String, handling both String and int.
  static String? _safeString(dynamic value) {
    if (value == null) return null;
    if (value is String) return value;
    return value.toString();
  }

  factory TenantModel.fromJson(Map<String, dynamic> json) {
    return TenantModel(
      id: _safeString(json['\$id']) ?? _safeString(json['id']) ?? '',
      roomId: _safeString(json['room_id']),
      fullName: _safeString(json['full_name']) ?? '',
      phoneNumber: _safeString(json['phone_number']) ?? '',
      email: _safeString(json['email']) ?? '',
      monthlyRent: (json['monthly_rent'] as num?)?.toDouble() ?? 0.0,
      securityDeposit: (json['security_deposit'] as num?)?.toDouble() ?? 0.0,
      status: _safeString(json['status']) ?? 'active',
      checkInDate: _safeString(json['check_in_date']),
      checkOutDate: _safeString(json['check_out_date']),
      notes: _safeString(json['notes']),
    );
  }

  Map<String, dynamic> toJson() => {
        '\$id': id,
        'room_id': roomId,
        'full_name': fullName,
        'phone_number': phoneNumber,
        'email': email,
        'monthly_rent': monthlyRent,
        'security_deposit': securityDeposit,
        'status': status,
        'check_in_date': checkInDate,
        'check_out_date': checkOutDate,
        'notes': notes,
      };
}
