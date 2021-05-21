import 'package:cached_value/cached_value.dart';

int factorial(int n) {
  if (n < 0) throw ('Negative numbers are not allowed.');
  return n <= 1 ? 1 : n * factorial(n - 1);
}

void main() {
  withDependency();
  withTimeToLive();
}

void withDependency() {
  print("with dependency");

  int originalValue = 1;
  final factorialCache = CachedValue(
    () => factorial(originalValue),
  ).withDependency(
    () => originalValue,
  );

  print(factorialCache.value); // 1

  print(factorialCache.value); // 1 - not recomputes

  originalValue = 6;

  print(factorialCache.value); // 720
}

void withTimeToLive() async {
  print("with TTL:");

  int originalValue = 1;
  final factorialCache = CachedValue(
    () => factorial(originalValue),
  ).withTimeToLive(
    lifetime: Duration(seconds: 3),
  );

  originalValue = 6;

  print(factorialCache.value); // 1

  await Future.delayed(Duration(seconds: 3));

  print(factorialCache.value); // 720
}
