import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:birdle/core/app_theme.dart';
import 'package:birdle/models/room_model.dart';
import 'package:birdle/models/tenant_booking_dto.dart';
import 'package:birdle/services/room_service.dart';
import 'package:birdle/services/tenant_booking_service.dart';

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
  final TenantBookingService _bookingService = TenantBookingService();
  final RoomService _roomService = RoomService();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _rentController = TextEditingController();
  final _depositController = TextEditingController();
  final _idNumberController = TextEditingController();
  final _emergencyController = TextEditingController();
  final _notesController = TextEditingController();
  bool _isSubmitting = false;
  bool _isLoadingRooms = true;
  String? _roomsError;

  /// All rooms fetched from the API.
  List<PopulatedRoomModel> _allRooms = [];

  /// Unique building names extracted from the rooms data.
  List<String> _buildings = [];

  /// Floors available for the selected building.
  List<String> _floors = [];

  /// Rooms available for the selected building + floor.
  List<PopulatedRoomModel> _availableRooms = [];

  String? _selectedBuilding;
  String? _selectedFloor;
  PopulatedRoomModel? _selectedRoom;

  @override
  void initState() {
    super.initState();
    _loadRooms();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _rentController.dispose();
    _depositController.dispose();
    _idNumberController.dispose();
    _emergencyController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  /// Fetches populated rooms from the API and extracts building/floor/room data.
  Future<void> _loadRooms() async {
    setState(() {
      _isLoadingRooms = true;
      _roomsError = null;
    });

    try {
      final rooms = await _roomService.getRoomsPopulated();

      if (!mounted) return;

      setState(() {
        _allRooms = rooms;

        // Extract unique building names (use building_name, fall back to building_id)
        final buildingSet = <String>{};
        for (final room in rooms) {
          final name = room.buildingName ?? room.buildingId ?? 'Unknown';
          buildingSet.add(name);
        }
        _buildings = buildingSet.toList()..sort();

        // Auto-select first building if available
        if (_buildings.isNotEmpty) {
          _selectedBuilding = _buildings.first;
          _onBuildingChanged(_buildings.first);
        }

        _isLoadingRooms = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _roomsError = 'Failed to load rooms: $e';
        _isLoadingRooms = false;
      });
    }
  }

  /// Called when the selected building changes.
  /// Updates the floors and available rooms lists.
  void _onBuildingChanged(String building) {
    setState(() {
      _selectedBuilding = building;
      _selectedFloor = null;
      _selectedRoom = null;
      _floors = [];
      _availableRooms = [];

      // Get all rooms for this building
      final buildingRooms = _allRooms.where((r) {
        final name = r.buildingName ?? r.buildingId ?? 'Unknown';
        return name == building;
      }).toList();

      // Extract unique floors
      final floorSet = <String>{};
      for (final room in buildingRooms) {
        floorSet.add(room.floor);
      }
      _floors = floorSet.toList()..sort();

      // Auto-select first floor if available
      if (_floors.isNotEmpty) {
        _selectedFloor = _floors.first;
        _onFloorChanged(_floors.first);
      }
    });
  }

  /// Called when the selected floor changes.
  /// Updates the available rooms list.
  void _onFloorChanged(String floor) {
    setState(() {
      _selectedFloor = floor;
      _selectedRoom = null;

      _availableRooms = _allRooms.where((r) {
        final name = r.buildingName ?? r.buildingId ?? 'Unknown';
        return name == _selectedBuilding && r.floor == floor;
      }).toList();

      // Auto-select first vacant room if available, otherwise first room
      final vacantRooms =
          _availableRooms.where((r) => r.isVacant).toList();
      if (vacantRooms.isNotEmpty) {
        _selectedRoom = vacantRooms.first;
      } else if (_availableRooms.isNotEmpty) {
        _selectedRoom = _availableRooms.first;
      }
    });
  }

  Future<void> _onConfirmBooking() async {
    // Validate required fields
    if (_selectedRoom == null) {
      _showError('Please select a room');
      return;
    }
    if (_nameController.text.trim().isEmpty) {
      _showError('Please enter the tenant name');
      return;
    }
    if (_phoneController.text.trim().isEmpty) {
      _showError('Please enter the phone number');
      return;
    }
    if (_rentController.text.trim().isEmpty) {
      _showError('Please enter the monthly rent');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final rentAmount = double.tryParse(_rentController.text.trim()) ?? 0;
      final depositAmount = double.tryParse(_depositController.text.trim()) ?? 0;

      // Build the DTO matching the POST /api/tenants/booking request body
      final dto = TenantBookingDto(
        roomId: _selectedRoom!.id,
        fullName: _nameController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        checkInDate: DateTime.now().toUtc().toIso8601String(),
        monthlyRent: rentAmount,
        securityDeposit: depositAmount,
        idNumber: _idNumberController.text.trim().isNotEmpty
            ? _idNumberController.text.trim()
            : null,
        emergencyContact: _emergencyController.text.trim().isNotEmpty
            ? _emergencyController.text.trim()
            : null,
        notes: _notesController.text.trim().isNotEmpty
            ? _notesController.text.trim()
            : null,
      );

      // Execute the full booking flow via the orchestrator service
      final result = await _bookingService.bookTenant(dto);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Tenant added successfully — ${result.fullName} in Room ${result.roomNumber}',
            ),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            backgroundColor: AppTheme.success,
          ),
        );
        // Pop back to tenants list view with a result indicating success
        Navigator.of(context).pop(true);
      }
    } on TenantBookingException catch (e) {
      _showError(e.message);
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
      body: _isLoadingRooms
          ? const Center(child: CircularProgressIndicator())
          : _roomsError != null
              ? _buildErrorView()
              : ListView(
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
                            value: _selectedBuilding ?? '',
                            items: _buildings,
                            onChanged: (v) {
                              if (v != null) _onBuildingChanged(v);
                            },
                          ),
                          const SizedBox(height: 16),
                          _buildDropdownRow(
                            label: 'Select Floor',
                            value: _selectedFloor ?? '',
                            items: _floors,
                            onChanged: (v) {
                              if (v != null) _onFloorChanged(v);
                            },
                          ),
                          const SizedBox(height: 16),
                          _buildRoomDropdown(),
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
                            hintText: '+971501234567',
                            keyboardType: TextInputType.phone,
                          ),
                          const SizedBox(height: 16),
                          _buildRentField(
                            label: 'Monthly Rent (AED)',
                            controller: _rentController,
                          ),
                          const SizedBox(height: 16),
                          _buildRentField(
                            label: 'Security Deposit (AED)',
                            controller: _depositController,
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            label: 'ID Number (Optional)',
                            controller: _idNumberController,
                            hintText: '784-1990-1234567-1',
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            label: 'Emergency Contact (Optional)',
                            controller: _emergencyController,
                            hintText: '+971509876543',
                            keyboardType: TextInputType.phone,
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            label: 'Notes (Optional)',
                            controller: _notesController,
                            hintText: 'New booking via mobile app',
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
              onPressed: _isSubmitting || _isLoadingRooms ? null : _onConfirmBooking,
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

  /// Builds the error view with a retry button.
  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 64,
              color: AppTheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              _roomsError!,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppTheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadRooms,
              icon: const Icon(Icons.refresh_rounded),
              label: Text(
                'Retry',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: AppTheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the room dropdown showing room number, rent, and occupancy status.
  Widget _buildRoomDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Room #',
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
            child: DropdownButton<PopulatedRoomModel>(
              value: _selectedRoom,
              isExpanded: true,
              icon: const Icon(
                Icons.expand_more_rounded,
                color: AppTheme.outline,
              ),
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppTheme.onSurface,
              ),
              hint: Text(
                'Select a room',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: AppTheme.onSurfaceVariant,
                ),
              ),
              items: _availableRooms.map((room) {
                final statusLabel = room.isVacant
                    ? 'Vacant'
                    : room.isOccupied
                        ? 'Occupied'
                        : room.status;
                final statusColor = room.isVacant
                    ? AppTheme.success
                    : room.isOccupied
                        ? AppTheme.error
                        : AppTheme.warning;

                return DropdownMenuItem(
                  value: room,
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          room.displayLabel,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          statusLabel,
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: statusColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (room) {
                if (room != null) {
                  setState(() => _selectedRoom = room);
                }
              },
            ),
          ),
        ),
      ],
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
              value: items.contains(value) ? value : null,
              isExpanded: true,
              icon: const Icon(
                Icons.expand_more_rounded,
                color: AppTheme.outline,
              ),
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppTheme.onSurface,
              ),
              hint: Text(
                'Select $label',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: AppTheme.onSurfaceVariant,
                ),
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
