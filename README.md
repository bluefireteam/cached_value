# cached_value

[![Pub](https://img.shields.io/pub/v/cached_value.svg?style=popout)](https://pub.dartlang.org/packages/cached_value)

A simple way to cache values that result from rather expensive operations.

It is useful to cache values that:
 - Are computed from other values in a consistent way;
 - Can be changed given known and unknown conditions;
 - Should not be computed on every access (like a getter);

A `cached_value` is better used over imperative APIs, such as Flutter's render objects. See [Motivation](#motivation) for more.

## Installation

Add to pubspec.yaml:
```yaml
dart pub add cached_value
```

## Usage

A cache can start as a simple manually controlled cache and then be enhanced with automatic functionalities such as dependencies and time-to-live (TTL).

### 1.Creating a simple cached that is invaldiated manually



```dart
  int factorial(int n) {
    if (n < 0) throw ('Negative numbers are not allowed.');
    return n <= 1 ? 1 : n * factorial(n - 1);
  }

  int originalValue = 1;
  final factorialCache = CachedValue(() => factorial(originalValue));
  print(factorialCache.value); // 1

  originalValue = 6;

  print(factorialCache.value); // 1
  print(factorialCache.isValid) // true, invalid only when invalidate is called
  
  // mark as invalid
  factorialCache.invalidate();
  print(factorialCache.isValid); // false

  print(factorialCache.value); // 720
  print(factorialCache.isValid); // true
```
Accessing `value` when the cache is invalid refreshes the cache. It can be refreshed manually via 
the `refresh` method:

```dart
  // ...
  originalValue = 12;
  factorialCache.refresh();

  print(factorialCache.value); // 12
```

### 2. Adding dependencies

A dependent cache is marked as invalid if its dependency value has changed.

```dart
  int factorial(int n) {
    if (n < 0) throw ('Negative numbers are not allowed.');
    return n <= 1 ? 1 : n * factorial(n - 1);
  }
  
  int originalValue = 1;
  final factorialCache = CachedValue(
      () => factorial(originalValue),
  ).withDependency(() => originalValue);
  print(factorialCache.value); // 1
  print(factorialCache.isValid); // true
  
  // update value
  originalValue = 6;
  print(factorialCache.isValid); // false

  print(factorialCache.value); // 720
  print(factorialCache.isValid); // true
```

⚠️Important: 
The dependency callback is called on every value access. So it is recommended to keep it as declarative as possible.

```dart
final someCache = CachedValue(
  // ...
  ).withDependency(
    () => someExpensiveOperation(originalValue), // ❌ Avoid this:
  );
```



### 3. Adding time to live (TTL)

A cache can be automatically marked as invalid some time after a refresh.

```dart
    int factorial(int n) {
        if (n < 0) throw ('Negative numbers are not allowed.');
        return n <= 1 ? 1 : n * factorial(n - 1);
    }
  
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
```

## More docs

There is more detailed docs on the [API documentation](https://pub.dev/documentation/cached_value/latest/).

## Motivation

Some imperative APIs such as the canvas paint on Flutter render objects of Flame's components may 
benefit from values that can be stored and reused between more than a single frame (or paint).

In some very specific cases, I found very convenient to store some objects across frames, like 
`Paint` and `TextPainter` instances.

Example on a render object:
```dart
class BlurredRenderObject extends RenderObject {

  // ...

  double _blurSigma = 0.0;
  double get blurSigma => _blurSigma;
  set blurSigma(double value) {
    _blurSigma = blurSigma;
    markNeedsPaint();
  }

  // ...

  @override
  void paint(PaintingContext context, Offset offset) {
    final canvas = context.canvas;


    final paint = Paint()..maskFilter = MaskFilter.blur(
        BlurStyle.normal, blurSigma
    );
    canvas.drawRect(Rect.fromLTWH(0, 0, 100, 100), paint);
  }
}
```

Can be changed to:
```dart
class BlurredRenderObject extends RenderObject {

  // ...

  double _blurSigma = 0.0;
  double get blurSigma => _blurSigma;
  set blurSigma(double value) {
    _blurSigma = blurSigma;
    markNeedsPaint();
  }

  // Add cache:
  late final paintCache = CachedValue(
     () => Paint()..maskFilter = MaskFilter.blur(BlurStyle.normal, blurSigma),
  ).withDependency(() => blurSigma);

  // ...

  @override
  void paint(PaintingContext context, Offset offset) {
    final canvas = context.canvas;

    // use cache:
    final paint = paintCache.value;
    canvas.drawRect(Rect.fromLTWH(0, 0, 100, 100), paint);
  }
}
```