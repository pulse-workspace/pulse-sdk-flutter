import 'package:flutter/material.dart';
import 'package:pulse_flutter/pulse_flutter.dart';
import '../i18n/pulse_localizations.dart';
import '../theme/pulse_theme.dart';
import 'message_bubble.dart';

/// Pre-built scrollable list view for conversation messages.
class PulseMessageListView extends StatelessWidget {
  /// List of messages in ascending sequence order.
  final List<StoredMessage> messages;

  /// User ID of the local client user to differentiate incoming vs outgoing bubbles.
  final String currentUserId;

  /// Optional scroll controller.
  final ScrollController? scrollController;

  /// Custom theme override.
  final PulseThemeData? theme;

  /// Localization provider.
  final PulseLocalizations? localizations;

  /// Callback when a failed message retry is requested.
  final ValueChanged<StoredMessage>? onRetry;

  /// Constructs a PulseMessageListView.
  const PulseMessageListView({
    super.key,
    required this.messages,
    required this.currentUserId,
    this.scrollController,
    this.theme,
    this.localizations,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final activeTheme = theme ?? PulseThemeData.light();
    final l10n = localizations ?? const PulseLocalizations('en');

    if (messages.isEmpty) {
      return Center(
        child: Text(
          l10n.translate('no_messages'),
          style: TextStyle(
            color: activeTheme.inputPlaceholderColor,
            fontSize: 14,
          ),
        ),
      );
    }

    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.symmetric(vertical: 12),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        final isMe = message.senderID == currentUserId;

        return PulseMessageBubble(
          key: ValueKey(message.clientMsgID),
          message: message,
          isMe: isMe,
          theme: activeTheme,
          onRetry: onRetry != null ? () => onRetry!(message) : null,
        );
      },
    );
  }
}

