import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../models/connection_state.dart';
import '../protocol/codec.dart';
import '../protocol/frame_types.dart';
import '../protocol/raw_frame.dart';

/// Callback type for decoded incoming frames.
typedef FrameHandler = void Function(DecodedFrame<dynamic> frame);

/// Manages the low-level WebSocket connection, heartbeats, and reconnect loop.
class WebSocketTransport {
  final String wsUrl;
  final String token;
  final FrameHandler onFrameReceived;
  final void Function(PulseConnectionState state) onStateChanged;

  WebSocketChannel? _channel;
  StreamSubscription? _subscription;
  Timer? _pingTimer;
  Timer? _reconnectTimer;
  bool _disposed = false;
  int _reconnectAttempts = 0;

  /// Constructs a WebSocketTransport instance.
  WebSocketTransport({
    required this.wsUrl,
    required this.token,
    required this.onFrameReceived,
    required this.onStateChanged,
  });

  /// Establishes connection to the WebSocket endpoint.
  ///
  /// Business Logic:
  /// Appends auth token to URI, initiates WebSocketChannel, configures binary stream
  /// listener, sends initial FrameHello, and starts ping heartbeat timer.
  Future<void> connect() async {
    if (_disposed) return;
    onStateChanged(PulseConnectionState.connecting);

    try {
      final uri = Uri.parse('$wsUrl?token=${Uri.encodeComponent(token)}');
      _channel = WebSocketChannel.connect(uri);

      _subscription = _channel!.stream.listen(
        _handleData,
        onError: _handleError,
        onDone: _handleDone,
        cancelOnError: true,
      );

      _reconnectAttempts = 0;
      onStateChanged(PulseConnectionState.connected);

      // Send initial handshake hello
      sendFrame(FrameTypes.frameHello, {'token': token});

      // Start ping heartbeat every 25 seconds
      _startPingHeartbeat();
    } catch (e) {
      _scheduleReconnect();
    }
  }

  /// Sends a binary frame across the active WebSocket channel.
  ///
  /// Business Logic:
  /// Serializes frame via PulseFrameCodec into binary Uint8List and pushes onto channel sink.
  void sendFrame(int frameType, [Map<String, dynamic>? payload]) {
    if (_channel == null) return;
    try {
      final bytes = PulseFrameCodec.encode(frameType, payload);
      _channel!.sink.add(bytes);
    } catch (_) {
      // Failed to send, trigger reconnect
      _scheduleReconnect();
    }
  }

  /// Starts recurring ping timer to keep gateway NAT bindings alive.
  void _startPingHeartbeat() {
    _pingTimer?.cancel();
    _pingTimer = Timer.periodic(const Duration(seconds: 25), (_) {
      sendFrame(FrameTypes.framePing);
    });
  }

  /// Parses incoming binary data chunks from the socket.
  void _handleData(dynamic data) {
    if (data is Uint8List) {
      try {
        final decoded = PulseFrameCodec.decode(data);
        onFrameReceived(decoded);
      } catch (_) {
        // Discard malformed frames
      }
    } else if (data is List<int>) {
      try {
        final decoded = PulseFrameCodec.decode(Uint8List.fromList(data));
        onFrameReceived(decoded);
      } catch (_) {
        // Discard malformed frames
      }
    }
  }

  /// Handles transport error by scheduling reconnect.
  void _handleError(dynamic error) {
    _scheduleReconnect();
  }

  /// Handles socket closure by scheduling reconnect.
  void _handleDone() {
    _scheduleReconnect();
  }

  /// Schedules exponential backoff reconnect with random jitter.
  ///
  /// Business Logic:
  /// Computes backoff interval = min(1000 * 2^attempts, 30000) ms + random jitter,
  /// transitions state to reconnecting, and attempts reconnect when timer expires.
  void _scheduleReconnect() {
    if (_disposed) return;
    _pingTimer?.cancel();
    _subscription?.cancel();
    _channel = null;

    onStateChanged(PulseConnectionState.reconnecting);

    _reconnectTimer?.cancel();
    final delayMs = min(1000 * pow(2, _reconnectAttempts).toInt(), 30000);
    final jitter = Random().nextInt(500);
    _reconnectAttempts++;

    _reconnectTimer = Timer(Duration(milliseconds: delayMs + jitter), () {
      connect();
    });
  }

  /// Closes active socket and cleans up all timers.
  void dispose() {
    _disposed = true;
    _pingTimer?.cancel();
    _reconnectTimer?.cancel();
    _subscription?.cancel();
    _channel?.sink.close();
    _channel = null;
    onStateChanged(PulseConnectionState.disconnected);
  }
}

