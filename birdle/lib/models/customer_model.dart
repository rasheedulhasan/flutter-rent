/// Customer model for the business management app.
/// Ready for future backend integration.
class CustomerModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String company;
  final String status; // active, inactive, lead, vip
  final double totalSpent;
  final int totalOrders;
  final DateTime lastOrderDate;
  final DateTime createdAt;
  final String? avatarUrl;

  CustomerModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.company,
    required this.status,
    required this.totalSpent,
    required this.totalOrders,
    required this.lastOrderDate,
    required this.createdAt,
    this.avatarUrl,
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      company: json['company'] as String? ?? '',
      status: json['status'] as String? ?? 'active',
      totalSpent: (json['totalSpent'] as num?)?.toDouble() ?? 0.0,
      totalOrders: json['totalOrders'] as int? ?? 0,
      lastOrderDate: DateTime.tryParse(json['lastOrderDate'] as String? ?? '') ?? DateTime.now(),
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
      avatarUrl: json['avatarUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'phone': phone,
        'company': company,
        'status': status,
        'totalSpent': totalSpent,
        'totalOrders': totalOrders,
        'lastOrderDate': lastOrderDate.toIso8601String(),
        'createdAt': createdAt.toIso8601String(),
        'avatarUrl': avatarUrl,
      };
}
