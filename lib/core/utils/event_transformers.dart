import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stream_transform/stream_transform.dart';

/// Waits until events stop for [duration], then handles only the latest one
/// and cancels any handler still running for an older event.
///
/// Used for search-as-you-type: no request per keystroke, and a slow old
/// response can never overwrite a newer one.
EventTransformer<E> debounceRestartable<E>(Duration duration) {
  return (events, mapper) =>
      restartable<E>().call(events.debounce(duration), mapper);
}
