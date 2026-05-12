import 'package:birdle/models/order_model.dart';
import 'package:birdle/services/api_client.dart';

/// Order service for managing orders.
/// Fetches data from the live backend API via [ApiClient].
class OrderService {
  final ApiClient _apiClient;

  OrderService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  /// Fetches all orders from GET /api/orders.
  Future<List<OrderModel>> getOrders() async {
    try {
      final response = await _apiClient.get('/orders');

      if (response['success'] == true && response['data'] != null) {
        final dataList = response['data'] as List<dynamic>;
        return dataList
            .map((e) => OrderModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }

      return [];
    } catch (e) {
      throw OrderApiException(message: 'Failed to fetch orders: $e');
    }
  }

  /// Filters orders by status.
  /// GET /api/orders?status=status
  Future<List<OrderModel>> filterByStatus(String status) async {
    try {
      final queryParams = status == 'all' ? null : {'status': status};
      final response = await _apiClient.get(
        '/orders',
        queryParams: queryParams,
      );

      if (response['success'] == true && response['data'] != null) {
        final dataList = response['data'] as List<dynamic>;
        return dataList
            .map((e) => OrderModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }

      return [];
    } catch (e) {
      throw OrderApiException(message: 'Failed to filter orders: $e');
    }
  }

  /// Gets a single order by ID.
  /// GET /api/orders/:id
  Future<OrderModel?> getOrderById(String id) async {
    try {
      final response = await _apiClient.get('/orders/$id');

      if (response['success'] == true && response['data'] != null) {
        return OrderModel.fromJson(response['data'] as Map<String, dynamic>);
      }

      return null;
    } catch (e) {
      throw OrderApiException(message: 'Failed to fetch order: $e');
    }
  }

  /// Gets recent orders for dashboard.
  /// GET /api/orders?recent=true&limit=4
  Future<List<OrderModel>> getRecentOrders() async {
    try {
      final response = await _apiClient.get(
        '/orders',
        queryParams: {'recent': 'true', 'limit': '4'},
      );

      if (response['success'] == true && response['data'] != null) {
        final dataList = response['data'] as List<dynamic>;
        return dataList
            .map((e) => OrderModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }

      return [];
    } catch (e) {
      throw OrderApiException(message: 'Failed to fetch recent orders: $e');
    }
  }

  /// Creates a new order.
  /// POST /api/orders
  Future<OrderModel> createOrder(Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.post('/orders', body: data);

      if (response['success'] == true && response['data'] != null) {
        return OrderModel.fromJson(response['data'] as Map<String, dynamic>);
      }

      throw OrderApiException(message: 'Failed to create order');
    } catch (e) {
      if (e is OrderApiException) rethrow;
      throw OrderApiException(message: 'Failed to create order: $e');
    }
  }

  /// Updates an existing order.
  /// PUT /api/orders/:id
  Future<OrderModel> updateOrder(String id, Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.put('/orders/$id', body: data);

      if (response['success'] == true && response['data'] != null) {
        return OrderModel.fromJson(response['data'] as Map<String, dynamic>);
      }

      throw OrderApiException(message: 'Failed to update order');
    } catch (e) {
      if (e is OrderApiException) rethrow;
      throw OrderApiException(message: 'Failed to update order: $e');
    }
  }

  /// Deletes an order.
  /// DELETE /api/orders/:id
  Future<bool> deleteOrder(String id) async {
    try {
      final response = await _apiClient.delete('/orders/$id');
      return response['success'] == true;
    } catch (e) {
      throw OrderApiException(message: 'Failed to delete order: $e');
    }
  }
}

/// Exception thrown when an order API operation fails.
class OrderApiException implements Exception {
  final String message;

  const OrderApiException({required this.message});

  @override
  String toString() => 'OrderApiException: $message';
}
