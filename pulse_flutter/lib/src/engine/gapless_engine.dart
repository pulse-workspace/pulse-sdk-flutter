import 'dart:async';
import '../models/message.dart';

/// Callback type when a sequence gap is detected in a conversation.
typedef OnGapDetected = void Function(
  String convID,
  int fromSeq,
  int toSeq,
);

/// Engine ensuring strictly ordered, gapless message delivery to application layers.
class GaplessOrderingEngine {
  final Map<String, int> _lastProcessedSeq = {};
  final Map<String, Map<int, StoredMessage>> _reorderBuffers = {};
  final OnGapDetected? onGapDetected;

  /// Constructs a GaplessOrderingEngine with optional gap detection listener.
  GaplessOrderingEngine({this.onGapDetected});

  /// Initializes the baseline sequence number for a conversation.
  ///
  /// Business Logic:
  /// Sets the initial expected sequence tracking for the conversation to prevent
  /// false gap detections on startup.
  void initSeq(String convID, int seq) {
    if (!_lastProcessedSeq.containsKey(convID) || _lastProcessedSeq[convID]! < seq) {
      _lastProcessedSeq[convID] = seq;
    }
  }

  /// Processes an inbound message, buffering out-of-order messages and returning contiguous ordered items.
  ///
  /// Business Logic:
  /// 1. If seq <= lastSeq: Discard as duplicate or old message.
  /// 2. If seq == lastSeq + 1: Process immediately, check buffer for subsequent contiguous messages, and update lastSeq.
  /// 3. If seq > lastSeq + 1: Buffer the message and trigger onGapDetected callback for range [lastSeq + 1, seq - 1].
  List<StoredMessage> processInboundMessage(StoredMessage message) {
    final convID = message.convID;
    final seq = message.seq;
    final lastSeq = _lastProcessedSeq[convID] ?? 0;

    // Discard duplicates
    if (seq <= lastSeq) {
      return [];
    }

    // Expected next message
    if (seq == lastSeq + 1) {
      final result = <StoredMessage>[message];
      _lastProcessedSeq[convID] = seq;

      // Drain buffer if next consecutive messages are waiting
      final buffer = _reorderBuffers[convID];
      if (buffer != null) {
        var currentSeq = seq + 1;
        while (buffer.containsKey(currentSeq)) {
          final nextMsg = buffer.remove(currentSeq)!;
          result.add(nextMsg);
          _lastProcessedSeq[convID] = currentSeq;
          currentSeq++;
        }
      }
      return result;
    }

    // Gap detected: store in buffer
    final buffer = _reorderBuffers.putIfAbsent(convID, () => {});
    buffer[seq] = message;

    if (onGapDetected != null) {
      onGapDetected!(convID, lastSeq + 1, seq - 1);
    }

    return [];
  }

  /// Clears in-flight reordering buffers for a conversation or entirely.
  void reset([String? convID]) {
    if (convID != null) {
      _lastProcessedSeq.remove(convID);
      _reorderBuffers.remove(convID);
    } else {
      _lastProcessedSeq.clear;
      _reorderBuffers.clear();
    }
  }
}

