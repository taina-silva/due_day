import 'dart:async';
import 'package:flutter/foundation.dart';

/// Bridges a [Stream] to a [ChangeNotifier] so GoRouter's
/// [refreshListenable] can react to Bloc state changes.
class GoRouterRefreshStream extends ChangeNotifier {
  late final StreamSubscription<dynamic> _subscription;

  GoRouterRefreshStream(Stream<dynamic> stream) {
    _subscription = stream.listen((_) => notifyListeners());
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
