import 'package:flutter/material.dart';
import 'package:birdle/models/user_model.dart';
import 'package:birdle/models/customer_model.dart';
import 'package:birdle/models/order_model.dart';
import 'package:birdle/models/invoice_model.dart';
import 'package:birdle/models/notification_model.dart';
import 'package:birdle/models/report_model.dart';
import 'package:birdle/models/room_model.dart';

/// Centralized mock data for the entire app.
/// Replace with API calls when backend is integrated.
class MockData {
  // ===========================================================================
  // USER
  // ===========================================================================
  static const String adminUsername = 'admin';
  static const String adminPassword = 'admin';

  static UserModel get currentUser => UserModel(
        id: 'usr_001',
        name: 'John Doe',
        fullName: 'John Doe',
        email: 'john.doe@promanager.com',
        phone: '+1 (555) 123-4567',
        avatarUrl: '',
        role: 'Manager',
        joinedAt: DateTime(2023, 1, 15),
      );

  // ===========================================================================
  // PROPERTY MANAGEMENT STATS
  // ===========================================================================
  static const String buildingName = 'Central Square Tower';
  static const double rentDueThisWeek = 12500.00;
  static const int pendingRooms = 8;
  static const int totalRooms = 15;
  static const double occupancyRate = 94.2;
  static const int totalUnits = 120;
  static const int occupiedUnits = 113;
  static const int vacantUnits = 7;

  // Legacy dashboard stats (backward compatibility)
  static const double totalRevenue = 284500.00;
  static const double revenueGrowth = 12.5;
  static const int totalOrders = 1847;
  static const double ordersGrowth = 8.2;
  static const int totalCustomers = 562;
  static const double customersGrowth = 15.3;
  static const double avgOrderValue = 154.00;
  static const double avgOrderGrowth = -2.1;

  // ===========================================================================
  // REVENUE CHART DATA (Monthly Rent Collections)
  // ===========================================================================
  static List<RevenueDataPoint> get revenueChartData => [
        RevenueDataPoint(label: 'Jan', revenue: 18500, previousRevenue: 16000),
        RevenueDataPoint(label: 'Feb', revenue: 22300, previousRevenue: 19000),
        RevenueDataPoint(label: 'Mar', revenue: 19800, previousRevenue: 21000),
        RevenueDataPoint(label: 'Apr', revenue: 25600, previousRevenue: 22000),
        RevenueDataPoint(label: 'May', revenue: 28900, previousRevenue: 24000),
        RevenueDataPoint(label: 'Jun', revenue: 31200, previousRevenue: 26000),
        RevenueDataPoint(label: 'Jul', revenue: 27800, previousRevenue: 25500),
        RevenueDataPoint(label: 'Aug', revenue: 33400, previousRevenue: 27000),
        RevenueDataPoint(label: 'Sep', revenue: 36500, previousRevenue: 29000),
        RevenueDataPoint(label: 'Oct', revenue: 34200, previousRevenue: 31000),
        RevenueDataPoint(label: 'Nov', revenue: 38900, previousRevenue: 33000),
        RevenueDataPoint(label: 'Dec', revenue: 42400, previousRevenue: 35000),
      ];

  // ===========================================================================
  // CATEGORY SALES (Pie Chart)
  // ===========================================================================
  static List<CategorySales> get categorySales => [
        CategorySales(category: 'Studio', amount: 85200, percentage: 30, color: ColorCode(r: 108, g: 99, b: 255)),
        CategorySales(category: '1-Bedroom', amount: 56800, percentage: 20, color: ColorCode(r: 0, g: 217, b: 166)),
        CategorySales(category: '2-Bedroom', amount: 42600, percentage: 15, color: ColorCode(r: 245, g: 158, b: 11)),
        CategorySales(category: 'Penthouse', amount: 34100, percentage: 12, color: ColorCode(r: 239, g: 68, b: 68)),
        CategorySales(category: 'Commercial', amount: 28400, percentage: 10, color: ColorCode(r: 59, g: 130, b: 246)),
        CategorySales(category: 'Parking', amount: 37100, percentage: 13, color: ColorCode(r: 139, g: 92, b: 246)),
      ];

  // ===========================================================================
  // ACTIVITY TIMELINE
  // ===========================================================================
  static List<Map<String, dynamic>> get activityTimeline => [
        {
          'icon': Icons.payments_outlined,
          'title': 'Rent payment received',
          'subtitle': 'Unit #304 - Sarah Johnson paid د.إ1,850',
          'time': '2 minutes ago',
          'color': 0xFF0058BC,
        },
        {
          'icon': Icons.person_add_outlined,
          'title': 'New tenant registered',
          'subtitle': 'Michael Chen signed lease for Unit #512',
          'time': '15 minutes ago',
          'color': 0xFF00D9A6,
        },
        {
          'icon': Icons.build_outlined,
          'title': 'Maintenance request completed',
          'subtitle': 'Unit #208 - AC repair finished',
          'time': '1 hour ago',
          'color': 0xFF10B981,
        },
        {
          'icon': Icons.receipt_outlined,
          'title': 'Invoice overdue reminder sent',
          'subtitle': 'Invoice #INV-2024-0013 to Robert Taylor',
          'time': '2 hours ago',
          'color': 0xFFBA1A1A,
        },
        {
          'icon': Icons.warning_amber_outlined,
          'title': 'Low inventory alert',
          'subtitle': 'Cleaning supplies running low',
          'time': '3 hours ago',
          'color': 0xFFF59E0B,
        },
        {
          'icon': Icons.cancel_outlined,
          'title': 'Booking cancelled',
          'subtitle': 'Unit #415 booking was cancelled',
          'time': '5 hours ago',
          'color': 0xFFEF4444,
        },
      ];

  // ===========================================================================
  // CUSTOMERS (Tenants)
  // ===========================================================================
  static List<CustomerModel> get customers => [
        CustomerModel(
          id: 'cus_001',
          name: 'Sarah Johnson',
          email: 'sarah.j@email.com',
          phone: '+1 (555) 234-5678',
          company: 'TechCorp Inc.',
          status: 'vip',
          totalSpent: 28450.00,
          totalOrders: 48,
          lastOrderDate: DateTime(2024, 12, 15),
          createdAt: DateTime(2023, 3, 10),
        ),
        CustomerModel(
          id: 'cus_002',
          name: 'Michael Chen',
          email: 'michael.chen@email.com',
          phone: '+1 (555) 345-6789',
          company: 'Chen Industries',
          status: 'active',
          totalSpent: 12300.00,
          totalOrders: 23,
          lastOrderDate: DateTime(2024, 12, 14),
          createdAt: DateTime(2023, 6, 22),
        ),
        CustomerModel(
          id: 'cus_003',
          name: 'Emily Rodriguez',
          email: 'emily.r@email.com',
          phone: '+1 (555) 456-7890',
          company: 'Design Studio LLC',
          status: 'active',
          totalSpent: 8750.00,
          totalOrders: 15,
          lastOrderDate: DateTime(2024, 12, 10),
          createdAt: DateTime(2024, 1, 5),
        ),
        CustomerModel(
          id: 'cus_004',
          name: 'James Wilson',
          email: 'james.w@email.com',
          phone: '+1 (555) 567-8901',
          company: 'Wilson & Sons',
          status: 'inactive',
          totalSpent: 3200.00,
          totalOrders: 8,
          lastOrderDate: DateTime(2024, 9, 28),
          createdAt: DateTime(2023, 11, 15),
        ),
        CustomerModel(
          id: 'cus_005',
          name: 'Lisa Thompson',
          email: 'lisa.t@email.com',
          phone: '+1 (555) 678-9012',
          company: 'Thompson Retail',
          status: 'vip',
          totalSpent: 45200.00,
          totalOrders: 72,
          lastOrderDate: DateTime(2024, 12, 16),
          createdAt: DateTime(2022, 8, 1),
        ),
        CustomerModel(
          id: 'cus_006',
          name: 'David Kim',
          email: 'david.kim@email.com',
          phone: '+1 (555) 789-0123',
          company: 'Kim Consulting',
          status: 'lead',
          totalSpent: 0,
          totalOrders: 0,
          lastOrderDate: DateTime(2024, 12, 1),
          createdAt: DateTime(2024, 12, 1),
        ),
        CustomerModel(
          id: 'cus_007',
          name: 'Anna Martinez',
          email: 'anna.m@email.com',
          phone: '+1 (555) 890-1234',
          company: 'Martinez Co.',
          status: 'active',
          totalSpent: 15600.00,
          totalOrders: 31,
          lastOrderDate: DateTime(2024, 12, 12),
          createdAt: DateTime(2023, 9, 18),
        ),
        CustomerModel(
          id: 'cus_008',
          name: 'Robert Taylor',
          email: 'robert.t@email.com',
          phone: '+1 (555) 901-2345',
          company: 'Taylor Made Solutions',
          status: 'active',
          totalSpent: 9800.00,
          totalOrders: 19,
          lastOrderDate: DateTime(2024, 12, 8),
          createdAt: DateTime(2024, 4, 12),
        ),
      ];

  // ===========================================================================
  // ORDERS (Rent Payments / Bookings)
  // ===========================================================================
  static List<OrderModel> get orders => [
        OrderModel(
          id: 'ORD-2024-0042',
          customerId: 'cus_001',
          customerName: 'Sarah Johnson',
          customerAvatar: '',
          items: [
            OrderItem(name: 'Unit #304 - Monthly Rent', quantity: 1, price: 1850.00),
            OrderItem(name: 'Parking Fee', quantity: 1, price: 150.00),
          ],
          totalAmount: 2000.00,
          status: 'pending',
          paymentStatus: 'unpaid',
          orderDate: DateTime(2024, 12, 16, 14, 30),
          shippingAddress: 'Unit #304, Central Square Tower',
          trackingNumber: '',
          trackingHistory: [
            TrackingEvent(status: 'Rent Due', location: 'Online', description: 'Rent invoice generated', timestamp: DateTime(2024, 12, 16, 14, 30), isCompleted: true),
          ],
        ),
        OrderModel(
          id: 'ORD-2024-0041',
          customerId: 'cus_005',
          customerName: 'Lisa Thompson',
          customerAvatar: '',
          items: [
            OrderItem(name: 'Unit #1201 - Monthly Rent', quantity: 1, price: 3200.00),
            OrderItem(name: 'Storage Unit Fee', quantity: 1, price: 75.00),
          ],
          totalAmount: 3275.00,
          status: 'confirmed',
          paymentStatus: 'paid',
          orderDate: DateTime(2024, 12, 16, 10, 15),
          shippingAddress: 'Unit #1201, Central Square Tower',
          trackingNumber: 'RCPT-2024-0088',
          trackingHistory: [
            TrackingEvent(status: 'Rent Due', location: 'Online', description: 'Rent invoice generated', timestamp: DateTime(2024, 12, 16, 10, 15), isCompleted: true),
            TrackingEvent(status: 'Paid', location: 'Online', description: 'Payment received', timestamp: DateTime(2024, 12, 16, 11, 30), isCompleted: true),
          ],
        ),
        OrderModel(
          id: 'ORD-2024-0040',
          customerId: 'cus_003',
          customerName: 'Emily Rodriguez',
          customerAvatar: '',
          items: [
            OrderItem(name: 'Unit #508 - Monthly Rent', quantity: 1, price: 2100.00),
          ],
          totalAmount: 2100.00,
          status: 'processing',
          paymentStatus: 'paid',
          orderDate: DateTime(2024, 12, 15, 16, 45),
          shippingAddress: 'Unit #508, Central Square Tower',
          trackingNumber: 'RCPT-2024-0087',
          trackingHistory: [
            TrackingEvent(status: 'Rent Due', location: 'Online', description: 'Rent invoice generated', timestamp: DateTime(2024, 12, 15, 16, 45), isCompleted: true),
            TrackingEvent(status: 'Paid', location: 'Online', description: 'Payment received', timestamp: DateTime(2024, 12, 15, 18, 0), isCompleted: true),
          ],
        ),
        OrderModel(
          id: 'ORD-2024-0039',
          customerId: 'cus_007',
          customerName: 'Anna Martinez',
          customerAvatar: '',
          items: [
            OrderItem(name: 'Unit #712 - Monthly Rent', quantity: 1, price: 1750.00),
            OrderItem(name: 'Pet Fee', quantity: 1, price: 50.00),
          ],
          totalAmount: 1800.00,
          status: 'shipped',
          paymentStatus: 'paid',
          orderDate: DateTime(2024, 12, 14, 9, 0),
          shippingAddress: 'Unit #712, Central Square Tower',
          trackingNumber: 'RCPT-2024-0086',
          trackingHistory: [
            TrackingEvent(status: 'Rent Due', location: 'Online', description: 'Rent invoice generated', timestamp: DateTime(2024, 12, 14, 9, 0), isCompleted: true),
            TrackingEvent(status: 'Paid', location: 'Online', description: 'Payment received', timestamp: DateTime(2024, 12, 14, 10, 30), isCompleted: true),
          ],
        ),
        OrderModel(
          id: 'ORD-2024-0038',
          customerId: 'cus_002',
          customerName: 'Michael Chen',
          customerAvatar: '',
          items: [
            OrderItem(name: 'Unit #512 - Monthly Rent', quantity: 1, price: 1950.00),
          ],
          totalAmount: 1950.00,
          status: 'delivered',
          paymentStatus: 'paid',
          orderDate: DateTime(2024, 12, 10, 11, 20),
          deliveryDate: DateTime(2024, 12, 10, 15, 30),
          shippingAddress: 'Unit #512, Central Square Tower',
          trackingNumber: 'RCPT-2024-0085',
          trackingHistory: [
            TrackingEvent(status: 'Rent Due', location: 'Online', description: 'Rent invoice generated', timestamp: DateTime(2024, 12, 10, 11, 20), isCompleted: true),
            TrackingEvent(status: 'Paid', location: 'Online', description: 'Payment received', timestamp: DateTime(2024, 12, 10, 12, 0), isCompleted: true),
          ],
        ),
        OrderModel(
          id: 'ORD-2024-0037',
          customerId: 'cus_004',
          customerName: 'James Wilson',
          customerAvatar: '',
          items: [
            OrderItem(name: 'Unit #215 - Monthly Rent', quantity: 1, price: 1600.00),
          ],
          totalAmount: 1600.00,
          status: 'cancelled',
          paymentStatus: 'refunded',
          orderDate: DateTime(2024, 12, 8, 13, 10),
          shippingAddress: 'Unit #215, Central Square Tower',
          trackingNumber: '',
          trackingHistory: [
            TrackingEvent(status: 'Rent Due', location: 'Online', description: 'Rent invoice generated', timestamp: DateTime(2024, 12, 8, 13, 10), isCompleted: true),
            TrackingEvent(status: 'Cancelled', location: 'Online', description: 'Lease terminated', timestamp: DateTime(2024, 12, 8, 15, 0), isCompleted: true),
          ],
        ),
      ];

  // ===========================================================================
  // INVOICES
  // ===========================================================================
  static List<InvoiceModel> get invoices => [
        InvoiceModel(
          id: 'inv_001',
          invoiceNumber: 'INV-2024-0018',
          customerId: 'cus_001',
          customerName: 'Sarah Johnson',
          customerEmail: 'sarah.j@email.com',
          amount: 1850.00,
          tax: 0,
          total: 1850.00,
          status: 'unpaid',
          issueDate: DateTime(2024, 12, 16),
          dueDate: DateTime(2025, 1, 15),
          items: [
            InvoiceItem(description: 'Unit #304 - December Rent', quantity: 1, unitPrice: 1850.00, total: 1850.00),
          ],
        ),
        InvoiceModel(
          id: 'inv_002',
          invoiceNumber: 'INV-2024-0017',
          customerId: 'cus_005',
          customerName: 'Lisa Thompson',
          customerEmail: 'lisa.t@email.com',
          amount: 3200.00,
          tax: 75.00,
          total: 3275.00,
          status: 'paid',
          issueDate: DateTime(2024, 12, 16),
          dueDate: DateTime(2025, 1, 15),
          paidDate: DateTime(2024, 12, 16),
          items: [
            InvoiceItem(description: 'Unit #1201 - December Rent', quantity: 1, unitPrice: 3200.00, total: 3200.00),
            InvoiceItem(description: 'Storage Unit Fee', quantity: 1, unitPrice: 75.00, total: 75.00),
          ],
        ),
        InvoiceModel(
          id: 'inv_003',
          invoiceNumber: 'INV-2024-0016',
          customerId: 'cus_003',
          customerName: 'Emily Rodriguez',
          customerEmail: 'emily.r@email.com',
          amount: 2100.00,
          tax: 0,
          total: 2100.00,
          status: 'paid',
          issueDate: DateTime(2024, 12, 15),
          dueDate: DateTime(2025, 1, 14),
          paidDate: DateTime(2024, 12, 15),
          items: [
            InvoiceItem(description: 'Unit #508 - December Rent', quantity: 1, unitPrice: 2100.00, total: 2100.00),
          ],
        ),
        InvoiceModel(
          id: 'inv_004',
          invoiceNumber: 'INV-2024-0015',
          customerId: 'cus_007',
          customerName: 'Anna Martinez',
          customerEmail: 'anna.m@email.com',
          amount: 1750.00,
          tax: 50.00,
          total: 1800.00,
          status: 'paid',
          issueDate: DateTime(2024, 12, 14),
          dueDate: DateTime(2025, 1, 13),
          paidDate: DateTime(2024, 12, 14),
          items: [
            InvoiceItem(description: 'Unit #712 - December Rent', quantity: 1, unitPrice: 1750.00, total: 1750.00),
            InvoiceItem(description: 'Pet Fee', quantity: 1, unitPrice: 50.00, total: 50.00),
          ],
        ),
        InvoiceModel(
          id: 'inv_005',
          invoiceNumber: 'INV-2024-0014',
          customerId: 'cus_002',
          customerName: 'Michael Chen',
          customerEmail: 'michael.chen@email.com',
          amount: 1950.00,
          tax: 0,
          total: 1950.00,
          status: 'paid',
          issueDate: DateTime(2024, 12, 10),
          dueDate: DateTime(2025, 1, 9),
          paidDate: DateTime(2024, 12, 10),
          items: [
            InvoiceItem(description: 'Unit #512 - December Rent', quantity: 1, unitPrice: 1950.00, total: 1950.00),
          ],
        ),
        InvoiceModel(
          id: 'inv_006',
          invoiceNumber: 'INV-2024-0013',
          customerId: 'cus_008',
          customerName: 'Robert Taylor',
          customerEmail: 'robert.t@email.com',
          amount: 2200.00,
          tax: 0,
          total: 2200.00,
          status: 'overdue',
          issueDate: DateTime(2024, 11, 20),
          dueDate: DateTime(2024, 12, 20),
          items: [
            InvoiceItem(description: 'Unit #1001 - December Rent', quantity: 1, unitPrice: 2200.00, total: 2200.00),
          ],
        ),
      ];

  // ===========================================================================
  // NOTIFICATIONS
  // ===========================================================================
  static List<NotificationModel> get notifications => [
        NotificationModel(
          id: 'notif_001',
          title: 'Rent Payment Received',
          message: 'Unit #304 - Sarah Johnson paid د.إ1,850.00',
          type: 'order',
          isRead: false,
          createdAt: DateTime(2024, 12, 16, 14, 30),
          actionRoute: '/orders',
        ),
        NotificationModel(
          id: 'notif_002',
          title: 'Payment Received',
          message: 'Invoice #INV-2024-0017 from Lisa Thompson has been paid.',
          type: 'invoice',
          isRead: false,
          createdAt: DateTime(2024, 12, 16, 11, 45),
          actionRoute: '/invoices',
        ),
        NotificationModel(
          id: 'notif_003',
          title: 'New Tenant Registered',
          message: 'David Kim has signed a lease for Unit #315.',
          type: 'customer',
          isRead: false,
          createdAt: DateTime(2024, 12, 16, 9, 20),
          actionRoute: '/customers',
        ),
        NotificationModel(
          id: 'notif_004',
          title: 'Maintenance Request Completed',
          message: 'AC repair in Unit #712 has been completed.',
          type: 'order',
          isRead: true,
          createdAt: DateTime(2024, 12, 15, 8, 0),
          actionRoute: '/orders',
        ),
        NotificationModel(
          id: 'notif_005',
          title: 'Low Inventory Alert',
          message: 'Cleaning supplies are running low. Only 5 units left.',
          type: 'system',
          isRead: true,
          createdAt: DateTime(2024, 12, 14, 16, 0),
        ),
        NotificationModel(
          id: 'notif_006',
          title: 'Rent Overdue',
          message: 'Invoice #INV-2024-0013 for Robert Taylor is now overdue.',
          type: 'invoice',
          isRead: true,
          createdAt: DateTime(2024, 12, 21, 0, 0),
          actionRoute: '/invoices',
        ),
        NotificationModel(
          id: 'notif_007',
          title: 'Weekly Report Ready',
          message: 'Your weekly occupancy report for Dec 9-15 is now available.',
          type: 'system',
          isRead: true,
          createdAt: DateTime(2024, 12, 16, 6, 0),
          actionRoute: '/reports',
        ),
        NotificationModel(
          id: 'notif_008',
          title: 'Holiday Notice',
          message: 'Building office hours will change during the holiday season.',
          type: 'promotion',
          isRead: true,
          createdAt: DateTime(2024, 12, 13, 10, 0),
        ),
      ];

  // ===========================================================================
  // RECENT ORDERS (for dashboard)
  // ===========================================================================
  static List<OrderModel> get recentOrders => orders.take(4).toList();

  // ===========================================================================
  // MONTHLY STATS
  // ===========================================================================
  static MonthlyStats get currentMonthStats => MonthlyStats(
        totalOrders: 342,
        totalRevenue: 42400,
        newCustomers: 28,
        growthRate: 18.5,
      );
  // ===========================================================================
  // ROOMS (for Pending Rent)
  // ===========================================================================
  static List<RoomModel> get rooms => [
        RoomModel(
          id: 'room_001',
          buildingId: 'Central Square Tower',
          roomNumber: '101',
          floor: '1',
          type: 'Studio',
          monthlyRent: 1800.00,
          size: 35.0,
          amenities: 'AC, WiFi, Furnished',
          status: 'occupied',
        ),
        RoomModel(
          id: 'room_002',
          buildingId: 'Central Square Tower',
          roomNumber: '102',
          floor: '1',
          type: 'Studio',
          monthlyRent: 1750.00,
          size: 32.0,
          amenities: 'AC, WiFi',
          status: 'occupied',
        ),
        RoomModel(
          id: 'room_003',
          buildingId: 'Central Square Tower',
          roomNumber: '201',
          floor: '2',
          type: '1-Bedroom',
          monthlyRent: 2500.00,
          size: 50.0,
          amenities: 'AC, WiFi, Furnished, Balcony',
          status: 'occupied',
        ),
        RoomModel(
          id: 'room_004',
          buildingId: 'Central Square Tower',
          roomNumber: '202',
          floor: '2',
          type: '1-Bedroom',
          monthlyRent: 2400.00,
          size: 48.0,
          amenities: 'AC, WiFi, Furnished',
          status: 'occupied',
        ),
        RoomModel(
          id: 'room_005',
          buildingId: 'Central Square Tower',
          roomNumber: '301',
          floor: '3',
          type: '2-Bedroom',
          monthlyRent: 3500.00,
          size: 75.0,
          amenities: 'AC, WiFi, Furnished, Balcony, Parking',
          status: 'occupied',
        ),
        RoomModel(
          id: 'room_006',
          buildingId: 'Central Square Tower',
          roomNumber: '302',
          floor: '3',
          type: '2-Bedroom',
          monthlyRent: 3400.00,
          size: 70.0,
          amenities: 'AC, WiFi, Furnished, Balcony',
          status: 'occupied',
        ),
        RoomModel(
          id: 'room_007',
          buildingId: 'Central Square Tower',
          roomNumber: '401',
          floor: '4',
          type: 'Penthouse',
          monthlyRent: 5500.00,
          size: 120.0,
          amenities: 'AC, WiFi, Fully Furnished, Balcony, Parking, Gym',
          status: 'occupied',
        ),
        RoomModel(
          id: 'room_008',
          buildingId: 'Central Square Tower',
          roomNumber: '103',
          floor: '1',
          type: 'Studio',
          monthlyRent: 1700.00,
          size: 30.0,
          amenities: 'AC, WiFi',
          status: 'available',
        ),
        RoomModel(
          id: 'room_009',
          buildingId: 'Central Square Tower',
          roomNumber: '203',
          floor: '2',
          type: '1-Bedroom',
          monthlyRent: 2300.00,
          size: 45.0,
          amenities: 'AC, WiFi',
          status: 'available',
        ),
        RoomModel(
          id: 'room_010',
          buildingId: 'Central Square Tower',
          roomNumber: '303',
          floor: '3',
          type: '2-Bedroom',
          monthlyRent: 3300.00,
          size: 68.0,
          amenities: 'AC, WiFi, Furnished',
          status: 'available',
        ),
        RoomModel(
          id: 'room_011',
          buildingId: 'Central Square Tower',
          roomNumber: '404',
          floor: '4',
          type: 'Studio',
          monthlyRent: 1850.00,
          size: 33.0,
          amenities: 'AC, WiFi, Furnished, View',
          status: 'occupied',
        ),
        RoomModel(
          id: 'room_012',
          buildingId: 'Central Square Tower',
          roomNumber: '405',
          floor: '4',
          type: '1-Bedroom',
          monthlyRent: 2600.00,
          size: 52.0,
          amenities: 'AC, WiFi, Furnished, Balcony',
          status: 'occupied',
        ),
        RoomModel(
          id: 'room_013',
          buildingId: 'Central Square Tower',
          roomNumber: '406',
          floor: '4',
          type: '1-Bedroom',
          monthlyRent: 2550.00,
          size: 50.0,
          amenities: 'AC, WiFi, Furnished',
          status: 'occupied',
        ),
        RoomModel(
          id: 'room_014',
          buildingId: 'Central Square Tower',
          roomNumber: '501',
          floor: '5',
          type: '2-Bedroom',
          monthlyRent: 3600.00,
          size: 78.0,
          amenities: 'AC, WiFi, Furnished, Balcony, Parking',
          status: 'occupied',
        ),
        RoomModel(
          id: 'room_015',
          buildingId: 'Central Square Tower',
          roomNumber: '502',
          floor: '5',
          type: '2-Bedroom',
          monthlyRent: 3550.00,
          size: 72.0,
          amenities: 'AC, WiFi, Furnished, Balcony',
          status: 'occupied',
        ),
        RoomModel(
          id: 'room_016',
          buildingId: 'Central Square Tower',
          roomNumber: '503',
          floor: '5',
          type: 'Penthouse',
          monthlyRent: 6000.00,
          size: 130.0,
          amenities: 'AC, WiFi, Fully Furnished, Balcony, Parking, Gym, Pool',
          status: 'occupied',
        ),
        RoomModel(
          id: 'room_017',
          buildingId: 'Central Square Tower',
          roomNumber: '104',
          floor: '1',
          type: 'Studio',
          monthlyRent: 1650.00,
          size: 28.0,
          amenities: 'AC, WiFi',
          status: 'available',
        ),
        RoomModel(
          id: 'room_018',
          buildingId: 'Central Square Tower',
          roomNumber: '204',
          floor: '2',
          type: '1-Bedroom',
          monthlyRent: 2250.00,
          size: 44.0,
          amenities: 'AC, WiFi, Furnished',
          status: 'available',
        ),
        RoomModel(
          id: 'room_019',
          buildingId: 'Central Square Tower',
          roomNumber: '304',
          floor: '3',
          type: '2-Bedroom',
          monthlyRent: 3200.00,
          size: 65.0,
          amenities: 'AC, WiFi',
          status: 'available',
        ),
        RoomModel(
          id: 'room_020',
          buildingId: 'Central Square Tower',
          roomNumber: '407',
          floor: '4',
          type: 'Studio',
          monthlyRent: 1780.00,
          size: 31.0,
          amenities: 'AC, WiFi, Furnished',
          status: 'available',
        ),
      ];

  // ===========================================================================
  // OCCUPIED ROOMS (filtered from rooms list)
  // ===========================================================================
  static List<RoomModel> get occupiedRooms =>
      rooms.where((r) => r.isOccupied).toList();

  // ===========================================================================
  // TENANT DATA (for Pending Rent - returned by /rooms/:id/with-tenant)
  // ===========================================================================
  static Map<String, Map<String, dynamic>> get tenantDataByRoom => {
        'room_001': {
          'id': 'tenant_001',
          'full_name': 'Ahmed Al Mansouri',
          'phone_number': '+971 50 123 4567',
          'email': 'ahmed.almansouri@email.com',
          'monthly_rent': 1800.00,
          'status': 'active',
          'check_in_date': '2025-09-01',
        },
        'room_002': {
          'id': 'tenant_002',
          'full_name': 'Fatima Hassan',
          'phone_number': '+971 55 234 5678',
          'email': 'fatima.hassan@email.com',
          'monthly_rent': 1750.00,
          'status': 'active',
          'check_in_date': '2025-10-15',
        },
        'room_003': {
          'id': 'tenant_003',
          'full_name': 'Mohammed Al Zaabi',
          'phone_number': '+971 52 345 6789',
          'email': 'mohammed.alzaabi@email.com',
          'monthly_rent': 2500.00,
          'status': 'active',
          'check_in_date': '2025-08-01',
        },
        'room_004': {
          'id': 'tenant_004',
          'full_name': 'Sara Khalid',
          'phone_number': '+971 54 456 7890',
          'email': 'sara.khalid@email.com',
          'monthly_rent': 2400.00,
          'status': 'active',
          'check_in_date': '2025-11-01',
        },
        'room_005': {
          'id': 'tenant_005',
          'full_name': 'Omar Al Hashimi',
          'phone_number': '+971 58 567 8901',
          'email': 'omar.alhashimi@email.com',
          'monthly_rent': 3500.00,
          'status': 'active',
          'check_in_date': '2025-07-01',
        },
        'room_006': {
          'id': 'tenant_006',
          'full_name': 'Noora Al Suwaidi',
          'phone_number': '+971 56 678 9012',
          'email': 'noora.alsuwaidi@email.com',
          'monthly_rent': 3400.00,
          'status': 'active',
          'check_in_date': '2025-06-01',
        },
        'room_007': {
          'id': 'tenant_007',
          'full_name': 'Khalid Al Nuaimi',
          'phone_number': '+971 50 789 0123',
          'email': 'khalid.alnuaimi@email.com',
          'monthly_rent': 5500.00,
          'status': 'active',
          'check_in_date': '2025-05-01',
        },
        // New occupied rooms - tenants
        'room_011': {
          'id': 'tenant_008',
          'full_name': 'Layla Al Mazroui',
          'phone_number': '+971 52 111 2233',
          'email': 'layla.almazroui@email.com',
          'monthly_rent': 1850.00,
          'status': 'active',
          'check_in_date': '2025-12-01',
        },
        'room_012': {
          'id': 'tenant_009',
          'full_name': 'Rashid Al Falasi',
          'phone_number': '+971 55 222 3344',
          'email': 'rashid.alfalasi@email.com',
          'monthly_rent': 2600.00,
          'status': 'active',
          'check_in_date': '2026-01-15',
        },
        'room_013': {
          'id': 'tenant_010',
          'full_name': 'Mariam Al Qubaisi',
          'phone_number': '+971 54 333 4455',
          'email': 'mariam.alqubaisi@email.com',
          'monthly_rent': 2550.00,
          'status': 'active',
          'check_in_date': '2026-02-01',
        },
        'room_014': {
          'id': 'tenant_011',
          'full_name': 'Sultan Al Neyadi',
          'phone_number': '+971 50 444 5566',
          'email': 'sultan.alneyadi@email.com',
          'monthly_rent': 3600.00,
          'status': 'active',
          'check_in_date': '2025-10-01',
        },
        'room_015': {
          'id': 'tenant_012',
          'full_name': 'Hessa Al Muhairi',
          'phone_number': '+971 56 555 6677',
          'email': 'hessa.almuhairi@email.com',
          'monthly_rent': 3550.00,
          'status': 'active',
          'check_in_date': '2025-11-15',
        },
        'room_016': {
          'id': 'tenant_013',
          'full_name': 'Abdulla Al Shamsi',
          'phone_number': '+971 58 666 7788',
          'email': 'abdulla.alshamsi@email.com',
          'monthly_rent': 6000.00,
          'status': 'active',
          'check_in_date': '2025-09-01',
        },
      };

  // ===========================================================================
  // TRANSACTIONS (for Pending Rent)
  // ===========================================================================
  static Map<String, List<Map<String, dynamic>>> get transactionsByTenant => {
        // Ahmed - paid Jan, Feb, Mar; pending Apr, May
        'tenant_001': [
          {'id': 'txn_001', 'amount': 1800.00, 'payment_status': 'paid', 'transaction_date': '2026-01-05', 'period_month': '01', 'period_year': '2026', 'monthly_rent': 1800.00},
          {'id': 'txn_002', 'amount': 1800.00, 'payment_status': 'paid', 'transaction_date': '2026-02-03', 'period_month': '02', 'period_year': '2026', 'monthly_rent': 1800.00},
          {'id': 'txn_003', 'amount': 1800.00, 'payment_status': 'paid', 'transaction_date': '2026-03-07', 'period_month': '03', 'period_year': '2026', 'monthly_rent': 1800.00},
          {'id': 'txn_004', 'amount': 1800.00, 'payment_status': 'pending', 'period_month': '04', 'period_year': '2026', 'monthly_rent': 1800.00},
          {'id': 'txn_005', 'amount': 1800.00, 'payment_status': 'pending', 'period_month': '05', 'period_year': '2026', 'monthly_rent': 1800.00},
        ],
        // Fatima - paid Jan, Feb; partial Mar; pending Apr, May
        'tenant_002': [
          {'id': 'txn_006', 'amount': 1750.00, 'payment_status': 'paid', 'transaction_date': '2026-01-10', 'period_month': '01', 'period_year': '2026', 'monthly_rent': 1750.00},
          {'id': 'txn_007', 'amount': 1750.00, 'payment_status': 'paid', 'transaction_date': '2026-02-08', 'period_month': '02', 'period_year': '2026', 'monthly_rent': 1750.00},
          {'id': 'txn_008', 'amount': 1000.00, 'payment_status': 'partial', 'transaction_date': '2026-03-12', 'period_month': '03', 'period_year': '2026', 'monthly_rent': 1750.00},
          {'id': 'txn_009', 'amount': 1750.00, 'payment_status': 'pending', 'period_month': '04', 'period_year': '2026', 'monthly_rent': 1750.00},
          {'id': 'txn_010', 'amount': 1750.00, 'payment_status': 'pending', 'period_month': '05', 'period_year': '2026', 'monthly_rent': 1750.00},
        ],
        // Mohammed - paid Jan, Feb, Mar, Apr; pending May
        'tenant_003': [
          {'id': 'txn_011', 'amount': 2500.00, 'payment_status': 'paid', 'transaction_date': '2026-01-02', 'period_month': '01', 'period_year': '2026', 'monthly_rent': 2500.00},
          {'id': 'txn_012', 'amount': 2500.00, 'payment_status': 'paid', 'transaction_date': '2026-02-02', 'period_month': '02', 'period_year': '2026', 'monthly_rent': 2500.00},
          {'id': 'txn_013', 'amount': 2500.00, 'payment_status': 'paid', 'transaction_date': '2026-03-01', 'period_month': '03', 'period_year': '2026', 'monthly_rent': 2500.00},
          {'id': 'txn_014', 'amount': 2500.00, 'payment_status': 'paid', 'transaction_date': '2026-04-05', 'period_month': '04', 'period_year': '2026', 'monthly_rent': 2500.00},
          {'id': 'txn_015', 'amount': 2500.00, 'payment_status': 'pending', 'period_month': '05', 'period_year': '2026', 'monthly_rent': 2500.00},
        ],
        // Sara - paid Jan; partial Feb; pending Mar, Apr, May
        'tenant_004': [
          {'id': 'txn_016', 'amount': 2400.00, 'payment_status': 'paid', 'transaction_date': '2026-01-15', 'period_month': '01', 'period_year': '2026', 'monthly_rent': 2400.00},
          {'id': 'txn_017', 'amount': 1200.00, 'payment_status': 'partial', 'transaction_date': '2026-02-20', 'period_month': '02', 'period_year': '2026', 'monthly_rent': 2400.00},
          {'id': 'txn_018', 'amount': 2400.00, 'payment_status': 'pending', 'period_month': '03', 'period_year': '2026', 'monthly_rent': 2400.00},
          {'id': 'txn_019', 'amount': 2400.00, 'payment_status': 'pending', 'period_month': '04', 'period_year': '2026', 'monthly_rent': 2400.00},
          {'id': 'txn_020', 'amount': 2400.00, 'payment_status': 'pending', 'period_month': '05', 'period_year': '2026', 'monthly_rent': 2400.00},
        ],
        // Omar - paid Jan, Feb, Mar, Apr, May (fully paid - should NOT appear in pending list)
        'tenant_005': [
          {'id': 'txn_021', 'amount': 3500.00, 'payment_status': 'paid', 'transaction_date': '2026-01-01', 'period_month': '01', 'period_year': '2026', 'monthly_rent': 3500.00},
          {'id': 'txn_022', 'amount': 3500.00, 'payment_status': 'paid', 'transaction_date': '2026-02-01', 'period_month': '02', 'period_year': '2026', 'monthly_rent': 3500.00},
          {'id': 'txn_023', 'amount': 3500.00, 'payment_status': 'paid', 'transaction_date': '2026-03-01', 'period_month': '03', 'period_year': '2026', 'monthly_rent': 3500.00},
          {'id': 'txn_024', 'amount': 3500.00, 'payment_status': 'paid', 'transaction_date': '2026-04-01', 'period_month': '04', 'period_year': '2026', 'monthly_rent': 3500.00},
          {'id': 'txn_025', 'amount': 3500.00, 'payment_status': 'paid', 'transaction_date': '2026-05-01', 'period_month': '05', 'period_year': '2026', 'monthly_rent': 3500.00},
        ],
        // Noora - no transactions at all (should show full pending amount)
        'tenant_006': [],
        // Khalid - paid Jan, Feb, Mar; partial Apr; pending May
        'tenant_007': [
          {'id': 'txn_026', 'amount': 5500.00, 'payment_status': 'paid', 'transaction_date': '2026-01-05', 'period_month': '01', 'period_year': '2026', 'monthly_rent': 5500.00},
          {'id': 'txn_027', 'amount': 5500.00, 'payment_status': 'paid', 'transaction_date': '2026-02-05', 'period_month': '02', 'period_year': '2026', 'monthly_rent': 5500.00},
          {'id': 'txn_028', 'amount': 5500.00, 'payment_status': 'paid', 'transaction_date': '2026-03-05', 'period_month': '03', 'period_year': '2026', 'monthly_rent': 5500.00},
          {'id': 'txn_029', 'amount': 3000.00, 'payment_status': 'partial', 'transaction_date': '2026-04-10', 'period_month': '04', 'period_year': '2026', 'monthly_rent': 5500.00},
          {'id': 'txn_030', 'amount': 5500.00, 'payment_status': 'pending', 'period_month': '05', 'period_year': '2026', 'monthly_rent': 5500.00},
        ],
        // Layla - paid Jan, Feb, Mar; pending Apr, May
        'tenant_008': [
          {'id': 'txn_031', 'amount': 1850.00, 'payment_status': 'paid', 'transaction_date': '2026-01-10', 'period_month': '01', 'period_year': '2026', 'monthly_rent': 1850.00},
          {'id': 'txn_032', 'amount': 1850.00, 'payment_status': 'paid', 'transaction_date': '2026-02-08', 'period_month': '02', 'period_year': '2026', 'monthly_rent': 1850.00},
          {'id': 'txn_033', 'amount': 1850.00, 'payment_status': 'paid', 'transaction_date': '2026-03-12', 'period_month': '03', 'period_year': '2026', 'monthly_rent': 1850.00},
          {'id': 'txn_034', 'amount': 1850.00, 'payment_status': 'pending', 'period_month': '04', 'period_year': '2026', 'monthly_rent': 1850.00},
          {'id': 'txn_035', 'amount': 1850.00, 'payment_status': 'pending', 'period_month': '05', 'period_year': '2026', 'monthly_rent': 1850.00},
        ],
        // Rashid - paid Jan, Feb; pending Mar, Apr, May
        'tenant_009': [
          {'id': 'txn_036', 'amount': 2600.00, 'payment_status': 'paid', 'transaction_date': '2026-01-20', 'period_month': '01', 'period_year': '2026', 'monthly_rent': 2600.00},
          {'id': 'txn_037', 'amount': 2600.00, 'payment_status': 'paid', 'transaction_date': '2026-02-18', 'period_month': '02', 'period_year': '2026', 'monthly_rent': 2600.00},
          {'id': 'txn_038', 'amount': 2600.00, 'payment_status': 'pending', 'period_month': '03', 'period_year': '2026', 'monthly_rent': 2600.00},
          {'id': 'txn_039', 'amount': 2600.00, 'payment_status': 'pending', 'period_month': '04', 'period_year': '2026', 'monthly_rent': 2600.00},
          {'id': 'txn_040', 'amount': 2600.00, 'payment_status': 'pending', 'period_month': '05', 'period_year': '2026', 'monthly_rent': 2600.00},
        ],
        // Mariam - paid Jan only; pending Feb, Mar, Apr, May
        'tenant_010': [
          {'id': 'txn_041', 'amount': 2550.00, 'payment_status': 'paid', 'transaction_date': '2026-01-25', 'period_month': '01', 'period_year': '2026', 'monthly_rent': 2550.00},
          {'id': 'txn_042', 'amount': 2550.00, 'payment_status': 'pending', 'period_month': '02', 'period_year': '2026', 'monthly_rent': 2550.00},
          {'id': 'txn_043', 'amount': 2550.00, 'payment_status': 'pending', 'period_month': '03', 'period_year': '2026', 'monthly_rent': 2550.00},
          {'id': 'txn_044', 'amount': 2550.00, 'payment_status': 'pending', 'period_month': '04', 'period_year': '2026', 'monthly_rent': 2550.00},
          {'id': 'txn_045', 'amount': 2550.00, 'payment_status': 'pending', 'period_month': '05', 'period_year': '2026', 'monthly_rent': 2550.00},
        ],
        // Sultan - paid Jan, Feb, Mar, Apr; pending May
        'tenant_011': [
          {'id': 'txn_046', 'amount': 3600.00, 'payment_status': 'paid', 'transaction_date': '2026-01-05', 'period_month': '01', 'period_year': '2026', 'monthly_rent': 3600.00},
          {'id': 'txn_047', 'amount': 3600.00, 'payment_status': 'paid', 'transaction_date': '2026-02-05', 'period_month': '02', 'period_year': '2026', 'monthly_rent': 3600.00},
          {'id': 'txn_048', 'amount': 3600.00, 'payment_status': 'paid', 'transaction_date': '2026-03-05', 'period_month': '03', 'period_year': '2026', 'monthly_rent': 3600.00},
          {'id': 'txn_049', 'amount': 3600.00, 'payment_status': 'paid', 'transaction_date': '2026-04-05', 'period_month': '04', 'period_year': '2026', 'monthly_rent': 3600.00},
          {'id': 'txn_050', 'amount': 3600.00, 'payment_status': 'pending', 'period_month': '05', 'period_year': '2026', 'monthly_rent': 3600.00},
        ],
        // Hessa - paid Jan, Feb, Mar; partial Apr; pending May
        'tenant_012': [
          {'id': 'txn_051', 'amount': 3550.00, 'payment_status': 'paid', 'transaction_date': '2026-01-12', 'period_month': '01', 'period_year': '2026', 'monthly_rent': 3550.00},
          {'id': 'txn_052', 'amount': 3550.00, 'payment_status': 'paid', 'transaction_date': '2026-02-12', 'period_month': '02', 'period_year': '2026', 'monthly_rent': 3550.00},
          {'id': 'txn_053', 'amount': 3550.00, 'payment_status': 'paid', 'transaction_date': '2026-03-12', 'period_month': '03', 'period_year': '2026', 'monthly_rent': 3550.00},
          {'id': 'txn_054', 'amount': 2000.00, 'payment_status': 'partial', 'transaction_date': '2026-04-15', 'period_month': '04', 'period_year': '2026', 'monthly_rent': 3550.00},
          {'id': 'txn_055', 'amount': 3550.00, 'payment_status': 'pending', 'period_month': '05', 'period_year': '2026', 'monthly_rent': 3550.00},
        ],
        // Abdulla - paid Jan, Feb, Mar, Apr, May (fully paid)
        'tenant_013': [
          {'id': 'txn_056', 'amount': 6000.00, 'payment_status': 'paid', 'transaction_date': '2026-01-01', 'period_month': '01', 'period_year': '2026', 'monthly_rent': 6000.00},
          {'id': 'txn_057', 'amount': 6000.00, 'payment_status': 'paid', 'transaction_date': '2026-02-01', 'period_month': '02', 'period_year': '2026', 'monthly_rent': 6000.00},
          {'id': 'txn_058', 'amount': 6000.00, 'payment_status': 'paid', 'transaction_date': '2026-03-01', 'period_month': '03', 'period_year': '2026', 'monthly_rent': 6000.00},
          {'id': 'txn_059', 'amount': 6000.00, 'payment_status': 'paid', 'transaction_date': '2026-04-01', 'period_month': '04', 'period_year': '2026', 'monthly_rent': 6000.00},
          {'id': 'txn_060', 'amount': 6000.00, 'payment_status': 'paid', 'transaction_date': '2026-05-01', 'period_month': '05', 'period_year': '2026', 'monthly_rent': 6000.00},
        ],
      };
}
