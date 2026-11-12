import 'package:flutter/material.dart';
import '../i18n/pulse_localizations.dart';
import '../theme/pulse_theme.dart';

/// Pre-built message input widget with send button and auto-expanding text box.
class PulseChatInput extends StatefulWidget {
  /// Callback when user submits a message text.
  final ValueChanged<String> onSend;

  /// Optional callback for typing events (true when actively typing, false on stop).
  final ValueChanged<bool>? onTypingChanged;

  /// Localization provider.
  final PulseLocalizations? localizations;

  /// Custom theme override.
  final PulseThemeData? theme;

  /// Constructs a PulseChatInput widget.
  const PulseChatInput({
    super.key,
    required this.onSend,
    this.onTypingChanged,
    this.localizations,
    this.theme,
  });

  @override
  State<PulseChatInput> createState() => _PulseChatInputState();
}

class _PulseChatInputState extends State<PulseChatInput> {
  final TextEditingController _controller = TextEditingController();
  bool _isComposing = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleSubmitted() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    widget.onSend(text);
    _controller.clear();
    setState(() {
      _isComposing = false;
    });
    widget.onTypingChanged?.call(false);
  }

  @override
  Widget build(BuildContext context) {
    final activeTheme = widget.theme ?? PulseThemeData.light();
    final l10n = widget.localizations ?? const PulseLocalizations('en');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      color: activeTheme.backgroundColor,
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: activeTheme.inputBackgroundColor,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TextField(
                  controller: _controller,
                  maxLines: 4,
                  minLines: 1,
                  style: TextStyle(color: activeTheme.incomingTextColor),
                  decoration: InputDecoration(
                    hintText: l10n.translate('input_placeholder'),
                    hintStyle: TextStyle(color: activeTheme.inputPlaceholderColor),
                    border: InputBorder.none,
                  ),
                  onChanged: (text) {
                    final hasText = text.trim().isNotEmpty;
                    if (hasText != _isComposing) {
                      setState(() {
                        _isComposing = hasText;
                      });
                      widget.onTypingChanged?.call(hasText);
                    }
                  },
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: Icon(Icons.send, color: _isComposing ? activeTheme.primaryColor : activeTheme.inputPlaceholderColor),
              onPressed: _isComposing ? _handleSubmitted : null,
              tooltip: l10n.translate('send_button'),
            ),
          ],
        ),
      ),
    );
  }
}

