import 'dart:convert';
import 'dart:typed_data';
import 'package:test/test.dart';
import 'package:pulse_flutter/pulse_flutter.dart';

void main() {
  group('PulseFrameCodec & RawFrame', () {
    test('encodes and decodes raw binary frame header correctly', () {
      final payload = Uint8List.fromList([1, 2, 3, 4, 5]);
      final encoded = encodeRawFrame(FrameTypes.frameSendMessage, payload);

      expect(encoded.length, equals(frameHeaderSize + 5));

      final decoded = decodeRawFrame(encoded);
      expect(decoded.frameType, equals(FrameTypes.frameSendMessage));
      expect(decoded.payloadBytes, equals(payload));
    });

    test('encodes and decodes JSON frame payload accurately', () {
      final payload = {
        'clientMsgID': 'msg_001',
        'convID': 'conv_test',
        'content': {'text': 'Hello Dart'},
      };

      final encoded = PulseFrameCodec.encode(FrameTypes.frameSendMessage, payload);
      final decoded = PulseFrameCodec.decode(encoded);

      expect(decoded.frameType, equals(FrameTypes.frameSendMessage));
      expect(decoded.payload['clientMsgID'], equals('msg_001'));
      expect(decoded.payload['content']['text'], equals('Hello Dart'));
    });

    test('throws ArgumentError on truncated header (fail-fast)', () {
      final shortBytes = Uint8List.fromList([0, 1, 0]);
      expect(() => decodeRawFrame(shortBytes), throwsArgumentError);
    });
  });
}

