import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:birdle/models/user_model.dart';
import 'package:birdle/services/api_client.dart';

/// Authentication service that communicates with the backend API.
/// Uses a singleton pattern so all consumers share the same auth state.
/// Persists the token and user data to [SharedPreferences] so the user
/// stays logged in across app restarts / page refreshes until they log out.
class AuthService {
  static AuthService? _instance;

  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'auth_user';

  final ApiClient _apiClient;
  UserModel? _currentUser;
  bool _isAuthenticated = false;
  String? _token;

  AuthService._internal({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  /// Returns the singleton instance of [AuthService].
  /// All consumers should use this shared instance so auth state is consistent.
  factory AuthService({ApiClient? apiClient}) {
    _instance ??= AuthService._internal(apiClient: apiClient);
    return _instance!;
  }

  bool get isAuthenticated => _isAuthenticated;
  UserModel? get currentUser => _currentUser;
  String? get token => _token;

  /// Returns the ApiClient instance so other services can share the token.
  ApiClient get apiClient => _apiClient;

  // ------------------------------------------------------------------
  // Persistence helpers
  // ------------------------------------------------------------------

  /// Persists the current token and user data to SharedPreferences.
  Future<void> _persistAuth() async {
    final prefs = await SharedPreferences.getInstance();
    if (_token != null) {
      await prefs.setString(_tokenKey, _token!);
    }
    if (_currentUser != null) {
      await prefs.setString(_userKey, jsonEncode(_currentUser!.toJson()));
    }
  }

  /// Clears persisted auth data from SharedPreferences.
  Future<void> _clearPersistedAuth() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
  }

  /// Attempts to restore a previous auth session from SharedPreferences.
  /// Returns `true` if a valid session was restored, `false` otherwise.
  Future<bool> tryRestoreSession() async {
    final prefs = await SharedPreferences.getInstance();
    final savedToken = prefs.getString(_tokenKey);
    final savedUserJson = prefs.getString(_userKey);

    if (savedToken == null || savedUserJson == null) {
      return false;
    }

    try {
      final userMap = jsonDecode(savedUserJson) as Map<String, dynamic>;
      _token = savedToken;
      _currentUser = UserModel.fromJson(userMap);
      _isAuthenticated = true;
      _apiClient.setToken(_token!);
      return true;
    } catch (_) {
      // Corrupted data – clear and return false
      await _clearPersistedAuth();
      return false;
    }
  }

  // ------------------------------------------------------------------
  // Auth operations
  // ------------------------------------------------------------------

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

        // Persist auth data so the user stays logged in across restarts
        await _persistAuth();

        return true;
      }

      return false;
    } on ApiException {
      // Re-throw so the caller can display the error message
      rethrow;
    }
  }

  /// Logs out the current user and clears persisted auth data.
  Future<void> logout() async {
    _currentUser = null;
    _isAuthenticated = false;
    _token = null;
    _apiClient.clearToken();
    await _clearPersistedAuth();
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
