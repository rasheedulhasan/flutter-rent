import 'package:birdle/models/invoice_model.dart';
import 'package:birdle/services/api_client.dart';

/// Invoice service for managing invoices.
/// Fetches data from the live backend API via [ApiClient].
class InvoiceService {
  final ApiClient _apiClient;

  InvoiceService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  /// Fetches all invoices from GET /api/invoices.
  Future<List<InvoiceModel>> getInvoices() async {
    try {
      final response = await _apiClient.get('/invoices');

      if (response['success'] == true && response['data'] != null) {
        final dataList = response['data'] as List<dynamic>;
        return dataList
            .map((e) => InvoiceModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }

      return [];
    } catch (e) {
      throw InvoiceApiException(message: 'Failed to fetch invoices: $e');
    }
  }

  /// Filters invoices by status.
  /// GET /api/invoices?status=status
  Future<List<InvoiceModel>> filterByStatus(String status) async {
    try {
      final queryParams = status == 'all' ? null : {'status': status};
      final response = await _apiClient.get(
        '/invoices',
        queryParams: queryParams,
      );

      if (response['success'] == true && response['data'] != null) {
        final dataList = response['data'] as List<dynamic>;
        return dataList
            .map((e) => InvoiceModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }

      return [];
    } catch (e) {
      throw InvoiceApiException(message: 'Failed to filter invoices: $e');
    }
  }

  /// Gets a single invoice by ID.
  /// GET /api/invoices/:id
  Future<InvoiceModel?> getInvoiceById(String id) async {
    try {
      final response = await _apiClient.get('/invoices/$id');

      if (response['success'] == true && response['data'] != null) {
        return InvoiceModel.fromJson(response['data'] as Map<String, dynamic>);
      }

      return null;
    } catch (e) {
      throw InvoiceApiException(message: 'Failed to fetch invoice: $e');
    }
  }

  /// Creates a new invoice.
  /// POST /api/invoices
  Future<InvoiceModel> createInvoice(Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.post('/invoices', body: data);

      if (response['success'] == true && response['data'] != null) {
        return InvoiceModel.fromJson(response['data'] as Map<String, dynamic>);
      }

      throw InvoiceApiException(message: 'Failed to create invoice');
    } catch (e) {
      if (e is InvoiceApiException) rethrow;
      throw InvoiceApiException(message: 'Failed to create invoice: $e');
    }
  }

  /// Updates an existing invoice.
  /// PUT /api/invoices/:id
  Future<InvoiceModel> updateInvoice(String id, Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.put('/invoices/$id', body: data);

      if (response['success'] == true && response['data'] != null) {
        return InvoiceModel.fromJson(response['data'] as Map<String, dynamic>);
      }

      throw InvoiceApiException(message: 'Failed to update invoice');
    } catch (e) {
      if (e is InvoiceApiException) rethrow;
      throw InvoiceApiException(message: 'Failed to update invoice: $e');
    }
  }

  /// Downloads invoice as PDF.
  /// GET /api/invoices/:id/pdf
  Future<String> downloadPdf(String invoiceId) async {
    try {
      final response = await _apiClient.get('/invoices/$invoiceId/pdf');
      return response['url'] as String? ?? '';
    } catch (e) {
      throw InvoiceApiException(message: 'Failed to download invoice PDF: $e');
    }
  }

  /// Shares invoice via WhatsApp.
  /// POST /api/invoices/:id/share/whatsapp
  Future<void> shareViaWhatsApp(String invoiceId) async {
    try {
      await _apiClient.post('/invoices/$invoiceId/share/whatsapp');
    } catch (e) {
      throw InvoiceApiException(message: 'Failed to share invoice: $e');
    }
  }
}

/// Exception thrown when an invoice API operation fails.
class InvoiceApiException implements Exception {
  final String message;

  const InvoiceApiException({required this.message});

  @override
  String toString() => 'InvoiceApiException: $message';
}
