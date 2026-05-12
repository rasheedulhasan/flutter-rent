import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:birdle/core/app_theme.dart';
import 'package:birdle/widgets/toast_notification.dart';

/// Settings screen with theme toggle, language, notification, and account settings.
class SettingsScreen extends StatefulWidget {
  final ValueChanged<bool>? onThemeChanged;

  const SettingsScreen({super.key, this.onThemeChanged});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isDarkMode = false;
  String _selectedLanguage = 'English';
  bool _pushEnabled = true;
  bool _emailEnabled = true;
  bool _smsEnabled = false;
  bool _orderUpdates = true;
  bool _promotions = false;

  final List<String> _languages = ['English', 'Spanish', 'French', 'Arabic', 'German'];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Text(
                'Settings',
                style: GoogleFonts.inter(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimaryLight,
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Appearance section
            _buildSectionHeader('Appearance', isDark),
            _buildSettingCard([
              _buildSwitchTile(
                icon: Icons.dark_mode_rounded,
                title: 'Dark Mode',
                subtitle: 'Toggle dark theme',
                value: _isDarkMode,
                onChanged: (value) {
                  setState(() => _isDarkMode = value);
                  widget.onThemeChanged?.call(value);
                },
                isDark: isDark,
              ),
              _buildListTile(
                icon: Icons.language_rounded,
                title: 'Language',
                subtitle: _selectedLanguage,
                trailing: _buildDropdown(),
                isDark: isDark,
              ),
            ], isDark),

            const SizedBox(height: 16),

            // Notifications section
            _buildSectionHeader('Notifications', isDark),
            _buildSettingCard([
              _buildSwitchTile(
                icon: Icons.notifications_active_rounded,
                title: 'Push Notifications',
                subtitle: 'Receive push notifications',
                value: _pushEnabled,
                onChanged: (v) => setState(() => _pushEnabled = v),
                isDark: isDark,
              ),
              const _SettingDivider(),
              _buildSwitchTile(
                icon: Icons.email_rounded,
                title: 'Email Notifications',
                subtitle: 'Receive email updates',
                value: _emailEnabled,
                onChanged: (v) => setState(() => _emailEnabled = v),
                isDark: isDark,
              ),
              const _SettingDivider(),
              _buildSwitchTile(
                icon: Icons.sms_rounded,
                title: 'SMS Notifications',
                subtitle: 'Receive SMS alerts',
                value: _smsEnabled,
                onChanged: (v) => setState(() => _smsEnabled = v),
                isDark: isDark,
              ),
            ], isDark),

            const SizedBox(height: 16),

            // Preferences section
            _buildSectionHeader('Preferences', isDark),
            _buildSettingCard([
              _buildSwitchTile(
                icon: Icons.inventory_2_rounded,
                title: 'Order Updates',
                subtitle: 'Get notified about order changes',
                value: _orderUpdates,
                onChanged: (v) => setState(() => _orderUpdates = v),
                isDark: isDark,
              ),
              const _SettingDivider(),
              _buildSwitchTile(
                icon: Icons.local_offer_rounded,
                title: 'Promotions',
                subtitle: 'Receive promotional offers',
                value: _promotions,
                onChanged: (v) => setState(() => _promotions = v),
                isDark: isDark,
              ),
            ], isDark),

            const SizedBox(height: 16),

            // Account section
            _buildSectionHeader('Account', isDark),
            _buildSettingCard([
              _buildListTile(
                icon: Icons.person_outline_rounded,
                title: 'Edit Profile',
                subtitle: 'Update your personal information',
                isDark: isDark,
                onTap: () => Navigator.of(context).pushNamed('/profile'),
              ),
              const _SettingDivider(),
              _buildListTile(
                icon: Icons.lock_outline_rounded,
                title: 'Change Password',
                subtitle: 'Update your password',
                isDark: isDark,
                onTap: () {
                  ToastNotification.show(
                    context: context,
                    message: 'Password change UI coming soon',
                    type: ToastType.info,
                  );
                },
              ),
              const _SettingDivider(),
              _buildListTile(
                icon: Icons.delete_outline_rounded,
                title: 'Delete Account',
                subtitle: 'Permanently remove your account',
                isDark: isDark,
                textColor: AppTheme.error,
                onTap: () {
                  ToastNotification.show(
                    context: context,
                    message: 'Account deletion is not available in demo',
                    type: ToastType.warning,
                  );
                },
              ),
            ], isDark),

            const SizedBox(height: 24),

            // App info
            Center(
              child: Column(
                children: [
                  Text(
                    'BizManager v1.0.0',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Demo Version · UI Prototype',
                    style: GoogleFonts.inter(
                      fontSize: 11,
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

  Widget _buildSectionHeader(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
      child: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppTheme.primary,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildSettingCard(List<Widget> children, bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark : AppTheme.cardLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
          width: 0.5,
        ),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required bool isDark,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: AppTheme.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimaryLight,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeTrackColor: AppTheme.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isDark,
    Color? textColor,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: (textColor ?? AppTheme.primary).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 18, color: textColor ?? AppTheme.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: textColor ?? (isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimaryLight),
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            ),
            trailing ??
                Icon(
                  Icons.chevron_right_rounded,
                  color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight,
                  size: 20,
                ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedLanguage,
          isDense: true,
          items: _languages.map((lang) {
            return DropdownMenuItem(
              value: lang,
              child: Text(
                lang,
                style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500),
              ),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() => _selectedLanguage = value);
              ToastNotification.show(
                context: context,
                message: 'Language changed to $value',
                type: ToastType.success,
              );
            }
          },
        ),
      ),
    );
  }
}

class _SettingDivider extends StatelessWidget {
  const _SettingDivider();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Divider(
      height: 1,
      thickness: 0.5,
      color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
      indent: 60,
    );
  }
}
