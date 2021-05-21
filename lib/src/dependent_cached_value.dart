import 'package:collection/collection.dart';

import 'cached_value.dart';
import 'single_child_cached_value.dart';

/// A signature for functions that provides dependency of a
/// [DependentCachedValue].
///
/// It s called in every [CachedValue.value] access. {@macro dependency_advice}
typedef ComputeCacheDependency<DependencyType> = DependencyType Function();

/// A [CachedValue] that its validity is defined by a dependency.
/// It  holds the last result of the computation callback since the last change
/// on the result of the dependency callback.
///
/// This cache will be considered invalid if the overall returned value of
/// the dependency callback changes since the last refresh.
///
/// Besides dependency change, this cache can also be manually updated on
/// marked as invalid via [refresh] and [invalidate].
///
/// The dependency callback is called in every [value] access.
/// {@template dependency_advice}
/// So it is recommended to keep the dependency callback as declarative as
/// possible.
/// {@endtemplate}
///
/// It can be created via `CachedValue.withDependency`
class DependentCachedValue<CacheContentType, DependencyType>
    extends SingleChildCachedValue<CacheContentType> {
  late DependencyType _dependencyCache = _getDependency();

  @override
  CacheContentType get value {
    if (!isValid) {
      return refresh();
    }
    return super.value;
  }

  @override
  bool get isValid =>
      super.isValid && _equalityCompare(_dependencyCache, _getDependency());

  final ComputeCacheDependency<DependencyType> _getDependency;

  DependentCachedValue._(
      CachedValue<CacheContentType> child, this._getDependency)
      : super(child);

  /// {@template dependent_refresh}
  /// Calls refresh on its child and updates the local cache of dependency.
  /// {@endtemplate}
  ///
  /// {@macro main_refresh}
  ///
  /// See also:
  /// - [CachedValue.refresh] for the general behavior of refresh.
  @override
  CacheContentType refresh() {
    final newValue = super.refresh();
    _dependencyCache = _getDependency();
    return newValue;
  }
}

const DeepCollectionEquality _collectionEquality = DeepCollectionEquality();

bool _equalityCompare<EqualityType>(EqualityType a, EqualityType b) {
  if (a is Iterable || a is Map) {
    return _collectionEquality.equals(a, b);
  }
  return a == b;
}

/// Adds [withDependency] to [CachedValue].
extension DependentExtension<CacheContentType>
    on CachedValue<CacheContentType> {
  /// Wraps the declared [CachedValue] with a [DependentCachedValue].
  ///
  /// The dependency callback [on] is called on every [value] access.
  /// {@macro dependency_advice}
  ///
  /// Usage example:
  /// ```dart
  /// int factorial(int n) {
  ///   if (n < 0) throw ('Negative numbers are not allowed.');
  ///   return n <= 1 ? 1 : n * factorial(n - 1);
  /// }
  ///
  /// int originalValue = 1;
  /// final factorialCache = CachedValue(() => factorial(originalValue))
  /// .withDependency(
  ///   () => originalValue,
  /// );
  /// print(factorialCache.value); // 1
  ///
  /// originalValue = 6;
  /// print(factorialCache.value); // 720
  /// ```
  DependentCachedValue<CacheContentType, DependencyType>
      withDependency<DependencyType>(
    ComputeCacheDependency<DependencyType> on,
  ) =>
          DependentCachedValue._(this, on);
}
