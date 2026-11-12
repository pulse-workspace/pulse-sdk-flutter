import 'package:flutter/material.dart';

/// Design tokens and theming configuration for Pulse Flutter UI components.
class PulseThemeData {
  /// Primary brand color.
  final Color primaryColor;

  /// Background color for outgoing message bubbles sent by local user.
  final Color outgoingBubbleColor;

  /// Text color for outgoing messages.
  final Color outgoingTextColor;

  /// Background color for incoming message bubbles.
  final Color incomingBubbleColor;

  /// Text color for incoming messages.
  final Color incomingTextColor;

  /// General screen background color.
  final Color backgroundColor;

  /// Chat input field background color.
  final Color inputBackgroundColor;

  /// Input hint and icon color.
  final Color inputPlaceholderColor;

  /// Border radius applied to message bubbles.
  final BorderRadius bubbleBorderRadius;

  /// Constructs a custom PulseThemeData.
  const PulseThemeData({
    required this.primaryColor,
    required this.outgoingBubbleColor,
    required this.outgoingTextColor,
    required this.incomingBubbleColor,
    required this.incomingTextColor,
    required this.backgroundColor,
    required this.inputBackgroundColor,
    required this.inputPlaceholderColor,
    required this.bubbleBorderRadius,
  });

  /// Light theme preset.
  factory PulseThemeData.light() {
    return const PulseThemeData(
      primaryColor: Color(0xFF2563EB),
      outgoingBubbleColor: Color(0xFF2563EB),
      outgoingTextColor: Colors.white,
      incomingBubbleColor: Color(0xFFF1F5F9),
      incomingTextColor: Color(0xFF0F172A),
      backgroundColor: Colors.white,
      inputBackgroundColor: Color(0xFFF8FAFC),
      inputPlaceholderColor: Color(0xFF94A3B8),
      bubbleBorderRadius: BorderRadius.all(Radius.circular(16)),
    );
  }

  /// Dark theme preset.
  factory PulseThemeData.dark() {
    return const PulseThemeData(
      primaryColor: Color(0xFF3B82F6),
      outgoingBubbleColor: Color(0xFF2563EB),
      outgoingTextColor: Colors.white,
      incomingBubbleColor: Color(0xFF1E293B),
      incomingTextColor: Color(0xFFF8FAFC),
      backgroundColor: Color(0xFF0F172A),
      inputBackgroundColor: Color(0xFF1E293B),
      inputPlaceholderColor: Color(0xFF64748B),
      bubbleBorderRadius: BorderRadius.all(Radius.circular(16)),
    );
  }
}

