/// Represents a message stored locally or dispatched across the network.
class StoredMessage {
  /// Unique client-generated identifier for deduplication and local tracking.
  final String clientMsgID;

  /// Server-assigned unique message identifier.
  final String? serverMsgID;

  /// Conversation identifier the message belongs to.
  final String convID;

  /// User identifier of the sender.
  final String senderID;

  /// Content type identifier (e.g. 101 for text, 102 for image).
  final int contentType;

  /// Structured message payload.
  final Map<String, dynamic> content;

  /// Gapless sequence number assigned by the cell engine.
  final int seq;

  /// Delivery status: PENDING, SENT, DELIVERED, READ, FAILED.
  final String status;

  /// Unix timestamp (ms) when sender initiated dispatch.
  final int sendTime;

  /// Unix timestamp (ms) when message record was created.
  final int createdAt;

  /// Constructs a StoredMessage instance.
  StoredMessage({
    required this.clientMsgID,
    this.serverMsgID,
    required this.convID,
    required this.senderID,
    required this.contentType,
    required this.content,
    required this.seq,
    required this.status,
    required this.sendTime,
    required this.createdAt,
  });

  /// Creates a copy of StoredMessage with optional updated properties.
  StoredMessage copyWith({
    String? clientMsgID,
    String? serverMsgID,
    String? convID,
    String? senderID,
    int? contentType,
    Map<String, dynamic>? content,
    int? seq,
    String? status,
    int? sendTime,
    int? createdAt,
  }) {
    return StoredMessage(
      clientMsgID: clientMsgID ?? this.clientMsgID,
      serverMsgID: serverMsgID ?? this.serverMsgID,
      convID: convID ?? this.convID,
      senderID: senderID ?? this.senderID,
      contentType: contentType ?? this.contentType,
      content: content ?? this.content,
      seq: seq ?? this.seq,
      status: status ?? this.status,
      sendTime: sendTime ?? this.sendTime,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Converts StoredMessage to a JSON-serializable Map.
  Map<String, dynamic> toMap() {
    return {
      'clientMsgID': clientMsgID,
      'serverMsgID': serverMsgID,
      'convID': convID,
      'senderID': senderID,
      'contentType': contentType,
      'content': content,
      'seq': seq,
      'status': status,
      'sendTime': sendTime,
      'createdAt': createdAt,
    };
  }

  /// Deserializes a Map into a StoredMessage instance.
  factory StoredMessage.fromMap(Map<String, dynamic> map) {
    return StoredMessage(
      clientMsgID: map['clientMsgID'] as String,
      serverMsgID: map['serverMsgID'] as String?,
      convID: map['convID'] as String,
      senderID: map['senderID'] as String,
      contentType: map['contentType'] as int,
      content: Map<String, dynamic>.from(map['content'] as Map),
      seq: map['seq'] as int? ?? 0,
      status: map['status'] as String,
      sendTime: map['sendTime'] as int,
      createdAt: map['createdAt'] as int,
    );
  }
}

