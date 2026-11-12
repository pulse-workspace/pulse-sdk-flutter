import 'package:flutter/material.dart';
import 'package:pulse_flutter/pulse_flutter.dart';
import '../i18n/pulse_localizations.dart';
import '../theme/pulse_theme.dart';

/// Pre-built conversation inbox list view with unread badges and last message previews.
class PulseConversationListView extends StatelessWidget {
  /// List of conversations sorted by latest activity.
  final List<StoredConversation> conversations;

  /// Callback when user selects a conversation.
  final ValueChanged<StoredConversation> onConversationSelected;

  /// Custom theme override.
  final PulseThemeData? theme;

  /// Localization provider.
  final PulseLocalizations? localizations;

  /// Constructs a PulseConversationListView.
  const PulseConversationListView({
    super.key,
    required this.conversations,
    required this.onConversationSelected,
    this.theme,
    this.localizations,
  });

  @override
  Widget build(BuildContext context) {
    final activeTheme = theme ?? PulseThemeData.light();
    final l10n = localizations ?? const PulseLocalizations('en');

    if (conversations.isEmpty) {
      return Center(
        child: Text(
          l10n.translate('no_conversations'),
          style: TextStyle(
            color: activeTheme.inputPlaceholderColor,
            fontSize: 14,
          ),
        ),
      );
    }

    return ListView.separated(
      itemCount: conversations.length,
      separatorBuilder: (_, __) => Divider(
        height: 1,
        color: activeTheme.inputBackgroundColor,
      ),
      itemBuilder: (context, index) {
        final conv = conversations[index];
        final title = conv.title ?? conv.convID;
        final lastSnippet = conv.lastMessage?.content['text']?.toString() ?? '';

        return ListTile(
          onTap: () => onConversationSelected(conv),
          leading: CircleAvatar(
            backgroundColor: activeTheme.primaryColor.withOpacity(0.15),
            child: Text(
              title.isNotEmpty ? title[0].toUpperCase() : '?',
              style: TextStyle(
                color: activeTheme.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          title: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: activeTheme.incomingTextColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Text(
            lastSnippet,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: activeTheme.inputPlaceholderColor,
              fontSize: 13,
            ),
          ),
          trailing: conv.unreadCount > 0
              ? Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: activeTheme.primaryColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${conv.unreadCount}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              : null,
        );
      },
    );
  }
}

