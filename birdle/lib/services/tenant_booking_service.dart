import 'package:birdle/models/tenant_booking_dto.dart';
import 'package:birdle/services/api_client.dart';

/// Handles tenant booking by calling the single POST /api/tenants/booking endpoint.
///
/// The backend handles all business logic (room validation, tenant creation,
/// room status update) in one atomic request.
class TenantBookingService {
  final ApiClient _apiClient;

  TenantBookingService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  /// Books a tenant by sending a POST request to /api/tenants/booking.
  ///
  /// Returns a [TenantBookingResult] with the created tenant details.
  /// Throws [TenantBookingException] on validation or API failure.
  Future<TenantBookingResult> bookTenant(TenantBookingDto dto) async {
    // Step 1: Validate input via DTO
    final validationErrors = dto.validate();
    if (validationErrors.isNotEmpty) {
      throw TenantBookingException(
        message: 'Validation failed',
        errors: validationErrors,
      );
    }

    // Step 2: Send POST /api/tenants/booking with the DTO as the request body
    final response = await _apiClient.post(
      '/tenants/booking',
      body: dto.toJson(),
    );

    // Step 3: Parse the success response
    if (response['success'] == true && response['data'] != null) {
      return TenantBookingResult.fromJson(
        response['data'] as Map<String, dynamic>,
      );
    }

    throw TenantBookingException(
      message: response['message'] as String? ?? 'Booking failed',
    );
  }
}

/// Result of a successful tenant booking operation.
/// Parsed from the POST /api/tenants/booking success response.
class TenantBookingResult {
  final String tenantId;
  final String fullName;
  final String phoneNumber;
  final String roomId;
  final String roomNumber;
  final double monthlyRent;
  final String checkInDate;
  final String status;

  TenantBookingResult({
    required this.tenantId,
    required this.fullName,
    required this.phoneNumber,
    required this.roomId,
    required this.roomNumber,
    required this.monthlyRent,
    required this.checkInDate,
    required this.status,
  });

  /// Creates a [TenantBookingResult] from the `data` field of the
  /// POST /api/tenants/booking success response.
  factory TenantBookingResult.fromJson(Map<String, dynamic> json) {
    return TenantBookingResult(
      tenantId: json['tenant_id'] as String? ?? '',
      fullName: json['full_name'] as String? ?? '',
      phoneNumber: json['phone_number'] as String? ?? '',
      roomId: json['room_id'] as String? ?? '',
      roomNumber: json['room_number'] as String? ?? '',
      monthlyRent: (json['monthly_rent'] as num?)?.toDouble() ?? 0.0,
      checkInDate: json['check_in_date'] as String? ?? '',
      status: json['status'] as String? ?? 'active',
    );
  }

  /// Converts the result to a map matching the success response schema.
  Map<String, dynamic> toResponseMap() => {
        'tenant_id': tenantId,
        'full_name': fullName,
        'phone_number': phoneNumber,
        'room_id': roomId,
        'room_number': roomNumber,
        'monthly_rent': monthlyRent,
        'check_in_date': checkInDate,
        'status': status,
      };
}

/// Exception thrown when the tenant booking process fails.
class TenantBookingException implements Exception {
  final String message;
  final List<String>? errors;

  const TenantBookingException({
    required this.message,
    this.errors,
  });

  @override
  String toString() {
    if (errors != null && errors!.isNotEmpty) {
      return 'TenantBookingException: $message (${errors!.join(', ')})';
    }
    return 'TenantBookingException: $message';
  }
}
