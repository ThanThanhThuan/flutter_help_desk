// lib/providers/app_providers.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/ticket.dart';

part 'app_providers.g.dart';

// --- User Context State ---

@riverpod
class CurrentUserRole extends _$CurrentUserRole {
  @override
  String build() => 'Customer';

  void toggle() {
    state = state == 'Customer' ? 'Staff' : 'Customer';
  }
}

// --- Firestore Repositories ---

@riverpod
FirebaseFirestore firestore(FirestoreRef ref) {
  return FirebaseFirestore.instance;
}

// --- Ticket Logic ---

@riverpod
Stream<List<Ticket>> ticketList(TicketListRef ref) {
  final firestore = ref.watch(firestoreProvider);
  return firestore
      .collection('tickets')
      .orderBy('date', descending: true)
      .snapshots()
      .map(
        (snapshot) =>
            snapshot.docs.map((doc) => Ticket.fromDocument(doc)).toList(),
      );
}

@riverpod
class TicketController extends _$TicketController {
  // FIX: Use 'void' instead of 'FutureOr<void>' to prevent generator conflicts
  @override
  void build() {
    // Initial state is null (void)
  }

  Future<void> createTicket(Ticket ticket) async {
    final firestore = ref.read(firestoreProvider);
    state = const AsyncLoading();
    try {
      await firestore.collection('tickets').add(ticket.toMap());
      // Success: Reset state to data(null)
      state = const AsyncData(null);
    } catch (e, stack) {
      state = AsyncError(e, stack);
    }
  }

  Future<void> updateStatus(String ticketId, String newStatus) async {
    final firestore = ref.read(firestoreProvider);
    // Optional: state = const AsyncLoading();
    try {
      await firestore.collection('tickets').doc(ticketId).update({
        'status': newStatus,
      });
      state = const AsyncData(null);
    } catch (e, stack) {
      state = AsyncError(e, stack);
    }
  }
}

// --- Chat Logic ---

@riverpod
Stream<List<ChatMessage>> chatMessages(ChatMessagesRef ref, String ticketId) {
  final firestore = ref.watch(firestoreProvider);
  return firestore
      .collection('tickets')
      .doc(ticketId)
      .collection('messages')
      .orderBy('timestamp', descending: false)
      .snapshots()
      .map(
        (snapshot) =>
            snapshot.docs.map((doc) => ChatMessage.fromDocument(doc)).toList(),
      );
}

@riverpod
class ChatController extends _$ChatController {
  // FIX: Use 'void' instead of 'FutureOr<void>'
  @override
  void build() {
    // Initial state is null (void)
  }

  Future<void> sendMessage(String ticketId, ChatMessage message) async {
    final firestore = ref.read(firestoreProvider);
    state = const AsyncLoading();
    try {
      await firestore
          .collection('tickets')
          .doc(ticketId)
          .collection('messages')
          .add(message.toMap());
      state = const AsyncData(null);
    } catch (e, stack) {
      state = AsyncError(e, stack);
    }
  }
}
