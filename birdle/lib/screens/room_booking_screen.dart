import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:birdle/core/app_theme.dart';
import 'package:birdle/services/api_client.dart';

/// Room Booking Screen
/// Matches the ProManager HTML design with:
/// - TopAppBar with back button + "New Tenant Booking" title + profile
/// - Room Information section (Building, Floor, Room #)
/// - Tenant Information section (Name, Phone, Email, Monthly Rent)
/// - Documents section (Scan NID/Passport, Thumbnail Preview)
/// - Fixed bottom CONFIRM BOOKING button
class RoomBookingScreen extends StatefulWidget {
  const RoomBookingScreen({super.key});

  @override
  State<RoomBookingScreen> createState() => _RoomBookingScreenState();
}

class _RoomBookingScreenState extends State<RoomBookingScreen> {
  final ApiClient _apiClient = ApiClient();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController(text: '+971-XX-XXXXXXX');
  final _emailController = TextEditingController();
  final _rentController = TextEditingController(text: '5000');
  bool _isSubmitting = false;

  String _selectedBuilding = 'Downtown Plaza';
  String _selectedFloor = 'Floor 3';
  String _selectedRoom = 'A-305';

  final List<String> _buildings = [
    'Downtown Plaza',
    'Skyline Towers',
    'Central Park Residency',
  ];

  final List<String> _floors = [
    'Floor 3',
    'Floor 4',
    'Floor 5',
  ];

  final List<String> _rooms = [
    'A-305',
    'A-306',
    'A-307',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _rentController.dispose();
    super.dispose();
  }

  Future<void> _onConfirmBooking() async {
    // Validate required fields
    if (_nameController.text.trim().isEmpty) {
      _showError('Please enter the tenant name');
      return;
    }
    if (_emailController.text.trim().isEmpty) {
      _showError('Please enter the email address');
      return;
    }
    if (_rentController.text.trim().isEmpty) {
      _showError('Please enter the monthly rent');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final rentAmount = double.tryParse(_rentController.text.trim()) ?? 0;
      await _apiClient.post('/tenants', body: {
        'name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'email': _emailController.text.trim(),
        'monthlyRent': rentAmount,
        'building': _selectedBuilding,
        'floor': _selectedFloor,
        'roomNumber': _selectedRoom,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Booking confirmed for ${_nameController.text.trim()} - $_selectedRoom',
            ),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            backgroundColor: AppTheme.success,
          ),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      _showError('Failed to create booking: $e');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: AppTheme.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: AppTheme.background,
      // ================================================================
      // TopAppBar - matches HTML design
      // ================================================================
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(64),
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? AppTheme.cardDark : Colors.white,
            border: Border(
              bottom: BorderSide(
                color: isDark ? AppTheme.borderDark : AppTheme.outlineVariant,
                width: 0.5,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                height: 64,
                child: Row(
                  children: [
                    // Back button
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        margin: const EdgeInsets.only(right: 8),
                        child: Icon(
                          Icons.arrow_back_rounded,
                          color: isDark
                              ? AppTheme.textSecondaryDark
                              : AppTheme.onSurfaceVariant,
                          size: 24,
                        ),
                      ),
                    ),
                    // Title
                    Expanded(
                      child: Text(
                        'New Tenant Booking',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.02,
                          color: isDark
                              ? AppTheme.textPrimaryDark
                              : AppTheme.onSurface,
                        ),
                      ),
                    ),
                    // Profile avatar
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(9999),
                        border: Border.all(color: AppTheme.outlineVariant, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(9999),
                        child: Container(
                          color: AppTheme.primaryFixed,
                          child: Center(
                            child: Text(
                              'JD',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.onPrimaryFixed,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      // ================================================================
      // Body
      // ================================================================
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Room Information Section
          _buildSectionCard(
            icon: Icons.home_work_rounded,
            title: 'Room Information',
            child: Column(
              children: [
                _buildDropdownRow(
                  label: 'Select Building',
                  value: _selectedBuilding,
                  items: _buildings,
                  onChanged: (v) => setState(() => _selectedBuilding = v!),
                ),
                const SizedBox(height: 16),
                _buildDropdownRow(
                  label: 'Select Floor',
                  value: _selectedFloor,
                  items: _floors,
                  onChanged: (v) => setState(() => _selectedFloor = v!),
                ),
                const SizedBox(height: 16),
                _buildDropdownRow(
                  label: 'Select Room #',
                  value: _selectedRoom,
                  items: _rooms,
                  onChanged: (v) => setState(() => _selectedRoom = v!),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Tenant Information Section
          _buildSectionCard(
            icon: Icons.person_rounded,
            title: 'Tenant Information',
            child: Column(
              children: [
                _buildTextField(
                  label: 'Tenant Name',
                  controller: _nameController,
                  hintText: 'Full Legal Name',
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  label: 'Phone Number',
                  controller: _phoneController,
                  hintText: '+971-XX-XXXXXXX',
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  label: 'Email Address',
                  controller: _emailController,
                  hintText: 'example@email.com',
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                _buildRentField(
                  label: 'Monthly Rent (AED)',
                  controller: _rentController,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Documents Section
          _buildSectionCard(
            icon: Icons.description_rounded,
            title: 'Documents',
            child: Row(
              children: [
                // Tap to Scan
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Camera / Scanner would open here'),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      );
                    },
                    child: Container(
                      height: 140,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: AppTheme.outlineVariant,
                          width: 2,
                          strokeAlign: BorderSide.strokeAlignInside,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        color: AppTheme.surfaceContainerLow,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryContainer.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(9999),
                            ),
                            child: Icon(
                              Icons.photo_camera_rounded,
                              color: AppTheme.primary,
                              size: 32,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Tap to Scan',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.primary,
                            ),
                          ),
                          Text(
                            'NID / Passport Front',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: AppTheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Thumbnail Preview
                Expanded(
                  child: Container(
                    height: 140,
                    decoration: BoxDecoration(
                      border: Border.all(color: AppTheme.outlineVariant),
                      borderRadius: BorderRadius.circular(12),
                      color: AppTheme.surfaceContainerLow,
                    ),
                    child: Stack(
                      children: [
                        Center(
                          child: Icon(
                            Icons.description_rounded,
                            color: AppTheme.outlineVariant,
                            size: 48,
                          ),
                        ),
                        Positioned(
                          bottom: 8,
                          left: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.9),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'Thumbnail Preview',
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.onSurface,
                                letterSpacing: -0.02,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 100), // Space for bottom button
        ],
      ),
      // ================================================================
      // Fixed Bottom Confirm Booking Button - matches HTML design
      // ================================================================
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: (isDark ? AppTheme.cardDark : Colors.white).withValues(alpha: 0.95),
          border: Border(
            top: BorderSide(
              color: isDark ? AppTheme.borderDark : AppTheme.outlineVariant,
              width: 0.5,
            ),
          ),
        ),
        child: SafeArea(
          child: SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              onPressed: _isSubmitting ? null : _onConfirmBooking,
              icon: _isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.check_circle_rounded, size: 24),
              label: Text(
                _isSubmitting ? 'SUBMITTING...' : 'CONFIRM BOOKING (SUBMIT)',
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.onPrimary,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: AppTheme.onPrimary,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                shadowColor: AppTheme.primary.withValues(alpha: 0.2),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Builds a section card with icon header.
  Widget _buildSectionCard({
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppTheme.outlineVariant),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Row(
            children: [
              Icon(icon, size: 20, color: AppTheme.primary),
              const SizedBox(width: 8),
              Text(
                title.toUpperCase(),
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.05,
                  color: AppTheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  /// Builds a dropdown row with label.
  Widget _buildDropdownRow({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.05,
            color: AppTheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.surfaceContainerLowest,
            border: Border.all(color: AppTheme.outlineVariant),
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              icon: const Icon(
                Icons.expand_more_rounded,
                color: AppTheme.outline,
              ),
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppTheme.onSurface,
              ),
              items: items.map((item) {
                return DropdownMenuItem(
                  value: item,
                  child: Text(item),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  /// Builds a text input field.
  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    String? hintText,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.05,
            color: AppTheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.surfaceContainerLowest,
            border: Border.all(color: AppTheme.outlineVariant),
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppTheme.onSurface,
            ),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: GoogleFonts.inter(
                fontSize: 14,
                color: AppTheme.onSurfaceVariant,
              ),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Builds the monthly rent field with AED prefix.
  Widget _buildRentField({
    required String label,
    required TextEditingController controller,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.05,
            color: AppTheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.surfaceContainerLowest,
            border: Border.all(color: AppTheme.outlineVariant),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  'AED',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.outline,
                  ),
                ),
              ),
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppTheme.onSurface,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 0,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
