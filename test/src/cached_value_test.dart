import 'package:cached_value/cached_value.dart';
import 'package:test/test.dart';

void main() {
  test('Constructor creates a simple cached value', () {
    final cachedValue = CachedValue(() => 2);
    expect(cachedValue, const TypeMatcher<SimpleCachedValue<dynamic>>());
  });

  test('with dependency', () {
    const dependency = 2;
    final cachedValue =
        CachedValue(() => 4 / dependency).withDependency(() => dependency);
    expect(
      cachedValue,
      const TypeMatcher<DependentCachedValue<dynamic, dynamic>>(),
    );
  });

  test('with ttl', () {
    final cachedValue = CachedValue(() => 2).withTimeToLive(
      lifetime: const Duration(seconds: 12),
    );
    expect(cachedValue, const TypeMatcher<TimeToLiveCachedValue<dynamic>>());
  });
}
