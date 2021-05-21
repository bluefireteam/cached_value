import 'dart:async';

import 'cached_value.dart';
import 'single_child_cached_value.dart';

class TimeToLiveCachedValue<CacheContentType>
    extends SingleChildCachedValue<CacheContentType> {
  final Duration lifetime;
  late Timer _timer;

  TimeToLiveCachedValue._(CachedValue<CacheContentType> child, this.lifetime)
      : super(child) {
    assert(_debugVerifyDuplicity());
    _timer = Timer(lifetime, invalidate);
  }

  void _startLifeAgain() {
    if (_timer.isActive) {
      _timer.cancel();
    }
    _timer = Timer(lifetime, invalidate);
  }

  @override
  CacheContentType get value {
    if (!isValid) {
      return refresh();
    }
    return super.value;
  }

  /// {@template ttl_refresh}
  /// Calls refresh on its [child] and restarts the internal [Timer].
  /// {@endtemplate}
  ///
  /// {@macro main_refresh}
  ///
  /// See also:
  /// - [CachedValue.refresh] for the general behavior of refresh.
  @override
  CacheContentType refresh() {
    final newValue = super.refresh();
    _startLifeAgain();
    return newValue;
  }

  bool _debugVerifyDuplicity() {
    assert(() {
      bool verifyDuplicity(CachedValue child) {
        if (child is TimeToLiveCachedValue) {
          return false;
        }
        if (child is SingleChildCachedValue) {
          return verifyDuplicity(child.child);
        }
        return true;
      }

      return verifyDuplicity(child);
    }(), """
There is a declaration of a cached value time to live specified more than once""");
    return true;
  }
}

extension TimeToLiveExtension<CacheContentType>
    on CachedValue<CacheContentType> {
  CachedValue<CacheContentType> withTimeToLive({
    required Duration lifetime,
  }) =>
      TimeToLiveCachedValue._(this, lifetime);
}
