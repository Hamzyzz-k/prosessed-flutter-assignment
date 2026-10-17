import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shopsphere/core/network/network_info.dart';

/// `true` while the device is online. Drives the offline banner.
class ConnectivityCubit extends Cubit<bool> {
  ConnectivityCubit(this._networkInfo) : super(true) {
    _subscription = _networkInfo.onStatusChange.listen(_set);
    unawaited(_networkInfo.isOnline.then(_set));
  }

  final NetworkInfo _networkInfo;
  late final StreamSubscription<bool> _subscription;

  void _set(bool online) {
    if (!isClosed) emit(online);
  }

  @override
  Future<void> close() async {
    await _subscription.cancel();
    await super.close();
  }
}
