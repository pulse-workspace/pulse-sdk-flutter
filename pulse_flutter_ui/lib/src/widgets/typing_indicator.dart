import 'package:flutter/material.dart';
import '../i18n/pulse_localizations.dart';
import '../theme/pulse_theme.dart';

/// Renders an animated or styled typing notification bar when participants are typing.
class PulseTypingIndicator extends StatelessWidget {
  /// List of usernames or user IDs currently typing.
  final List<String> activeTypers;

  /// Custom theme override.
  final PulseThemeData? theme;

  /// Localization provider.
  final PulseLocalizations? localizations;

  /// Constructs a PulseTypingIndicator widget.
  const PulseTypingIndicator({
    super.key,
    required this.activeTypers,
    this.theme,
    this.localizations,
  });

  @override
  Widget build(BuildContext context) {
    if (activeTypers.isEmpty) {
      return const SizedBox.shrink();
    }

    final activeTheme = theme ?? PulseThemeData.light();
    final l10n = localizations ?? const PulseLocalizations('en');

    final String text;
    if (activeTypers.length == 1) {
      text = '${activeTypers.first} ${l10n.translate('typing_singular')}';
    } else {
      text = '${activeTypers.take(2).join(', ')} ${l10n.translate('typing_plural')}';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      alignment: Alignment.centerLeft,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 12,
            height: 12,
            child: CircularProgressIndicator(
              strokeWidth: 1.5,
              valueColor: AlwaysStoppedAnimation<Color>(activeTheme.primaryColor),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontStyle: FontStyle.italic,
              color: activeTheme.inputPlaceholderColor,
            ),
          ),
        ],
      ),
    );
  }
}

