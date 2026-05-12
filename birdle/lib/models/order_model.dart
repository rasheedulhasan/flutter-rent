/// Order model for the business management app.
/// Ready for future backend integration.
class OrderModel {
  final String id;
  final String customerId;
  final String customerName;
  final String customerAvatar;
  final List<OrderItem> items;
  final double totalAmount;
  final String status; // pending, confirmed, processing, shipped, delivered, cancelled
  final String paymentStatus; // paid, unpaid, refunded
  final DateTime orderDate;
  final DateTime? deliveryDate;
  final String shippingAddress;
  final String trackingNumber;
  final List<TrackingEvent> trackingHistory;

  OrderModel({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.customerAvatar,
    required this.items,
    required this.totalAmount,
    required this.status,
    required this.paymentStatus,
    required this.orderDate,
    this.deliveryDate,
    required this.shippingAddress,
    required this.trackingNumber,
    required this.trackingHistory,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] as String? ?? '',
      customerId: json['customerId'] as String? ?? '',
      customerName: json['customerName'] as String? ?? '',
      customerAvatar: json['customerAvatar'] as String? ?? '',
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => OrderItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] as String? ?? 'pending',
      paymentStatus: json['paymentStatus'] as String? ?? 'unpaid',
      orderDate: DateTime.tryParse(json['orderDate'] as String? ?? '') ?? DateTime.now(),
      deliveryDate: DateTime.tryParse(json['deliveryDate'] as String? ?? ''),
      shippingAddress: json['shippingAddress'] as String? ?? '',
      trackingNumber: json['trackingNumber'] as String? ?? '',
      trackingHistory: (json['trackingHistory'] as List<dynamic>?)
              ?.map((e) => TrackingEvent.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'customerId': customerId,
        'customerName': customerName,
        'customerAvatar': customerAvatar,
        'items': items.map((e) => e.toJson()).toList(),
        'totalAmount': totalAmount,
        'status': status,
        'paymentStatus': paymentStatus,
        'orderDate': orderDate.toIso8601String(),
        'deliveryDate': deliveryDate?.toIso8601String(),
        'shippingAddress': shippingAddress,
        'trackingNumber': trackingNumber,
        'trackingHistory': trackingHistory.map((e) => e.toJson()).toList(),
      };
}

class OrderItem {
  final String name;
  final int quantity;
  final double price;
  final String? imageUrl;

  OrderItem({
    required this.name,
    required this.quantity,
    required this.price,
    this.imageUrl,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      name: json['name'] as String? ?? '',
      quantity: json['quantity'] as int? ?? 1,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      imageUrl: json['imageUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'quantity': quantity,
        'price': price,
        'imageUrl': imageUrl,
      };
}

class TrackingEvent {
  final String status;
  final String location;
  final String description;
  final DateTime timestamp;
  final bool isCompleted;

  TrackingEvent({
    required this.status,
    required this.location,
    required this.description,
    required this.timestamp,
    required this.isCompleted,
  });

  factory TrackingEvent.fromJson(Map<String, dynamic> json) {
    return TrackingEvent(
      status: json['status'] as String? ?? '',
      location: json['location'] as String? ?? '',
      description: json['description'] as String? ?? '',
      timestamp: DateTime.tryParse(json['timestamp'] as String? ?? '') ?? DateTime.now(),
      isCompleted: json['isCompleted'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'status': status,
        'location': location,
        'description': description,
        'timestamp': timestamp.toIso8601String(),
        'isCompleted': isCompleted,
      };
}
