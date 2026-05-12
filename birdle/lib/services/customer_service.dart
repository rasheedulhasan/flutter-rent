import 'package:birdle/models/customer_model.dart';
import 'package:birdle/services/api_client.dart';

/// Customer service for managing customer data.
/// Fetches data from the live backend API via [ApiClient].
class CustomerService {
  final ApiClient _apiClient;

  CustomerService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  /// Fetches all customers from GET /api/customers.
  Future<List<CustomerModel>> getCustomers() async {
    try {
      final response = await _apiClient.get('/customers');

      if (response['success'] == true && response['data'] != null) {
        final dataList = response['data'] as List<dynamic>;
        return dataList
            .map((e) => CustomerModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }

      return [];
    } catch (e) {
      throw CustomerApiException(message: 'Failed to fetch customers: $e');
    }
  }

  /// Searches customers by query string.
  /// GET /api/customers?search=query
  Future<List<CustomerModel>> searchCustomers(String query) async {
    if (query.trim().isEmpty) {
      return getCustomers();
    }
    try {
      final response = await _apiClient.get(
        '/customers',
        queryParams: {'search': query},
      );

      if (response['success'] == true && response['data'] != null) {
        final dataList = response['data'] as List<dynamic>;
        return dataList
            .map((e) => CustomerModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }

      return [];
    } catch (e) {
      throw CustomerApiException(message: 'Failed to search customers: $e');
    }
  }

  /// Filters customers by status.
  /// GET /api/customers?status=status
  Future<List<CustomerModel>> filterByStatus(String status) async {
    try {
      final queryParams = status == 'all' ? null : {'status': status};
      final response = await _apiClient.get(
        '/customers',
        queryParams: queryParams,
      );

      if (response['success'] == true && response['data'] != null) {
        final dataList = response['data'] as List<dynamic>;
        return dataList
            .map((e) => CustomerModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }

      return [];
    } catch (e) {
      throw CustomerApiException(message: 'Failed to filter customers: $e');
    }
  }

  /// Gets a single customer by ID.
  /// GET /api/customers/:id
  Future<CustomerModel?> getCustomerById(String id) async {
    try {
      final response = await _apiClient.get('/customers/$id');

      if (response['success'] == true && response['data'] != null) {
        return CustomerModel.fromJson(response['data'] as Map<String, dynamic>);
      }

      return null;
    } catch (e) {
      throw CustomerApiException(message: 'Failed to fetch customer: $e');
    }
  }

  /// Creates a new customer.
  /// POST /api/customers
  Future<CustomerModel> createCustomer(Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.post('/customers', body: data);

      if (response['success'] == true && response['data'] != null) {
        return CustomerModel.fromJson(response['data'] as Map<String, dynamic>);
      }

      throw CustomerApiException(message: 'Failed to create customer');
    } catch (e) {
      if (e is CustomerApiException) rethrow;
      throw CustomerApiException(message: 'Failed to create customer: $e');
    }
  }

  /// Updates an existing customer.
  /// PUT /api/customers/:id
  Future<CustomerModel> updateCustomer(String id, Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.put('/customers/$id', body: data);

      if (response['success'] == true && response['data'] != null) {
        return CustomerModel.fromJson(response['data'] as Map<String, dynamic>);
      }

      throw CustomerApiException(message: 'Failed to update customer');
    } catch (e) {
      if (e is CustomerApiException) rethrow;
      throw CustomerApiException(message: 'Failed to update customer: $e');
    }
  }

  /// Deletes a customer.
  /// DELETE /api/customers/:id
  Future<bool> deleteCustomer(String id) async {
    try {
      final response = await _apiClient.delete('/customers/$id');
      return response['success'] == true;
    } catch (e) {
      throw CustomerApiException(message: 'Failed to delete customer: $e');
    }
  }
}

/// Exception thrown when a customer API operation fails.
class CustomerApiException implements Exception {
  final String message;

  const CustomerApiException({required this.message});

  @override
  String toString() => 'CustomerApiException: $message';
}
