// ignore_for_file: avoid_print

import 'package:cached_value/cached_value.dart';

int factorial(int n) {
  if (n < 0) throw Exception('Negative numbers are not allowed.');
  return n <= 1 ? 1 : n * factorial(n - 1);
}

void main() {
  withDependency();
  withMultipleDependencies();
  withTimeToLive();
}

void withDependency() {
  print('with dependency');

  var originalValue = 1;
  final factorialCache = CachedValue(
    () => factorial(originalValue),
  ).withDependency(
    () => originalValue,
  );

  print(factorialCache.value); // 1

  print(factorialCache.value); // 1 - cached

  originalValue = 6;

  print(factorialCache.value); // 720
}

void withMultipleDependencies() {
  print('with multiple dependencies');

  var originalValue1 = 1;
  var originalValue2 = 2;
  final factorialCache = CachedValue(
    () => factorial(originalValue1) + factorial(originalValue2),
  ).withDependency(
    () sync* {
      yield originalValue1;
      yield originalValue2;
    },
  );

  print(factorialCache.value); // 3

  print(factorialCache.value); // 3 - cached

  originalValue2 = 6;

  print(factorialCache.value); // 721
}

Future<void> withTimeToLive() async {
  print('with TTL:');

  var originalValue = 1;
  final factorialCache = CachedValue(
    () => factorial(originalValue),
  ).withTimeToLive(
    lifetime: const Duration(seconds: 3),
  );

  originalValue = 6;

  print(factorialCache.value); // 1

  await Future<void>.delayed(const Duration(seconds: 3));

  print(factorialCache.value); // 720
}
