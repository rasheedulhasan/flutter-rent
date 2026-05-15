import 'dart:async';
import 'dart:convert';
import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as models;
import 'package:shared_preferences/shared_preferences.dart';
import 'appwrite_client.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Data Transfer Objects
// ─────────────────────────────────────────────────────────────────────────────

/// Input payload for recording a rent collection.
class RentCollectionInput {
  final String tenantId;
  final String roomId;
  final String collectedBy;
  final double amount;
  final double monthlyRent;
  final DateTime transactionDate;
  final DateTime rentDueDate;
  final int periodMonth;
  final int periodYear;
  final String paymentMethod;
  final String? notes;
  final String? pendingReason;

  const RentCollectionInput({
    required this.tenantId,
    required this.roomId,
    required this.collectedBy,
    required this.amount,
    required this.monthlyRent,
    required this.transactionDate,
    required this.rentDueDate,
    required this.periodMonth,
    required this.periodYear,
    required this.paymentMethod,
    this.notes,
    this.pendingReason,
  });

  Map<String, dynamic> toJson() => {
        'tenant_id': tenantId,
        'room_id': roomId,
        'collected_by': collectedBy,
        'amount': amount,
        'monthly_rent': monthlyRent,
        'transaction_date': transactionDate.toUtc().toIso8601String(),
        'rent_due_date': rentDueDate.toUtc().toIso8601String(),
        'period_month': periodMonth,
        'period_year': periodYear,
        'payment_method': paymentMethod,
        'notes': notes ?? '',
        'pending_reason': pendingReason ?? '',
        'payment_status': 'paid',
      };
}

/// Result returned after a successful two-step collection.
class RentCollectionResult {
  final String transactionId;
  final String rentCycleId;
  final double amount;
  final String status;

  const RentCollectionResult({
    required this.transactionId,
    required this.rentCycleId,
    required this.amount,
    required this.status,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// Exceptions
// ─────────────────────────────────────────────────────────────────────────────

/// Base exception for rent collection failures.
class RentCollectionAppwriteException implements Exception {
  final String message;
  final String? transactionId; // non-null if step 1 succeeded
  final Object? originalError;

  const RentCollectionAppwriteException({
    required this.message,
    this.transactionId,
    this.originalError,
  });

  @override
  String toString() => 'RentCollectionAppwriteException: $message';
}

/// Thrown when step 1 (create transaction) succeeded but step 2
/// (update rent cycle status) failed. Carries the [transactionId] so
/// callers can reconcile later.
class RentCycleUpdateException extends RentCollectionAppwriteException {
  const RentCycleUpdateException({
    required super.message,
    required super.transactionId,
    super.originalError,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// Local Pending Queue (offline retry)
// ─────────────────────────────────────────────────────────────────────────────

/// A persisted queue entry for a rent collection that was created locally
/// but whose rent-cycle status update has not yet been confirmed.
class _PendingStatusUpdate {
  final String transactionId;
  final String rentCycleDocumentId;
  final String tenantId;
  final String roomId;
  final int retryCount;
  final DateTime createdAt;

  const _PendingStatusUpdate({
    required this.transactionId,
    required this.rentCycleDocumentId,
    required this.tenantId,
    required this.roomId,
    required this.retryCount,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'transactionId': transactionId,
        'rentCycleDocumentId': rentCycleDocumentId,
        'tenantId': tenantId,
        'roomId': roomId,
        'retryCount': retryCount,
        'createdAt': createdAt.toIso8601String(),
      };

  factory _PendingStatusUpdate.fromJson(Map<String, dynamic> json) =>
      _PendingStatusUpdate(
        transactionId: json['transactionId'] as String,
        rentCycleDocumentId: json['rentCycleDocumentId'] as String,
        tenantId: json['tenantId'] as String,
        roomId: json['roomId'] as String,
        retryCount: json['retryCount'] as int? ?? 0,
        createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
            DateTime.now(),
      );

  _PendingStatusUpdate copyWith({int? retryCount}) =>
      _PendingStatusUpdate(
        transactionId: transactionId,
        rentCycleDocumentId: rentCycleDocumentId,
        tenantId: tenantId,
        roomId: roomId,
        retryCount: retryCount ?? this.retryCount,
        createdAt: createdAt,
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// Main Service
// ─────────────────────────────────────────────────────────────────────────────

/// Enhanced rent collection service that uses the Appwrite Client SDK
/// to perform a **two-step atomic-like flow**:
///
/// 1. Create a document in the **transactions** collection.
/// 2. Update the corresponding **rent cycle** document's status to `"paid"`.
///
/// If step 2 fails (e.g. network drop), the transaction is persisted and
/// a local retry queue is used to attempt the status update later.
class RentCollectionAppwriteService {
  final AppwriteClient _appwrite;
  final Databases _databases;

  /// Maximum number of automatic retry attempts for step 2.
  static const int maxRetries = 3;

  /// Key used to persist the pending-update queue in SharedPreferences.
  static const String _pendingQueueKey = 'pending_rent_status_updates';

  RentCollectionAppwriteService({AppwriteClient? appwrite})
      : _appwrite = appwrite ?? AppwriteClient(),
        _databases = (appwrite ?? AppwriteClient()).databases;

  // ───────────────────────────────────────────────────────────────────────────
  // PUBLIC API
  // ───────────────────────────────────────────────────────────────────────────

  /// Records a rent collection by executing the two-step flow:
  ///
  /// **Step 1** – Creates a transaction document in the Appwrite
  /// `transactions` collection.
  ///
  /// **Step 2** – Updates the matching rent cycle document's `status` field
  /// to `"paid"` so it is automatically excluded from pending-list queries
  /// that filter by `Query.equal('status', 'pending')`.
  ///
  /// If step 2 fails, the transaction is still persisted and the update is
  /// enqueued for local retry. The caller receives a
  /// [RentCycleUpdateException] with the [transactionId] so they can
  /// surface appropriate UI feedback.
  Future<RentCollectionResult> recordPayment({
    required RentCollectionInput input,
  }) async {
    // ── Step 1: Create the transaction document ──────────────────────
    late models.Document transactionDoc;
    try {
      transactionDoc = await _databases.createDocument(
        databaseId: _appwrite.dbId,
        collectionId: _appwrite.transactionsCollection,
        documentId: 'unique()', // let Appwrite auto-generate the ID
        data: input.toJson(),
      );
    } catch (e) {
      // Step 1 itself failed – nothing was persisted, safe to throw.
      throw RentCollectionAppwriteException(
        message: 'Failed to create transaction record: $e',
        originalError: e,
      );
    }

    final transactionId = transactionDoc.$id;

    // ── Step 2: Update the rent cycle status to "paid" ───────────────
    try {
      final rentCycleDocId = input.pendingReason != null &&
              input.pendingReason!.isNotEmpty
          ? input.roomId // partial payments may use a different lookup
          : input.roomId;

      await _databases.updateDocument(
        databaseId: _appwrite.dbId,
        collectionId: _appwrite.rentCyclesCollection,
        documentId: rentCycleDocId,
        data: {
          'status': 'paid',
          'paid_at': DateTime.now().toUtc().toIso8601String(),
          'transaction_id': transactionId,
        },
      );

      // Success – return the result.
      return RentCollectionResult(
        transactionId: transactionId,
        rentCycleId: rentCycleDocId,
        amount: input.amount,
        status: 'paid',
      );
    } catch (e) {
      // Step 2 failed. Enqueue a local retry so we don't lose the update.
      await _enqueuePendingUpdate(
        _PendingStatusUpdate(
          transactionId: transactionId,
          rentCycleDocumentId: input.roomId,
          tenantId: input.tenantId,
          roomId: input.roomId,
          retryCount: 0,
          createdAt: DateTime.now(),
        ),
      );

      throw RentCycleUpdateException(
        message:
            'Transaction #$transactionId created, but failed to update rent '
            'cycle status. The update has been queued for automatic retry. '
            'Original error: $e',
        transactionId: transactionId,
        originalError: e,
      );
    }
  }

  /// Attempts to process any pending status updates that were queued
  /// after a previous step-2 failure. Call this on app startup or when
  /// network connectivity is restored.
  ///
  /// Returns the number of successfully resolved updates.
  Future<int> processPendingUpdates() async {
    final queue = await _loadPendingQueue();
    if (queue.isEmpty) return 0;

    int resolved = 0;
    final remaining = <_PendingStatusUpdate>[];

    for (final entry in queue) {
      if (entry.retryCount >= maxRetries) {
        // Give up after max retries – keep in queue for manual review.
        remaining.add(entry);
        continue;
      }

      try {
        await _databases.updateDocument(
          databaseId: _appwrite.dbId,
          collectionId: _appwrite.rentCyclesCollection,
          documentId: entry.rentCycleDocumentId,
          data: {
            'status': 'paid',
            'transaction_id': entry.transactionId,
          },
        );
        resolved++;
        // Do NOT add back to remaining – success.
      } catch (_) {
        // Increment retry count and keep in queue.
        remaining.add(entry.copyWith(retryCount: entry.retryCount + 1));
      }
    }

    // Persist the remaining (failed or exhausted) entries.
    await _savePendingQueue(remaining);
    return resolved;
  }

  /// Returns the number of pending status updates still awaiting retry.
  Future<int> pendingUpdateCount() async {
    final queue = await _loadPendingQueue();
    return queue.length;
  }

  // ───────────────────────────────────────────────────────────────────────────
  // LOCAL RETRY QUEUE (persisted via SharedPreferences)
  // ───────────────────────────────────────────────────────────────────────────

  Future<void> _enqueuePendingUpdate(_PendingStatusUpdate entry) async {
    final queue = await _loadPendingQueue();
    queue.add(entry);
    await _savePendingQueue(queue);
  }

  Future<List<_PendingStatusUpdate>> _loadPendingQueue() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_pendingQueueKey);
    if (raw == null || raw.isEmpty) return [];

    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => _PendingStatusUpdate.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> _savePendingQueue(List<_PendingStatusUpdate> queue) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(queue.map((e) => e.toJson()).toList());
    await prefs.setString(_pendingQueueKey, raw);
  }
}
