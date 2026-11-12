/// Localization strings container for Pulse UI components supporting English and Vietnamese.
class PulseLocalizations {
  /// Language code ('en' or 'vi').
  final String locale;

  const PulseLocalizations(this.locale);

  static const Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'input_placeholder': 'Type a message...',
      'send_button': 'Send',
      'typing_singular': 'is typing...',
      'typing_plural': 'are typing...',
      'conversations_title': 'Conversations',
      'no_conversations': 'No conversations yet',
      'no_messages': 'No messages in this chat',
      'status_pending': 'Sending...',
      'status_sent': 'Sent',
      'status_delivered': 'Delivered',
      'status_read': 'Read',
      'status_failed': 'Failed to send',
      'retry': 'Retry',
    },
    'vi': {
      'input_placeholder': 'Nhập tin nhắn...',
      'send_button': 'Gửi',
      'typing_singular': 'đang soạn tin...',
      'typing_plural': 'đang soạn tin...',
      'conversations_title': 'Hội thoại',
      'no_conversations': 'Chưa có cuộc hội thoại nào',
      'no_messages': 'Chưa có tin nhắn trong cuộc trò chuyện này',
      'status_pending': 'Đang gửi...',
      'status_sent': 'Đã gửi',
      'status_delivered': 'Đã nhận',
      'status_read': 'Đã xem',
      'status_failed': 'Gửi thất bại',
      'retry': 'Thử lại',
    },
  };

  /// Translates a key according to current locale.
  ///
  /// Business Logic:
  /// Looks up translation in current locale dictionary; if key is not found,
  /// returns the fallback English translation.
  String translate(String key) {
    final dict = _localizedValues[locale] ?? _localizedValues['en']!;
    return dict[key] ?? _localizedValues['en']![key] ?? key;
  }
}

