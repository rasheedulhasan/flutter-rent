import 'package:birdle/models/notification_model.dart';
import 'package:birdle/services/api_client.dart';

/// Notification service for managing notifications.
/// Fetches data from the live backend API via [ApiClient].
class NotificationService {
  final ApiClient _apiClient;

  NotificationService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  /// Fetches all notifications from GET /api/notifications.
  Future<List<NotificationModel>> getNotifications() async {
    try {
      final response = await _apiClient.get('/notifications');

      if (response['success'] == true && response['data'] != null) {
        final dataList = response['data'] as List<dynamic>;
        return dataList
            .map((e) => NotificationModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }

      return [];
    } catch (e) {
      throw NotificationApiException(
          message: 'Failed to fetch notifications: $e');
    }
  }

  /// Marks a notification as read.
  /// PATCH /api/notifications/:id/read
  Future<void> markAsRead(String notificationId) async {
    try {
      await _apiClient.patch('/notifications/$notificationId/read');
    } catch (e) {
      throw NotificationApiException(
          message: 'Failed to mark notification as read: $e');
    }
  }

  /// Marks all notifications as read.
  /// PATCH /api/notifications/read-all
  Future<void> markAllAsRead() async {
    try {
      await _apiClient.patch('/notifications/read-all');
    } catch (e) {
      throw NotificationApiException(
          message: 'Failed to mark all notifications as read: $e');
    }
  }

  /// Gets unread notification count.
  /// GET /api/notifications/unread-count
  Future<int> getUnreadCount() async {
    try {
      final response = await _apiClient.get('/notifications/unread-count');

      if (response['success'] == true && response['data'] != null) {
        final data = response['data'] as Map<String, dynamic>;
        return data['count'] as int? ?? 0;
      }

      return 0;
    } catch (e) {
      throw NotificationApiException(
          message: 'Failed to get unread count: $e');
    }
  }
}

/// Exception thrown when a notification API operation fails.
class NotificationApiException implements Exception {
  final String message;

  const NotificationApiException({required this.message});

  @override
  String toString() => 'NotificationApiException: $message';
}
