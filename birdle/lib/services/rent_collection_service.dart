import 'package:birdle/models/rent_collection_model.dart';
import 'package:birdle/services/api_client.dart';

/// Service for managing rent collection data.
/// Communicates with the backend API via [ApiClient].
class RentCollectionService {
  final ApiClient _apiClient;

  RentCollectionService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  /// Returns all pending rent collections from the API.
  Future<List<RentCollectionModel>> getPendingCollections() async {
    try {
      final response = await _apiClient.get('/rent-collections');
      if (response['success'] == true && response['data'] != null) {
        final dataList = response['data'] as List<dynamic>;
        return dataList
            .map((e) => RentCollectionModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      throw RentCollectionApiException(
          message: 'Failed to fetch rent collections: $e');
    }
  }

  /// Searches pending collections by room number or tenant name.
  Future<List<RentCollectionModel>> searchCollections(String query) async {
    if (query.trim().isEmpty) return getPendingCollections();
    try {
      final response =
          await _apiClient.get('/rent-collections/search', queryParams: {
        'q': query,
      });
      if (response['success'] == true && response['data'] != null) {
        final dataList = response['data'] as List<dynamic>;
        return dataList
            .map((e) => RentCollectionModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      throw RentCollectionApiException(
          message: 'Failed to search rent collections: $e');
    }
  }

  /// Returns a single collection by ID.
  Future<RentCollectionModel?> getCollectionById(String id) async {
    try {
      final response = await _apiClient.get('/rent-collections/$id');
      if (response['success'] == true && response['data'] != null) {
        final data = response['data'] as Map<String, dynamic>;
        return RentCollectionModel.fromJson(data);
      }
      return null;
    } catch (e) {
      throw RentCollectionApiException(
          message: 'Failed to fetch rent collection: $e');
    }
  }

  /// Records a rent collection payment via the API.
  Future<RentCollectionRecord> recordPayment({
    required String rentCollectionId,
    required double amountPaid,
    required DateTime paymentDate,
    required String paymentMethod,
    String? notes,
    bool sendSmsReceipt = true,
  }) async {
    try {
      final response = await _apiClient.post('/rent-collections/pay', body: {
        'rentCollectionId': rentCollectionId,
        'amountPaid': amountPaid,
        'paymentDate': paymentDate.toIso8601String(),
        'paymentMethod': paymentMethod,
        'notes': notes,
        'sendSmsReceipt': sendSmsReceipt,
      });

      if (response['success'] == true && response['data'] != null) {
        final data = response['data'] as Map<String, dynamic>;
        return RentCollectionRecord.fromJson(data);
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
