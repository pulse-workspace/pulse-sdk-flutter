import '../models/conversation.dart';
import '../models/message.dart';
import '../models/outbox.dart';
import 'storage_adapter.dart';

/// In-memory implementation of StorageAdapter for fast testing and volatile sessions.
class MemoryStorageAdapter implements StorageAdapter {
  final Map<String, StoredMessage> _messagesByClient = {};
  final Map<String, List<String>> _convMessageIds = {};
  final Map<String, StoredConversation> _conversations = {};
  final Map<String, OutboxItem> _outbox = {};

  /// Saves a message in memory and indexes it by conversation.
  ///
  /// Business Logic:
  /// Stores message into primary map by clientMsgID and appends the ID to the
  /// conversation message index if not already present.
  @override
  Future<void> saveMessage(StoredMessage message) async {
    _messagesByClient[message.clientMsgID] = message;
    final ids = _convMessageIds.putIfAbsent(message.convID, () => []);
    if (!ids.contains(message.clientMsgID)) {
      ids.add(message.clientMsgID);
    }
  }

  /// Looks up a message by client-generated ID.
  @override
  Future<StoredMessage?> getMessageByClientId(String clientMsgID) async {
    return _messagesByClient[clientMsgID];
  }

  /// Retrieves paginated messages for a conversation, optionally filtered before a sequence.
  ///
  /// Business Logic:
  /// Collects all messages for convID, filters by beforeSeq if provided,
  /// sorts ascending by seq, and slices up to limit entries.
  @override
  Future<List<StoredMessage>> getMessages(
    String convID,
    int limit, [
    int? beforeSeq,
  ]) async {
    final ids = _convMessageIds[convID] ?? [];
    var list = ids
        .map((id) => _messagesByClient[id])
        .whereType<StoredMessage>()
        .toList();

    if (beforeSeq != null && beforeSeq > 0) {
      list = list.where((m) => m.seq < beforeSeq).toList();
    }

    list.sort((a, b) => a.seq.compareTo(b.seq));

    if (list.length > limit) {
      return list.sublist(list.length - limit);
    }
    return list;
  }

  /// Updates status, serverMsgID and sequence on an existing message.
  @override
  Future<void> updateMessageStatus(
    String clientMsgID,
    String status, [
    String? serverMsgID,
    int? seq,
  ]) async {
    final existing = _messagesByClient[clientMsgID];
    if (existing != null) {
      _messagesByClient[clientMsgID] = existing.copyWith(
        status: status,
        serverMsgID: serverMsgID ?? existing.serverMsgID,
        seq: seq ?? existing.seq,
      );
    }
  }

  /// Persists conversation metadata in memory.
  @override
  Future<void> saveConversation(StoredConversation conversation) async {
    _conversations[conversation.convID] = conversation;
  }

  /// Retrieves conversation by ID.
  @override
  Future<StoredConversation?> getConversation(String convID) async {
    return _conversations[convID];
  }

  /// Retrieves all conversations sorted by updatedAt descending.
  @override
  Future<List<StoredConversation>> getAllConversations() async {
    final list = _conversations.values.toList();
    list.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return list;
  }

  /// Computes the highest seq number observed for a conversation.
  @override
  Future<int> getLatestSeq(String convID) async {
    final ids = _convMessageIds[convID] ?? [];
    var maxSeq = 0;
    for (final id in ids) {
      final msg = _messagesByClient[id];
      if (msg != null && msg.seq > maxSeq) {
        maxSeq = msg.seq;
      }
    }
    return maxSeq;
  }

  /// Saves an outbox queue item in memory.
  @override
  Future<void> saveOutbox(OutboxItem item) async {
    _outbox[item.clientMsgID] = item;
  }

  /// Retrieves all pending outbox queue items sorted by createdAt ascending.
  @override
  Future<List<OutboxItem>> getPendingOutbox() async {
    final list = _outbox.values.toList();
    list.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return list;
  }

  /// Deletes an outbox item upon confirmation.
  @override
  Future<void> removeOutbox(String clientMsgID) async {
    _outbox.remove(clientMsgID);
  }

  /// Clears all in-memory structures.
  @override
  Future<void> clearAll() async {
    _messagesByClient.clear();
    _convMessageIds.clear();
    _conversations.clear();
    _outbox.clear();
  }
}

