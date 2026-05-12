import 'dart:convert';
import 'package:http/http.dart' as http;

/// Base API client for making HTTP requests to the backend.
class ApiClient {
  static const String _baseUrl = 'https://monkfish-app-a3cq3.ondigitalocean.app/rent-management/api';

  static ApiClient? _instance;

  final http.Client _httpClient;
  String? _token;

  ApiClient._internal({http.Client? httpClient})
      : _httpClient = httpClient ?? http.Client();

  /// Returns the singleton instance of [ApiClient].
  /// All services should use this shared instance so auth tokens are consistent.
  factory ApiClient({http.Client? httpClient}) {
    _instance ??= ApiClient._internal(httpClient: httpClient);
    return _instance!;
  }

  /// Base URL for all API requests.
  String get baseUrl => _baseUrl;

  /// Sets the auth token for subsequent requests.
  void setToken(String token) {
    _token = token;
  }

  /// Clears the auth token.
  void clearToken() {
    _token = null;
  }

  /// Common headers with optional auth token.
  Map<String, String> _buildHeaders({Map<String, String>? extra, String? token}) {
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
      if (token == null && _token != null) 'Authorization': 'Bearer $_token',
      ...?extra,
    };
  }

  /// Parses the response body and throws [ApiException] on non-2xx status codes.
  Map<String, dynamic> _handleResponse(http.Response response) {
    final decoded = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return decoded;
    }

    final errorMessage = decoded['error'] as String? ??
        decoded['message'] as String? ??
        'An unknown error occurred';
    throw ApiException(
      statusCode: response.statusCode,
      message: errorMessage,
    );
  }

  /// Sends a GET request to the given [endpoint].
  /// Returns the decoded JSON response body.
  /// Throws [ApiException] on non-2xx responses.
  Future<Map<String, dynamic>> get(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, String>? queryParams,
    String? token,
  }) async {
    final uri = Uri.parse('$_baseUrl$endpoint').replace(queryParameters: queryParams);
    final response = await _httpClient.get(
      uri,
      headers: _buildHeaders(extra: headers, token: token),
    );

    return _handleResponse(response);
  }

  /// Sends a POST request to the given [endpoint].
  /// Returns the decoded JSON response body.
  /// Throws [ApiException] on non-2xx responses.
  Future<Map<String, dynamic>> post(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    String? token,
  }) async {
    final uri = Uri.parse('$_baseUrl$endpoint');
    final response = await _httpClient.post(
      uri,
      headers: _buildHeaders(extra: headers, token: token),
      body: body != null ? jsonEncode(body) : null,
    );

    return _handleResponse(response);
  }

  /// Sends a PUT request to the given [endpoint].
  /// Returns the decoded JSON response body.
  /// Throws [ApiException] on non-2xx responses.
  Future<Map<String, dynamic>> put(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    String? token,
  }) async {
    final uri = Uri.parse('$_baseUrl$endpoint');
    final response = await _httpClient.put(
      uri,
      headers: _buildHeaders(extra: headers, token: token),
      body: body != null ? jsonEncode(body) : null,
    );

    return _handleResponse(response);
  }

  /// Sends a PATCH request to the given [endpoint].
  /// Returns the decoded JSON response body.
  /// Throws [ApiException] on non-2xx responses.
  Future<Map<String, dynamic>> patch(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    String? token,
  }) async {
    final uri = Uri.parse('$_baseUrl$endpoint');
    final response = await _httpClient.patch(
      uri,
      headers: _buildHeaders(extra: headers, token: token),
      body: body != null ? jsonEncode(body) : null,
    );

    return _handleResponse(response);
  }

  /// Sends a DELETE request to the given [endpoint].
  /// Returns the decoded JSON response body.
  /// Throws [ApiException] on non-2xx responses.
  Future<Map<String, dynamic>> delete(
    String endpoint, {
    Map<String, String>? headers,
    String? token,
  }) async {
    final uri = Uri.parse('$_baseUrl$endpoint');
    final response = await _httpClient.delete(
      uri,
      headers: _buildHeaders(extra: headers, token: token),
    );

    return _handleResponse(response);
  }

  /// Disposes the underlying HTTP client.
  void dispose() {
    _httpClient.close();
  }
}

/// Exception thrown when an API request fails.
class ApiException implements Exception {
  final int statusCode;
  final String message;

  const ApiException({
    required this.statusCode,
    required this.message,
  });

  @override
  String toString() => 'ApiException($statusCode): $message';
}
