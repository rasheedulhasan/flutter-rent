/// Data Transfer Object for tenant booking requests.
/// Maps to the POST /api/tenants/booking request body.
class TenantBookingDto {
  final String roomId;
  final String fullName;
  final String phoneNumber;
  final String checkInDate;
  final double monthlyRent;
  final double securityDeposit;
  final String? idNumber;
  final String? emergencyContact;
  final String? notes;

  TenantBookingDto({
    required this.roomId,
    required this.fullName,
    required this.phoneNumber,
    required this.checkInDate,
    required this.monthlyRent,
    required this.securityDeposit,
    this.idNumber,
    this.emergencyContact,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
        'room_id': roomId,
        'full_name': fullName,
        'phone_number': phoneNumber,
        'check_in_date': checkInDate,
        'monthly_rent': monthlyRent,
        'security_deposit': securityDeposit,
        if (idNumber != null) 'id_number': idNumber,
        if (emergencyContact != null) 'emergency_contact': emergencyContact,
        if (notes != null) 'notes': notes,
      };

  /// Validates the DTO fields.
  /// Returns a list of validation error messages (empty if valid).
  List<String> validate() {
    final errors = <String>[];

    if (roomId.trim().isEmpty) {
      errors.add('room_id is required');
    }
    if (fullName.trim().isEmpty) {
      errors.add('full_name is required');
    }
    if (phoneNumber.trim().isEmpty) {
      errors.add('phone_number is required');
    }
    if (checkInDate.trim().isEmpty) {
      errors.add('check_in_date is required');
    }
    if (monthlyRent <= 0) {
      errors.add('monthly_rent must be greater than 0');
    }
    if (securityDeposit < 0) {
      errors.add('security_deposit cannot be negative');
    }

    return errors;
  }
}
