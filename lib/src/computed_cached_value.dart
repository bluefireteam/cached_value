import 'package:collection/collection.dart';

import 'cached_value.dart';

/// A [CachedValue] that holds the last result of the computation callback since
/// the last change on the result pf the dependency callback.
///
/// {@template computed_cache}
/// This cache type will be considered invalid if the overall returned value of
/// the dependency callback changes since the last refresh.
///
///
///
/// Besides dependency change, this cache can also be manually updated on
/// marked as invalid via [refresh] and [invalidate].
/// {@endtemplate}
///
/// The dependency callback (`on`) is called in every [value] access. So it is
/// recommended to keep the decency callback as declarative as possible.
/// It can be created via [CachedValue.dependent].
class ComputedCachedValue<CacheContentType, DependencyType>
    implements CachedValue<CacheContentType> {
  late CacheContentType _value = _computeCache();
  late DependencyType _dependencyCache = _getDependency();

  bool _isValid = true;

  @override
  CacheContentType get value {
    if (!isValid) {
      return refresh();
    }
    return _value;
  }

  @override
  bool get isValid =>
      _isValid && _equalityCompare(_dependencyCache, _getDependency());

  final ComputeCacheCallback<CacheContentType> _computeCache;
  final ComputeCacheDependency<DependencyType> _getDependency;

  /// See [CachedValue.dependent].
  ComputedCachedValue(this._getDependency, this._computeCache);

  @override
  void invalidate() {
    _isValid = false;
  }

  @override
  CacheContentType refresh() {
    _dependencyCache = _getDependency();
    _value = _computeCache();
    _isValid = true;
    return _value;
  }
}

const DeepCollectionEquality _collectionEquality = DeepCollectionEquality();

bool _equalityCompare<EqualityType>(EqualityType a, EqualityType b) {
  if (a is Iterable || a is Map) {
    return _collectionEquality.equals(a, b);
  }
  return a == b;
}
