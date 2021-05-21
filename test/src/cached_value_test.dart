import 'package:cached_value/cached_value.dart';
import 'package:test/test.dart';

void main() {
  test('Constructor creates a simple cached value', () {
    final cachedValue = CachedValue(() => 2);
    expect(cachedValue, TypeMatcher<SimpleCachedValue>());
  });

  test('with dependency', () {
    final dependency = 2;
    final cachedValue =
        CachedValue(() => 4 / dependency).withDependency(() => dependency);
    expect(cachedValue, TypeMatcher<DependentCachedValue>());
  });

  test('with ttl', () {
    final cachedValue =
        CachedValue(() => 2).withTimeToLive(lifetime: Duration(seconds: 12));
    expect(cachedValue, TypeMatcher<TimeToLiveCachedValue>());
  });
}
