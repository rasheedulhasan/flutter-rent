import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:birdle/core/app_theme.dart';
import 'package:birdle/models/notification_model.dart';
import 'package:birdle/services/notification_service.dart';
import 'package:birdle/widgets/tab_selector.dart';
import 'package:birdle/widgets/skeleton_loader.dart';
import 'package:birdle/widgets/empty_state.dart';
import 'package:intl/intl.dart';

/// Notifications screen with read/unread states and filter tabs.
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final NotificationService _notificationService = NotificationService();
  List<NotificationModel> _notifications = [];
  List<NotificationModel> _filteredNotifications = [];
  String _selectedTab = 'all';
  bool _isLoading = true;
  String? _errorMessage;

  final List<String> _tabs = ['all', 'unread', 'order', 'invoice', 'system'];

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      _notifications = await _notificationService.getNotifications();
      _applyFilter();
    } catch (e) {
      _errorMessage = e.toString();
    }
    if (mounted) setState(() => _isLoading = false);
  }

  void _applyFilter() {
    switch (_selectedTab) {
      case 'all':
        _filteredNotifications = List.from(_notifications);
        break;
      case 'unread':
        _filteredNotifications = _notifications.where((n) => !n.isRead).toList();
        break;
      default:
        _filteredNotifications = _notifications.where((n) => n.type == _selectedTab).toList();
    }
  }

  Future<void> _markAsRead(String id) async {
    try {
      await _notificationService.markAsRead(id);
      setState(() {
        final index = _notifications.indexWhere((n) => n.id == id);
        if (index != -1) {
          _notifications[index] = _notifications[index].copyWith(isRead: true);
        }
        _applyFilter();
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to mark as read: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _markAllAsRead() async {
    try {
      await _notificationService.markAllAsRead();
      setState(() {
        _notifications = _notifications.map((n) => n.copyWith(isRead: true)).toList();
        _applyFilter();
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to mark all as read: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  int get _unreadCount => _notifications.where((n) => !n.isRead).length;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      'Notifications',
                      style: GoogleFonts.inter(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        color: isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimaryLight,
                      ),
                    ),
                    if (_unreadCount > 0) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppTheme.error,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '$_unreadCount',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                if (_unreadCount > 0)
                  GestureDetector(
                    onTap: _markAllAsRead,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Mark all read',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primary,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          TabSelector(
            tabs: _tabs,
            selectedTab: _selectedTab,
            onTabChanged: (tab) {
              setState(() => _selectedTab = tab);
              _applyFilter();
            },
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _isLoading
                ? const CardSkeleton(itemCount: 4)
                : _errorMessage != null
                    ? _buildErrorState(isDark)
                    : _filteredNotifications.isEmpty
                        ? EmptyState(
                            icon: Icons.notifications_none_rounded,
                            title: 'No notifications',
                            subtitle: _selectedTab == 'unread'
                                ? 'You have no unread notifications'
                                : 'No notifications to show',
                          )
                        : RefreshIndicator(
                            onRefresh: _loadNotifications,
                            child: ListView.builder(
                              padding: const EdgeInsets.only(bottom: 16),
                              itemCount: _filteredNotifications.length,
                              itemBuilder: (context, index) =>
                                  _buildNotificationCard(_filteredNotifications[index], isDark),
                            ),
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(NotificationModel notification, bool isDark) {
    final iconConfig = _getNotificationIcon(notification.type);
    return GestureDetector(
      onTap: () => _markAsRead(notification.id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.cardDark : AppTheme.cardLight,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: !notification.isRead
                ? AppTheme.primary.withValues(alpha: 0.3)
                : (isDark ? AppTheme.borderDark : AppTheme.borderLight),
            width: !notification.isRead ? 1.5 : 0.5,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: iconConfig.color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(iconConfig.icon, color: iconConfig.color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: notification.isRead ? FontWeight.w500 : FontWeight.w600,
                            color: isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimaryLight,
                          ),
                        ),
                      ),
                      if (!notification.isRead)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppTheme.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.message,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    DateFormat('MMM dd, yyyy · HH:mm').format(notification.createdAt),
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  _NotificationIconConfig _getNotificationIcon(String type) {
    switch (type) {
      case 'order':
        return _NotificationIconConfig(Icons.shopping_cart_rounded, AppTheme.primary);
      case 'invoice':
        return _NotificationIconConfig(Icons.receipt_rounded, AppTheme.accent);
      case 'customer':
        return _NotificationIconConfig(Icons.person_rounded, AppTheme.info);
      case 'promotion':
        return _NotificationIconConfig(Icons.local_offer_rounded, AppTheme.warning);
      default:
        return _NotificationIconConfig(Icons.notifications_rounded, AppTheme.textSecondaryLight);
    }
  }
  Widget _buildErrorState(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppTheme.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.cloud_off_rounded,
                size: 36,
                color: AppTheme.error.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Failed to Load Notifications',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimaryLight,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? 'An unexpected error occurred.',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadNotifications,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationIconConfig {
  final IconData icon;
  final Color color;
  _NotificationIconConfig(this.icon, this.color);
}
