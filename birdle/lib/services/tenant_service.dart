import 'package:birdle/models/tenant_model.dart';
import 'package:birdle/services/api_client.dart';

/// Tenant service that fetches tenant data from the live backend API.
/// Uses the existing [ApiClient] for HTTP requests.
class TenantService {
  final ApiClient _apiClient;

  TenantService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  /// Fetches the list of tenants from GET /api/tenants.
  ///
  /// Optional query parameters:
  /// - [status]: filter by tenant status (active, inactive, moved_out)
  /// - [roomId]: filter by room ID
  /// - [limit]: number of records per page (default 25)
  /// - [offset]: pagination offset (default 0)
  Future<List<TenantModel>> getTenants({
    String? status,
    String? roomId,
    int? limit,
    int? offset,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (status != null) queryParams['status'] = status;
      if (roomId != null) queryParams['room_id'] = roomId;
      if (limit != null) queryParams['limit'] = limit.toString();
      if (offset != null) queryParams['offset'] = offset.toString();

      final response = await _apiClient.get(
        '/tenants',
        queryParams: queryParams.isNotEmpty ? queryParams : null,
      );

      if (response['success'] == true && response['data'] != null) {
        final dataList = response['data'] as List<dynamic>;
        return dataList
            .map((e) => TenantModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }

      return [];
    } catch (e) {
      // Log and rethrow so callers can handle errors appropriately
      throw TenantApiException(message: 'Failed to fetch tenants: $e');
    }
  }

  /// Searches tenants by query string.
  /// GET /api/tenants/search/:query
  Future<List<TenantModel>> searchTenants(String query) async {
    if (query.trim().isEmpty) {
      return getTenants();
    }
    try {
      final response = await _apiClient.get(
        '/tenants/search/${Uri.encodeComponent(query)}',
      );

      if (response['success'] == true && response['data'] != null) {
        final dataList = response['data'] as List<dynamic>;
        return dataList
            .map((e) => TenantModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }

      return [];
    } catch (e) {
      throw TenantApiException(message: 'Failed to search tenants: $e');
    }
  }

  /// Fetches a single tenant by ID.
  /// GET /api/tenants/:id
  Future<TenantModel?> getTenantById(String id) async {
    try {
      final response = await _apiClient.get('/tenants/$id');

      if (response['success'] == true && response['data'] != null) {
        return TenantModel.fromJson(response['data'] as Map<String, dynamic>);
      }

      return null;
    } catch (e) {
      throw TenantApiException(message: 'Failed to fetch tenant: $e');
    }
  }

  /// Fetches a tenant with their transactions.
  /// GET /api/tenants/:id/with-transactions
  Future<Map<String, dynamic>?> getTenantWithTransactions(String id) async {
    try {
      final response = await _apiClient.get('/tenants/$id/with-transactions');

      if (response['success'] == true && response['data'] != null) {
        return response['data'] as Map<String, dynamic>;
      }

      return null;
    } catch (e) {
      throw TenantApiException(
        message: 'Failed to fetch tenant with transactions: $e',
      );
    }
  }

  /// Creates a new tenant record.
  /// POST /api/tenants
  /// Returns the created tenant data as a Map.
  Future<Map<String, dynamic>> createTenant(Map<String, dynamic> tenantData) async {
    try {
      final response = await _apiClient.post('/tenants', body: tenantData);

      if (response['success'] == true && response['data'] != null) {
        return response['data'] as Map<String, dynamic>;
      }

      throw TenantApiException(
        message: response['message'] as String? ?? 'Failed to create tenant',
      );
    } catch (e) {
      if (e is TenantApiException) rethrow;
      throw TenantApiException(message: 'Failed to create tenant: $e');
    }
  }
}

/// Exception thrown when a tenant API operation fails.
class TenantApiException implements Exception {
  final String message;

  const TenantApiException({required this.message});

  @override
  String toString() => 'TenantApiException: $message';
}
