import 'package:meta/meta.dart';

import '../cached_value.dart';

/// A type of [CachedValue] that contains another.
///
/// All elements of its public interface calls its [child] methods.
///
/// See also:
/// - [DependentCachedValue] and [TimeToLiveCachedValue] that are the main
/// implementations of this class.
///
/// To subclass this, consider:
/// - A cache type may define custom behaviors to when and how a cache should be
/// invalidated and refreshed.
/// - Avoid and verify for conflict with other cache types.
abstract class SingleChildCachedValue<CacheContentType>
    implements CachedValue<CacheContentType> {
  /// A [CachedValue] in which this cache wraps.
  final CachedValue<CacheContentType> child;

  /// Creates a cached value that wraps a [child]
  const SingleChildCachedValue(this.child);

  @override
  @mustCallSuper
  void invalidate() => child.invalidate();

  @override
  @mustCallSuper
  bool get isValid => child.isValid;

  @override
  @mustCallSuper
  CacheContentType refresh() => child.refresh();

  @override
  @mustCallSuper
  CacheContentType get value => child.value;
}
