import 'dart:convert';
import 'dart:typed_data';
import 'raw_frame.dart';

/// Decoded frame structure containing deserialized payload.
class DecodedFrame<T> {
  /// The 16-bit frame identifier.
  final int frameType;

  /// The deserialized payload body or null if frame carries no body.
  final T? payload;

  /// Constructs a DecodedFrame.
  DecodedFrame({
    required this.frameType,
    this.payload,
  });
}

/// Binary serializer and deserializer for Pulse wire protocol frames.
class PulseFrameCodec {
  PulseFrameCodec._();

  /// Encodes a frame type and optional Map payload into binary bytes.
  ///
  /// Business Logic:
  /// Serializes the payload into UTF-8 JSON bytes (or empty if null) and wraps it
  /// with the 6-byte BigEndian Pulse frame header.
  static Uint8List encode(int frameType, [Map<String, dynamic>? payload]) {
    Uint8List payloadBytes;
    if (payload == null || payload.isEmpty) {
      payloadBytes = Uint8List(0);
    } else {
      final jsonStr = jsonEncode(payload);
      payloadBytes = Uint8List.fromList(utf8.encode(jsonStr));
    }
    return encodeRawFrame(frameType, payloadBytes);
  }

  /// Decodes raw binary bytes from WebSocket into a DecodedFrame.
  ///
  /// Business Logic:
  /// Reads the 6-byte header, verifies payload length, and deserializes the
  /// payload bytes from UTF-8 JSON into a dynamic Map or List.
  static DecodedFrame<dynamic> decode(Uint8List rawBytes) {
    final rawFrame = decodeRawFrame(rawBytes);
    if (rawFrame.payloadBytes.isEmpty) {
      return DecodedFrame(frameType: rawFrame.frameType, payload: null);
    }

    final jsonStr = utf8.decode(rawFrame.payloadBytes);
    final dynamic decoded = jsonDecode(jsonStr);
    return DecodedFrame(
      frameType: rawFrame.frameType,
      payload: decoded,
    );
  }
}

