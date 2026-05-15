import 'package:appwrite/appwrite.dart';

/// Singleton wrapper around the Appwrite Client SDK.
///
/// Provides a single shared [Client], [Databases], and [Account] instance
/// so all services use consistent auth and session state.
class AppwriteClient {
  // ── Appwrite Cloud Configuration ──────────────────────────────────
  static const String endpoint = 'https://cloud.appwrite.io/v1';
  static const String projectId = 'YOUR_PROJECT_ID'; // TODO: Replace with your Appwrite project ID
  static const String databaseId = '69e5580f00087e980ef3';

  // ── Collection IDs ────────────────────────────────────────────────
  static const String transactionsCollectionId =
      'YOUR_TRANSACTIONS_COLLECTION_ID'; // TODO: Replace
  static const String rentCyclesCollectionId =
      'YOUR_RENT_CYCLES_COLLECTION_ID'; // TODO: Replace

  // ── Singleton ─────────────────────────────────────────────────────
  static AppwriteClient? _instance;

  late final Client client;
  late final Databases databases;
  late final Account account;

  AppwriteClient._internal() {
    client = Client()
        .setEndpoint(endpoint)
        .setProject(projectId);

    databases = Databases(client);
    account = Account(client);
  }

  /// Returns the shared [AppwriteClient] instance.
  factory AppwriteClient() {
    _instance ??= AppwriteClient._internal();
    return _instance!;
  }

  /// Convenience getter for the database ID.
  String get dbId => databaseId;

  /// Convenience getter for the transactions collection ID.
  String get transactionsCollection => transactionsCollectionId;

  /// Convenience getter for the rent cycles collection ID.
  String get rentCyclesCollection => rentCyclesCollectionId;

  /// Sets the session token (e.g. after login) so subsequent requests
  /// are authenticated.
  void setSession(String token) {
    client.setSession(token);
  }

  /// Clears the current session by creating a fresh client instance.
  /// The Appwrite Dart SDK's [Client] does not expose a public headers
  /// mutator, so we re-initialize the client to drop the session token.
  void clearSession() {
    client = Client()
        .setEndpoint(endpoint)
        .setProject(projectId);
    databases = Databases(client);
    account = Account(client);
  }
}
