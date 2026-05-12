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
