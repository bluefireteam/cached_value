import 'package:cached_value/cached_value.dart';
import 'package:meta/meta.dart';
import 'package:test/test.dart';


class TestBed {
  String name1 = 'Elon Musk'; 
  String name2 = 'Jeff Bezos';
  late final marriedNameCache = CachedValue(
    () => '${name1.split(' ').first} ${name2.split(' ').last}',
  ).withDependency(
    () sync* {
      yield name1;
      yield name2;
    },
  );
}

void main() {
  late TestBed testBed;

  setUp(() {
    testBed = TestBed();
  });

  test(
    'cached value should be computed and cached',
    () {
      final cachedValueAtStart = testBed.marriedNameCache.value;

      // update value
      testBed.name1 = 'Mark Zuckerberg';
      final cachedValueAfterUpdate = testBed.marriedNameCache.value;

      expect(cachedValueAtStart, equals('Elon Bezos'));
      expect(cachedValueAfterUpdate, equals('Mark Bezos'));
    },
  );

  test(
    'cached value with multiple dependencies should be computed and cached',
    () {
      final cachedValueAtStart = testBed.marriedNameCache.value;

      // update value
      testBed.name2 = 'Mark Zuckerberg';
      final cachedValueAfterUpdate = testBed.marriedNameCache.value;

      expect(cachedValueAtStart, equals('Elon Bezos'));
      expect(cachedValueAfterUpdate, equals('Elon Zuckerberg'));
    },
  );

  test(
    'dependency change should update cached value on next access',
    () {
      final cachedValueAtStart = testBed.marriedNameCache.value;
      final validAfterFirstAccess = testBed.marriedNameCache.isValid;

      // update value
      testBed.name1 = 'Mark Zuckerberg';
      final validAfterUpdate = testBed.marriedNameCache.isValid;
      final cachedValueAfterUpdate = testBed.marriedNameCache.value;
      final validAfterUpdateAccess = testBed.marriedNameCache.isValid;

      expect(cachedValueAtStart, equals('Elon Bezos'));
      expect(cachedValueAfterUpdate, equals('Mark Bezos'));

      expect(validAfterFirstAccess, isTrue);
      expect(validAfterUpdate, isFalse);
      expect(validAfterUpdateAccess, isTrue);
    },
  );

  test(
    'invalidate should update cached value on next access',
    () {
      // first access
      final cachedValueStart = testBed.marriedNameCache.value;
      final validAfterFirstAccess = testBed.marriedNameCache.isValid;

      // invalidate
      testBed.marriedNameCache.invalidate();
      final validAfterInvalidate = testBed.marriedNameCache.isValid;

      // second access
      final cachedValueAfterInvalidate = testBed.marriedNameCache.value;
      final validAfterInvalidateAccess = testBed.marriedNameCache.isValid;

      expect(cachedValueStart, equals('Elon Bezos'));
      expect(cachedValueAfterInvalidate, equals('Elon Bezos'));

      expect(validAfterFirstAccess, isTrue);
      expect(validAfterInvalidate, isFalse);
      expect(validAfterInvalidateAccess, isTrue);
    },
  );

  test('refresh should update cached value immediately', () {
    // first access
    final cachedValueStart = testBed.marriedNameCache.value;
    final validAfterFirstAccess = testBed.marriedNameCache.isValid;

    // update value
    testBed.name1 = 'Mark Zuckerberg';
    final validAfterUpdate = testBed.marriedNameCache.isValid;

    // refresh
    testBed.marriedNameCache.refresh();
    final validAfterRefresh = testBed.marriedNameCache.isValid;

    // second access
    final cachedValueAfterUpdate = testBed.marriedNameCache.value;

    expect(cachedValueStart, equals('Elon Bezos'));
    expect(cachedValueAfterUpdate, equals('Mark Bezos'));

    expect(validAfterFirstAccess, isTrue);
    expect(validAfterUpdate, isFalse);
    expect(validAfterRefresh, isTrue);
  });
}
