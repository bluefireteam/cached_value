import 'package:cached_value/cached_value.dart';

int factorial(int n) {
  if (n < 0) throw ('Negative numbers are not allowed.');
  return n <= 1 ? 1 : n * factorial(n - 1);
}

void main() {
  int originalValue = 1;
  final factorialCache = CachedValue.dependent(
    on: () => originalValue,
    compute: () => factorial(originalValue),
  );
  print(factorialCache.value); // 1

  originalValue = 6;

  print(factorialCache.value); // 720
}
