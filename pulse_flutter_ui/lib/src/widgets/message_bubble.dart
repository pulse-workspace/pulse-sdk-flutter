import 'package:flutter/material.dart';
import 'package:pulse_flutter/pulse_flutter.dart';
import '../theme/pulse_theme.dart';

/// Pre-built bubble widget displaying message text, timestamp, and delivery status.
class PulseMessageBubble extends StatelessWidget {
  /// Message data payload to render.
  final StoredMessage message;

  /// Whether the message was authored by the active local user.
  final bool isMe;

  /// Custom theme override; defaults to light theme if null.
  final PulseThemeData? theme;

  /// Callback when a failed message bubble is tapped for retry.
  final VoidCallback? onRetry;

  /// Constructs a PulseMessageBubble.
  const PulseMessageBubble({
    super.key,
    required this.message,
    required this.isMe,
    this.theme,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final activeTheme = theme ?? PulseThemeData.light();
    final bubbleColor = isMe ? activeTheme.outgoingBubbleColor : activeTheme.incomingBubbleColor;
    final textColor = isMe ? activeTheme.outgoingTextColor : activeTheme.incomingTextColor;
    final text = message.content['text']?.toString() ?? '';

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: activeTheme.bubbleBorderRadius,
        ),
        child: Column(
          crossAxisAlignment: isMe ? CrossAlignment.end : CrossAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              text,
              style: TextStyle(
                color: textColor,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _formatTime(message.sendTime),
                  style: TextStyle(
                    color: textColor.withOpacity(0.7),
                    fontSize: 10,
                  ),
                ),
                if (isMe) ...[
                  const SizedBox(width: 4),
                  _buildStatusIndicator(message.status, textColor),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Formats unix timestamp into HH:mm clock time.
  String _formatTime(int timestamp) {
    final dt = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final hours = dt.hour.toString().padLeft(2, '0');
    final minutes = dt.minute.toString().padLeft(2, '0');
    return '$hours:$minutes';
  }

  /// Renders a tiny status icon for outbound messages.
  Widget _buildStatusIndicator(String status, Color color) {
    IconData icon;
    switch (status) {
      case 'PENDING':
        icon = Icons.access_time;
        break;
      case 'SENT':
        icon = Icons.check;
        break;
      case 'DELIVERED':
      case 'READ':
        icon = Icons.done_all;
        break;
      case 'FAILED':
        icon = Icons.error_outline;
        break;
      default:
        icon = Icons.check;
    }

    return Icon(
      icon,
      size: 12,
      color: status == 'FAILED' ? Colors.redAccent : color.withOpacity(0.7),
    );
  }
}

