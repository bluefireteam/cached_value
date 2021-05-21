import 'package:cached_value/src/cached_value.dart';
import 'package:meta/meta.dart' show isTest;
import 'package:test/test.dart';

class TestBed {
  int current = 0;
  int updates = 0;
  late final cached = CachedValue(() {
    updates++;
    return current;
  });
}

@isTest
void testCachedValue(
  String description,
  dynamic Function(TestBed testBed) body,
) {
  final testBed = TestBed();

  test(description, () => body(testBed));
}

void main() {
  testCachedValue('Cached value should be cached', (testBed) {
    expect(testBed.current, equals(0));
    expect(testBed.updates, equals(0));
    final cachedValue = testBed.cached.value;
    testBed.current = 1;
    expect(cachedValue, equals(0));
    expect(testBed.updates, equals(1));
  });
  testCachedValue(
    'invalidate should update cached value on next access',
    (testBed) {
      // first access
      final cachedValueStart = testBed.cached.value;
      final updatesAfterFirstAccess = testBed.updates;
      final validAfterFirstAccess = testBed.cached.isValid;

      // update value
      testBed.current = 100;
      final cachedValueAfterUpdate = testBed.cached.value;

      // invalidate
      testBed.cached.invalidate();
      final updatesAfterInvalidate = testBed.updates;
      final validAfterInvalidate = testBed.cached.isValid;

      // second access
      final cachedValueAfterInvalidate = testBed.cached.value;
      final updatesAfterInvalidateAccess = testBed.updates;
      final validAfterInvalidateAccess = testBed.cached.isValid;

      expect(cachedValueStart, equals(0));
      expect(cachedValueAfterUpdate, equals(0));
      expect(cachedValueAfterInvalidate, equals(100));

      expect(updatesAfterFirstAccess, equals(1));
      expect(updatesAfterInvalidate, equals(1));
      expect(updatesAfterInvalidateAccess, equals(2));

      expect(validAfterFirstAccess, isTrue);
      expect(validAfterInvalidate, isFalse);
      expect(validAfterInvalidateAccess, isTrue);
    },
  );
  testCachedValue('refresh should update cached value immediately', (testBed) {
    final cachedValueStart = testBed.cached.value;
    testBed.current = 100;
    final updatesBeforeRefresh = testBed.updates;
    final validBeforeRefresh = testBed.cached.isValid;

    // refresh
    final refreshReturn = testBed.cached.refresh();
    final updatesAfterRefresh = testBed.updates;
    final cachedValueAfterRefresh = testBed.cached.value;
    final validAfterRefresh = testBed.cached.isValid;

    expect(cachedValueStart, equals(0));
    expect(refreshReturn, equals(100));
    expect(cachedValueAfterRefresh, equals(100));

    expect(updatesBeforeRefresh, equals(1));
    expect(updatesAfterRefresh, equals(2));

    expect(validBeforeRefresh, isTrue);
    expect(validAfterRefresh, isTrue);
  });
}
