import 'package:birdle/models/room_model.dart';
import 'package:birdle/services/api_client.dart';

/// Room service that fetches room data from the live backend API.
/// Uses the existing [ApiClient] for HTTP requests.
class RoomService {
  final ApiClient _apiClient;

  RoomService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  /// Fetches the list of rooms from GET /api/rooms.
  Future<List<RoomModel>> getRooms() async {
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
      throw RoomApiException(message: 'Failed to fetch rooms: $e');
    }
  }

  /// Fetches rooms with building name + current tenant.
  /// GET /api/rooms/populated
  ///
  /// Optional query parameters:
  /// - [buildingId]: filter by building
  /// - [status]: filter by status (vacant, occupied, under_maintenance)
  /// - [floor]: filter by floor number
  /// - [limit]: results per page (default: 25)
  /// - [offset]: pagination offset (default: 0)
  Future<List<PopulatedRoomModel>> getRoomsPopulated({
    String? buildingId,
    String? status,
    String? floor,
    int? limit,
    int? offset,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (buildingId != null) queryParams['building_id'] = buildingId;
      if (status != null) queryParams['status'] = status;
      if (floor != null) queryParams['floor'] = floor;
      if (limit != null) queryParams['limit'] = limit.toString();
      if (offset != null) queryParams['offset'] = offset.toString();

      final response = await _apiClient.get(
        '/rooms/populated',
        queryParams: queryParams.isNotEmpty ? queryParams : null,
      );

      if (response['success'] == true && response['data'] != null) {
        final dataList = response['data'] as List<dynamic>;
        return dataList
            .map((e) =>
                PopulatedRoomModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }

      return [];
    } catch (e) {
      throw RoomApiException(
        message: 'Failed to fetch populated rooms: $e',
      );
    }
  }

  /// Fetches a single room by ID.
  /// GET /api/rooms/:id
  Future<RoomModel?> getRoomById(String id) async {
    try {
      final response = await _apiClient.get('/rooms/$id');

      if (response['success'] == true && response['data'] != null) {
        return RoomModel.fromJson(response['data'] as Map<String, dynamic>);
      }

      return null;
    } catch (e) {
      throw RoomApiException(message: 'Failed to fetch room: $e');
    }
  }

  /// Updates the status of a room.
  /// PATCH /api/rooms/:id/status
  /// [status] should be one of: 'available', 'occupied', 'maintenance'
  Future<Map<String, dynamic>> updateRoomStatus(
    String roomId,
    String status,
  ) async {
    try {
      final response = await _apiClient.patch(
        '/rooms/$roomId/status',
        body: {'status': status},
      );

      if (response['success'] == true && response['data'] != null) {
        return response['data'] as Map<String, dynamic>;
      }

      throw RoomApiException(
        message: response['message'] as String? ??
            'Failed to update room status',
      );
    } catch (e) {
      if (e is RoomApiException) rethrow;
      throw RoomApiException(message: 'Failed to update room status: $e');
    }
  }
}

/// Exception thrown when a room API operation fails.
class RoomApiException implements Exception {
  final String message;

  const RoomApiException({required this.message});

  @override
  String toString() => 'RoomApiException: $message';
}
