/// Client configuration parameters for initializing PulseClient.
class PulseClientConfig {
  /// Base WebSocket URL to connect to the Pulse Gateway (e.g. wss://chat.pulse.internal/ws).
  final String wsUrl;

  /// Base HTTP API URL for media uploads and push token registration (e.g. https://chat.pulse.internal).
  final String apiUrl;

  /// Authentication token for the current user session.
  final String token;

  /// User identifier of the authenticated user.
  final String userId;

  /// Constructs a validated PulseClientConfig instance.
  ///
  /// Business Logic:
  /// Enforces fail-fast configuration validation. Throws ArgumentError if any
  /// required parameter is empty or null, strictly avoiding silent fallback defaults.
  PulseClientConfig({
    required this.wsUrl,
    required this.apiUrl,
    required this.token,
    required this.userId,
  }) {
    if (wsUrl.trim().isEmpty) {
      throw ArgumentError('wsUrl is required and cannot be empty');
    }
    if (apiUrl.trim().isEmpty) {
      throw ArgumentError('apiUrl is required and cannot be empty');
    }
    if (token.trim().isEmpty) {
      throw ArgumentError('token is required and cannot be empty');
    }
    if (userId.trim().isEmpty) {
      throw ArgumentError('userId is required and cannot be empty');
    }
  }
}

