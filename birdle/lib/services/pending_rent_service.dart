import 'package:birdle/models/pending_rent_item.dart';
import 'package:birdle/services/api_client.dart';

/// Service for fetching pending rent data from the dedicated API endpoint.
///
/// Uses the consolidated endpoint:
/// `GET /rent/pending/` which returns all pending rent items with summary stats.
class PendingRentService {
  final ApiClient _apiClient;

  PendingRentService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  /// Fetches all pending rent items from the dedicated endpoint.
  ///
  /// Returns a [PendingRentApiResponse] containing summary + data list.
  Future<PendingRentApiResponse> getPendingRentItems() async {
    try {
      final response = await _apiClient.get('/rent/pending/');
      return PendingRentApiResponse.fromJson(response);
    } catch (e) {
      throw PendingRentApiException(
          message: 'Failed to fetch pending rent data: $e');
    }
  }

  /// Searches pending rent items by tenant name or room number.
  List<PendingRentItem> searchItems(
      List<PendingRentItem> items, String query) {
    if (query.trim().isEmpty) return items;
    final q = query.toLowerCase();
    return items.where((item) {
      return item.roomNumber.toLowerCase().contains(q) ||
          item.tenantName.toLowerCase().contains(q);
    }).toList();
  }
}

/// Exception thrown when a pending rent API operation fails.
class PendingRentApiException implements Exception {
  final String message;

  const PendingRentApiException({required this.message});

  @override
  String toString() => 'PendingRentApiException: $message';
}
