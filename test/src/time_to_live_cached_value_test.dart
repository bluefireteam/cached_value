import 'package:cached_value/cached_value.dart';
import 'package:test/test.dart';

void main() {
  group("TimeToLiveCachedValue", () {
    test("should wait not compute before lifetime", () async {
      var numberOfLifeProblems = 10;
      final lifeProblemsAMinuteAgo = CachedValue(() => numberOfLifeProblems)
          .withTimeToLive(lifetime: Duration(seconds: 4));

      final validAfterDeclaration = lifeProblemsAMinuteAgo.isValid;
      final valueAfterDeclaration = lifeProblemsAMinuteAgo.value;

      numberOfLifeProblems = 150;

      final validAfterUpdate = lifeProblemsAMinuteAgo.isValid;
      final valueAfterUpdate = lifeProblemsAMinuteAgo.value;

      await Future.delayed(Duration(seconds: 2));

      final validAfter2Seconds = lifeProblemsAMinuteAgo.isValid;
      final valueAfter2Seconds = lifeProblemsAMinuteAgo.value;

      expect(validAfterDeclaration, true);
      expect(valueAfterDeclaration, 10);
      expect(validAfterUpdate, true);
      expect(valueAfterUpdate, 10);
      expect(validAfter2Seconds, true);
      expect(valueAfter2Seconds, 10);
    });
    test("should recompute after lifetime", () async {
      var numberOfLifeProblems = 10;
      final lifeProblemsAMinuteAgo = CachedValue(() => numberOfLifeProblems)
          .withTimeToLive(lifetime: Duration(seconds: 2));

      numberOfLifeProblems = 150;

      await Future.delayed(Duration(seconds: 3));

      final validAfter3Seconds = lifeProblemsAMinuteAgo.isValid;
      final valueAfter3Seconds = lifeProblemsAMinuteAgo.value;

      numberOfLifeProblems = 9750;

      await Future.delayed(Duration(seconds: 3));

      final validAfter6Seconds = lifeProblemsAMinuteAgo.isValid;
      final valueAfter6Seconds = lifeProblemsAMinuteAgo.value;

      expect(validAfter3Seconds, false);
      expect(valueAfter3Seconds, 150);
      expect(validAfter6Seconds, false);
      expect(valueAfter6Seconds, 9750);
    });
    test("refresh should reset lifetime", () async {
      var numberOfLifeProblems = 10;
      final lifeProblemsAMinuteAgo = CachedValue(() => numberOfLifeProblems)
          .withTimeToLive(lifetime: Duration(seconds: 4));

      numberOfLifeProblems = 150;

      await Future.delayed(Duration(seconds: 2));

      // before lifetime ends, force refresh
      final validAfter2SecondsBeforeRefresh = lifeProblemsAMinuteAgo.isValid;
      final valueAfter2SecondsBeforeRefresh = lifeProblemsAMinuteAgo.value;

      final valueAfter2SecondsAfterRefresh = lifeProblemsAMinuteAgo.refresh();
      final validAfter2SecondsAfterRefresh = lifeProblemsAMinuteAgo.isValid;

      numberOfLifeProblems = 1750;

      await Future.delayed(Duration(seconds: 2));

      final validAfter4Seconds = lifeProblemsAMinuteAgo.isValid;
      final valueAfter4Seconds = lifeProblemsAMinuteAgo.value;

      expect(validAfter2SecondsBeforeRefresh, true);
      expect(valueAfter2SecondsBeforeRefresh, 10);

      expect(validAfter2SecondsAfterRefresh, true);
      expect(valueAfter2SecondsAfterRefresh, 150);

      expect(validAfter4Seconds, true);
      expect(valueAfter4Seconds, 150);
    });
    test("prevent duplicated time to live", () {
      expect(
        () => CachedValue(() => "lolo")
            .withTimeToLive(lifetime: Duration(seconds: 1))
            .withTimeToLive(lifetime: Duration(seconds: 1)),
        throwsA(
          predicate(
            (e) =>
                e is AssertionError &&
                e.message ==
                    """
There is a declaration of a cached value time to live specified more than once""",
          ),
        ),
      );
    });
    test("pile up with dependency", () async {
      var numberOfLifeProblems = 10;
      final realNumberOfLifeProblemsAMinuteAgo =
          CachedValue(() => numberOfLifeProblems * 2)
              .withDependency(() => numberOfLifeProblems)
              .withTimeToLive(lifetime: Duration(seconds: 3));

      final validAfterDeclaration = realNumberOfLifeProblemsAMinuteAgo.isValid;
      final valueAfterDeclaration = realNumberOfLifeProblemsAMinuteAgo.value;

      numberOfLifeProblems = 150;

      final validAfterUpdate = realNumberOfLifeProblemsAMinuteAgo.isValid;
      final valueAfterUpdate = realNumberOfLifeProblemsAMinuteAgo.value;

      await Future.delayed(Duration(seconds: 4));

      final validAfter2Seconds = realNumberOfLifeProblemsAMinuteAgo.isValid;
      final valueAfter2Seconds = realNumberOfLifeProblemsAMinuteAgo.value;

      expect(validAfterDeclaration, true);
      expect(valueAfterDeclaration, 20);
      expect(validAfterUpdate, false);
      expect(valueAfterUpdate, 300);
      expect(validAfter2Seconds, false);
      expect(valueAfter2Seconds, 300);
    });
  });
}
