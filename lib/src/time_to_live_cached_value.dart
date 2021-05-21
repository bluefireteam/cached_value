import 'dart:async';

import 'cached_value.dart';
import 'single_child_cached_value.dart';

/// A [CachedValue] that is invalidated some time after a refresh.
///
/// It keeps an internal [Timer] that is restarted very time the cache is
/// refreshed.
///
/// After that time, [isValid] will be false and any access to [value] will
/// trigger [refresh] and the timer will be restarted.
///
/// Besides dependency change, this cache can also be manually updated on
/// marked as invalid via [refresh] and [invalidate].
///
/// The duration of the timer is equal to [lifeTime].
///
/// Do not wrap a TTL cache on another, otherwise an assertion will be thrown.
///
/// It can be created via `CachedValue.withTimeToLive`
class TimeToLiveCachedValue<CacheContentType>
    extends SingleChildCachedValue<CacheContentType> {
  /// The amount of time that will take to the cache to be considered invalid
  /// after a refresh.
  final Duration lifeTime;
  late Timer _timer;

  TimeToLiveCachedValue._(CachedValue<CacheContentType> child, this.lifeTime)
      : super(child) {
    assert(_debugVerifyDuplicity());
    _timer = Timer(lifeTime, () {});
  }

  @override
  bool get isValid => super.isValid && _timer.isActive;

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

  void _startLifeAgain() {
    if (_timer.isActive) {
      _timer.cancel();
    }
    _timer = Timer(lifeTime, () {});
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

/// Adds [withTimeToLive] to [CachedValue].
extension TimeToLiveExtension<CacheContentType>
    on CachedValue<CacheContentType> {
  /// Wraps the declared [CachedValue] with a [TimeToLiveCachedValue].
  ///
  /// Usage example:
  /// ```dart
  /// int factorial(int n) {
  ///   if (n < 0) throw ('Negative numbers are not allowed.');
  ///   return n <= 1 ? 1 : n * factorial(n - 1);
  /// }
  ///
  /// int originalValue = 1;
  /// final factorialCache = CachedValue(
  ///   () => factorial(originalValue),
  /// ).withTimeToLive(
  ///   lifetime: Duration(seconds: 3),
  /// );
  ///
  /// originalValue = 6;
  /// print(factorialCache.value); // 1
  ///
  /// await Future.delayed(Duration(seconds: 3));
  ///
  /// print(factorialCache.value); // 720
  /// ```
  CachedValue<CacheContentType> withTimeToLive({
    required Duration lifetime,
  }) =>
      TimeToLiveCachedValue._(this, lifetime);
}
