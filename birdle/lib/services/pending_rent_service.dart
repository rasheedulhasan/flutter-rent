import 'package:birdle/models/pending_rent_item.dart';
import 'package:birdle/models/room_model.dart';
import 'package:birdle/models/transaction_model.dart';
import 'package:birdle/services/api_client.dart';

/// Service for fetching pending rent data.
///
/// Communicates with the backend API via [ApiClient].
/// Flow:
/// 1. Get all rooms from API
/// 2. For each occupied room → get tenant from API (filtered by room_id)
/// 3. For each tenant → get transactions from API (via /tenants/:id/with-transactions)
/// 4. Calculate pending amounts and statuses
class PendingRentService {
  final ApiClient _apiClient;

  PendingRentService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  /// Safely converts a dynamic value to String, handling both String and int.
  static String? _safeString(dynamic value) {
    if (value == null) return null;
    if (value is String) return value;
    return value.toString();
  }

  /// Fetches all pending rent items.
  /// Returns only occupied rooms with pending or partial payment status.
  Future<List<PendingRentItem>> getPendingRentItems() async {
    try {
      // Step 1: Get all rooms from API
      final roomsResponse = await _apiClient.get('/rooms');
      final allRooms = <RoomModel>[];
      if (roomsResponse['success'] == true && roomsResponse['data'] != null) {
        final dataList = roomsResponse['data'] as List<dynamic>;
        allRooms.addAll(
          dataList
              .map((e) => RoomModel.fromJson(e as Map<String, dynamic>))
              .toList(),
        );
      }

      // Step 2: Filter occupied rooms
      final occupiedRooms = allRooms.where((r) => r.isOccupied).toList();
      final pendingRentItems = <PendingRentItem>[];

      for (final room in occupiedRooms) {
        try {
          // Step 3: Get tenant data for this room via API
          // Use /tenants?room_id={room.id} to find the tenant for this room
          final tenantResponse = await _apiClient.get(
            '/tenants',
            queryParams: {'room_id': room.id},
          );
          if (tenantResponse['success'] != true ||
              tenantResponse['data'] == null) {
            continue;
          }

          final dataList = tenantResponse['data'] as List<dynamic>;
          if (dataList.isEmpty) continue;

          final tenantData = dataList.first as Map<String, dynamic>;
          final tenantId = _safeString(tenantData['\$id']) ??
              _safeString(tenantData['id']);
          if (tenantId == null || tenantId.isEmpty) continue;

          // Step 4: Get transactions for this tenant via API
          // Use /transactions?tenant_id={id} which is fully implemented
          final txResponse = await _apiClient.get(
            '/transactions',
            queryParams: {'tenant_id': tenantId},
          );
          final rawTransactions = <Map<String, dynamic>>[];
          if (txResponse['success'] == true && txResponse['data'] != null) {
            final txList = txResponse['data'] as List<dynamic>;
            rawTransactions.addAll(
              txList
                  .map((e) => e as Map<String, dynamic>)
                  .toList(),
            );
          }

          final transactions = rawTransactions
              .map((e) => TransactionModel.fromJson(e))
              .toList();

          // Step 5: Calculate pending rent
          final item = PendingRentItem.fromRoomWithTenantAndTransactions(
            room: room,
            tenantData: tenantData,
            transactions: transactions,
          );

          // Step 6: Only include items with pending or partial status
          if (item.paymentStatus == 'pending' ||
              item.paymentStatus == 'partial') {
            pendingRentItems.add(item);
          }
        } catch (e) {
          // Skip rooms that fail to load tenant/transaction data
          continue;
        }
      }

      return pendingRentItems;
    } catch (e) {
      throw PendingRentApiException(
          message: 'Failed to fetch pending rent data: $e');
    }
  }

  /// Returns all rooms (for summary stats) from the API.
  Future<List<RoomModel>> getAllRooms() async {
    try {
      final response = await _apiClient.get('/rooms');
      if (response['success'] == true && response['data'] != null) {
        final dataList = response['data'] as List<dynamic>;
        return dataList
            .map((e) => RoomModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      throw PendingRentApiException(
          message: 'Failed to fetch rooms: $e');
    }
  }

  /// Returns summary statistics for pending rent items.
  Future<PendingRentSummary> getSummary() async {
    final items = await getPendingRentItems();
    final allRooms = await getAllRooms();
    final occupiedRooms = allRooms.where((r) => r.isOccupied).toList();
    return PendingRentSummary(
      totalRooms: allRooms.length,
      occupiedRooms: occupiedRooms.length,
      pendingPayments: items.length,
      totalPendingAmount:
          items.fold(0.0, (sum, item) => sum + item.pendingAmount),
    );
  }

  /// Searches pending rent items by room number or tenant name.
  List<PendingRentItem> searchItems(
      List<PendingRentItem> items, String query) {
    if (query.trim().isEmpty) return items;
    final q = query.toLowerCase();
    return items.where((item) {
      return item.room.roomNumber.toLowerCase().contains(q) ||
          item.tenant.fullName.toLowerCase().contains(q);
    }).toList();
  }
}

/// Summary statistics for the Pending Rent dashboard.
class PendingRentSummary {
  final int totalRooms;
  final int occupiedRooms;
  final int pendingPayments;
  final double totalPendingAmount;

  PendingRentSummary({
    required this.totalRooms,
    required this.occupiedRooms,
    required this.pendingPayments,
    required this.totalPendingAmount,
  });

  factory PendingRentSummary.fromItems(List<PendingRentItem> items) {
    // Note: totalRooms and occupiedRooms are placeholders
    // since we only have pending items here. The screen will
    // calculate these from the full room list.
    return PendingRentSummary(
      totalRooms: 0, // Will be set separately
      occupiedRooms: 0, // Will be set separately
      pendingPayments: items.length,
      totalPendingAmount:
          items.fold(0.0, (sum, item) => sum + item.pendingAmount),
    );
  }
}

/// Exception thrown when a pending rent API operation fails.
class PendingRentApiException implements Exception {
  final String message;

  const PendingRentApiException({required this.message});

  @override
  String toString() => 'PendingRentApiException: $message';
}
