import 'message.dart';

/// Represents a conversation stored in local state.
class StoredConversation {
  /// Unique conversation identifier.
  final String convID;

  /// Conversation type: 1 for single/direct, 2 for group.
  final int convType;

  /// Display title for group or direct conversation.
  final String? title;

  /// Total count of unread messages for the local user.
  final int unreadCount;

  /// Last sequence number acknowledged as read by local user.
  final int lastReadSeq;

  /// Latest known sequence number in this conversation.
  final int latestSeq;

  /// Most recent message in the conversation.
  final StoredMessage? lastMessage;

  /// Unix timestamp (ms) of the latest update.
  final int updatedAt;

  /// Constructs a StoredConversation instance.
  StoredConversation({
    required this.convID,
    required this.convType,
    this.title,
    required this.unreadCount,
    required this.lastReadSeq,
    required this.latestSeq,
    this.lastMessage,
    required this.updatedAt,
  });

  /// Creates a copy of StoredConversation with optional updated fields.
  StoredConversation copyWith({
    String? convID,
    int? convType,
    String? title,
    int? unreadCount,
    int? lastReadSeq,
    int? latestSeq,
    StoredMessage? lastMessage,
    int? updatedAt,
  }) {
    return StoredConversation(
      convID: convID ?? this.convID,
      convType: convType ?? this.convType,
      title: title ?? this.title,
      unreadCount: unreadCount ?? this.unreadCount,
      lastReadSeq: lastReadSeq ?? this.lastReadSeq,
      latestSeq: latestSeq ?? this.latestSeq,
      lastMessage: lastMessage ?? this.lastMessage,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Converts StoredConversation to a Map.
  Map<String, dynamic> toMap() {
    return {
      'convID': convID,
      'convType': convType,
      'title': title,
      'unreadCount': unreadCount,
      'lastReadSeq': lastReadSeq,
      'latestSeq': latestSeq,
      'lastMessage': lastMessage?.toMap(),
      'updatedAt': updatedAt,
    };
  }

  /// Deserializes a Map into a StoredConversation instance.
  factory StoredConversation.fromMap(Map<String, dynamic> map) {
    return StoredConversation(
      convID: map['convID'] as String,
      convType: map['convType'] as int,
      title: map['title'] as String?,
      unreadCount: map['unreadCount'] as int? ?? 0,
      lastReadSeq: map['lastReadSeq'] as int? ?? 0,
      latestSeq: map['latestSeq'] as int? ?? 0,
      lastMessage: map['lastMessage'] != null
          ? StoredMessage.fromMap(Map<String, dynamic>.from(map['lastMessage'] as Map))
          : null,
      updatedAt: map['updatedAt'] as int,
    );
  }
}

