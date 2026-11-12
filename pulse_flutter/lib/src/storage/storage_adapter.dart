import '../models/conversation.dart';
import '../models/message.dart';
import '../models/outbox.dart';

/// Storage adapter contract for caching messages, conversations and outbox queue offline.
abstract class StorageAdapter {
  /// Persists a message record to local storage.
  Future<void> saveMessage(StoredMessage message);

  /// Retrieves a single message by client-generated ID.
  Future<StoredMessage?> getMessageByClientId(String clientMsgID);

  /// Retrieves paginated messages for a conversation ordered by seq ascending.
  Future<List<StoredMessage>> getMessages(
    String convID,
    int limit, [
    int? beforeSeq,
  ]);

  /// Updates status and server identifiers on an existing message.
  Future<void> updateMessageStatus(
    String clientMsgID,
    String status, [
    String? serverMsgID,
    int? seq,
  ]);

  /// Persists or updates a conversation entry.
  Future<void> saveConversation(StoredConversation conversation);

  /// Retrieves conversation metadata by ID.
  Future<StoredConversation?> getConversation(String convID);

  /// Returns all stored conversations sorted by updatedAt descending.
  Future<List<StoredConversation>> getAllConversations();

  /// Gets the highest sequence number recorded for a conversation.
  Future<int> getLatestSeq(String convID);

  /// Enqueues an outbound message to local outbox.
  Future<void> saveOutbox(OutboxItem item);

  /// Returns all outbound items pending transmission.
  Future<List<OutboxItem>> getPendingOutbox();

  /// Removes an item from the outbox upon successful delivery acknowledgment.
  Future<void> removeOutbox(String clientMsgID);

  /// Clears all local caches upon user logout.
  Future<void> clearAll();
}

