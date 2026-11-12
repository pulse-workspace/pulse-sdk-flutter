import 'package:test/test.dart';
import 'package:pulse_flutter/pulse_flutter.dart';

void main() {
  group('GaplessOrderingEngine', () {
    test('delivers in-order messages sequentially', () {
      final engine = GaplessOrderingEngine();
      engine.initSeq('c1', 0);

      final msg1 = StoredMessage(
        clientMsgID: 'm1',
        convID: 'c1',
        senderID: 'u1',
        contentType: 101,
        content: {'text': 'First'},
        seq: 1,
        status: 'SENT',
        sendTime: 1000,
        createdAt: 1000,
      );

      final msg2 = StoredMessage(
        clientMsgID: 'm2',
        convID: 'c1',
        senderID: 'u1',
        contentType: 101,
        content: {'text': 'Second'},
        seq: 2,
        status: 'SENT',
        sendTime: 2000,
        createdAt: 2000,
      );

      final out1 = engine.processInboundMessage(msg1);
      expect(out1.length, equals(1));
      expect(out1[0].seq, equals(1));

      final out2 = engine.processInboundMessage(msg2);
      expect(out2.length, equals(1));
      expect(out2[0].seq, equals(2));
    });

    test('buffers out-of-order messages and flushes on gap resolution', () {
      var gapDetected = false;
      int gapFrom = 0;
      int gapTo = 0;

      final engine = GaplessOrderingEngine(
        onGapDetected: (convID, from, to) {
          gapDetected = true;
          gapFrom = from;
          gapTo = to;
        },
      );
      engine.initSeq('c1', 0);

      // Message seq 2 arrives before seq 1
      final msg2 = StoredMessage(
        clientMsgID: 'm2',
        convID: 'c1',
        senderID: 'u1',
        contentType: 101,
        content: {'text': 'Second'},
        seq: 2,
        status: 'SENT',
        sendTime: 2000,
        createdAt: 2000,
      );

      final outBuffered = engine.processInboundMessage(msg2);
      expect(outBuffered, isEmpty);
      expect(gapDetected, isTrue);
      expect(gapFrom, equals(1));
      expect(gapTo, equals(1));

      // Now missing message seq 1 arrives
      final msg1 = StoredMessage(
        clientMsgID: 'm1',
        convID: 'c1',
        senderID: 'u1',
        contentType: 101,
        content: {'text': 'First'},
        seq: 1,
        status: 'SENT',
        sendTime: 1000,
        createdAt: 1000,
      );

      final outDrained = engine.processInboundMessage(msg1);
      expect(outDrained.length, equals(2));
      expect(outDrained[0].seq, equals(1));
      expect(outDrained[1].seq, equals(2));
    });
  });
}

