import 'package:cached_value/cached_value.dart';
import 'package:meta/meta.dart';
import 'package:test/test.dart';

class TestBed {
  String name = "Elon Bezos"; // Married name
  late final firstNameCache = CachedValue(
    () => name.split(" ").first,
  ).withDependency(
    () => name,
  );
}

@isTest
void testComputedCachedValue(
  String description,
  dynamic Function(TestBed testBed) body,
) {
  final testBed = TestBed();

  test(description, () => body(testBed));
}

void main() {
  testComputedCachedValue(
    "cached value should be computed and cached",
    (testBed) {
      final cachedValueAtStart = testBed.firstNameCache.value;

      // update value
      testBed.name = "Joseph climber";
      final cachedValueAfterUpdate = testBed.firstNameCache.value;

      expect(cachedValueAtStart, equals('Elon'));
      expect(cachedValueAfterUpdate, equals('Joseph'));
    },
  );

  testComputedCachedValue(
    'dependency change should update cached value on next access',
    (testBed) {
      final cachedValueAtStart = testBed.firstNameCache.value;
      final validAfterFirstAccess = testBed.firstNameCache.isValid;

      // update value
      testBed.name = "Joseph climber";
      final validAfterUpdate = testBed.firstNameCache.isValid;
      final cachedValueAfterUpdate = testBed.firstNameCache.value;
      final validAfterUpdateAccess = testBed.firstNameCache.isValid;

      expect(cachedValueAtStart, equals('Elon'));
      expect(cachedValueAfterUpdate, equals('Joseph'));

      expect(validAfterFirstAccess, isTrue);
      expect(validAfterUpdate, isFalse);
      expect(validAfterUpdateAccess, isTrue);
    },
  );

  testComputedCachedValue(
    'invalidate should update cached value on next access',
    (testBed) {
      // first access
      final cachedValueStart = testBed.firstNameCache.value;
      final validAfterFirstAccess = testBed.firstNameCache.isValid;

      // invalidate
      testBed.firstNameCache.invalidate();
      final validAfterInvalidate = testBed.firstNameCache.isValid;

      // second access
      final cachedValueAfterInvalidate = testBed.firstNameCache.value;
      final validAfterInvalidateAccess = testBed.firstNameCache.isValid;

      expect(cachedValueStart, equals('Elon'));
      expect(cachedValueAfterInvalidate, equals('Elon'));

      expect(validAfterFirstAccess, isTrue);
      expect(validAfterInvalidate, isFalse);
      expect(validAfterInvalidateAccess, isTrue);
    },
  );

  testComputedCachedValue('refresh should update cached value immediately',
      (testBed) {
    // first access
    final cachedValueStart = testBed.firstNameCache.value;
    final validAfterFirstAccess = testBed.firstNameCache.isValid;

    // update value
    testBed.name = "Joseph climber";
    final validAfterUpdate = testBed.firstNameCache.isValid;

    // refresh
    testBed.firstNameCache.refresh();
    final validAfterRefresh = testBed.firstNameCache.isValid;

    // second access
    final cachedValueAfterUpdate = testBed.firstNameCache.value;

    expect(cachedValueStart, equals('Elon'));
    expect(cachedValueAfterUpdate, equals('Joseph'));

    expect(validAfterFirstAccess, isTrue);
    expect(validAfterUpdate, isFalse);
    expect(validAfterRefresh, isTrue);
  });
}
