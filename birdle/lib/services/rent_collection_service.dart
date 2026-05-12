import 'package:birdle/models/rent_collection_model.dart';
import 'package:birdle/services/api_client.dart';

/// Service for managing rent collection data.
/// Communicates with the backend API via [ApiClient].
class RentCollectionService {
  final ApiClient _apiClient;

  RentCollectionService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  /// Records a rent collection payment via the API.
  /// Matches the POST /api/rent/collect endpoint.
  Future<RentCollectionRecord> recordPayment({
    required String tenantId,
    required String roomId,
    required String collectedBy,
    required double amount,
    required double monthlyRent,
    required DateTime transactionDate,
    required DateTime rentDueDate,
    required int periodMonth,
    required int periodYear,
    required String paymentMethod,
    String pendingReason = '',
  }) async {
    try {
      final response = await _apiClient.post('/rent/collect', body: {
        'tenant_id': tenantId,
        'room_id': roomId,
        'collected_by': collectedBy,
        'amount': amount,
        'monthly_rent': monthlyRent,
        'transaction_date': transactionDate.toUtc().toIso8601String(),
        'rent_due_date': rentDueDate.toUtc().toIso8601String(),
        'period_month': periodMonth,
        'period_year': periodYear,
        'payment_method': paymentMethod,
        'pending_reason': pendingReason,
      });

      if (response['success'] == true && response['data'] != null) {
        final data = response['data'] as Map<String, dynamic>;
        return RentCollectionRecord.fromJson(data);
      }

      // Handle validation errors from the API
      if (response['success'] == false && response['details'] != null) {
        final details = response['details'] as List<dynamic>;
        throw RentCollectionApiException(
            message: details.join('\n'));
      }

      throw RentCollectionApiException(
          message: 'Failed to record payment: Unexpected response');
    } catch (e) {
      if (e is RentCollectionApiException) rethrow;
      throw RentCollectionApiException(
          message: 'Failed to record payment: $e');
    }
  }

  /// Returns total pending amount.
  Future<double> getTotalPendingAmount() async {
    try {
      final response = await _apiClient.get('/rent-collections/summary');
      if (response['success'] == true && response['data'] != null) {
        final data = response['data'] as Map<String, dynamic>;
        return (data['totalPendingAmount'] as num?)?.toDouble() ?? 0.0;
      }
      return 0.0;
    } catch (e) {
      throw RentCollectionApiException(
          message: 'Failed to fetch total pending amount: $e');
    }
  }

  /// Returns total overdue amount.
  Future<double> getTotalOverdueAmount() async {
    try {
      final response = await _apiClient.get('/rent-collections/summary');
      if (response['success'] == true && response['data'] != null) {
        final data = response['data'] as Map<String, dynamic>;
        return (data['totalOverdueAmount'] as num?)?.toDouble() ?? 0.0;
      }
      return 0.0;
    } catch (e) {
      throw RentCollectionApiException(
          message: 'Failed to fetch total overdue amount: $e');
    }
  }

  /// Returns count of pending units.
  Future<int> getPendingCount() async {
    try {
      final response = await _apiClient.get('/rent-collections/summary');
      if (response['success'] == true && response['data'] != null) {
        final data = response['data'] as Map<String, dynamic>;
        return (data['pendingCount'] as num?)?.toInt() ?? 0;
      }
      return 0;
    } catch (e) {
      throw RentCollectionApiException(
          message: 'Failed to fetch pending count: $e');
    }
  }

  /// Returns count of overdue units.
  Future<int> getOverdueCount() async {
    try {
      final response = await _apiClient.get('/rent-collections/summary');
      if (response['success'] == true && response['data'] != null) {
        final data = response['data'] as Map<String, dynamic>;
        return (data['overdueCount'] as num?)?.toInt() ?? 0;
      }
      return 0;
    } catch (e) {
      throw RentCollectionApiException(
          message: 'Failed to fetch overdue count: $e');
    }
  }

  /// Returns collection history.
  Future<List<RentCollectionRecord>> getCollectionHistory() async {
    try {
      final response = await _apiClient.get('/rent-collections/history');
      if (response['success'] == true && response['data'] != null) {
        final dataList = response['data'] as List<dynamic>;
        return dataList
            .map((e) =>
                RentCollectionRecord.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      throw RentCollectionApiException(
          message: 'Failed to fetch collection history: $e');
    }
  }
}

/// Exception thrown when a rent collection API operation fails.
class RentCollectionApiException implements Exception {
  final String message;

  const RentCollectionApiException({required this.message});

  @override
  String toString() => 'RentCollectionApiException: $message';
}
