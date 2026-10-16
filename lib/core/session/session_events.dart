import 'dart:async';

/// A tiny broadcast channel the network layer uses to say
/// "the session is dead" without knowing who is listening.
class SessionEvents {
  final _expired = StreamController<void>.broadcast();

  Stream<void> get onExpired => _expired.stream;

  void notifyExpired() => _expired.add(null);

  Future<void> dispose() => _expired.close();
}
