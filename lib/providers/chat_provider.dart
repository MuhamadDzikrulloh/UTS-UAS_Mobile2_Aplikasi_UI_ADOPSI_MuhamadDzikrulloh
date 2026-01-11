import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChatMessage {
  final String sender;
  final String text;
  final DateTime timestamp;
  final String? userEmail;

  ChatMessage({
    required this.sender,
    required this.text,
    DateTime? timestamp,
    this.userEmail,
  }) : timestamp = timestamp ?? DateTime.now();
}

class ChatNotifier extends StateNotifier<Map<String, List<ChatMessage>>> {
  ChatNotifier() : super({});

  void sendMessage({
    required String sender,
    required String text,
    required String userEmail,
  }) {
    if (text.trim().isEmpty) return;
    final msg = ChatMessage(
      sender: sender,
      text: text.trim(),
      userEmail: sender == 'user' ? userEmail : null,
    );
    final existing = state[userEmail] ?? [];
    state = {...state, userEmail: [...existing, msg]};
  }

  List<ChatMessage> getMessagesForUser(String userEmail) {
    return state[userEmail] ?? [];
  }

  List<String> getAllUserEmails() {
    return state.keys.toList();
  }

  void clearUser(String userEmail) {
    final newState = Map<String, List<ChatMessage>>.from(state);
    newState.remove(userEmail);
    state = newState;
  }

  void clearAll() {
    state = {};
  }
}

final chatProvider =
    StateNotifierProvider<ChatNotifier, Map<String, List<ChatMessage>>>(
  (ref) => ChatNotifier(),
);
