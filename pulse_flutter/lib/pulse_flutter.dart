/// Pulse Flutter & Dart Client SDK.
/// Provides offline-first messaging, gapless sequence ordering,
/// fail-fast configuration, and binary wire protocol codecs.
library pulse_flutter;

export 'src/protocol/frame_types.dart';
export 'src/protocol/raw_frame.dart';
export 'src/protocol/codec.dart';
export 'src/models/connection_state.dart';
export 'src/models/message.dart';
export 'src/models/conversation.dart';
export 'src/models/outbox.dart';
export 'src/storage/storage_adapter.dart';
export 'src/storage/memory_storage.dart';
export 'src/engine/gapless_engine.dart';
export 'src/transport/websocket_transport.dart';
export 'src/client/pulse_config.dart';
export 'src/client/pulse_client.dart';

