import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';

class NotificationsController extends ChangeNotifier {
  final FirebaseFirestore firestore;
  final AuthController authController;

  StreamSubscription? _subscription;
  List<Map<String, dynamic>> _notifications = [];
  List<Map<String, dynamic>> _allRawNotifications = [];
  int _unreadCount = 0;
  bool _isLoading = false;

  NotificationsController({
    required this.firestore,
    required this.authController,
  }) {
    // Listen to auth changes to subscribe/unsubscribe automatically
    authController.addListener(_onAuthChanged);
    _onAuthChanged();
  }

  List<Map<String, dynamic>> get notifications =>
      List.unmodifiable(_notifications);
  int get unreadCount => _unreadCount;
  bool get isLoading => _isLoading;

  @override
  void dispose() {
    authController.removeListener(_onAuthChanged);
    _subscription?.cancel();
    super.dispose();
  }

  void _onAuthChanged() {
    final uid = authController.currentUser?.id;
    if (uid != null && uid.isNotEmpty) {
      _subscribe(uid);
    } else {
      _unsubscribe();
    }
  }

  void _subscribe(String uid) {
    if (_subscription != null) return; // Already subscribed

    _isLoading = true;
    notifyListeners();

    _subscription = firestore
        .collection('notifications')
        .where('userId', isEqualTo: uid)
        .orderBy('ts', descending: true)
        .snapshots()
        .listen(
          (snapshot) {
            _allRawNotifications = snapshot.docs.map((doc) {
              final data = doc.data();
              data['id'] = doc.id; // Include doc ID
              return data;
            }).toList();

            final allNotifications = _allRawNotifications;

            // Deduplicate by transactionId
            final Map<String, Map<String, dynamic>> uniqueByTx = {};
            for (final n in allNotifications) {
              final tx = (n['transactionId'] as String?) ?? '';
              final key = tx.isNotEmpty ? tx : n['id'];
              // Since list is ordered by ts descending, putIfAbsent keeps the newest
              uniqueByTx.putIfAbsent(key, () => n);
            }

            _notifications = uniqueByTx.values.toList();
            // Sort again just in case, though map values iteration order should be preserved in Dart
            _notifications.sort((a, b) {
              final tsA = (a['ts'] as String?) ?? '';
              final tsB = (b['ts'] as String?) ?? '';
              return tsB.compareTo(tsA);
            });

            _unreadCount = _notifications.where((n) {
              final isRead = n['isRead'] as bool? ?? false;
              return !isRead;
            }).length;

            _isLoading = false;
            notifyListeners();
          },
          onError: (e) {
            debugPrint('Error listening to notifications: $e');
            _isLoading = false;
            notifyListeners();
          },
        );
  }

  void _unsubscribe() {
    _subscription?.cancel();
    _subscription = null;
    _notifications = [];
    _allRawNotifications = [];
    _unreadCount = 0;
    notifyListeners();
  }

  Future<void> markAsRead(String id) async {
    try {
      final batch = firestore.batch();
      final col = firestore.collection('notifications');

      final notification = _allRawNotifications.firstWhere(
        (n) => n['id'] == id,
        orElse: () => {},
      );

      if (notification.isEmpty) {
        // Fallback to single update if not found in local cache
        await col.doc(id).update({'isRead': true});
        return;
      }

      final tx = notification['transactionId'] as String?;
      if (tx != null && tx.isNotEmpty) {
        final relatedDocs = _allRawNotifications.where(
          (n) => n['transactionId'] == tx,
        );
        for (final n in relatedDocs) {
          batch.update(col.doc(n['id']), {'isRead': true});
        }
      } else {
        batch.update(col.doc(id), {'isRead': true});
      }

      await batch.commit();
    } catch (e) {
      debugPrint('Error marking notification as read: $e');
    }
  }

  Future<void> markAllAsRead() async {
    final batch = firestore.batch();
    // Use _allRawNotifications to ensure we mark absolutely everything as read
    final unreadDocs = _allRawNotifications.where(
      (n) => (n['isRead'] as bool? ?? false) == false,
    );

    for (final n in unreadDocs) {
      final ref = firestore.collection('notifications').doc(n['id']);
      batch.update(ref, {'isRead': true});
    }

    if (unreadDocs.isNotEmpty) {
      try {
        await batch.commit();
      } catch (e) {
        debugPrint('Error marking all as read: $e');
      }
    }
  }

  Future<void> deleteNotifications(List<String> ids) async {
    if (ids.isEmpty) return;
    try {
      final batch = firestore.batch();
      final col = firestore.collection('notifications');
      final Set<String> idsToDelete = {};

      for (final id in ids) {
        // Find the notification object for this ID (could be in _notifications or _allRawNotifications)
        // We look in _allRawNotifications to be safe as it contains everything
        final notification = _allRawNotifications.firstWhere(
          (n) => n['id'] == id,
          orElse: () => {},
        );

        if (notification.isEmpty) {
          // If not found (shouldn't happen if UI is consistent), just delete the ID
          idsToDelete.add(id);
          continue;
        }

        final tx = notification['transactionId'] as String?;
        if (tx != null && tx.isNotEmpty) {
          // Find all notifications with this transactionId
          final relatedDocs = _allRawNotifications.where(
            (n) => n['transactionId'] == tx,
          );
          idsToDelete.addAll(relatedDocs.map((n) => n['id'] as String));
        } else {
          // No transaction ID, just delete this one
          idsToDelete.add(id);
        }
      }

      for (final id in idsToDelete) {
        batch.delete(col.doc(id));
      }
      await batch.commit();
    } catch (e) {
      debugPrint('Error deleting notifications: $e');
      rethrow;
    }
  }
}
