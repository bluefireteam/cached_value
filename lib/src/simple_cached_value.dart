import 'cached_value.dart';
import 'dependent_cached_value.dart';
import 'single_child_cached_value.dart';
import 'time_to_live_cached_value.dart';

/// A [CachedValue] that holds the last result of the computation callback since
/// the start of the last time the cache was refresh via [refresh].
///
/// As a comparison to [TimeToLiveCachedValue] and [DependentCachedValue],
/// it defines the most fundamental behavior of teh cache.
///
/// {@template simple_cache}
/// This cache type will only be considered invalid if [invalidate] is called
/// manually (or by a [SingleChildCachedValue] that wraps a cache of this type).
/// {@endtemplate}
///
/// It is recommended to be created via [CachedValue]'s main constructor
/// [new CachedValue].
class SimpleCachedValue<CacheContentType>
    implements CachedValue<CacheContentType> {
  late CacheContentType _value;

  bool _isValid = true;

  @override
  CacheContentType get value {
    if (!isValid) {
      return refresh();
    }
    return _value;
  }

  @override
  bool get isValid => _isValid;

  final ComputeCacheCallback<CacheContentType> _computeCache;

  /// Creates a [SimpleCachedValue]. It is recommended to use
  /// [new CachedValue] instead of this constructor.
  SimpleCachedValue(this._computeCache) {
    _value = _computeCache();
  }

  @override
  void invalidate() {
    _isValid = false;
  }

  /// {@template simple_refresh}
  /// Manually calls the compute update callback (given by the constructor) and
  /// store the result on cache.
  /// {@endtemplate}
  ///
  /// {@macro main_refresh}
  ///
  /// See also:
  /// - [CachedValue.refresh] for the general behavior of refresh.
  @override
  CacheContentType refresh() {
    _value = _computeCache();
    _isValid = true;
    return _value;
  }
}
