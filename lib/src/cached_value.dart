import 'computed_cached_value.dart';
import 'simple_cached_value.dart';

/// A signature for functions that computes the value to be cached.
///
/// It is called:
/// - On the creation of the cache;
/// - When [CachedValue.refresh] is manually called;
/// - When [CachedValue.value] is accessed and the cache is considered invalid.
typedef ComputeCacheCallback<CacheContentType> = CacheContentType Function();

/// A signature for functions that provides dependency of caches created via
/// [CachedValue.dependent].
///
/// It s called in every [CachedValue.value] access.
typedef ComputeCacheDependency<DependencyType> = DependencyType Function();

/// A value container that caches values resultant from a potentially expensive
/// operation.
///
/// It is convenient for storing values that:
/// - Are computed from other values;
/// - Can be changed given known and unknown conditions;
/// - Should not be computed on every access;
///
/// See also:
/// - [CachedValue.simple] that creates a cache updated manually
/// - [CachedValue.dependent] that creates a cache that is updated if a
///   dependency changes.
abstract class CachedValue<CacheContentType> {
  /// Access the most current cache value.
  ///
  /// If the cache is considered invalid, calls [refresh].
  CacheContentType get value;

  /// Check the current state of the cache.
  ///
  /// On [CachedValue.simple] caches it only checks if [invalidate] has been
  /// called.
  ///
  /// On [CachedValue.dependent] caches it also checks if teh result of the
  /// dependency callback has changed.
  bool get isValid;

  /// Marks the cache as invalid.
  ///
  /// This means that the cached value will be considered outdated and next time
  /// [value] is accessed, [refresh] will be called.
  void invalidate();

  /// Updates the cache to an updated state.
  ///
  /// It is called either manually or via the [value] getter when it is
  /// accessed and the cached is considered invalid.
  ///
  /// On [CachedValue.simple],
  /// {@macro simple_refresh}
  ///
  /// {@template main_refresh}
  /// After refresh, the cache is considered valid.
  ///
  /// The returned value should be the new cache value.
  /// {@endtemplate}
  CacheContentType refresh();

  /// A shorthand to [CachedValue.simple].
  factory CachedValue(ComputeCacheCallback<CacheContentType> callback) {
    return CachedValue.simple(callback);
  }

  /// Creates a [CachedValue] that is only manually invalidated.
  /// The main [CachedValue] constructor is a shorthand for this method.
  ///
  /// {@macro simple_cache}
  ///
  /// Usage example:
  /// ```dart
  /// int factorial(int n) {
  ///   if (n < 0) throw ('Negative numbers are not allowed.');
  ///   return n <= 1 ? 1 : n * factorial(n - 1);
  /// }
  ///
  /// int originalValue =1;
  /// final factorialCache = CachedValue.simple(() => factorial(originalValue));
  /// print(factorialCache.value); // 1
  ///
  /// originalValue = 6;
  ///
  /// print(factorialCache.value); // 1
  /// factorialCache.invalidate();
  ///
  /// print(factorialCache.value); // 720
  /// ```
  ///
  /// See also:
  /// - [CachedValue.dependent] that creates a cache that is updated if a
  ///   dependency changes.
  static SimpleCachedValue<CacheContentType> simple<CacheContentType>(
      ComputeCacheCallback<CacheContentType> callback) {
    return SimpleCachedValue<CacheContentType>(callback);
  }

  /// Creates a [CachedValue] that its validity is defined by a dependency.
  ///
  /// {@macro computed_cache}
  ///
  /// Usage example:
  /// ```dart
  /// int factorial(int n) {
  ///   if (n < 0) throw ('Negative numbers are not allowed.');
  ///   return n <= 1 ? 1 : n * factorial(n - 1);
  /// }
  ///
  /// int originalValue = 1;
  /// final factorialCache = CachedValue.dependent(
  ///   on: () => originalValue,
  ///   compute: () => factorial(originalValue),
  /// );
  /// print(factorialCache.value); // 1
  ///
  /// originalValue = 6;
  /// print(factorialCache.value); // 720
  /// ```
  ///
  /// The dependency callback [on] is called on every [value] access. So it is
  /// recommended to keep the dependency callback as declarative as possible.
  ///
  /// See also:
  /// - [CachedValue.simple] that creates a cache updated manually
  static ComputedCachedValue<A, B> dependent<A, B>({
    required ComputeCacheDependency<B> on,
    required ComputeCacheCallback<A> compute,
  }) {
    return ComputedCachedValue<A, B>(on, compute);
  }
}
