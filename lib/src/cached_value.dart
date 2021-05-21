import 'dependent_cached_value.dart';
import 'simple_cached_value.dart';
import 'single_child_cached_value.dart';
import 'time_to_live_cached_value.dart';

/// A signature for functions that computes the value to be cached.
///
/// It is called:
/// - On the creation of the cache;
/// - When [CachedValue.refresh] is manually called;
/// - When [CachedValue.value] is accessed and the cache is considered invalid.
typedef ComputeCacheCallback<CacheContentType> = CacheContentType Function();

/// A value container that caches values resultant from a potentially expensive
/// operation.
///
/// It is convenient for storing values that:
/// - Are computed from other values;
/// - Can be changed given known and unknown conditions;
/// - Should not be computed on every access;
///
/// As an abstract class main constructor returns a [SimpleCachedValue] that
/// creates a cache that can only be marked as invalid or refresh manually.
///
/// To add automatic rules on invalidating and refreshing of a cache, see:
/// - [DependentCachedValue] creates a cache that is updated if a
///   dependency changes.
/// - [TimeToLiveCachedValue] creates a cache that is invalidated after
/// some given [Duration].
abstract class CachedValue<CacheContentType> {
  /// Access the current cache value.
  ///
  /// If the cache is considered invalid, calls [refresh].
  CacheContentType get value;

  /// Check the current state of the cache.
  ///
  /// On a simple [SimpleCachedValue] caches it only checks
  /// if [invalidate] has been called.
  ///
  /// On a [DependentCachedValue] checks if the result of the dependency
  /// callback has changed and its child is valid.
  ///
  /// on [TimeToLiveCachedValue] checks if its ligetime has been spent and if
  /// its child is valid.
  bool get isValid;

  /// Marks the cache as invalid.
  ///
  /// This means that the cached value will be considered outdated and next time
  /// [value] is accessed, [refresh] will be called.
  ///
  /// Calling this on a subclass of [SingleChildCachedValue]
  /// makes the child also invalid.
  void invalidate();

  /// Updates the cache to an updated state.
  ///
  /// It is called either manually or via the [value] getter when it is
  /// accessed and the cached is considered invalid.
  ///
  /// On [SimpleCachedValue],
  /// {@macro simple_refresh}
  ///
  /// On [DependentCachedValue],
  /// {@macro dependent_refresh}
  ///
  /// On [TimeToLiveCachedValue],
  /// {@macro ttl_refresh}
  ///
  /// {@template main_refresh}
  /// After refresh, the cache is considered valid.
  ///
  /// The returned value should be the new cache value.
  /// {@endtemplate}
  CacheContentType refresh();

  /// Creates a [CachedValue] that is only manually invalidated.
  ///
  /// The implementation type for the returned value is [SimpleCachedValue].
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
  /// final factorialCache = CachedValue(() => factorial(originalValue));
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
  /// - [DependentCachedValue] creates a cache that is updated if a
  ///   dependency changes.
  /// - [TimeToLiveCachedValue] creates a cache that is invalidated after
  /// some given [Duration].
  factory CachedValue(ComputeCacheCallback<CacheContentType> callback) {
    return SimpleCachedValue<CacheContentType>(callback);
  }

  /// Creates a [CachedValue] that is only manually invalidated.
  ///
  /// Use [new CachedValue] instead.
  @Deprecated('Use the constructor instead')
  static SimpleCachedValue<CacheContentType> simple<CacheContentType>(
      ComputeCacheCallback<CacheContentType> callback) {
    return SimpleCachedValue<CacheContentType>(callback);
  }

  /// Creates a [CachedValue] that its validity is defined by a dependency.
  ///
  /// Use `CachedValue.withDependency` instead.
  @Deprecated('Use "withDependency" instead')
  static DependentCachedValue<A, B> dependent<A, B>({
    required ComputeCacheDependency<B> on,
    required ComputeCacheCallback<A> compute,
  }) {
    return CachedValue<A>(compute).withDependency<B>(on);
  }
}
