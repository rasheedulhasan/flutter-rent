/// Room model mapped from the GET /api/rooms response.
class RoomModel {
  final String id;
  final String? buildingId;
  final String roomNumber;
  final String floor;
  final String type;
  final double monthlyRent;
  final double size;
  final String? amenities;
  final String status;

  RoomModel({
    required this.id,
    this.buildingId,
    required this.roomNumber,
    required this.floor,
    required this.type,
    required this.monthlyRent,
    required this.size,
    this.amenities,
    required this.status,
  });

  /// Safely converts a dynamic value to String, handling both String and int.
  static String? _safeString(dynamic value) {
    if (value == null) return null;
    if (value is String) return value;
    return value.toString();
  }

  factory RoomModel.fromJson(Map<String, dynamic> json) {
    return RoomModel(
      id: _safeString(json['\$id']) ?? _safeString(json['id']) ?? '',
      buildingId: _safeString(json['building_id']),
      roomNumber: _safeString(json['room_number']) ?? '',
      floor: _safeString(json['floor']) ?? '',
      type: _safeString(json['type']) ?? '',
      monthlyRent: (json['monthly_rent'] as num?)?.toDouble() ?? 0.0,
      size: (json['size'] as num?)?.toDouble() ?? 0.0,
      amenities: _safeString(json['amenities']),
      status: _safeString(json['status']) ?? 'available',
    );
  }

  Map<String, dynamic> toJson() => {
        '\$id': id,
        'building_id': buildingId,
        'room_number': roomNumber,
        'floor': floor,
        'type': type,
        'monthly_rent': monthlyRent,
        'size': size,
        'amenities': amenities,
        'status': status,
      };

  bool get isOccupied => status.toLowerCase() == 'occupied';
}

/// Populated room model returned by GET /api/rooms/populated endpoints.
/// Includes building_name and current_tenant fields.
class PopulatedRoomModel {
  final String id;
  final String roomNumber;
  final String floor;
  final String type;
  final double monthlyRent;
  final String status;
  final String? buildingId;
  final String? buildingName;
  final PopulatedTenant? currentTenant;

  PopulatedRoomModel({
    required this.id,
    required this.roomNumber,
    required this.floor,
    required this.type,
    required this.monthlyRent,
    required this.status,
    this.buildingId,
    this.buildingName,
    this.currentTenant,
  });

  /// Safely converts a dynamic value to String, handling both String and int.
  static String? _safeString(dynamic value) {
    if (value == null) return null;
    if (value is String) return value;
    return value.toString();
  }

  factory PopulatedRoomModel.fromJson(Map<String, dynamic> json) {
    return PopulatedRoomModel(
      id: _safeString(json['\$id']) ?? _safeString(json['id']) ?? '',
      roomNumber: _safeString(json['room_number']) ?? '',
      floor: _safeString(json['floor']) ?? '',
      type: _safeString(json['type']) ?? '',
      monthlyRent: (json['monthly_rent'] as num?)?.toDouble() ?? 0.0,
      status: _safeString(json['status']) ?? 'available',
      buildingId: _safeString(json['building_id']),
      buildingName: _safeString(json['building_name']),
      currentTenant: json['current_tenant'] != null
          ? PopulatedTenant.fromJson(
              json['current_tenant'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  /// Display-friendly room label (e.g. "A-305 - 5,000 AED")
  String get displayLabel =>
      '$roomNumber - ${monthlyRent.toStringAsFixed(0)} AED';

  bool get isOccupied => status.toLowerCase() == 'occupied';
  bool get isVacant => status.toLowerCase() == 'vacant';
}

/// Minimal tenant info embedded in the populated room response.
class PopulatedTenant {
  final String id;
  final String fullName;
  final String? phoneNumber;
  final double monthlyRent;
  final String status;

  PopulatedTenant({
    required this.id,
    required this.fullName,
    this.phoneNumber,
    required this.monthlyRent,
    required this.status,
  });

  static String? _safeString(dynamic value) {
    if (value == null) return null;
    if (value is String) return value;
    return value.toString();
  }

  factory PopulatedTenant.fromJson(Map<String, dynamic> json) {
    return PopulatedTenant(
      id: _safeString(json['\$id']) ?? _safeString(json['id']) ?? '',
      fullName: _safeString(json['full_name']) ?? '',
      phoneNumber: _safeString(json['phone_number']),
      monthlyRent: (json['monthly_rent'] as num?)?.toDouble() ?? 0.0,
      status: _safeString(json['status']) ?? 'active',
    );
  }
}
