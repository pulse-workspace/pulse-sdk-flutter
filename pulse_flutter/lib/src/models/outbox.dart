/// Represents a queued outbound message waiting for network dispatch.
class OutboxItem {
  /// Unique client message identifier.
  final String clientMsgID;

  /// Target conversation identifier.
  final String convID;

  /// Content type identifier (e.g. 101 for text).
  final int contentType;

  /// Content dictionary payload.
  final Map<String, dynamic> content;

  /// Count of transmission attempts executed.
  final int retryCount;

  /// Timestamp (ms) when item was originally enqueued.
  final int createdAt;

  /// Constructs an OutboxItem instance.
  OutboxItem({
    required this.clientMsgID,
    required this.convID,
    required this.contentType,
    required this.content,
    required this.retryCount,
    required this.createdAt,
  });

  /// Creates a copy with optional updated fields.
  OutboxItem copyWith({
    String? clientMsgID,
    String? convID,
    int? contentType,
    Map<String, dynamic>? content,
    int? retryCount,
    int? createdAt,
  }) {
    return OutboxItem(
      clientMsgID: clientMsgID ?? this.clientMsgID,
      convID: convID ?? this.convID,
      contentType: contentType ?? this.contentType,
      content: content ?? this.content,
      retryCount: retryCount ?? this.retryCount,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Converts OutboxItem to a serializable Map.
  Map<String, dynamic> toMap() {
    return {
      'clientMsgID': clientMsgID,
      'convID': convID,
      'contentType': contentType,
      'content': content,
      'retryCount': retryCount,
      'createdAt': createdAt,
    };
  }

  /// Deserializes a Map into an OutboxItem.
  factory OutboxItem.fromMap(Map<String, dynamic> map) {
    return OutboxItem(
      clientMsgID: map['clientMsgID'] as String,
      convID: map['convID'] as String,
      contentType: map['contentType'] as int,
      content: Map<String, dynamic>.from(map['content'] as Map),
      retryCount: map['retryCount'] as int? ?? 0,
      createdAt: map['createdAt'] as int,
    );
  }
}

