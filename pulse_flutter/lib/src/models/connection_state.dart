/// Connection lifecycle state of PulseClient.
enum PulseConnectionState {
  /// Initial or disconnected state.
  disconnected,

  /// Connecting to the gateway cluster.
  connecting,

  /// Connected, authenticated and ready for messaging.
  connected,

  /// Temporarily disconnected; automatic backoff reconnect in progress.
  reconnecting,
}

