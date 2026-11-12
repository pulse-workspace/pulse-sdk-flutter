import 'dart:typed_data';

/// Encapsulates a raw decoded binary frame from the Pulse wire protocol.
class RawFrame {
  /// The 16-bit frame identifier.
  final int frameType;

  /// The binary payload payload bytes.
  final Uint8List payloadBytes;

  /// Constructs a raw frame with validated type and payload.
  RawFrame({
    required this.frameType,
    required this.payloadBytes,
  });
}

/// Header size in bytes: 2 bytes frameType (uint16) + 4 bytes length (uint32).
const int frameHeaderSize = 6;

/// Encodes a 6-byte Pulse header along with the payload bytes into a single buffer.
///
/// Business Logic:
/// 1. Allocates byte array of size (6 + payload.length).
/// 2. Writes uint16 BigEndian for frameType at offset 0.
/// 3. Writes uint32 BigEndian for payloadLength at offset 2.
/// 4. Copies payload bytes into buffer starting at offset 6.
Uint8List encodeRawFrame(int frameType, Uint8List payloadBytes) {
  final totalLength = frameHeaderSize + payloadBytes.length;
  final buffer = Uint8List(totalLength);
  final byteData = ByteData.sublistView(buffer);

  byteData.setUint16(0, frameType, Endian.big);
  byteData.setUint32(2, payloadBytes.length, Endian.big);

  if (payloadBytes.isNotEmpty) {
    buffer.setRange(frameHeaderSize, totalLength, payloadBytes);
  }

  return buffer;
}

/// Decodes the 6-byte header and extracts payload bytes.
///
/// Business Logic:
/// 1. Validates that the buffer contains at least 6 bytes (fail-fast).
/// 2. Reads uint16 frameType and uint32 payloadLength in BigEndian format.
/// 3. Validates that available bytes match the declared payload length.
/// 4. Slices the exact payload bytes and returns a RawFrame.
RawFrame decodeRawFrame(Uint8List rawBytes) {
  if (rawBytes.length < frameHeaderSize) {
    throw ArgumentError(
      'Invalid frame: received ${rawBytes.length} bytes, smaller than minimum header size ($frameHeaderSize bytes)',
    );
  }

  final byteData = ByteData.sublistView(rawBytes);
  final frameType = byteData.getUint16(0, Endian.big);
  final declaredLength = byteData.getUint32(2, Endian.big);

  final availablePayloadLength = rawBytes.length - frameHeaderSize;
  if (availablePayloadLength < declaredLength) {
    throw StateError(
      'Truncated frame: header declared $declaredLength bytes but only $availablePayloadLength bytes received',
    );
  }

  final payloadBytes = rawBytes.sublist(
    frameHeaderSize,
    frameHeaderSize + declaredLength,
  );

  return RawFrame(
    frameType: frameType,
    payloadBytes: payloadBytes,
  );
}

