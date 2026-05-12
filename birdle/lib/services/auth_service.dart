import 'package:birdle/models/user_model.dart';
import 'package:birdle/services/api_client.dart';

/// Authentication service that communicates with the backend API.
class AuthService {
  final ApiClient _apiClient;
  UserModel? _currentUser;
  bool _isAuthenticated = false;
  String? _token;

  AuthService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  bool get isAuthenticated => _isAuthenticated;
  UserModel? get currentUser => _currentUser;
  String? get token => _token;

  /// Returns the ApiClient instance so other services can share the token.
  ApiClient get apiClient => _apiClient;

  /// Attempts to log in with the given credentials via the API.
  /// Returns true if successful, false otherwise.
  /// Throws [ApiException] on network/server errors.
  Future<bool> login(String username, String password) async {
    try {
      final response = await _apiClient.post(
        '/users/validate',
        body: {
          'username': username,
          'password': password,
        },
      );

      if (response['success'] == true && response['data'] != null) {
        final data = response['data'] as Map<String, dynamic>;
        final userJson = data['user'] as Map<String, dynamic>;
        _token = data['token'] as String?;

        _currentUser = UserModel.fromJson(userJson);
        _isAuthenticated = true;

        // Set the token on the ApiClient for subsequent requests
        if (_token != null) {
          _apiClient.setToken(_token!);
        }

        return true;
      }

      return false;
    } on ApiException {
      // Re-throw so the caller can display the error message
      rethrow;
    }
  }

  /// Logs out the current user.
  Future<void> logout() async {
    // Optionally call a logout endpoint in the future
    _currentUser = null;
    _isAuthenticated = false;
    _token = null;
    _apiClient.clearToken();
  }

  /// Sends a forgot password request to the API.
  Future<bool> forgotPassword(String email) async {
    try {
      await _apiClient.post(
        '/users/forgot-password',
        body: {'email': email},
      );
      return true;
    } on ApiException {
      return false;
    }
  }
}
