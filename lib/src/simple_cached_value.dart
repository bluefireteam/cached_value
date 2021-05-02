import 'cached_value.dart';

/// A [CachedValue] that holds the last result of the computation callback since
/// the start of the last time the cache was refresh via [refresh].
///
/// {@template simple_cache}
/// This cache type will only be considered invalid if [invalidate] is called
/// manually.
/// {@endtemplate}
///
/// It can be created via [CachedValue]'s main constructor and
/// [CachedValue.simple]
class SimpleCachedValue<CacheContentType>
    implements CachedValue<CacheContentType> {
  late CacheContentType _value = _computeCache();

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

  /// See [CachedValue.simple].
  SimpleCachedValue(this._computeCache);

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
