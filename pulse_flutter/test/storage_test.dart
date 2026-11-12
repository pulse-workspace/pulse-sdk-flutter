import 'package:test/test.dart';
import 'package:pulse_flutter/pulse_flutter.dart';

void main() {
  group('MemoryStorageAdapter', () {
    test('persists and retrieves messages and outbox items correctly', () async {
      final storage = MemoryStorageAdapter();

      final msg = StoredMessage(
        clientMsgID: 'cl_10',
        convID: 'conv_a',
        senderID: 'u_alice',
        contentType: 101,
        content: {'text': 'Offline test'},
        seq: 1,
        status: 'PENDING',
        sendTime: 5000,
        createdAt: 5000,
      );

      await storage.saveMessage(msg);
      final retrieved = await storage.getMessageByClientId('cl_10');
      expect(retrieved, isNotNull);
      expect(retrieved!.clientMsgID, equals('cl_10'));
      expect(retrieved.status, equals('PENDING'));

      await storage.updateMessageStatus('cl_10', 'SENT', 'srv_10', 1);
      final updated = await storage.getMessageByClientId('cl_10');
      expect(updated!.status, equals('SENT'));
      expect(updated.serverMsgID, equals('srv_10'));

      // Outbox testing
      await storage.saveOutbox(OutboxItem(
        clientMsgID: 'cl_10',
        convID: 'conv_a',
        contentType: 101,
        content: {'text': 'Offline test'},
        retryCount: 0,
        createdAt: 5000,
      ));

      var pending = await storage.getPendingOutbox();
      expect(pending.length, equals(1));

      await storage.removeOutbox('cl_10');
      pending = await storage.getPendingOutbox();
      expect(pending, isEmpty);
    });
  });
}

