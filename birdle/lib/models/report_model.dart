// Report data models for charts and analytics.
// Ready for future backend integration.

class RevenueDataPoint {
  final String label;
  final double revenue;
  final double? previousRevenue;

  RevenueDataPoint({
    required this.label,
    required this.revenue,
    this.previousRevenue,
  });

  factory RevenueDataPoint.fromJson(Map<String, dynamic> json) {
    return RevenueDataPoint(
      label: json['label'] as String? ?? '',
      revenue: (json['revenue'] as num?)?.toDouble() ?? 0.0,
      previousRevenue: (json['previousRevenue'] as num?)?.toDouble(),
    );
  }
}

class CategorySales {
  final String category;
  final double amount;
  final double percentage;
  final ColorCode color;

  CategorySales({
    required this.category,
    required this.amount,
    required this.percentage,
    required this.color,
  });

  factory CategorySales.fromJson(Map<String, dynamic> json) {
    return CategorySales(
      category: json['category'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      percentage: (json['percentage'] as num?)?.toDouble() ?? 0.0,
      color: ColorCode.fromJson(json['color'] as Map<String, dynamic>? ?? {}),
    );
  }
}

class ColorCode {
  final int r;
  final int g;
  final int b;

  ColorCode({required this.r, required this.g, required this.b});

  factory ColorCode.fromJson(Map<String, dynamic> json) {
    return ColorCode(
      r: json['r'] as int? ?? 0,
      g: json['g'] as int? ?? 0,
      b: json['b'] as int? ?? 0,
    );
  }
}

class MonthlyStats {
  final int totalOrders;
  final double totalRevenue;
  final int newCustomers;
  final double growthRate;

  MonthlyStats({
    required this.totalOrders,
    required this.totalRevenue,
    required this.newCustomers,
    required this.growthRate,
  });

  factory MonthlyStats.fromJson(Map<String, dynamic> json) {
    return MonthlyStats(
      totalOrders: json['totalOrders'] as int? ?? 0,
      totalRevenue: (json['totalRevenue'] as num?)?.toDouble() ?? 0.0,
      newCustomers: json['newCustomers'] as int? ?? 0,
      growthRate: (json['growthRate'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
