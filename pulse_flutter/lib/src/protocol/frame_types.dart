/// Wire protocol frame type constants for Pulse Real-Time Platform.
/// Matches definitions in pkg/protocol/frames.go of Pulse backend server.
class FrameTypes {
  FrameTypes._();

  // Handshake & Session Management
  static const int frameHello = 1;
  static const int frameWelcome = 2;
  static const int frameSubscribe = 3;
  static const int frameUnsubscribe = 4;

  // Messaging frames
  static const int frameSendMessage = 10;
  static const int frameMessageAck = 11;
  static const int frameMessageRecv = 12;
  static const int frameMessageRead = 13;
  static const int frameMarkRead = 14;

  // Typing indicators
  static const int frameTypingStart = 20;
  static const int frameTypingStop = 21;

  // Reactions
  static const int frameReactionAdd = 30;
  static const int frameReactionDel = 31;
  static const int frameReactionUpd = 32;

  // Presence & Entity updates
  static const int framePresenceUpd = 40;
  static const int frameConvUpd = 50;
  static const int frameGroupUpd = 60;
  static const int frameGroupMember = 61;

  // Keepalive
  static const int framePing = 80;
  static const int framePong = 81;

  // Control & Resync
  static const int frameError = 100;
  static const int frameResync = 101;

  // WebRTC Calling frames
  static const int frameCallRing = 110;
  static const int frameCallAccept = 111;
  static const int frameCallReject = 112;
  static const int frameCallHangup = 113;
  static const int frameCallCandidate = 114;
}

/// Standard IM content types matching Pulse specification.
class ContentTypes {
  ContentTypes._();

  static const int text = 101;
  static const int image = 102;
  static const int audio = 103;
  static const int video = 104;
  static const int file = 105;
  static const int location = 106;
  static const int custom = 107;
  static const int callSignal = 130;
}

