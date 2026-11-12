import 'dart:async';
import '../engine/gapless_engine.dart';
import '../models/connection_state.dart';
import '../models/conversation.dart';
import '../models/message.dart';
import '../models/outbox.dart';
import '../protocol/codec.dart';
import '../protocol/frame_types.dart';
import '../storage/memory_storage.dart';
import '../storage/storage_adapter.dart';
import '../transport/websocket_transport.dart';
import 'pulse_config.dart';

/// Primary client for connecting to the Pulse Real-Time Platform from Flutter and Dart.
class PulseClient {
  final PulseClientConfig config;
  final StorageAdapter storage;
  late final GaplessOrderingEngine _orderingEngine;
  WebSocketTransport? _transport;

  final _messageController = StreamController<StoredMessage>.broadcast();
  final _stateController = StreamController<PulseConnectionState>.broadcast();
  final _typingController = StreamController<Map<String, dynamic>>.broadcast();
  final _presenceController = StreamController<Map<String, dynamic>>.broadcast();

  PulseConnectionState _currentState = PulseConnectionState.disconnected;

  /// Stream of ordered inbound and acknowledged messages.
  Stream<StoredMessage> get onMessage => _messageController.stream;

  /// Stream of connection lifecycle transitions.
  Stream<PulseConnectionState> get onConnectionState => _stateController.stream;

  /// Stream of typing activity notifications.
  Stream<Map<String, dynamic>> get onTyping => _typingController.stream;

  /// Stream of presence updates.
  Stream<Map<String, dynamic>> get onPresence => _presenceController.stream;

  /// Current connection state.
  PulseConnectionState get state => _currentState;

  /// Constructs a PulseClient instance.
  PulseClient({
    required this.config,
    StorageAdapter? storageAdapter,
  }) : storage = storageAdapter ?? MemoryStorageAdapter() {
    _orderingEngine = GaplessOrderingEngine(
      onGapDetected: (convID, fromSeq, toSeq) {
        // Gap detected: request resync from server
        _transport?.sendFrame(FrameTypes.frameResync, {
          'convID': convID,
          'fromSeq': fromSeq,
          'toSeq': toSeq,
        });
      },
    );
  }

  /// Establishes the WebSocket connection to the gateway.
  Future<void> connect() async {
    _transport?.dispose();
    _transport = WebSocketTransport(
      wsUrl: config.wsUrl,
      token: config.token,
      onFrameReceived: _handleFrame,
      onStateChanged: _handleStateChanged,
    );
    await _transport!.connect();
  }

  /// Dispatches a new message, enqueuing locally first for offline-first resilience.
  ///
  /// Business Logic:
  /// 1. Generates unique clientMsgID and StoredMessage record with PENDING status.
  /// 2. Saves to local storage and enqueues to outbox table.
  /// 3. Emits to onMessage stream immediately for zero-latency local optimistic UI.
  /// 4. If connected, sends FrameSendMessage over WebSocket immediately.
  Future<StoredMessage> sendMessage({
    required String convID,
    required int contentType,
    required Map<String, dynamic> content,
  }) async {
    final clientMsgID = 'msg_${DateTime.now().millisecondsSinceEpoch}_${config.userId}';
    final now = DateTime.now().millisecondsSinceEpoch;

    final stored = StoredMessage(
      clientMsgID: clientMsgID,
      convID: convID,
      senderID: config.userId,
      contentType: contentType,
      content: content,
      seq: 0,
      status: 'PENDING',
      sendTime: now,
      createdAt: now,
    );

    await storage.saveMessage(stored);
    await storage.saveOutbox(OutboxItem(
      clientMsgID: clientMsgID,
      convID: convID,
      contentType: contentType,
      content: content,
      retryCount: 0,
      createdAt: now,
    ));

    _messageController.add(stored);

    if (_currentState == PulseConnectionState.connected) {
      _transport?.sendFrame(FrameTypes.frameSendMessage, stored.toMap());
    }

    return stored;
  }

  /// Sends a mark-read acknowledgment frame for a conversation.
  Future<void> markRead(String convID, int seq) async {
    if (_currentState == PulseConnectionState.connected) {
      _transport?.sendFrame(FrameTypes.frameMarkRead, {
        'convID': convID,
        'seq': seq,
      });
    }
  }

  /// Emits a typing start or stop indicator frame.
  Future<void> sendTyping(String convID, bool isTyping) async {
    if (_currentState == PulseConnectionState.connected) {
      final frameType = isTyping ? FrameTypes.frameTypingStart : FrameTypes.frameTypingStop;
      _transport?.sendFrame(frameType, {
        'convID': convID,
        'userID': config.userId,
      });
    }
  }

  /// Drains any pending outbox messages upon network reconnection.
  Future<void> drainOutbox() async {
    final pending = await storage.getPendingOutbox();
    for (final item in pending) {
      _transport?.sendFrame(FrameTypes.frameSendMessage, item.toMap());
    }
  }

  /// Handles incoming decoded frames from WebSocket transport.
  void _handleFrame(DecodedFrame<dynamic> frame) {
    switch (frame.frameType) {
      case FrameTypes.frameMessageAck:
        _handleMessageAck(frame.payload);
        break;
      case FrameTypes.frameMessageRecv:
        _handleMessageRecv(frame.payload);
        break;
      case FrameTypes.frameTypingStart:
      case FrameTypes.frameTypingStop:
        if (frame.payload is Map<String, dynamic>) {
          _typingController.add(frame.payload as Map<String, dynamic>);
        }
        break;
      case FrameTypes.framePresenceUpd:
        if (frame.payload is Map<String, dynamic>) {
          _presenceController.add(frame.payload as Map<String, dynamic>);
        }
        break;
    }
  }

  /// Updates message status to SENT and removes it from outbox.
  void _handleMessageAck(dynamic payload) {
    if (payload is Map<String, dynamic>) {
      final clientMsgID = payload['clientMsgID'] as String?;
      final serverMsgID = payload['serverMsgID'] as String?;
      final seq = payload['seq'] as int?;

      if (clientMsgID != null) {
        storage.updateMessageStatus(clientMsgID, 'SENT', serverMsgID, seq);
        storage.removeOutbox(clientMsgID);
      }
    }
  }

  /// Orders incoming messages through gapless engine and emits to stream.
  void _handleMessageRecv(dynamic payload) {
    if (payload is Map<String, dynamic>) {
      final msg = StoredMessage.fromMap(payload);
      final ordered = _orderingEngine.processInboundMessage(msg);
      for (final m in ordered) {
        storage.saveMessage(m);
        _messageController.add(m);
      }
    }
  }

  /// Updates connection state and triggers outbox drain on connect.
  void _handleStateChanged(PulseConnectionState newState) {
    _currentState = newState;
    _stateController.add(newState);
    if (newState == PulseConnectionState.connected) {
      drainOutbox();
    }
  }

  /// Closes connection and cleans up all stream controllers.
  void dispose() {
    _transport?.dispose();
    _messageController.close();
    _stateController.close();
    _typingController.close();
    _presenceController.close();
  }
}

