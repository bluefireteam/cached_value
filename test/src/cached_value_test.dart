import 'package:cached_value/src/cached_value.dart';
import 'package:cached_value/src/computed_cached_value.dart';
import 'package:cached_value/src/simple_cached_value.dart';
import 'package:test/test.dart';

void main() {
  test('Simple creates a simple cached value', () {
    final cachedValue = CachedValue.simple(() => 2);
    expect(cachedValue, TypeMatcher<SimpleCachedValue>());
  });
  test('Main constructor creates a simple cached value', () {
    final cachedValue = CachedValue(() => 2);
    expect(cachedValue, TypeMatcher<SimpleCachedValue>());
  });
  test('dependent creates a computed cached value', () {
    final dependency = 2;
    final cachedValue = CachedValue.dependent(
      on: () => dependency,
      compute: () => 4 / dependency,
    );
    expect(cachedValue, TypeMatcher<ComputedCachedValue>());
  });
}
