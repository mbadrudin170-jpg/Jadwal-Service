# 📚 Dokumentasi File Eksternal & Core

> **Tanggal dibuat:** 2026-07-08 18:04:05
> **Total file unik:** 13

---


// ============================================================
// 🔧 Core Dart: future.dart
// 📁 /home/user/flutter/bin/cache/pkg/sky_engine/lib/async/future.dart
// ============================================================

```dart
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of "dart:async";

/// A type representing values that are either `Future<T>` or `T`.
///
/// This class declaration is a public stand-in for an internal
/// future-or-value generic type, which is not a class type.
/// References to this class are resolved to the internal type.
///
/// It is a compile-time error for any class to extend, mix in or implement
/// `FutureOr`.
///
/// ### Examples
///
/// ```dart
/// // The `Future<T>.then` function takes a callback [f] that returns either
/// // an `S` or a `Future<S>`.
/// Future<S> then<S>(FutureOr<S> f(T x), ...);
///
/// // `Completer<T>.complete` takes either a `T` or `Future<T>`.
/// void complete(FutureOr<T> value);
/// ```
///
/// ### Advanced
///
/// The `FutureOr<int>` type is actually the "type union" of the types `int` and
/// `Future<int>`. This type union is defined in such a way that
/// `FutureOr<Object>` is both a super- and sub-type of `Object` (sub-type
/// because `Object` is one of the types of the union, super-type because
/// `Object` is a super-type of both of the types of the union). Together it
/// means that `FutureOr<Object>` is equivalent to `Object`.
///
/// As a corollary, `FutureOr<Object>` is equivalent to
/// `FutureOr<FutureOr<Object>>`, `FutureOr<Future<Object>>` is equivalent to
/// `Future<Object>`.
@pragma("vm:entry-point")
abstract class FutureOr<T> {
  // Private generative constructor, so that it is not subclassable, mixable,
  // or instantiable.
  FutureOr._() {
    throw UnsupportedError("FutureOr cannot be instantiated");
  }
}

/// The result of an asynchronous computation.
///
/// An _asynchronous computation_ cannot provide a result immediately
/// when it is started, unlike a synchronous computation which does compute
/// a result immediately by either returning a value or by throwing.
/// An asynchronous computation may need to wait for something external
/// to the program (reading a file, querying a database, fetching a web page)
/// which takes time.
/// Instead of blocking all computation until the result is available,
/// the asynchronous computation immediately returns a `Future`
/// which will *eventually* "complete" with the result.
///
/// ### Asynchronous programming
///
/// To perform an asynchronous computation, you use an `async` function
/// which always produces a future.
/// Inside such an asynchronous function, you can use the `await` operation
/// to delay execution until another asynchronous computation has a result.
/// While execution of the awaiting function is delayed,
/// the program is not blocked, and can continue doing other things.
///
/// Example:
/// ```dart
/// import "dart:io";
/// Future<bool> fileContains(String path, String needle) async {
///    var haystack = await File(path).readAsString();
///    return haystack.contains(needle);
/// }
/// ```
/// Here the `File.readAsString` method from `dart:io` is an asynchronous
/// function returning a `Future<String>`.
/// The `fileContains` function is marked with `async` right before its body,
/// which means that you can use `await` inside it,
/// and that it must return a future.
/// The call to `File(path).readAsString()` initiates reading the file into
/// a string and produces a `Future<String>` which will eventually contain the
/// result.
/// The `await` then waits for that future to complete with a string
/// (or an error, if reading the file fails).
/// While waiting, the program can do other things.
/// When the future completes with a string, the `fileContains` function
/// computes a boolean and returns it, which then completes the original
/// future that it returned when first called.
///
/// If a future completes with an *error*, awaiting that future will
/// (re-)throw that error. In the example here, we can add error checking:
/// ```dart
/// import "dart:io";
/// Future<bool> fileContains(String path, String needle) async {
///   try {
///     var haystack = await File(path).readAsString();
///     return haystack.contains(needle);
///   } on FileSystemException catch (exception, stack) {
///     _myLog.logError(exception, stack);
///     return false;
///   }
/// }
/// ```
/// You use a normal `try`/`catch` to catch the failures of awaited
/// asynchronous computations.
///
/// In general, when writing asynchronous code, you should always await a
/// future when it is produced, and not wait until after another asynchronous
/// delay. That ensures that you are ready to receive any error that the
/// future might produce, which is important because an asynchronous error
/// that no-one is awaiting is an *uncaught* error and may terminate
/// the running program.
///
/// ### Programming with the `Future` API.
///
/// The `Future` class also provides a more direct, low-level functionality
/// for accessing the result that it completes with.
/// The `async` and `await` language features are built on top of this
/// functionality, and it sometimes makes sense to use it directly.
/// There are things that you cannot do by just `await`ing one future at
/// a time.
///
/// With a [Future], you can manually register callbacks
/// that handle the value, or error, once it is available.
/// For example:
/// ```dart
/// Future<int> future = getFuture();
/// future.then((value) => handleValue(value))
///       .catchError((error) => handleError(error));
/// ```
/// Since a [Future] can be completed in two ways,
/// either with a value (if the asynchronous computation succeeded)
/// or with an error (if the computation failed),
/// you can install callbacks for either or both cases.
///
/// In some cases we say that a future is completed *with another future*.
/// This is a short way of stating that the future is completed in the same way,
/// with the same value or error,
/// as the other future once that other future itself completes.
/// Most functions in the platform libraries that complete a future
/// (for example [Completer.complete] or [Future.value]),
/// also accepts another future, and automatically handles forwarding
/// the result to the future being completed.
///
/// The result of registering callbacks is itself a `Future`,
/// which in turn is completed with the result of invoking the
/// corresponding callback with the original future's result.
/// The new future is completed with an error if the invoked callback throws.
/// For example:
/// ```dart
/// Future<int> successor = future.then((int value) {
///     // Invoked when the future is completed with a value.
///     return 42;  // The successor is completed with the value 42.
///   },
///   onError: (e) {
///     // Invoked when the future is completed with an error.
///     if (canHandle(e)) {
///       return 499;  // The successor is completed with the value 499.
///     } else {
///       throw e;  // The successor is completed with the error e.
///     }
///   });
/// ```
///
/// If a future does not have any registered handler when it completes
/// with an error, it forwards the error to an "uncaught-error handler".
/// This behavior ensures that no error is silently dropped.
/// However, it also means that error handlers should be installed early,
/// so that they are present as soon as a future is completed with an error.
/// The following example demonstrates this potential bug:
/// ```dart
/// var future = getFuture();
/// Timer(const Duration(milliseconds: 5), () {
///   // The error-handler is not attached until 5 ms after the future has
///   // been received. If the future fails before that, the error is
///   // forwarded to the global error-handler, even though there is code
///   // (just below) to eventually handle the error.
///   future.then((value) { useValue(value); },
///               onError: (e) { handleError(e); });
/// });
/// ```
///
/// When registering callbacks, it's often more readable to register the two
/// callbacks separately, by first using [then] with one argument
/// (the value handler) and using a second [catchError] for handling errors.
/// Each of these will forward the result that they don't handle
/// to their successors, and together they handle both value and error result.
/// It has the additional benefit of the [catchError] handling errors in the
/// [then] value callback too.
/// Using sequential handlers instead of parallel ones often leads to code that
/// is easier to reason about.
/// It also makes asynchronous code very similar to synchronous code:
/// ```dart
/// // Synchronous code.
/// try {
///   int value = foo();
///   return bar(value);
/// } catch (e) {
///   return 499;
/// }
/// ```
///
/// Equivalent asynchronous code, based on futures:
/// ```dart
/// Future<int> asyncValue = Future(foo);  // Result of foo() as a future.
/// asyncValue.then((int value) {
///   return bar(value);
/// }).catchError((e) {
///   return 499;
/// });
/// ```
///
/// Similar to the synchronous code, the error handler (registered with
/// [catchError]) is handling any errors thrown by either `foo` or `bar`.
/// If the error-handler had been registered as the `onError` parameter of
/// the `then` call, it would not catch errors from the `bar` call.
///
/// Futures can have more than one callback-pair registered. Each successor is
/// treated independently and is handled as if it was the only successor.
/// The order in which the individual successors are completed is undefined.
///
/// A future may also fail to ever complete. In that case, no callbacks are
/// called. That situation should generally be avoided if possible, unless
/// it's very clearly documented.
@pragma("wasm:entry-point")
@vmIsolateUnsendable
abstract interface class Future<T> {
  /// A `Future<void>` completed with `null`.
  ///
  /// Currently shared with `dart:internal`.
  /// If that future can be removed, then change this back to
  /// `_Future<void>.zoneValue(null, _rootZone);`
  static final _Future<void> _nullFuture = nullFuture as _Future<void>;

  /// A `Future<bool>` completed with `false`.
  static final _Future<bool> _falseFuture = _Future<bool>.zoneValue(
    false,
    _rootZone,
  );

  /// Creates a future containing the result of calling [computation]
  /// asynchronously with [Timer.run].
  ///
  /// If the result of executing [computation] throws, the returned future is
  /// completed with the error.
  ///
  /// If the returned value is itself a [Future], completion of
  /// the created future will wait until the returned future completes,
  /// and will then complete with the same result.
  ///
  /// If a non-future value is returned, the returned future is completed
  /// with that value.
  factory Future(FutureOr<T> computation()) {
    _Future<T> result = _Future<T>();
    Timer.run(() {
      FutureOr<T> computationResult;
      try {
        computationResult = computation();
      } catch (e, s) {
        _completeWithErrorCallback(result, e, s);
        return;
      }
      result._complete(computationResult);
    });
    return result;
  }

  /// Creates a future containing the result of calling [computation]
  /// asynchronously with [scheduleMicrotask].
  ///
  /// If executing [computation] throws,
  /// the returned future is completed with the thrown error.
  ///
  /// If calling [computation] returns a [Future], completion of
  /// the created future will wait until the returned future completes,
  /// and will then complete with the same result.
  ///
  /// If calling [computation] returns a non-future value,
  /// the returned future is completed with that value.
  factory Future.microtask(FutureOr<T> computation()) {
    _Future<T> result = _Future<T>();
    scheduleMicrotask(() {
      FutureOr<T> computationResult;
      try {
        computationResult = computation();
      } catch (e, s) {
        _completeWithErrorCallback(result, e, s);
        return;
      }
      result._complete(computationResult);
    });
    return result;
  }

  /// The result of calling [computation] as a future.
  ///
  /// Mainly used when working with functions returning a `FutureOr<T>`,
  /// or non-async functions in a non-`async` asynchronous function,
  /// where you want to capture any error in a future.
  ///
  /// If calling [computation] throws, the returned future is completed
  /// with the error.
  ///
  /// If calling [computation] returns a `Future<T>`, that future is returned.
  ///
  /// If calling [computation] returns a non-`Future<T>` value,
  /// a future is created which has been completed with that value.
  ///
  /// Example:
  /// ```dart
  /// Future<int> asyncAdd(
  ///   FutureOr<int> Function() a,
  ///   FutureOr<int> Function() b,
  /// ) =>
  ///   (Future.sync(a), Future.sync(b)).wait.then((ab) => ab.$1 + ab.$2);
  /// ```
  ///
  /// To create a future with a known value, use [Future.syncValue] instead,
  /// as `Future.syncValue(12)`.
  factory Future.sync(FutureOr<T> computation()) {
    FutureOr<T> result;
    try {
      result = computation();
    } catch (error, stackTrace) {
      return _Future<T>()
        .._asyncCompleteErrorObject(_interceptCaughtError(error, stackTrace));
    }
    return result is Future<T> ? result : _Future<T>.value(result);
  }

  /// Creates a future completed with [value].
  ///
  /// The future is guaranteed to not have an error.
  ///
  /// If a synchronous computation can throw,
  /// rather than doing `Future.syncValue(computation())` and wrapping that in
  /// a `try`/`catch`, you can use [Future.sync] which catches an error
  /// into its returned future, as `Future.sync(() => computation())`.
  @Since("3.10")
  factory Future.syncValue(T value) => _Future<T>().._setValue(value);

  /// Creates a future completed with [value].
  ///
  /// If [value] is a future, the created future waits for the
  /// [value] future to complete, and then completes with the same result.
  /// Since a [value] future can complete with an error, so can the future
  /// created by [Future.value], even if the name suggests otherwise.
  ///
  /// If [value] is not a [Future], the created future is completed
  /// with the [value] value,
  /// equivalently to `new Future<T>.sync(() => value)`.
  ///
  /// If [value] is omitted or `null`, it is converted to `FutureOr<T>` by
  /// `value as FutureOr<T>`. If `T` is not nullable, then a non-`null` [value]
  /// must be provided, otherwise the construction throws.
  ///
  /// Use [Completer] to create a future now and complete it later.
  ///
  /// Example:
  /// ```dart
  /// Future<int> getFuture() {
  ///  return Future<int>.value(2021);
  /// }
  ///
  /// final result = await getFuture();
  /// ```
  @pragma("vm:entry-point")
  @pragma("vm:prefer-inline")
  factory Future.value([FutureOr<T>? value]) {
    return _Future<T>.immediate(value == null ? value as T : value);
  }

  /// Creates a future that completes with an error.
  ///
  /// The created future will be completed with an error in a future microtask.
  /// This allows enough time for someone to add an error handler on the future.
  /// If an error handler isn't added before the future completes, the error
  /// will be considered unhandled.
  ///
  /// Use [Completer] to create a future and complete it later.
  ///
  /// Example:
  /// ```dart
  /// Future<int> getFuture() {
  ///  return Future.error(Exception('Issue'));
  /// }
  ///
  /// final error = await getFuture(); // Throws.
  /// ```
  factory Future.error(Object error, [StackTrace? stackTrace]) =>
      _Future<T>.immediateError(_interceptUserError(error, stackTrace));

  /// Creates a future that runs its computation after a delay.
  ///
  /// The [computation] will be executed after the given [duration] has passed,
  /// and the future is completed with the result of the computation.
  ///
  /// If [computation] returns a future,
  /// the future returned by this constructor will complete with the value or
  /// error of that future.
  ///
  /// If the duration is 0 or less,
  /// it completes no sooner than in the next event-loop iteration,
  /// after all microtasks have run.
  ///
  /// If [computation] is omitted,
  /// it will be treated as if [computation] was `() => null`,
  /// and the future will eventually complete with the `null` value.
  /// In that case, [T] must be nullable.
  ///
  /// If calling [computation] throws, the created future will complete with the
  /// error.
  ///
  /// See also [Completer] for a way to create and complete a future at a
  /// later time that isn't necessarily after a known fixed duration.
  ///
  /// Example:
  /// ```dart
  /// Future.delayed(const Duration(seconds: 1), () {
  ///   print('One second has passed.'); // Prints after 1 second.
  /// });
  /// ```
  factory Future.delayed(Duration duration, [FutureOr<T> computation()?]) {
    if (computation == null && !typeAcceptsNull<T>()) {
      throw ArgumentError.value(
        null,
        "computation",
        "The type parameter is not nullable",
      );
    }
    _Future<T> result = _Future<T>();
    Timer(duration, () {
      if (computation == null) {
        result._complete(null as T);
      } else {
        FutureOr<T> computationResult;
        try {
          computationResult = computation();
        } catch (e, s) {
          _completeWithErrorCallback(result, e, s);
          return;
        }
        result._complete(computationResult);
      }
    });
    return result;
  }

  /// Waits for multiple futures to complete and collects their results.
  ///
  /// Returns a future which will complete once all the provided futures
  /// have completed, either with their results, or with an error if any
  /// of the provided futures fail.
  ///
  /// The value of the returned future will be a list of all the values that
  /// were produced in the order that the futures are provided by iterating
  /// [futures].
  ///
  /// If any future completes with an error,
  /// then the returned future completes with that error.
  /// If further futures also complete with errors, those errors are discarded.
  ///
  /// If `eagerError` is true, the returned future completes with an error
  /// immediately on the first error from one of the futures. Otherwise all
  /// futures must complete before the returned future is completed (still with
  /// the first error; the remaining errors are silently dropped).
  ///
  /// In the case of an error, [cleanUp] (if provided), is invoked on any
  /// non-null result of successful futures.
  /// This makes it possible to `cleanUp` resources that would otherwise be
  /// lost (since the returned future does not provide access to these values).
  /// The [cleanUp] function is unused if there is no error.
  ///
  /// The call to [cleanUp] should not throw. If it does, the error will be an
  /// uncaught asynchronous error.
  ///
  /// Example:
  /// ```dart
  /// void main() async {
  ///   var value = await Future.wait([delayedNumber(), delayedString()]);
  ///   print(value); // [2, result]
  /// }
  ///
  /// Future<int> delayedNumber() async {
  ///   await Future.delayed(const Duration(seconds: 2));
  ///   return 2;
  /// }
  ///
  /// Future<String> delayedString() async {
  ///   await Future.delayed(const Duration(seconds: 2));
  ///   return 'result';
  /// }
  /// ```
  static Future<List<T>> wait<T>(
    Iterable<Future<T>> futures, {
    bool eagerError = false,
    void cleanUp(T successValue)?,
  }) {
    @pragma('vm:awaiter-link')
    final _Future<List<T>> _future = _Future<List<T>>();
    List<T?>? values; // Collects the values. Set to null on error.
    int remaining = 0; // How many futures are we waiting for.
    Object? error; // The first error from a future.
    StackTrace? stackTrace; // The stackTrace that came with the error.

    // Handle an error from any of the futures.
    void handleError(Object theError, StackTrace theStackTrace) {
      var remainingResults = --remaining;
      List<T?>? valueList = values;
      if (valueList != null) {
        // First error, set state to represent error having already happened.
        values = null;
        error = theError;
        stackTrace = theStackTrace;
        // Then clean up any already successfully produced results.
        if (cleanUp != null) {
          for (var value in valueList) {
            if (value != null) {
              // Ensure errors from `cleanUp` are uncaught.
              T cleanUpValue = value;
              Future.sync(() {
                cleanUp(cleanUpValue);
              });
            }
          }
        }
        if (remainingResults == 0 || eagerError) {
          _future._completeError(theError, theStackTrace);
        }
      } else {
        // Not the first error.
        if (remainingResults == 0 && !eagerError) {
          // Last future completed, non-eagerly report the first error.
          _future._completeError(error!, stackTrace!);
        }
      }
    }

    try {
      // As each future completes, put its value into the corresponding
      // position in the list of values.
      for (var future in futures) {
        int pos = remaining;
        future.then((T value) {
          var remainingResults = --remaining;
          List<T?>? valueList = values;
          if (valueList != null) {
            // No errors yet.
            assert(valueList[pos] == null);
            valueList[pos] = value;
            if (remainingResults == 0) {
              _future._completeWithValue([
                for (var value in valueList) value as T,
              ]);
            }
          } else {
            // Prior error, clean-up this value if necessary.
            if (cleanUp != null && value != null) {
              // Ensure errors from cleanUp are uncaught.
              Future.sync(() {
                cleanUp(value);
              });
            }
            if (remainingResults == 0 && !eagerError) {
              // Last future completed, non-eagerly report the first error.
              _future._completeError(error!, stackTrace!);
            }
          }
        }, onError: handleError);
        // Increment the 'remaining' after the call to 'then'.
        // If that call throws, we don't expect any future callback from
        // the future, and we also don't increment remaining.
        remaining++;
      }
      if (remaining == 0) {
        // No elements in iterable.
        return _future.._completeWithValue(<T>[]);
      }
      values = List<T?>.filled(remaining, null);
    } catch (e, s) {
      // The error must have been thrown while iterating over the futures
      // list, or while installing a callback handler on the future.
      // This is a breach of the `Future` protocol, but we try to handle it
      // gracefully.
      if (remaining == 0 || eagerError) {
        // Complete asynchronously to give receiver time to handle
        // the result.
        return _future.._asyncCompleteErrorObject(_interceptCaughtError(e, s));
      } else {
        // Don't allocate a list for values, thus indicating that there was an
        // error.
        // Set error to the caught exception.
        error = e;
        stackTrace = s;
      }
    }
    return _future;
  }

  /// Returns the result of the first future in [futures] to complete.
  ///
  /// The returned future is completed with the result of the first
  /// future in [futures] to report that it is complete,
  /// whether it's with a value or an error.
  /// The results of all the other futures are discarded.
  ///
  /// If [futures] is empty, or if none of its futures complete,
  /// the returned future never completes.
  ///
  /// Example:
  /// ```dart
  /// void main() async {
  ///   final result =
  ///       await Future.any([slowInt(), delayedString(), fastInt()]);
  ///   // The future of fastInt completes first, others are ignored.
  ///   print(result); // 3
  /// }
  /// Future<int> slowInt() async {
  ///   await Future.delayed(const Duration(seconds: 2));
  ///   return 2;
  /// }
  ///
  /// Future<String> delayedString() async {
  ///   await Future.delayed(const Duration(seconds: 2));
  ///   throw TimeoutException('Time has passed');
  /// }
  ///
  /// Future<int> fastInt() async {
  ///   await Future.delayed(const Duration(seconds: 1));
  ///   return 3;
  /// }
  /// ```
  static Future<T> any<T>(Iterable<Future<T>> futures) {
    var completer = Completer<T>.sync();
    void onValue(T value) {
      if (!completer.isCompleted) completer.complete(value);
    }

    void onError(Object error, StackTrace stack) {
      if (!completer.isCompleted) completer.completeError(error, stack);
    }

    for (var future in futures) {
      future.then(onValue, onError: onError);
    }
    return completer.future;
  }

  /// Performs an action for each element of the iterable, in turn.
  ///
  /// The [action] may be either synchronous or asynchronous.
  ///
  /// Calls [action] with each element in [elements] in order.
  /// If the call to [action] returns a `Future<T>`, the iteration waits
  /// until the future is completed before continuing with the next element.
  ///
  /// Returns a [Future] that completes with `null` when all elements have been
  /// processed.
  ///
  /// Non-[Future] return values, and completion-values of returned [Future]s,
  /// are discarded.
  ///
  /// Any error from [action], synchronous or asynchronous,
  /// will stop the iteration and be reported in the returned [Future].
  static Future<void> forEach<T>(
    Iterable<T> elements,
    FutureOr action(T element),
  ) {
    var iterator = elements.iterator;
    return doWhile(() {
      if (!iterator.moveNext()) return false;
      var result = action(iterator.current);
      if (result is Future) return result.then(_kTrue);
      return true;
    });
  }

  // Constant `true` function, used as callback by [forEach].
  static bool _kTrue(Object? _) => true;

  /// Performs an operation repeatedly until it returns `false`.
  ///
  /// The operation, [action], may be either synchronous or asynchronous.
  ///
  /// The operation is called repeatedly as long as it returns either the [bool]
  /// value `true` or a `Future<bool>` which completes with the value `true`.
  ///
  /// If a call to [action] returns `false` or a [Future] that completes to
  /// `false`, iteration ends and the future returned by [doWhile] is completed
  /// with a `null` value.
  ///
  /// If a call to [action] throws or a future returned by [action] completes
  /// with an error, iteration ends and the future returned by [doWhile]
  /// completes with the same error.
  ///
  /// Calls to [action] may happen at any time,
  /// including immediately after calling `doWhile`.
  /// The only restriction is a new call to [action] won't happen before
  /// the previous call has returned, and if it returned a `Future<bool>`, not
  /// until that future has completed.
  ///
  /// Example:
  /// ```dart
  /// void main() async {
  ///   var value = 0;
  ///   await Future.doWhile(() async {
  ///     value++;
  ///     await Future.delayed(const Duration(seconds: 1));
  ///     if (value == 3) {
  ///       print('Finished with $value');
  ///       return false;
  ///     }
  ///     return true;
  ///   });
  /// }
  /// // Outputs: 'Finished with 3'
  /// ```
  static Future<void> doWhile(FutureOr<bool> action()) {
    @pragma('vm:awaiter-link')
    _Future<void> doneSignal = _Future<void>();
    late void Function(bool) nextIteration;
    // Bind this callback explicitly so that each iteration isn't bound in the
    // context of all the previous iterations' callbacks.
    // This avoids, e.g., deeply nested stack traces from the stack trace
    // package.
    nextIteration = Zone.current.bindUnaryCallbackGuarded((bool keepGoing) {
      while (keepGoing) {
        FutureOr<bool> result;
        try {
          result = action();
        } catch (error, stackTrace) {
          // Cannot use `_completeWithErrorCallback` because it completes
          // the future synchronously.
          doneSignal._asyncCompleteErrorObject(
            _interceptCaughtError(error, stackTrace),
          );
          return;
        }
        if (result is Future<bool>) {
          result.then(nextIteration, onError: doneSignal._completeError);
          return;
        }
        keepGoing = result;
      }
      doneSignal._complete(null);
    });
    nextIteration(true);
    return doneSignal;
  }

  /// Register callbacks to be called when this future completes.
  ///
  /// When this future completes with a value,
  /// the [onValue] callback will be called with that value.
  /// If this future is already completed, the callback will not be called
  /// immediately, but will be scheduled in a later microtask.
  ///
  /// If [onError] is provided, and this future completes with an error,
  /// the `onError` callback is called with that error and its stack trace.
  /// The `onError` callback must accept either one argument or two arguments
  /// where the latter is a [StackTrace].
  /// If `onError` accepts two arguments,
  /// it is called with both the error and the stack trace,
  /// otherwise it is called with just the error object.
  /// The `onError` callback must return a value or future that can be used
  /// to complete the returned future, so it must be something assignable to
  /// `FutureOr<R>`.
  ///
  /// Returns a new [Future]
  /// which is completed with the result of the call to `onValue`
  /// (if this future completes with a value)
  /// or to `onError` (if this future completes with an error).
  ///
  /// If the invoked callback throws,
  /// the returned future is completed with the thrown error
  /// and a stack trace for the error.
  /// In the case of `onError`,
  /// if the exception thrown is `identical` to the error argument to `onError`,
  /// and it is thrown *synchronously*
  /// the throw is considered a rethrow,
  /// and the original stack trace is used instead.
  /// To rethrow with the same stack trace in an asynchronous callback,
  /// use [Error.throwWithStackTrace].
  ///
  /// If the callback returns a [Future],
  /// the future returned by `then` will be completed with
  /// the same result as the future returned by the callback.
  ///
  /// If [onError] is not given, and this future completes with an error,
  /// the error is forwarded directly to the returned future.
  ///
  /// In most cases, it is more readable to use [catchError] separately,
  /// possibly with a `test` parameter,
  /// instead of handling both value and error in a single [then] call.
  ///
  /// Note that futures don't delay reporting of errors until listeners are
  /// added. If the first `then` or `catchError` call happens
  /// after this future has completed with an error,
  /// then the error is reported as unhandled error.
  /// See the description on [Future].
  Future<R> then<R>(FutureOr<R> onValue(T value), {Function? onError});

  /// Handles errors emitted by this [Future].
  ///
  /// This is the asynchronous equivalent of a "catch" block.
  ///
  /// Returns a new [Future] that will be completed with either the result of
  /// this future or the result of calling the `onError` callback.
  ///
  /// If this future completes with a value,
  /// the returned future completes with the same value.
  ///
  /// If this future completes with an error,
  /// then [test] is first called with the error value.
  ///
  /// If `test` returns false, the exception is not handled by this `catchError`,
  /// and the returned future completes with the same error and stack trace
  /// as this future.
  ///
  /// If `test` returns `true`,
  /// [onError] is called with the error and possibly stack trace,
  /// and the returned future is completed with the result of this call
  /// in exactly the same way as for [then]'s `onError`.
  ///
  /// If `test` is omitted, it defaults to a function that always returns true.
  /// The `test` function should not throw, but if it does, it is handled as
  /// if the `onError` function had thrown.
  ///
  /// Note that futures don't delay reporting of errors until listeners are
  /// added. If the first `catchError` (or `then`) call happens after this future
  /// has completed with an error then the error is reported as unhandled error.
  /// See the description on [Future].
  ///
  /// Example:
  /// ```dart
  /// Future.delayed(
  ///   const Duration(seconds: 1),
  ///   () => throw 401,
  /// ).then((value) {
  ///   throw 'Unreachable';
  /// }).catchError((err) {
  ///   print('Error: $err'); // Prints 401.
  /// }, test: (error) {
  ///   return error is int && error >= 400;
  /// });
  /// ```
  // The `Function` below stands for one of two types:
  // - (dynamic) -> FutureOr<T>
  // - (dynamic, StackTrace) -> FutureOr<T>
  // Given that there is a `test` function that is usually used to do an
  // `is` check, we should also expect functions that take a specific argument.
  Future<T> catchError(Function onError, {bool test(Object error)?});

  /// Registers a function to be called when this future completes.
  ///
  /// The [action] function is called when this future completes, whether it
  /// does so with a value or with an error.
  ///
  /// This is the asynchronous equivalent of a "finally" block.
  ///
  /// The future returned by this call, `f`, will complete the same way
  /// as this future unless an error occurs in the [action] call, or in
  /// a [Future] returned by the [action] call. If the call to [action]
  /// does not return a future, its return value is ignored.
  ///
  /// If the call to [action] throws, then `f` is completed with the
  /// thrown error.
  ///
  /// If the call to [action] returns a [Future], `f2`, then completion of
  /// `f` is delayed until `f2` completes. If `f2` completes with
  /// an error, that will be the result of `f` too. The value of `f2` is always
  /// ignored.
  ///
  /// This method is equivalent to:
  /// ```dart
  /// Future<T> whenComplete(action()) {
  ///   return this.then((v) {
  ///     var f2 = action();
  ///     if (f2 is Future) return f2.then((_) => v);
  ///     return v;
  ///   }, onError: (e) {
  ///     var f2 = action();
  ///     if (f2 is Future) return f2.then((_) { throw e; });
  ///     throw e;
  ///   });
  /// }
  /// ```
  /// Example:
  /// ```dart
  /// void main() async {
  ///   var value =
  ///       await waitTask().whenComplete(() => print('do something here'));
  ///   // Prints "do something here" after waitTask() completed.
  ///   print(value); // Prints "done"
  /// }
  ///
  /// Future<String> waitTask() {
  ///   Future.delayed(const Duration(seconds: 5));
  ///   return Future.value('done');
  /// }
  /// // Outputs: 'do some work here' after waitTask is completed.
  /// ```
  Future<T> whenComplete(FutureOr<void> action());

  /// Creates a [Stream] containing the result of this future.
  ///
  /// The stream will produce single data or error event containing the
  /// completion result of this future, and then it will close with a
  /// done event.
  ///
  /// If the future never completes, the stream will not produce any events.
  Stream<T> asStream();

  /// Stop waiting for this future after [timeLimit] has passed.
  ///
  /// Creates a new _timeout future_ that completes
  /// with the same result as this future, the _source future_,
  /// *if* the source future completes in time.
  ///
  /// If the source future does not complete before [timeLimit] has passed,
  /// the [onTimeout] action is executed,
  /// and its result (whether it returns or throws)
  /// is used as the result of the timeout future.
  /// The [onTimeout] function must return a [T] or a `Future<T>`.
  /// If [onTimeout] returns a future, the _alternative result future_,
  /// the eventual result of the alternative result future is used
  /// to complete the timeout future,
  /// even if the source future completes
  /// before the alternative result future.
  /// It only matters that the source future did not complete in time.
  ///
  /// If `onTimeout` is omitted, a timeout will cause the returned future to
  /// complete with a [TimeoutException].
  ///
  /// In either case, the source future can still complete normally
  /// at a later time.
  /// It just won't be used as the result of the timeout future
  /// unless it completes within the time bound.
  /// Even if the source future completes with an error,
  /// if that error happens after [timeLimit] has passed,
  /// the error is ignored, just like a value result would be.
  ///
  /// Examples:
  /// ```dart
  /// void main() async {
  ///   var result =
  ///       await waitTask("completed").timeout(const Duration(seconds: 10));
  ///   print(result); // Prints "completed" after 5 seconds.
  ///
  ///   result = await waitTask("completed")
  ///       .timeout(const Duration(seconds: 1), onTimeout: () => "timeout");
  ///   print(result); // Prints "timeout" after 1 second.
  ///
  ///   result = await waitTask("first").timeout(const Duration(seconds: 2),
  ///       onTimeout: () => waitTask("second"));
  ///   print(result); // Prints "second" after 7 seconds.
  ///
  ///   try {
  ///     await waitTask("completed").timeout(const Duration(seconds: 2));
  ///   } on TimeoutException {
  ///     print("throws"); // Prints "throws" after 2 seconds.
  ///   }
  ///
  ///   var printFuture = waitPrint();
  ///   await printFuture.timeout(const Duration(seconds: 2), onTimeout: () {
  ///     print("timeout"); // Prints "timeout" after 2 seconds.
  ///   });
  ///   await printFuture; // Prints "printed" after additional 3 seconds.
  ///
  ///   try {
  ///     await waitThrow("error").timeout(const Duration(seconds: 2));
  ///   } on TimeoutException {
  ///     print("throws"); // Prints "throws" after 2 seconds.
  ///   }
  ///   // StateError is ignored
  /// }
  ///
  /// /// Returns [string] after five seconds.
  /// Future<String> waitTask(String string) async {
  ///   await Future.delayed(const Duration(seconds: 5));
  ///   return string;
  /// }
  ///
  /// /// Prints "printed" after five seconds.
  /// Future<void> waitPrint() async {
  ///   await Future.delayed(const Duration(seconds: 5));
  ///   print("printed");
  /// }
  /// /// Throws a [StateError] with [message] after five seconds.
  /// Future<void> waitThrow(String message) async {
  ///   await Future.delayed(const Duration(seconds: 5));
  ///   throw Exception(message);
  /// }
  /// ```
  Future<T> timeout(Duration timeLimit, {FutureOr<T> onTimeout()?});
}

/// Explicitly ignores a future.
///
/// Not all futures need to be awaited.
/// The Dart linter has an optional
/// ["unawaited futures" lint](https://dart.dev/lints/unawaited_futures)
/// which enforces that potential futures
/// (expressions with a static type of [Future] or `Future?`)
/// in asynchronous functions are handled *somehow*.
/// If a particular future value doesn't need to be awaited,
/// you can call `unawaited(...)` with it, which will avoid the lint,
/// simply because the expression no longer has type [Future].
/// Using `unawaited` has no other effect.
/// You should use `unawaited` to convey the *intention* of
/// deliberately not waiting for the future.
///
/// If the future completes with an error,
/// it was likely a mistake to not await it.
/// That error will still occur and will be considered unhandled
/// unless the same future is awaited (or otherwise handled) elsewhere too.
/// Because of that, `unawaited` should only be used for futures that
/// are *expected* to complete with a value.
/// You can use [FutureExtensions.ignore] if you also don't want to know
/// about errors from this future.
@Since("2.15")
void unawaited(Future<void>? future) {}

/// Convenience methods on futures.
///
/// Adds functionality to futures which makes it easier to
/// write well-typed asynchronous code.
extension FutureExtensions<T> on Future<T> {
  /// Handles errors on this future.
  ///
  /// Catches errors of type [E] that this future complete with.
  /// If [test] is supplied, only catches errors of type [E]
  /// where [test] returns `true`.
  /// If [E] is [Object], then all errors are potentially caught,
  /// depending only on a supplied [test].
  ///
  /// If the error is caught,
  /// the returned future completes with the result of calling [handleError]
  /// with the error and stack trace.
  /// This result must be a value of the same type that this future
  /// could otherwise complete with.
  /// For example, if this future cannot complete with `null`,
  /// then [handleError] also cannot return `null`.
  /// Example:
  /// ```dart
  /// Future<T> retryOperation<T>(Future<T> operation(), T onFailure()) =>
  ///     operation().onError<RetryException>((e, s) {
  ///       if (e.canRetry) {
  ///         return retryOperation(operation, onFailure);
  ///       }
  ///       return onFailure();
  ///     });
  /// ```
  ///
  /// If [handleError] throws, the returned future completes
  /// with the thrown error and stack trace,
  /// except that if it throws the *same* error object again,
  /// then it is considered a "rethrow"
  /// and the original stack trace is retained.
  /// This can be used as an alternative to skipping the
  /// error in [test].
  /// Example:
  /// ```dart
  /// // Unwraps an exceptions cause, if it has one.
  /// someFuture.onError<SomeException>((e, _) {
  ///   throw e.cause ?? e;
  /// });
  /// // vs.
  /// someFuture.onError<SomeException>((e, _) {
  ///   throw e.cause!;
  /// }, test: (e) => e.cause != null);
  /// ```
  ///
  /// If the error is not caught, the returned future
  /// completes with the same result, value or error,
  /// as this future.
  ///
  /// This method is effectively a more precisely typed version
  /// of [Future.catchError].
  /// It makes it easy to catch specific error types,
  /// and requires a correctly typed error handler function,
  /// rather than just [Function].
  /// Because of this, the error handlers must accept
  /// the stack trace argument.
  Future<T> onError<E extends Object>(
    FutureOr<T> handleError(E error, StackTrace stackTrace), {
    bool test(E error)?,
  }) {
    FutureOr<T> onError(Object error, StackTrace stackTrace) {
      if (error is! E || test != null && !test(error)) {
        // Counts as rethrow, preserves stack trace.
        throw error;
      }
      return handleError(error, stackTrace);
    }

    if (this is _Future<Object?>) {
      // Internal method working like `catchError`,
      // but allows specifying a different result future type.
      return unsafeCast<_Future<T>>(this)._safeOnError<T>(onError);
    }

    return this.then<T>((T value) => value, onError: onError);
  }

  /// Completely ignores this future and its result.
  ///
  /// Not all futures are important, not even if they contain errors,
  /// for example if a request was made, but the response is no longer needed.
  /// Simply ignoring a future can result in uncaught asynchronous errors.
  /// This method instead handles (and ignores) any values or errors
  /// coming from this future, making it safe to otherwise ignore
  /// the future.
  ///
  /// Use `ignore` to signal that the result of the future is
  /// no longer important to the program, not even if it's an error.
  /// If you merely want to silence the
  /// ["unawaited futures" lint](https://dart.dev/lints/unawaited_futures),
  /// use the [unawaited] function instead.
  /// That will ensure that an unexpected error is still reported.
  @Since("2.14")
  void ignore() {
    var self = this;
    if (self is _Future<T>) {
      self._ignore();
    } else {
      self.then<void>(_ignore, onError: _ignore);
    }
  }

  static void _ignore(Object? _, [Object? __]) {}
}

/// Thrown when a scheduled timeout happens while waiting for an async result.
class TimeoutException implements Exception {
  /// Description of the cause of the timeout.
  final String? message;

  /// The duration that was exceeded.
  final Duration? duration;

  TimeoutException(this.message, [this.duration]);

  String toString() {
    String result = "TimeoutException";
    if (duration != null) result = "TimeoutException after $duration";
    if (message != null) result = "$result: $message";
    return result;
  }
}

/// A way to produce Future objects and to complete them later
/// with a value or error.
///
/// Most of the time, the simplest way to create a future is to just use
/// one of the [Future] constructors to capture the result of a single
/// asynchronous computation:
/// ```dart
/// Future(() { doSomething(); return result; });
/// ```
/// or, if the future represents the result of a sequence of asynchronous
/// computations, they can be chained using [Future.then] or similar functions
/// on [Future]:
/// ```dart
/// Future doStuff(){
///   return someAsyncOperation().then((result) {
///     return someOtherAsyncOperation(result);
///   });
/// }
/// ```
/// If you do need to create a Future from scratch — for example,
/// when you're converting a callback-based API into a Future-based
/// one — you can use a Completer as follows:
/// ```dart
/// class AsyncOperation {
///   final Completer _completer = new Completer();
///
///   Future<T> doOperation() {
///     _startOperation();
///     return _completer.future; // Send future object back to client.
///   }
///
///   // Something calls this when the value is ready.
///   void _finishOperation(T result) {
///     _completer.complete(result);
///   }
///
///   // If something goes wrong, call this.
///   void _errorHappened(error) {
///     _completer.completeError(error);
///   }
/// }
/// ```
@vmIsolateUnsendable
abstract interface class Completer<T> {
  /// Creates a new completer.
  ///
  /// The general workflow for creating a new future is to 1) create a
  /// new completer, 2) hand out its future, and, at a later point, 3) invoke
  /// either [complete] or [completeError].
  ///
  /// The completer completes the future asynchronously. That means that
  /// callbacks registered on the future are not called immediately when
  /// [complete] or [completeError] is called. Instead the callbacks are
  /// delayed until a later microtask.
  ///
  /// Example:
  /// ```dart
  /// var completer = new Completer();
  /// handOut(completer.future);
  /// later: {
  ///   completer.complete('completion value');
  /// }
  /// ```
  factory Completer() => _AsyncCompleter<T>();

  /// Completes the future synchronously.
  ///
  /// This constructor should be avoided unless the completion of the future is
  /// known to be the final result of another asynchronous operation. If in doubt
  /// use the default [Completer] constructor.
  ///
  /// Using an normal, asynchronous, completer will never give the wrong
  /// behavior, but using a synchronous completer incorrectly can cause
  /// otherwise correct programs to break.
  ///
  /// A synchronous completer is only intended for optimizing event
  /// propagation when one asynchronous event immediately triggers another.
  /// It should not be used unless the calls to [complete] and [completeError]
  /// are guaranteed to occur in places where it won't break `Future` invariants.
  ///
  /// Completing synchronously means that the completer's future will be
  /// completed immediately when calling the [complete] or [completeError]
  /// method on a synchronous completer, which also calls any callbacks
  /// registered on that future.
  ///
  /// Completing synchronously must not break the rule that when you add a
  /// callback on a future, that callback must not be called until the code
  /// that added the callback has completed.
  /// For that reason, a synchronous completion must only occur at the very end
  /// (in "tail position") of another synchronous event,
  /// because at that point, completing the future immediately is be equivalent
  /// to returning to the event loop and completing the future in the next
  /// microtask.
  ///
  /// Example:
  /// ```dart
  /// var completer = Completer.sync();
  /// // The completion is the result of the asynchronous onDone event.
  /// // No other operation is performed after the completion. It is safe
  /// // to use the Completer.sync constructor.
  /// stream.listen(print, onDone: () { completer.complete("done"); });
  /// ```
  /// Bad example. Do not use this code. Only for illustrative purposes:
  /// ```dart
  /// var completer = Completer.sync();
  /// completer.future.then((_) { bar(); });
  /// // The completion is the result of the asynchronous onDone event.
  /// // However, there is still code executed after the completion. This
  /// // operation is *not* safe.
  /// stream.listen(print, onDone: () {
  ///   completer.complete("done");
  ///   foo();  // In this case, foo() runs after bar().
  /// });
  /// ```
  factory Completer.sync() => _SyncCompleter<T>();

  /// The future that is completed by this completer.
  ///
  /// The future that is completed when [complete] or [completeError] is called.
  Future<T> get future;

  /// Completes [future] with the supplied values.
  ///
  /// The value must be either a value of type [T]
  /// or a future of type `Future<T>`.
  /// If the value is omitted or `null`, and `T` is not nullable, the call
  /// to `complete` throws.
  ///
  /// If the value is itself a future, the completer will wait for that future
  /// to complete, and complete with the same result, whether it is a success
  /// or an error.
  ///
  /// Calling [complete] or [completeError] must be done at most once.
  ///
  /// All listeners on the future are informed about the value.
  void complete([FutureOr<T>? value]);

  /// Complete [future] with an error.
  ///
  /// Calling [complete] or [completeError] must be done at most once.
  ///
  /// Completing a future with an error indicates that an exception was thrown
  /// while trying to produce a value.
  ///
  /// If [error] is a [Future], the future itself is used as the error value.
  /// If you want to complete with the result of the future, you can use:
  /// ```dart
  /// thisCompleter.complete(theFuture)
  /// ```
  /// or if you only want to handle an error from the future:
  /// ```dart
  /// theFuture.catchError(thisCompleter.completeError);
  /// ```
  ///
  /// The [future] must have an error handler installed before the call to
  /// [completeError]) or [error] will be considered an uncaught error.
  ///
  /// ```dart
  /// void doStuff() {
  ///   // Outputs a message like:
  ///   // Uncaught Error: Assertion failed: "future not consumed"
  ///   Completer().completeError(AssertionError('future not consumed'));
  /// }
  /// ```
  ///
  /// You can install an error handler through [Future.catchError],
  /// [Future.then] or the `await` operation.
  ///
  /// ```dart
  /// void doStuff() {
  ///   final c = Completer();
  ///   c.future.catchError((e) {
  ///     // Handle the error.
  ///   });
  ///   c.completeError(AssertionError('future not consumed'));
  /// }
  /// ```
  ///
  /// See the
  /// [Zones article](https://dart.dev/articles/archive/zones#handling-uncaught-errors)
  /// for details on uncaught errors.
  void completeError(Object error, [StackTrace? stackTrace]);

  /// Whether the [future] has been completed.
  ///
  /// Reflects whether [complete] or [completeError] has been called.
  /// A `true` value doesn't necessarily mean that listeners of this future
  /// have been invoked yet, either because the completer usually waits until
  /// a later microtask to propagate the result, or because [complete]
  /// was called with a future that hasn't completed yet.
  ///
  /// When this value is `true`, [complete] and [completeError] must not be
  /// called again.
  bool get isCompleted;
}

// Helper function completing a _Future with an error, but checking the zone
// for error replacement and missing stack trace first.
// Only used for errors that are *caught*.
// A user provided error object should use `_interceptUserError` which
// also sets `Error.stackTrace`.
void _completeWithErrorCallback(
  _Future result,
  Object error,
  StackTrace stackTrace,
) {
  result._completeErrorObject(_interceptCaughtError(error, stackTrace));
}
```

// ============================================================
// 🔧 Core Dart: iterable.dart
// 📁 /home/user/flutter/bin/cache/pkg/sky_engine/lib/core/iterable.dart
// ============================================================

```dart
// Copyright (c) 2011, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of "dart:core";

/// A collection of values, or "elements", that can be accessed sequentially.
///
/// The elements of the iterable are accessed by getting an [Iterator]
/// using the [iterator] getter, and using it to step through the values.
/// Stepping with the iterator is done by calling [Iterator.moveNext],
/// and if the call returns `true`,
/// the iterator has now moved to the next element,
/// which is then available as [Iterator.current].
/// If the call returns `false`, there are no more elements.
/// The [Iterator.current] value must only be used when the most
/// recent call to [Iterator.moveNext] has returned `true`.
/// If it is used before calling [Iterator.moveNext] the first time
/// on an iterator, or after a call has returned false or has thrown an error,
/// reading [Iterator.current] may throw or may return an arbitrary value.
///
/// You can create more than one iterator from the same `Iterable`.
/// Each time `iterator` is read, it returns a new iterator,
/// and different iterators can be stepped through independently,
/// each giving access to all the elements of the iterable.
/// The iterators of the same iterable *should* provide the same values
/// in the same order (unless the underlying collection is modified between
/// the iterations, which some collections allow).
///
/// You can also iterate over the elements of an `Iterable`
/// using the for-in loop construct, which uses the `iterator` getter behind the
/// scenes.
/// For example, you can iterate over all of the keys of a [Map],
/// because `Map` keys are iterable.
/// ```dart
/// var kidsBooks = {'Matilda': 'Roald Dahl',
///                  'Green Eggs and Ham': 'Dr Seuss',
///                  'Where the Wild Things Are': 'Maurice Sendak'};
/// for (var book in kidsBooks.keys) {
///   print('$book was written by ${kidsBooks[book]}');
/// }
/// ```
/// The [List] and [Set] classes are both `Iterable`,
/// as are most classes in the `dart:collection` library.
///
/// Some [Iterable] collections can be modified.
/// Adding an element to a `List` or `Set` will change which elements it
/// contains, and adding a new key to a `Map` changes the elements of [Map.keys].
/// Iterators created after the change will provide the new elements, and may
/// or may not preserve the order of existing elements
/// (for example, a [HashSet] may completely change its order when a single
/// element is added).
///
/// Changing a collection *while* it is being iterated
/// is generally *not* allowed.
/// Doing so will break the iteration, which is typically signalled
/// by throwing a [ConcurrentModificationError]
/// the next time [Iterator.moveNext] is called.
/// The current value of [Iterator.current] getter
/// should not be affected by the change in the collection,
/// the `current` value was set by the previous call to [Iterator.moveNext].
///
/// Some iterables compute their elements dynamically every time they are
/// iterated, like the one returned by [Iterable.generate] or the iterable
/// returned by a `sync*` generator function. If the computation doesn't depend
/// on other objects that may change, then the generated sequence should be
/// the same one every time it's iterated.
///
/// The members of `Iterable`, other than `iterator` itself,
/// work by looking at the elements of the iterable.
/// This can be implemented by running through the [iterator], but some classes
/// may have more efficient ways of finding the result
/// (like [last] or [length] on a [List], or [contains] on a [Set]).
///
/// The methods that return another `Iterable` (like [map] and [where])
/// are all *lazy* - they will iterate the original (as necessary)
/// every time the returned iterable is iterated, and not before.
///
/// Since an iterable may be iterated more than once, it's not recommended to
/// have detectable side-effects in the iterator.
/// For methods like [map] and [where], the returned iterable will execute the
/// argument function on every iteration, so those functions should also not
/// have side effects.
///
/// The `Iterable` declaration provides a default implementation,
/// which can be extended or mixed in to implement the `Iterable` interface.
/// It implements every member other than the [iterator] getter,
/// using the [Iterator] provided by [iterator].
/// An implementation of the `Iterable` interface should
/// provide a more efficient implementation of the members of `Iterable`
/// when it can do so.
abstract mixin class Iterable<E> {
  // This class has methods copied verbatim into:
  // - SetMixin
  // If changing a method here, also change other copies.

  const Iterable();

  /// Creates an `Iterable` which generates its elements dynamically.
  ///
  /// The generated iterable has [count] elements,
  /// and the element at index `n` is computed by calling `generator(n)`.
  /// Values are not cached, so each iteration computes the values again.
  ///
  /// If [generator] is omitted, it defaults to an identity function
  /// on integers `(int x) => x`, so it may only be omitted if the type
  /// parameter allows integer values. That is, if [E] is a super-type
  /// of [int].
  ///
  /// As an `Iterable`, `Iterable.generate(n, generator))` is equivalent to
  /// `const [0, ..., n - 1].map(generator)`.
  factory Iterable.generate(int count, [E generator(int index)?]) {
    // Always OK to omit generator when count is zero.
    if (count <= 0) return EmptyIterable<E>();
    if (generator == null) {
      // If generator is omitted, we generate integers.
      // If `E` does not allow integers, it's an error.
      Function id = _GeneratorIterable._id;
      if (id is! E Function(int)) {
        throw ArgumentError(
          "Generator must be supplied or element type must allow integers",
          "generator",
        );
      }
      generator = id;
    }
    return _GeneratorIterable<E>(count, generator);
  }

  /// Creates an [Iterable] from the [Iterator] factory.
  ///
  /// The returned iterable creates a new iterator each time [iterator] is read,
  /// by calling the provided [iteratorFactory] function. The [iteratorFactory]
  /// function must return a new instance of `Iterator<E>` on each call.
  ///
  /// This factory is useful when you need to create an iterable from a custom
  /// iterator, or when you want to ensure a fresh iteration state on each use.
  ///
  /// Example:
  /// ```dart
  /// final numbers = Iterable.withIterator(() => [1, 2, 3].iterator);
  /// print(numbers.toList()); // [1, 2, 3]
  /// ```
  @Since("3.8")
  factory Iterable.withIterator(Iterator<E> Function() iteratorFactory) =
      _WithIteratorIterable<E>;

  /// Creates an empty iterable.
  ///
  /// The empty iterable has no elements, and iterating it always stops
  /// immediately.
  const factory Iterable.empty() = EmptyIterable<E>;

  /// Adapts [source] to be an `Iterable<T>`.
  ///
  /// Any time the iterable would produce an element that is not a [T],
  /// the element access will throw. If all elements of [source] are actually
  /// instances of [T], or if only elements that are actually instances of [T]
  /// are accessed, then the resulting iterable can be used as an `Iterable<T>`.
  static Iterable<T> castFrom<S, T>(Iterable<S> source) =>
      CastIterable<S, T>(source);

  /// A new `Iterator` that allows iterating the elements of this `Iterable`.
  ///
  /// Iterable classes may specify the iteration order of their elements
  /// (for example [List] always iterate in index order),
  /// or they may leave it unspecified (for example a hash-based [Set]
  /// may iterate in any order).
  ///
  /// Each time `iterator` is read, it returns a new iterator,
  /// which can be used to iterate through all the elements again.
  /// The iterators of the same iterable can be stepped through independently,
  /// but should return the same elements in the same order,
  /// as long as the underlying collection isn't changed.
  ///
  /// Modifying the collection may cause new iterators to produce
  /// different elements, and may change the order of existing elements.
  /// A [List] specifies its iteration order precisely,
  /// so modifying the list changes the iteration order predictably.
  /// A hash-based [Set] may change its iteration order completely
  /// when adding a new element to the set.
  ///
  /// Modifying the underlying collection after creating the new iterator
  /// may cause an error the next time [Iterator.moveNext] is called
  /// on that iterator.
  /// Any *modifiable* iterable class should specify which operations will
  /// break iteration.
  Iterator<E> get iterator;

  /// A view of this iterable as an iterable of [R] instances.
  ///
  /// If this iterable only contains instances of [R], all operations
  /// will work correctly. If any operation tries to access an element
  /// that is not an instance of [R], the access will throw instead.
  ///
  /// When the returned iterable creates a new object that depends on
  /// the type [R], e.g., from [toList], it will have exactly the type [R].
  Iterable<R> cast<R>() => CastIterable<E, R>(this);

  /// Creates the lazy concatenation of this iterable and [other].
  ///
  /// The returned iterable will provide the same elements as this iterable,
  /// and, after that, the elements of [other], in the same order as in the
  /// original iterables.
  ///
  /// Example:
  /// ```dart
  /// var planets = <String>['Earth', 'Jupiter'];
  /// var updated = planets.followedBy(['Mars', 'Venus']);
  /// print(updated); // (Earth, Jupiter, Mars, Venus)
  /// ```
  Iterable<E> followedBy(Iterable<E> other) {
    var self = this; // TODO(lrn): Remove when we can promote `this`.
    if (self is EfficientLengthIterable<E>) {
      return FollowedByIterable<E>.firstEfficient(self, other);
    }
    return FollowedByIterable<E>(this, other);
  }

  /// The current elements of this iterable modified by [toElement].
  ///
  /// Returns a new lazy [Iterable] with elements that are created by
  /// calling `toElement` on each element of this `Iterable` in
  /// iteration order.
  ///
  /// The returned iterable is lazy, so it won't iterate the elements of
  /// this iterable until it is itself iterated, and then it will apply
  /// [toElement] to create one element at a time.
  /// The converted elements are not cached.
  /// Iterating multiple times over the returned [Iterable]
  /// will invoke the supplied [toElement] function once per element
  /// for on each iteration.
  ///
  /// Methods on the returned iterable are allowed to omit calling `toElement`
  /// on any element where the result isn't needed.
  /// For example, [elementAt] may call `toElement` only once.
  ///
  /// Equivalent to:
  /// ```
  /// Iterable<T> map<T>(T toElement(E e)) sync* {
  ///   for (var value in this) {
  ///     yield toElement(value);
  ///   }
  /// }
  /// ```
  /// Example:
  /// ```dart import:convert
  /// var products = jsonDecode('''
  /// [
  ///   {"name": "Screwdriver", "price": 42.00},
  ///   {"name": "Wingnut", "price": 0.50}
  /// ]
  /// ''');
  /// var values = products.map((product) => product['price'] as double);
  /// var totalPrice = values.fold(0.0, (a, b) => a + b); // 42.5.
  /// ```
  Iterable<T> map<T>(T toElement(E e)) => MappedIterable<E, T>(this, toElement);

  /// Creates a new lazy [Iterable] with all elements that satisfy the
  /// predicate [test].
  ///
  /// The matching elements have the same order in the returned iterable
  /// as they have in [iterator].
  ///
  /// This method returns a view of the mapped elements.
  /// As long as the returned [Iterable] is not iterated over,
  /// the supplied function [test] will not be invoked.
  /// Iterating will not cache results, and thus iterating multiple times over
  /// the returned [Iterable] may invoke the supplied
  /// function [test] multiple times on the same element.
  ///
  /// Example:
  /// ```dart
  /// final numbers = <int>[1, 2, 3, 5, 6, 7];
  /// var result = numbers.where((x) => x < 5); // (1, 2, 3)
  /// result = numbers.where((x) => x > 5); // (6, 7)
  /// result = numbers.where((x) => x.isEven); // (2, 6)
  /// ```
  Iterable<E> where(bool test(E element)) => WhereIterable<E>(this, test);

  /// Creates a new lazy [Iterable] with all elements that have type [T].
  ///
  /// The matching elements have the same order in the returned iterable
  /// as they have in [iterator].
  ///
  /// This method returns a view of the mapped elements.
  /// Iterating will not cache results, and thus iterating multiple times over
  /// the returned [Iterable] may yield different results,
  /// if the underlying elements change between iterations.
  Iterable<T> whereType<T>() => WhereTypeIterable<T>(this);

  /// Expands each element of this [Iterable] into zero or more elements.
  ///
  /// The resulting Iterable runs through the elements returned
  /// by [toElements] for each element of this, in iteration order.
  ///
  /// The returned [Iterable] is lazy, and calls [toElements] for each element
  /// of this iterable every time the returned iterable is iterated.
  ///
  /// Example:
  /// ```dart
  /// Iterable<int> count(int n) sync* {
  ///   for (var i = 1; i <= n; i++) {
  ///     yield i;
  ///    }
  ///  }
  ///
  /// var numbers = [1, 3, 0, 2];
  /// print(numbers.expand(count)); // (1, 1, 2, 3, 1, 2)
  /// ```
  ///
  /// Equivalent to:
  /// ```
  /// Iterable<T> expand<T>(Iterable<T> toElements(E e)) sync* {
  ///   for (var value in this) {
  ///     yield* toElements(value);
  ///   }
  /// }
  /// ```
  Iterable<T> expand<T>(Iterable<T> toElements(E element)) =>
      ExpandIterable<E, T>(this, toElements);

  /// Whether the collection contains an element equal to [element].
  ///
  /// This operation will check each element in order for being equal to
  /// [element], unless it has a more efficient way to find an element
  /// equal to [element].
  /// Stops iterating on the first equal element.
  ///
  /// The equality used to determine whether [element] is equal to an element of
  /// the iterable defaults to the [Object.==] of the element.
  ///
  /// Some types of iterable may have a different equality used for its elements.
  /// For example, a [Set] may have a custom equality
  /// (see [Set.identity]) that its `contains` uses.
  /// Likewise the `Iterable` returned by a [Map.keys] call
  /// should use the same equality that the `Map` uses for keys.
  ///
  /// Example:
  /// ```dart
  /// final gasPlanets = <int, String>{1: 'Jupiter', 2: 'Saturn'};
  /// final containsOne = gasPlanets.keys.contains(1); // true
  /// final containsFive = gasPlanets.keys.contains(5); // false
  /// final containsJupiter = gasPlanets.values.contains('Jupiter'); // true
  /// final containsMercury = gasPlanets.values.contains('Mercury'); // false
  /// ```
  bool contains(Object? element) {
    for (E e in this) {
      if (e == element) return true;
    }
    return false;
  }

  /// Invokes [action] on each element of this iterable in iteration order.
  ///
  /// Example:
  /// ```dart
  /// final numbers = <int>[1, 2, 6, 7];
  /// numbers.forEach(print);
  /// // 1
  /// // 2
  /// // 6
  /// // 7
  /// ```
  void forEach(void action(E element)) {
    for (E element in this) action(element);
  }

  /// Reduces a collection to a single value by iteratively combining elements
  /// of the collection using the provided function.
  ///
  /// The iterable must have at least one element.
  /// If it has only one element, that element is returned.
  ///
  /// Otherwise this method starts with the first element from the iterator,
  /// and then combines it with the remaining elements in iteration order,
  /// as if by:
  /// ```
  /// E value = iterable.first;
  /// iterable.skip(1).forEach((element) {
  ///   value = combine(value, element);
  /// });
  /// return value;
  /// ```
  /// Example of calculating the sum of an iterable:
  /// ```dart
  /// final numbers = <double>[10, 2, 5, 0.5];
  /// final result = numbers.reduce((value, element) => value + element);
  /// print(result); // 17.5
  /// ```
  /// Consider using [fold] if the iterable can be empty.
  E reduce(E combine(E value, E element)) {
    Iterator<E> iterator = this.iterator;
    if (!iterator.moveNext()) {
      throw IterableElementError.noElement();
    }
    E value = iterator.current;
    while (iterator.moveNext()) {
      value = combine(value, iterator.current);
    }
    return value;
  }

  /// Reduces a collection to a single value by iteratively combining each
  /// element of the collection with an existing value
  ///
  /// Uses [initialValue] as the initial value,
  /// then iterates through the elements and updates the value with
  /// each element using the [combine] function, as if by:
  /// ```
  /// var value = initialValue;
  /// for (E element in this) {
  ///   value = combine(value, element);
  /// }
  /// return value;
  /// ```
  /// Example of calculating the sum of an iterable:
  /// ```dart
  /// final numbers = <double>[10, 2, 5, 0.5];
  /// const initialValue = 100.0;
  /// final result = numbers.fold<double>(
  ///     initialValue, (previousValue, element) => previousValue + element);
  /// print(result); // 117.5
  /// ```
  T fold<T>(T initialValue, T combine(T previousValue, E element)) {
    var value = initialValue;
    for (E element in this) value = combine(value, element);
    return value;
  }

  /// Checks whether every element of this iterable satisfies [test].
  ///
  /// Checks every element in iteration order, and returns `false` if
  /// any of them make [test] return `false`, otherwise returns `true`.
  /// Returns `true` if the iterable is empty.
  ///
  /// Example:
  /// ```dart
  /// final planetsByMass = <double, String>{0.06: 'Mercury', 0.81: 'Venus',
  ///   0.11: 'Mars'};
  /// // Checks whether all keys are smaller than 1.
  /// final every = planetsByMass.keys.every((key) => key < 1.0); // true
  /// ```
  bool every(bool test(E element)) {
    for (E element in this) {
      if (!test(element)) return false;
    }
    return true;
  }

  /// Converts each element to a [String] and concatenates the strings.
  ///
  /// Iterates through elements of this iterable,
  /// converts each one to a [String] by calling [Object.toString],
  /// and then concatenates the strings, with the
  /// [separator] string interleaved between the elements.
  ///
  /// Example:
  /// ```dart
  /// final planetsByMass = <double, String>{0.06: 'Mercury', 0.81: 'Venus',
  ///   0.11: 'Mars'};
  /// final joinedNames = planetsByMass.values.join('-'); // Mercury-Venus-Mars
  /// ```
  String join([String separator = ""]) {
    Iterator<E> iterator = this.iterator;
    if (!iterator.moveNext()) return "";
    var first = iterator.current.toString();
    if (!iterator.moveNext()) return first;
    var buffer = StringBuffer(first);
    // TODO(51681): Drop null check when de-supporting pre-2.12 code.
    if (separator == null || separator.isEmpty) {
      do {
        buffer.write(iterator.current.toString());
      } while (iterator.moveNext());
    } else {
      do {
        buffer
          ..write(separator)
          ..write(iterator.current.toString());
      } while (iterator.moveNext());
    }
    return buffer.toString();
  }

  /// Checks whether any element of this iterable satisfies [test].
  ///
  /// Checks every element in iteration order, and returns `true` if
  /// any of them make [test] return `true`, otherwise returns false.
  /// Returns `false` if the iterable is empty.
  ///
  /// Example:
  /// ```dart
  /// final numbers = <int>[1, 2, 3, 5, 6, 7];
  /// var result = numbers.any((element) => element >= 5); // true;
  /// result = numbers.any((element) => element >= 10); // false;
  /// ```
  bool any(bool test(E element)) {
    for (E element in this) {
      if (test(element)) return true;
    }
    return false;
  }

  /// Creates a [List] containing the elements of this [Iterable].
  ///
  /// The elements are in iteration order.
  /// The list is fixed-length if [growable] is false.
  ///
  /// Example:
  /// ```dart
  /// final planets = <int, String>{1: 'Mercury', 2: 'Venus', 3: 'Mars'};
  /// final keysList = planets.keys.toList(growable: false); // [1, 2, 3]
  /// final valuesList =
  ///     planets.values.toList(growable: false); // [Mercury, Venus, Mars]
  /// ```
  List<E> toList({bool growable = true}) =>
      List<E>.of(this, growable: growable);

  /// Creates a [Set] containing the same elements as this iterable.
  ///
  /// The set may contain fewer elements than the iterable,
  /// if the iterable contains an element more than once,
  /// or it contains one or more elements that are equal.
  /// The order of the elements in the set is not guaranteed to be the same
  /// as for the iterable.
  ///
  /// Example:
  /// ```dart
  /// final planets = <int, String>{1: 'Mercury', 2: 'Venus', 3: 'Mars'};
  /// final valueSet = planets.values.toSet(); // {Mercury, Venus, Mars}
  /// ```
  Set<E> toSet() => Set<E>.of(this);

  /// The number of elements in this [Iterable].
  ///
  /// Counting all elements may involve iterating through all elements and can
  /// therefore be slow.
  /// Some iterables have a more efficient way to find the number of elements.
  /// These *must* override the default implementation of `length`.
  int get length {
    assert(this is! EfficientLengthIterable);
    int count = 0;
    Iterator<Object?> it = iterator;
    while (it.moveNext()) {
      count++;
    }
    return count;
  }

  /// Whether this collection has no elements.
  ///
  /// May be computed by checking if `iterator.moveNext()` returns `false`.
  ///
  /// Example:
  /// ```dart
  /// final emptyList = <int>[];
  /// print(emptyList.isEmpty); // true;
  /// print(emptyList.iterator.moveNext()); // false
  /// ```
  bool get isEmpty => !iterator.moveNext();

  /// Whether this collection has at least one element.
  ///
  /// May be computed by checking if `iterator.moveNext()` returns `true`.
  ///
  /// Example:
  /// ```dart
  /// final numbers = <int>{1, 2, 3};
  /// print(numbers.isNotEmpty); // true;
  /// print(numbers.iterator.moveNext()); // true
  /// ```
  bool get isNotEmpty => !isEmpty;

  /// Creates a lazy iterable of the [count] first elements of this iterable.
  ///
  /// The returned `Iterable` may contain fewer than `count` elements, if `this`
  /// contains fewer than `count` elements.
  ///
  /// The elements can be computed by stepping through [iterator] until [count]
  /// elements have been seen.
  ///
  /// The `count` must not be negative.
  ///
  /// Example:
  /// ```dart
  /// final numbers = <int>[1, 2, 3, 5, 6, 7];
  /// final result = numbers.take(4); // (1, 2, 3, 5)
  /// final takeAll = numbers.take(100); // (1, 2, 3, 5, 6, 7)
  /// ```
  Iterable<E> take(int count) => TakeIterable<E>(this, count);

  /// Creates a lazy iterable of the leading elements satisfying [test].
  ///
  /// The filtering happens lazily. Every new iterator of the returned
  /// iterable starts iterating over the elements of `this`.
  ///
  /// The elements can be computed by stepping through [iterator] until an
  /// element is found where `test(element)` is false. At that point,
  /// the returned iterable stops (its `moveNext()` returns false).
  ///
  /// Example:
  /// ```dart
  /// final numbers = <int>[1, 2, 3, 5, 6, 7];
  /// var result = numbers.takeWhile((x) => x < 5); // (1, 2, 3)
  /// result = numbers.takeWhile((x) => x != 3); // (1, 2)
  /// result = numbers.takeWhile((x) => x != 4); // (1, 2, 3, 5, 6, 7)
  /// result = numbers.takeWhile((x) => x.isOdd); // (1)
  /// ```
  Iterable<E> takeWhile(bool test(E value)) => TakeWhileIterable<E>(this, test);

  /// Creates an [Iterable] that provides all but the first [count] elements.
  ///
  /// When the returned iterable is iterated, it starts iterating over `this`,
  /// first skipping past the initial [count] elements.
  /// If `this` has fewer than `count` elements, then the resulting Iterable is
  /// empty.
  /// After that, the remaining elements are iterated in the same order as
  /// in this iterable.
  ///
  /// Some iterables may be able to find later elements without first iterating
  /// through earlier elements, for example when iterating a [List].
  /// Such iterables are allowed to ignore the initial skipped elements.
  ///
  /// Example:
  /// ```dart
  /// final numbers = <int>[1, 2, 3, 5, 6, 7];
  /// final result = numbers.skip(4); // (6, 7)
  /// final skipAll = numbers.skip(100); // () - no elements.
  /// ```
  ///
  /// The [count] must not be negative.
  Iterable<E> skip(int count) => SkipIterable<E>(this, count);

  /// Creates an `Iterable` that skips leading elements while [test] is satisfied.
  ///
  /// The filtering happens lazily. Every new [Iterator] of the returned
  /// iterable iterates over all elements of `this`.
  ///
  /// The returned iterable provides elements by iterating this iterable,
  /// but skipping over all initial elements where `test(element)` returns
  /// true. If all elements satisfy `test` the resulting iterable is empty,
  /// otherwise it iterates the remaining elements in their original order,
  /// starting with the first element for which `test(element)` returns `false`.
  ///
  /// Example:
  /// ```dart
  /// final numbers = <int>[1, 2, 3, 5, 6, 7];
  /// var result = numbers.skipWhile((x) => x < 5); // (5, 6, 7)
  /// result = numbers.skipWhile((x) => x != 3); // (3, 5, 6, 7)
  /// result = numbers.skipWhile((x) => x != 4); // ()
  /// result = numbers.skipWhile((x) => x.isOdd); // (2, 3, 5, 6, 7)
  /// ```
  Iterable<E> skipWhile(bool test(E value)) => SkipWhileIterable<E>(this, test);

  /// The first element.
  ///
  /// Throws a [StateError] if `this` is empty.
  /// Otherwise returns the first element in the iteration order,
  /// equivalent to `this.elementAt(0)`.
  E get first {
    Iterator<E> it = iterator;
    if (!it.moveNext()) {
      throw IterableElementError.noElement();
    }
    return it.current;
  }

  /// The last element.
  ///
  /// Throws a [StateError] if `this` is empty.
  /// Otherwise may iterate through the elements and returns the last one
  /// seen.
  /// Some iterables may have more efficient ways to find the last element
  /// (for example a list can directly access the last element,
  /// without iterating through the previous ones).
  E get last {
    Iterator<E> it = iterator;
    if (!it.moveNext()) {
      throw IterableElementError.noElement();
    }
    E result;
    do {
      result = it.current;
    } while (it.moveNext());
    return result;
  }

  /// Checks that this iterable has only one element, and returns that element.
  ///
  /// Throws a [StateError] if `this` is empty or has more than one element.
  /// This operation will not iterate past the second element.
  E get single {
    Iterator<E> it = iterator;
    if (!it.moveNext()) throw IterableElementError.noElement();
    E result = it.current;
    if (it.moveNext()) throw IterableElementError.tooMany();
    return result;
  }

  /// The first element that satisfies the given predicate [test].
  ///
  /// Iterates through elements and returns the first to satisfy [test].
  ///
  /// Example:
  /// ```dart
  /// final numbers = <int>[1, 2, 3, 5, 6, 7];
  /// var result = numbers.firstWhere((element) => element < 5); // 1
  /// result = numbers.firstWhere((element) => element > 5); // 6
  /// result =
  ///     numbers.firstWhere((element) => element > 10, orElse: () => -1); // -1
  /// ```
  ///
  /// If no element satisfies [test], the result of invoking the [orElse]
  /// function is returned.
  /// If [orElse] is omitted, it defaults to throwing a [StateError].
  /// Stops iterating on the first matching element.
  E firstWhere(bool test(E element), {E orElse()?}) {
    for (E element in this) {
      if (test(element)) return element;
    }
    if (orElse != null) return orElse();
    throw IterableElementError.noElement();
  }

  /// The last element that satisfies the given predicate [test].
  ///
  /// An iterable that can access its elements directly may check its
  /// elements in any order (for example a list starts by checking the
  /// last element and then moves towards the start of the list).
  /// The default implementation iterates elements in iteration order,
  /// checks `test(element)` for each,
  /// and finally returns that last one that matched.
  ///
  /// Example:
  /// ```dart
  /// final numbers = <int>[1, 2, 3, 5, 6, 7];
  /// var result = numbers.lastWhere((element) => element < 5); // 3
  /// result = numbers.lastWhere((element) => element > 5); // 7
  /// result = numbers.lastWhere((element) => element > 10,
  ///     orElse: () => -1); // -1
  /// ```
  ///
  /// If no element satisfies [test], the result of invoking the [orElse]
  /// function is returned.
  /// If [orElse] is omitted, it defaults to throwing a [StateError].
  E lastWhere(bool test(E element), {E orElse()?}) {
    var iterator = this.iterator;
    // Potential result during first loop.
    E result;
    do {
      if (!iterator.moveNext()) {
        if (orElse != null) return orElse();
        throw IterableElementError.noElement();
      }
      result = iterator.current;
    } while (!test(result));
    // Now `result` is actual result, unless a later one is found.
    while (iterator.moveNext()) {
      var current = iterator.current;
      if (test(current)) result = current;
    }
    return result;
  }

  /// The single element that satisfies [test].
  ///
  /// Checks elements to see if `test(element)` returns true.
  /// If exactly one element satisfies [test], that element is returned.
  /// If more than one matching element is found, throws [StateError].
  /// If no matching element is found, returns the result of [orElse].
  /// If [orElse] is omitted, it defaults to throwing a [StateError].
  ///
  /// Example:
  /// ```dart
  /// final numbers = <int>[2, 2, 10];
  /// var result = numbers.singleWhere((element) => element > 5); // 10
  /// ```
  /// When no matching element is found, the result of calling [orElse] is
  /// returned instead.
  /// ```dart continued
  /// result = numbers.singleWhere((element) => element == 1,
  ///     orElse: () => -1); // -1
  /// ```
  /// There must not be more than one matching element.
  /// ```dart continued
  /// result = numbers.singleWhere((element) => element == 2); // Throws Error.
  /// ```
  E singleWhere(bool test(E element), {E orElse()?}) {
    var iterator = this.iterator;
    E result;
    do {
      if (!iterator.moveNext()) {
        if (orElse != null) return orElse();
        throw IterableElementError.noElement();
      }
      result = iterator.current;
    } while (!test(result));
    while (iterator.moveNext()) {
      if (test(iterator.current)) throw IterableElementError.tooMany();
    }
    return result;
  }

  /// Returns the [index]th element.
  ///
  /// The [index] must be non-negative and less than [length].
  /// Index zero represents the first element (so `iterable.elementAt(0)` is
  /// equivalent to `iterable.first`).
  ///
  /// May iterate through the elements in iteration order, ignoring the
  /// first [index] elements and then returning the next.
  /// Some iterables may have a more efficient way to find the element.
  ///
  /// Example:
  /// ```dart
  /// final numbers = <int>[1, 2, 3, 5, 6, 7];
  /// final elementAt = numbers.elementAt(4); // 6
  /// ```
  E elementAt(int index) {
    RangeError.checkNotNegative(index, "index");
    var iterator = this.iterator;
    var skipCount = index;
    while (iterator.moveNext()) {
      if (skipCount == 0) return iterator.current;
      skipCount--;
    }
    throw IndexError.withLength(
      index,
      index - skipCount,
      indexable: this,
      name: "index",
    );
  }

  /// Returns a string representation of (some of) the elements of `this`.
  ///
  /// Elements are represented by their own `toString` results.
  ///
  /// The default representation always contains the first three elements.
  /// If there are less than a hundred elements in the iterable, it also
  /// contains the last two elements.
  ///
  /// If the resulting string isn't above 80 characters, more elements are
  /// included from the start of the iterable.
  ///
  /// The conversion may omit calling `toString` on some elements if they
  /// are known to not occur in the output, and it may stop iterating after
  /// a hundred elements.
  String toString() => iterableToShortString(this, '(', ')');

  /// Convert an `Iterable` to a string like [Iterable.toString].
  ///
  /// Allows using other delimiters than '(' and ')'.
  ///
  /// Handles circular references where converting one of the elements
  /// to a string ends up converting [iterable] to a string again.
  static String iterableToShortString(
    Iterable iterable, [
    String leftDelimiter = '(',
    String rightDelimiter = ')',
  ]) {
    if (isToStringVisiting(iterable)) {
      if (leftDelimiter == "(" && rightDelimiter == ")") {
        // Avoid creating a new string in the "common" case.
        return "(...)";
      }
      return "$leftDelimiter...$rightDelimiter";
    }
    List<String> parts = <String>[];
    toStringVisiting.add(iterable);
    try {
      _iterablePartsToStrings(iterable, parts);
    } finally {
      assert(identical(toStringVisiting.last, iterable));
      toStringVisiting.removeLast();
    }
    return (StringBuffer(leftDelimiter)
          ..writeAll(parts, ", ")
          ..write(rightDelimiter))
        .toString();
  }

  /// Converts an `Iterable` to a string.
  ///
  /// Converts each elements to a string, and separates the results by ", ".
  /// Then wraps the result in [leftDelimiter] and [rightDelimiter].
  ///
  /// Unlike [iterableToShortString], this conversion doesn't omit any
  /// elements or puts any limit on the size of the result.
  ///
  /// Handles circular references where converting one of the elements
  /// to a string ends up converting [iterable] to a string again.
  static String iterableToFullString(
    Iterable iterable, [
    String leftDelimiter = '(',
    String rightDelimiter = ')',
  ]) {
    if (isToStringVisiting(iterable)) {
      return "$leftDelimiter...$rightDelimiter";
    }
    StringBuffer buffer = StringBuffer(leftDelimiter);
    toStringVisiting.add(iterable);
    try {
      buffer.writeAll(iterable, ", ");
    } finally {
      assert(identical(toStringVisiting.last, iterable));
      toStringVisiting.removeLast();
    }
    buffer.write(rightDelimiter);
    return buffer.toString();
  }
}

class _GeneratorIterable<E> extends ListIterable<E> {
  // Methods have efficient implementations from `ListIterable`,
  // based on `length` and `elementAt`.

  /// The length of the generated iterable.
  final int length;

  /// The function mapping indices to values.
  final E Function(int) _generator;

  /// Creates the generated iterable.
  _GeneratorIterable(this.length, this._generator);

  E elementAt(int index) {
    IndexError.check(index, length, indexable: this);
    return _generator(index);
  }

  /// Helper function used as default _generator function.
  static int _id(int n) => n;
}

/// Used internally by [Iterable.withIterator].
///
/// This class implements [Iterable] by delegating the iterator creation
/// to the provided function.
class _WithIteratorIterable<E> extends Iterable<E> {
  final Iterator<E> Function() _iteratorFactory;

  /// Creates an iterable that gets its elements from iterators created by
  /// the provided factory function.
  _WithIteratorIterable(this._iteratorFactory);

  Iterator<E> get iterator => _iteratorFactory();
}

/// Convert elements of [iterable] to strings and store them in [parts].
void _iterablePartsToStrings(Iterable<Object?> iterable, List<String> parts) {
  // This is the complicated part of [iterableToShortString].
  // It is extracted as a separate function to avoid having too much code
  // inside the try/finally.

  // Try to stay below this many characters.
  const int lengthLimit = 80;

  // Always at least this many elements at the start.
  const int headCount = 3;

  // Always at least this many elements at the end.
  const int tailCount = 2;

  // Stop iterating after this many elements. Iterables can be infinite.
  const int maxCount = 100;
  // Per entry length overhead. It's for ", " for all after the first entry,
  // and for "(" and ")" for the initial entry. By pure luck, that's the same
  // number.
  const int overhead = 2;
  const int ellipsisSize = 3; // "...".length.

  int length = 0;
  int count = 0;
  Iterator<Object?> it = iterable.iterator;
  // Initial run of elements, at least headCount, and then continue until
  // passing at most lengthLimit characters.
  while (length < lengthLimit || count < headCount) {
    if (!it.moveNext()) return;
    String next = "${it.current}";
    parts.add(next);
    length += next.length + overhead;
    count++;
  }

  String penultimateString;
  String ultimateString;

  // Find last two elements. One or more of them may already be in the
  // parts array. Include their length in `length`.
  if (!it.moveNext()) {
    if (count <= headCount + tailCount) return;
    ultimateString = parts.removeLast();
    penultimateString = parts.removeLast();
  } else {
    Object? penultimate = it.current;
    count++;
    if (!it.moveNext()) {
      if (count <= headCount + 1) {
        parts.add("$penultimate");
        return;
      }
      ultimateString = "$penultimate";
      penultimateString = parts.removeLast();
      length += ultimateString.length + overhead;
    } else {
      Object? ultimate = it.current;
      count++;
      // Then keep looping, keeping the last two elements in variables.
      assert(count < maxCount);
      while (it.moveNext()) {
        penultimate = ultimate;
        ultimate = it.current;
        count++;
        if (count > maxCount) {
          // If we haven't found the end before maxCount, give up.
          // This cannot happen in the code above because each entry
          // increases length by at least two, so there is no way to
          // visit more than ~40 elements before this loop.

          // Remove any surplus elements until length, including ", ...)",
          // is at most lengthLimit.
          while (length > lengthLimit - ellipsisSize - overhead &&
              count > headCount) {
            length -= parts.removeLast().length + overhead;
            count--;
          }
          parts.add("...");
          return;
        }
      }
      penultimateString = "$penultimate";
      ultimateString = "$ultimate";
      length += ultimateString.length + penultimateString.length + 2 * overhead;
    }
  }

  // If there is a gap between the initial run and the last two,
  // prepare to add an ellipsis.
  String? elision;
  if (count > parts.length + tailCount) {
    elision = "...";
    length += ellipsisSize + overhead;
  }

  // If the last two elements were very long, and we have more than
  // headCount elements in the initial run, drop some to make room for
  // the last two.
  while (length > lengthLimit && parts.length > headCount) {
    length -= parts.removeLast().length + overhead;
    if (elision == null) {
      elision = "...";
      length += ellipsisSize + overhead;
    }
  }
  if (elision != null) {
    parts.add(elision);
  }
  parts.add(penultimateString);
  parts.add(ultimateString);
}
```

// ============================================================
// 🔧 Core Dart: list.dart
// 📁 /home/user/flutter/bin/cache/pkg/sky_engine/lib/core/list.dart
// ============================================================

```dart
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of "dart:core";

/// Helper interface to hide [EfficientLengthIterable] from the public
/// declaration of [List].
abstract class _ListIterable<E>
    implements EfficientLengthIterable<E>, HideEfficientLengthIterable<E> {}

/// An indexable collection of objects with a length.
///
/// Subclasses of this class implement different kinds of lists.
/// The most common kinds of lists are:
///
/// * **Fixed-length list**
///
///   An error occurs when attempting to use operations
///   that can change the length of the list.
///
/// * **Growable list**
///
///   Full implementation of the API defined in this class.
///
/// The default growable list, as created by `[]`, keeps
/// an internal buffer, and grows that buffer when necessary. This guarantees
/// that a sequence of [add] operations will each execute in amortized constant
/// time. Setting the length directly may take time proportional to the new
/// length, and may change the internal capacity so that a following add
/// operation will need to immediately increase the buffer capacity.
/// Other list implementations may have different performance behavior.
///
/// Example of fixed-length list:
/// ```dart
/// final fixedLengthList = List<int>.filled(5, 0); // Creates fixed-length list.
/// print(fixedLengthList); // [0, 0, 0, 0, 0]
/// fixedLengthList[0] = 87;
/// fixedLengthList.setAll(1, [1, 2, 3]);
/// print(fixedLengthList); // [87, 1, 2, 3, 0]
/// // Fixed length list length can't be changed or increased
/// fixedLengthList.length = 0;  // Throws
/// fixedLengthList.add(499);    // Throws
/// ```
///
/// Example of growable list:
/// ```dart
/// final growableList = <String>['A', 'B']; // Creates growable list.
/// ```
/// To add data to the growable list, use [operator[]=], [add] or [addAll].
/// ```
/// growableList[0] = 'G';
/// print(growableList); // [G, B]
/// growableList.add('X');
/// growableList.addAll({'C', 'B'});
/// print(growableList); // [G, B, X, C, B]
/// ```
/// To check whether, and where, the element is in the list, use [indexOf] or
/// [lastIndexOf].
/// ```
/// final indexA = growableList.indexOf('A'); // -1 (not in the list)
/// final firstIndexB = growableList.indexOf('B'); // 1
/// final lastIndexB = growableList.lastIndexOf('B'); // 4
/// ```
/// To remove an element from the growable list, use [remove], [removeAt],
/// [removeLast], [removeRange] or [removeWhere].
/// ```
/// growableList.remove('C');
/// growableList.removeLast();
/// print(growableList); // [G, B, X]
/// ```
/// To insert an element at position in the list, use [insert] or [insertAll].
/// ```
/// growableList.insert(1, 'New');
/// print(growableList); // [G, New, B, X]
/// ```
/// To replace a range of elements in the list, use [fillRange], [replaceRange]
/// or [setRange].
/// ```
/// growableList.replaceRange(0, 2, ['AB', 'A']);
/// print(growableList); // [AB, A, B, X]
/// growableList.fillRange(2, 4, 'F');
/// print(growableList); // [AB, A, F, F]
/// ```
/// To sort the elements of the list, use [sort].
/// ```
/// growableList.sort((a, b) => a.compareTo(b));
/// print(growableList); // [A, AB, F, F]
/// ```
/// To shuffle the elements of this list randomly, use [shuffle].
/// ```
/// growableList.shuffle();
/// print(growableList); // e.g. [AB, F, A, F]
/// ```
/// To find the first element satisfying some predicate, or give a default
/// value if none do, use [firstWhere].
/// ```
/// bool isVowel(String char) => char.length == 1 && "AEIOU".contains(char);
/// final firstVowel = growableList.firstWhere(isVowel, orElse: () => ''); // ''
/// ```
/// There are similar [lastWhere] and [singleWhere] methods.
///
/// A list is an [Iterable] and supports all its methods, including
/// [where], [map], [whereType] and [toList].
///
/// Lists are [Iterable]. Iteration occurs over values in index order. Changing
/// the values does not affect iteration, but changing the valid
/// indices&mdash;that is, changing the list's length&mdash;between iteration
/// steps causes a [ConcurrentModificationError]. This means that only growable
/// lists can throw ConcurrentModificationError. If the length changes
/// temporarily and is restored before continuing the iteration, the iterator
/// might not detect it.
///
/// It is generally not allowed to modify the list's length (adding or removing
/// elements) while an operation on the list is being performed,
/// for example during a call to [forEach] or [sort].
/// Changing the list's length while it is being iterated, either by iterating it
/// directly or through iterating an [Iterable] that is backed by the list, will
/// break the iteration.
abstract interface class List<E> implements Iterable<E>, _ListIterable<E> {
  /// Creates a list of the given length with [fill] at each position.
  ///
  /// The [length] must be a non-negative integer.
  ///
  /// Example:
  /// ```dart
  /// final zeroList = List<int>.filled(3, 0, growable: true); // [0, 0, 0]
  /// ```
  ///
  /// The created list is fixed-length if [growable] is false (the default)
  /// and growable if [growable] is true.
  /// If the list is growable, increasing its [length] will *not* initialize
  /// new entries with [fill].
  /// After being created and filled, the list is no different from any other
  /// growable or fixed-length list created
  /// using `[]` or other [List] constructors.
  ///
  /// All elements of the created list share the same [fill] value.
  /// ```dart
  /// final shared = List.filled(3, []);
  /// shared[0].add(499);
  /// print(shared);  // [[499], [499], [499]]
  /// ```
  /// You can use [List.generate] to create a list with a fixed length
  /// and a new object at each position.
  /// ```dart
  /// final unique = List.generate(3, (_) => []);
  /// unique[0].add(499);
  /// print(unique); // [[499], [], []]
  /// ```
  external factory List.filled(int length, E fill, {bool growable = false});

  /// Creates a new empty list.
  ///
  /// If [growable] is `false`, which is the default,
  /// the list is a fixed-length list of length zero.
  /// If [growable] is `true`, the list is growable and equivalent to `<E>[]`.
  /// ```dart
  /// final growableList = List.empty(growable: true); // []
  /// growableList.add(1); // [1]
  ///
  /// final fixedLengthList = List.empty(growable: false);
  /// fixedLengthList.add(1); // error
  /// ```
  external factory List.empty({bool growable = false});

  /// Creates a list containing all [elements].
  ///
  /// The [Iterator] of [elements] provides the order of the elements.
  ///
  /// All the [elements] should be instances of [E].
  ///
  /// Example:
  /// ```dart
  /// final numbers = <num>[1, 2, 3];
  /// final listFrom = List<int>.from(numbers);
  /// print(listFrom); // [1, 2, 3]
  /// ```
  /// The `elements` iterable itself may have any element type, so this
  /// constructor can be used to down-cast a `List`, for example as:
  /// ```dart import:convert
  /// const jsonArray = '''
  ///   [{"text": "foo", "value": 1, "status": true},
  ///    {"text": "bar", "value": 2, "status": false}]
  /// ''';
  /// final List<dynamic> dynamicList = jsonDecode(jsonArray);
  /// final List<Map<String, dynamic>> fooData =
  ///     List.from(dynamicList.where((x) => x is Map && x['text'] == 'foo'));
  /// print(fooData); // [{text: foo, value: 1, status: true}]
  /// ```
  ///
  /// This constructor creates a growable list when [growable] is true;
  /// otherwise, it returns a fixed-length list.
  external factory List.from(Iterable elements, {bool growable = true});

  /// Creates a list from [elements].
  ///
  /// The [Iterator] of [elements] provides the order of the elements.
  ///
  /// This constructor creates a growable list when [growable] is true;
  /// otherwise, it returns a fixed-length list.
  /// ```dart
  /// final numbers = <int>[1, 2, 3];
  /// final listOf = List<num>.of(numbers);
  /// print(listOf); // [1, 2, 3]
  /// ```
  external factory List.of(Iterable<E> elements, {bool growable = true});

  /// Generates a list of values.
  ///
  /// Creates a list with [length] positions and fills it with values created by
  /// calling [generator] for each index in the range `0` .. `length - 1`
  /// in increasing order.
  /// ```dart
  /// final growableList =
  ///     List<int>.generate(3, (int index) => index * index, growable: true);
  /// print(growableList); // [0, 1, 4]
  ///
  /// final fixedLengthList =
  ///     List<int>.generate(3, (int index) => index * index, growable: false);
  /// print(fixedLengthList); // [0, 1, 4]
  /// ```
  /// The created list is fixed-length if [growable] is set to false.
  ///
  /// The [length] must be non-negative.
  external factory List.generate(
    int length,
    E generator(int index), {
    bool growable = true,
  });

  /// Creates an unmodifiable list containing all [elements].
  ///
  /// The [Iterator] of [elements] provides the order of the elements.
  ///
  /// An unmodifiable list cannot have its length or elements changed.
  /// If the elements are themselves immutable, then the resulting list
  /// is also immutable.
  /// ```dart
  /// final numbers = <int>[1, 2, 3];
  /// final unmodifiableList = List.unmodifiable(numbers); // [1, 2, 3]
  /// unmodifiableList[1] = 87; // Throws.
  /// ```
  external factory List.unmodifiable(Iterable elements);

  /// Adapts [source] to be a `List<T>`.
  ///
  /// Any time the list would produce an element that is not a [T],
  /// the element access will throw.
  ///
  /// Any time a [T] value is attempted stored into the adapted list,
  /// the store will throw unless the value is also an instance of [S].
  ///
  /// If all accessed elements of [source] are actually instances of [T],
  /// and if all elements stored into the returned list are actually instance
  /// of [S],
  /// then the returned list can be used as a `List<T>`.
  ///
  /// Methods which accept `Object?` as argument, like [contains] and [remove],
  /// will pass the argument directly to the this list's method
  /// without any checks.
  static List<T> castFrom<S, T>(List<S> source) => CastList<S, T>(source);

  /// Copy a range of one list into another list.
  ///
  /// This is a utility function that can be used to implement methods like
  /// [setRange].
  ///
  /// The range from [start] to [end] must be a valid range of [source],
  /// and there must be room for `end - start` elements from position [at].
  /// If [start] is omitted, it defaults to zero.
  /// If [end] is omitted, it defaults to [source].length.
  ///
  /// If [source] and [target] are the same list, overlapping source and target
  /// ranges are respected so that the target range ends up containing the
  /// initial content of the source range.
  /// Otherwise the order of element copying is not guaranteed.
  static void copyRange<T>(
    List<T> target,
    int at,
    List<T> source, [
    int? start,
    int? end,
  ]) {
    start ??= 0;
    end = RangeError.checkValidRange(start, end, source.length);

    int length = end - start;
    if (target.length < at + length) {
      throw ArgumentError.value(
        target,
        "target",
        "Not big enough to hold $length elements at position $at",
      );
    }
    if (!identical(source, target) || start >= at) {
      for (int i = 0; i < length; i++) {
        target[at + i] = source[start + i];
      }
    } else {
      for (int i = length; --i >= 0;) {
        target[at + i] = source[start + i];
      }
    }
  }

  /// Write the elements of an iterable into a list.
  ///
  /// This is a utility function that can be used to implement methods like
  /// [setAll].
  ///
  /// The elements of [source] are written into [target] from position [at].
  /// The [source] must not contain more elements after writing the last
  /// position of [target].
  ///
  /// If the source is a list, the [copyRange] function is likely to be more
  /// efficient.
  static void writeIterable<T>(List<T> target, int at, Iterable<T> source) {
    RangeError.checkValueInInterval(at, 0, target.length, "at");
    int index = at;
    int targetLength = target.length;
    for (var element in source) {
      if (index == targetLength) {
        throw IndexError.withLength(index, targetLength, indexable: target);
      }
      target[index] = element;
      index++;
    }
  }

  /// Returns a view of this list as a list of [R] instances.
  ///
  /// If this list contains only instances of [R], all read operations
  /// will work correctly. If any operation tries to read an element
  /// that is not an instance of [R], the access will throw instead.
  ///
  /// Elements added to the list (e.g., by using [add] or [addAll])
  /// must be instances of [R] to be valid arguments to the adding function,
  /// and they must also be instances of [E] to be accepted by
  /// this list as well.
  ///
  /// Methods which accept `Object?` as argument, like [contains] and [remove],
  /// will pass the argument directly to the this list's method
  /// without any checks.
  /// That means that you can do `listOfStrings.cast<int>().remove("a")`
  /// successfully, even if it looks like it shouldn't have any effect.
  ///
  /// Typically implemented as `List.castFrom<E, R>(this)`.
  List<R> cast<R>();

  /// The object at the given [index] in the list.
  ///
  /// The [index] must be a valid index of this list,
  /// which means that `index` must be non-negative and
  /// less than [length].
  E operator [](int index);

  /// Sets the value at the given [index] in the list to [value].
  ///
  /// The [index] must be a valid index of this list,
  /// which means that `index` must be non-negative and
  /// less than [length].
  void operator []=(int index, E value);

  /// The first element of the list.
  ///
  /// The list must be non-empty when accessing its first element.
  ///
  /// The first element of a list can be modified, unlike an [Iterable].
  /// A `list.first` is equivalent to `list[0]`,
  /// both for getting and setting the value.
  ///
  /// ```dart
  /// final numbers = <int>[1, 2, 3];
  /// print(numbers.first); // 1
  /// numbers.first = 10;
  /// print(numbers.first); // 10
  /// numbers.clear();
  /// numbers.first; // Throws.
  /// ```
  void set first(E value);

  /// The last element of the list.
  ///
  /// The list must be non-empty when accessing its last element.
  ///
  /// The last element of a list can be modified, unlike an [Iterable].
  /// A `list.last` is equivalent to `theList[theList.length - 1]`,
  /// both for getting and setting the value.
  ///
  /// ```dart
  /// final numbers = <int>[1, 2, 3];
  /// print(numbers.last); // 3
  /// numbers.last = 10;
  /// print(numbers.last); // 10
  /// numbers.clear();
  /// numbers.last; // Throws.
  /// ```
  void set last(E value);

  /// The number of objects in this list.
  ///
  /// The valid indices for a list are `0` through `length - 1`.
  /// ```dart
  /// final numbers = <int>[1, 2, 3];
  /// print(numbers.length); // 3
  /// ```
  int get length;

  /// Setting the `length` changes the number of elements in the list.
  ///
  /// The list must be growable.
  /// If [newLength] is greater than current length,
  /// new entries are initialized to `null`,
  /// so [newLength] must not be greater than the current length
  /// if the element type [E] is non-nullable.
  ///
  /// ```dart
  /// final maybeNumbers = <int?>[1, null, 3];
  /// maybeNumbers.length = 5;
  /// print(maybeNumbers); // [1, null, 3, null, null]
  /// maybeNumbers.length = 2;
  /// print(maybeNumbers); // [1, null]
  ///
  /// final numbers = <int>[1, 2, 3];
  /// numbers.length = 1;
  /// print(numbers); // [1]
  /// numbers.length = 5; // Throws, cannot add `null`s.
  /// ```
  set length(int newLength);

  /// Adds [value] to the end of this list,
  /// extending the length by one.
  ///
  /// The list must be growable.
  ///
  /// ```dart
  /// final numbers = <int>[1, 2, 3];
  /// numbers.add(4);
  /// print(numbers); // [1, 2, 3, 4]
  /// ```
  void add(E value);

  /// Appends all objects of [iterable] to the end of this list.
  ///
  /// Extends the length of the list by the number of objects in [iterable].
  /// The list must be growable.
  ///
  /// ```dart
  /// final numbers = <int>[1, 2, 3];
  /// numbers.addAll([4, 5, 6]);
  /// print(numbers); // [1, 2, 3, 4, 5, 6]
  /// ```
  void addAll(Iterable<E> iterable);

  /// An [Iterable] of the objects in this list in reverse order.
  /// ```dart
  /// final numbers = <String>['two', 'three', 'four'];
  /// final reverseOrder = numbers.reversed;
  /// print(reverseOrder.toList()); // [four, three, two]
  /// ```
  Iterable<E> get reversed;

  /// Sorts this list according to the order specified by the [compare] function.
  ///
  /// The [compare] function must act as a [Comparator].
  /// ```dart
  /// final numbers = <String>['two', 'three', 'four'];
  /// // Sort from shortest to longest.
  /// numbers.sort((a, b) => a.length.compareTo(b.length));
  /// print(numbers); // [two, four, three]
  /// ```
  /// The default [List] implementations use [Comparable.compare] if
  /// [compare] is omitted.
  /// ```dart
  /// final numbers = <int>[13, 2, -11, 0];
  /// numbers.sort();
  /// print(numbers); // [-11, 0, 2, 13]
  /// ```
  /// In that case, the elements of the list must be [Comparable] to
  /// each other.
  ///
  /// A [Comparator] may compare objects as equal (return zero), even if they
  /// are distinct objects.
  /// The sort function is not guaranteed to be stable, so distinct objects
  /// that compare as equal may occur in any order in the result:
  /// ```dart
  /// final numbers = <String>['one', 'two', 'three', 'four'];
  /// numbers.sort((a, b) => a.length.compareTo(b.length));
  /// print(numbers); // [one, two, four, three] OR [two, one, four, three]
  /// ```
  void sort([int compare(E a, E b)?]);

  /// Shuffles the elements of this list randomly.
  /// ```dart
  /// final numbers = <int>[1, 2, 3, 4, 5];
  /// numbers.shuffle();
  /// print(numbers); // [1, 3, 4, 5, 2] OR some other random result.
  /// ```
  void shuffle([Random? random]);

  /// The first index of [element] in this list.
  ///
  /// Searches the list from index [start] to the end of the list.
  /// The first time an object `o` is encountered so that `o == element`,
  /// the index of `o` is returned.
  /// ```dart
  /// final notes = <String>['do', 're', 'mi', 're'];
  /// print(notes.indexOf('re')); // 1
  ///
  /// final indexWithStart = notes.indexOf('re', 2); // 3
  /// ```
  /// Returns -1 if [element] is not found.
  /// ```dart
  /// final notes = <String>['do', 're', 'mi', 're'];
  /// final index = notes.indexOf('fa'); // -1
  /// ```
  int indexOf(E element, [int start = 0]);

  /// The first index in the list that satisfies the provided [test].
  ///
  /// Searches the list from index [start] to the end of the list.
  /// The first time an object `o` is encountered so that `test(o)` is true,
  /// the index of `o` is returned.
  ///
  /// ```dart
  /// final notes = <String>['do', 're', 'mi', 're'];
  /// final first = notes.indexWhere((note) => note.startsWith('r')); // 1
  /// final second = notes.indexWhere((note) => note.startsWith('r'), 2); // 3
  /// ```
  ///
  /// Returns -1 if [element] is not found.
  /// ```dart
  /// final notes = <String>['do', 're', 'mi', 're'];
  /// final index = notes.indexWhere((note) => note.startsWith('k')); // -1
  /// ```
  int indexWhere(bool test(E element), [int start = 0]);

  /// The last index in the list that satisfies the provided [test].
  ///
  /// Searches the list from index [start] to 0.
  /// The first time an object `o` is encountered so that `test(o)` is true,
  /// the index of `o` is returned.
  /// If [start] is omitted, it defaults to the [length] of the list.
  ///
  /// ```dart
  /// final notes = <String>['do', 're', 'mi', 're'];
  /// final first = notes.lastIndexWhere((note) => note.startsWith('r')); // 3
  /// final second = notes.lastIndexWhere((note) => note.startsWith('r'),
  ///     2); // 1
  /// ```
  ///
  /// Returns -1 if [element] is not found.
  /// ```dart
  /// final notes = <String>['do', 're', 'mi', 're'];
  /// final index = notes.lastIndexWhere((note) => note.startsWith('k'));
  /// print(index); // -1
  /// ```
  int lastIndexWhere(bool test(E element), [int? start]);

  /// The last index of [element] in this list.
  ///
  /// Searches the list backwards from index [start] to 0.
  ///
  /// The first time an object `o` is encountered so that `o == element`,
  /// the index of `o` is returned.
  /// ```dart
  /// final notes = <String>['do', 're', 'mi', 're'];
  /// const startIndex = 2;
  /// final index = notes.lastIndexOf('re', startIndex); // 1
  /// ```
  /// If [start] is not provided, this method searches from the end of the
  /// list.
  /// ```dart
  /// final notes = <String>['do', 're', 'mi', 're'];
  /// final index = notes.lastIndexOf('re'); // 3
  /// ```
  /// Returns -1 if [element] is not found.
  /// ```dart
  /// final notes = <String>['do', 're', 'mi', 're'];
  /// final index = notes.lastIndexOf('fa'); // -1
  /// ```
  int lastIndexOf(E element, [int? start]);

  /// Removes all objects from this list; the length of the list becomes zero.
  ///
  /// The list must be growable.
  ///
  /// ```dart
  /// final numbers = <int>[1, 2, 3];
  /// numbers.clear();
  /// print(numbers.length); // 0
  /// print(numbers); // []
  /// ```
  void clear();

  /// Inserts [element] at position [index] in this list.
  ///
  /// This increases the length of the list by one and shifts all objects
  /// at or after the index towards the end of the list.
  ///
  /// The list must be growable.
  /// The [index] value must be non-negative and no greater than [length].
  ///
  /// ```dart
  /// final numbers = <int>[1, 2, 3, 4];
  /// const index = 2;
  /// numbers.insert(index, 10);
  /// print(numbers); // [1, 2, 10, 3, 4]
  /// ```
  void insert(int index, E element);

  /// Inserts all objects of [iterable] at position [index] in this list.
  ///
  /// This increases the length of the list by the length of [iterable] and
  /// shifts all later objects towards the end of the list.
  ///
  /// The list must be growable.
  /// The [index] value must be non-negative and no greater than [length].
  /// ```dart
  /// final numbers = <int>[1, 2, 3, 4];
  /// final insertItems = [10, 11];
  /// numbers.insertAll(2, insertItems);
  /// print(numbers); // [1, 2, 10, 11, 3, 4]
  /// ```
  void insertAll(int index, Iterable<E> iterable);

  /// Overwrites elements with the objects of [iterable].
  ///
  /// The elements of [iterable] are written into this list,
  /// starting at position [index].
  /// This operation does not increase the length of the list.
  ///
  /// The [index] must be non-negative and no greater than [length].
  ///
  /// The [iterable] must not have more elements than what can fit from [index]
  /// to [length].
  ///
  /// If `iterable` is based on this list, its values may change _during_ the
  /// `setAll` operation.
  /// ```dart
  /// final list = <String>['a', 'b', 'c', 'd'];
  /// list.setAll(1, ['bee', 'sea']);
  /// print(list); // [a, bee, sea, d]
  /// ```
  void setAll(int index, Iterable<E> iterable);

  /// Removes the first occurrence of [value] from this list.
  ///
  /// Returns true if [value] was in the list, false otherwise.
  /// The list must be growable.
  ///
  /// ```dart
  /// final parts = <String>['head', 'shoulders', 'knees', 'toes'];
  /// final retVal = parts.remove('head'); // true
  /// print(parts); // [shoulders, knees, toes]
  /// ```
  /// The method has no effect if [value] was not in the list.
  /// ```dart
  /// final parts = <String>['shoulders', 'knees', 'toes'];
  /// // Note: 'head' has already been removed.
  /// final retVal = parts.remove('head'); // false
  /// print(parts); // [shoulders, knees, toes]
  /// ```
  bool remove(Object? value);

  /// Removes the object at position [index] from this list.
  ///
  /// This method reduces the length of `this` by one and moves all later objects
  /// down by one position.
  ///
  /// Returns the removed value.
  ///
  /// The [index] must be in the range `0 ≤ index < length`.
  /// The list must be growable.
  /// ```dart
  /// final parts = <String>['head', 'shoulder', 'knees', 'toes'];
  /// final retVal = parts.removeAt(2); // knees
  /// print(parts); // [head, shoulder, toes]
  /// ```
  E removeAt(int index);

  /// Removes and returns the last object in this list.
  ///
  /// The list must be growable and non-empty.
  /// ```dart
  /// final parts = <String>['head', 'shoulder', 'knees', 'toes'];
  /// final retVal = parts.removeLast(); // toes
  /// print(parts); // [head, shoulder, knees]
  /// ```
  E removeLast();

  /// Removes all objects from this list that satisfy [test].
  ///
  /// An object `o` satisfies [test] if `test(o)` is true.
  /// ```dart
  /// final numbers = <String>['one', 'two', 'three', 'four'];
  /// numbers.removeWhere((item) => item.length == 3);
  /// print(numbers); // [three, four]
  /// ```
  /// The list must be growable.
  void removeWhere(bool test(E element));

  /// Removes all objects from this list that fail to satisfy [test].
  ///
  /// An object `o` satisfies [test] if `test(o)` is true.
  /// ```dart
  /// final numbers = <String>['one', 'two', 'three', 'four'];
  /// numbers.retainWhere((item) => item.length == 3);
  /// print(numbers); // [one, two]
  /// ```
  /// The list must be growable.
  void retainWhere(bool test(E element));

  /// Returns the concatenation of this list and [other].
  ///
  /// Returns a new list containing the elements of this list followed by
  /// the elements of [other].
  ///
  /// The default behavior is to return a normal growable list.
  /// Some list types may choose to return a list of the same type as themselves
  /// (see [Uint8List.+]);
  List<E> operator +(List<E> other);

  /// Returns a new list containing the elements between [start] and [end].
  ///
  /// The new list is a `List<E>` containing the elements of this list at
  /// positions greater than or equal to [start] and less than [end] in the same
  /// order as they occur in this list.
  ///
  /// ```dart
  /// final colors = <String>['red', 'green', 'blue', 'orange', 'pink'];
  /// print(colors.sublist(1, 3)); // [green, blue]
  /// ```
  ///
  /// If [end] is omitted, it defaults to the [length] of this list.
  ///
  /// ```dart
  /// final colors = <String>['red', 'green', 'blue', 'orange', 'pink'];
  /// print(colors.sublist(3)); // [orange, pink]
  /// ```
  ///
  /// The `start` and `end` positions must satisfy the relations
  /// 0 ≤ `start` ≤ `end` ≤ [length].
  /// If `end` is equal to `start`, then the returned list is empty.
  List<E> sublist(int start, [int? end]);

  /// Creates an [Iterable] that iterates over a range of elements.
  ///
  /// The returned iterable iterates over the elements of this list
  /// with positions greater than or equal to [start] and less than [end].
  ///
  /// The provided range, [start] and [end], must be valid at the time
  /// of the call.
  /// A range from [start] to [end] is valid if 0 ≤ `start` ≤ `end` ≤ [length].
  /// An empty range (with `end == start`) is valid.
  ///
  /// The returned [Iterable] behaves like `skip(start).take(end - start)`.
  /// That is, it does *not* break if this list changes size, it just
  /// ends early if it reaches the end of the list early
  /// (if `end`, or even `start`, becomes greater than [length]).
  /// ```dart
  /// final colors = <String>['red', 'green', 'blue', 'orange', 'pink'];
  /// final firstRange = colors.getRange(0, 3);
  /// print(firstRange.join(', ')); // red, green, blue
  ///
  /// final secondRange = colors.getRange(2, 5);
  /// print(secondRange.join(', ')); // blue, orange, pink
  /// ```
  Iterable<E> getRange(int start, int end);

  /// Writes some elements of [iterable] into a range of this list.
  ///
  /// Copies the objects of [iterable], skipping [skipCount] objects first,
  /// into the range from [start], inclusive, to [end], exclusive, of this list.
  /// ```dart
  /// final list1 = <int>[1, 2, 3, 4];
  /// final list2 = <int>[5, 6, 7, 8, 9];
  /// // Copies the 4th and 5th items in list2 as the 2nd and 3rd items
  /// // of list1.
  /// const skipCount = 3;
  /// list1.setRange(1, 3, list2, skipCount);
  /// print(list1); // [1, 8, 9, 4]
  /// ```
  /// The provided range, given by [start] and [end], must be valid.
  /// A range from [start] to [end] is valid if 0 ≤ `start` ≤ `end` ≤ [length].
  /// An empty range (with `end == start`) is valid.
  ///
  /// The [iterable] must have enough objects to fill the range from `start`
  /// to `end` after skipping [skipCount] objects.
  ///
  /// If `iterable` is this list, the operation correctly copies the elements
  /// originally in the range from `skipCount` to `skipCount + (end - start)` to
  /// the range `start` to `end`, even if the two ranges overlap.
  ///
  /// If `iterable` depends on this list in some other way, no guarantees are
  /// made.
  void setRange(int start, int end, Iterable<E> iterable, [int skipCount = 0]);

  /// Removes a range of elements from the list.
  ///
  /// Removes the elements with positions greater than or equal to [start]
  /// and less than [end], from the list.
  /// This reduces the list's length by `end - start`.
  ///
  /// The provided range, given by [start] and [end], must be valid.
  /// A range from [start] to [end] is valid if 0 ≤ `start` ≤ `end` ≤ [length].
  /// An empty range (with `end == start`) is valid.
  ///
  /// The list must be growable.
  /// ```dart
  /// final numbers = <int>[1, 2, 3, 4, 5];
  /// numbers.removeRange(1, 4);
  /// print(numbers); // [1, 5]
  /// ```
  void removeRange(int start, int end);

  /// Overwrites a range of elements with [fillValue].
  ///
  /// Sets the positions greater than or equal to [start] and less than [end],
  /// to [fillValue].
  ///
  /// The provided range, given by [start] and [end], must be valid.
  /// A range from [start] to [end] is valid if 0 ≤ `start` ≤ `end` ≤ [length].
  /// An empty range (with `end == start`) is valid.
  ///
  /// If the element type is not nullable, the [fillValue] must be provided and
  /// must be non-`null`.
  ///
  /// Example:
  /// ```dart
  /// final words = List.filled(5, 'old');
  /// print(words); // [old, old, old, old, old]
  /// words.fillRange(1, 3, 'new');
  /// print(words); // [old, new, new, old, old]
  /// ```
  void fillRange(int start, int end, [E? fillValue]);

  /// Replaces a range of elements with the elements of [replacements].
  ///
  /// Removes the objects in the range from [start] to [end],
  /// then inserts the elements of [replacements] at [start].
  /// ```dart
  /// final numbers = <int>[1, 2, 3, 4, 5];
  /// final replacements = [6, 7];
  /// numbers.replaceRange(1, 4, replacements);
  /// print(numbers); // [1, 6, 7, 5]
  /// ```
  /// The provided range, given by [start] and [end], must be valid.
  /// A range from [start] to [end] is valid if 0 ≤ `start` ≤ `end` ≤ [length].
  /// An empty range (with `end == start`) is valid.
  ///
  /// The operation `list.replaceRange(start, end, replacements)`
  /// is roughly equivalent to:
  /// ```dart
  /// final numbers = <int>[1, 2, 3, 4, 5];
  /// numbers.removeRange(1, 4);
  /// final replacements = [6, 7];
  /// numbers.insertAll(1, replacements);
  /// print(numbers); // [1, 6, 7, 5]
  /// ```
  /// but may be more efficient.
  ///
  /// The list must be growable.
  /// This method does not work on fixed-length lists, even when [replacements]
  /// has the same number of elements as the replaced range. In that case use
  /// [setRange] instead.
  void replaceRange(int start, int end, Iterable<E> replacements);

  /// An unmodifiable [Map] view of this list.
  ///
  /// The map uses the indices of this list as keys and the corresponding objects
  /// as values. The `Map.keys` [Iterable] iterates the indices of this list
  /// in numerical order.
  /// ```dart
  /// var words = <String>['fee', 'fi', 'fo', 'fum'];
  /// var map = words.asMap();  // {0: fee, 1: fi, 2: fo, 3: fum}
  /// map.keys.toList(); // [0, 1, 2, 3]
  /// ```
  Map<int, E> asMap();

  /// Whether this list is equal to [other].
  ///
  /// Lists are, by default, only equal to themselves.
  /// Even if [other] is also a list, the equality comparison
  /// does not compare the elements of the two lists.
  bool operator ==(Object other);
}
```

// ============================================================
// 📁 Project: framework.dart
// 📁 /home/user/flutter/packages/flutter/lib/src/widgets/framework.dart
// ============================================================

```dart
// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// @docImport 'dart:ui';
///
/// @docImport 'package:flutter/animation.dart';
/// @docImport 'package:flutter/material.dart';
/// @docImport 'package:flutter/widgets.dart';
/// @docImport 'package:flutter_test/flutter_test.dart';
library;

import 'dart:async';
import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';

import 'binding.dart';
import 'debug.dart';
import 'focus_manager.dart';
import 'inherited_model.dart';
import 'notification_listener.dart';
import 'widget_inspector.dart';

export 'package:flutter/foundation.dart'
    show
        factory,
        immutable,
        mustCallSuper,
        optionalTypeArgs,
        protected,
        required,
        visibleForTesting;
export 'package:flutter/foundation.dart'
    show ErrorDescription, ErrorHint, ErrorSummary, FlutterError, debugPrint, debugPrintStack;
export 'package:flutter/foundation.dart' show DiagnosticLevel, DiagnosticsNode;
export 'package:flutter/foundation.dart' show Key, LocalKey, ValueKey;
export 'package:flutter/foundation.dart' show ValueChanged, ValueGetter, ValueSetter, VoidCallback;
export 'package:flutter/rendering.dart'
    show RenderBox, RenderObject, debugDumpLayerTree, debugDumpRenderTree;

// Examples can assume:
// late BuildContext context;
// void setState(VoidCallback fn) { }
// abstract class RenderFrogJar extends RenderObject { }
// abstract class FrogJar extends RenderObjectWidget { const FrogJar({super.key}); }
// abstract class FrogJarParentData extends ParentData { late Size size; }
// abstract class SomeWidget extends StatefulWidget { const SomeWidget({super.key}); }
// typedef ChildWidget = Placeholder;
// class _SomeWidgetState extends State<SomeWidget> { @override Widget build(BuildContext context) => widget; }
// abstract class RenderFoo extends RenderObject { }
// abstract class Foo extends RenderObjectWidget { const Foo({super.key}); }
// abstract class StatefulWidgetX { const StatefulWidgetX({this.key}); final Key? key; Widget build(BuildContext context, State state); }
// class SpecialWidget extends StatelessWidget { const SpecialWidget({ super.key, this.handler }); final VoidCallback? handler; @override Widget build(BuildContext context) => this; }
// late Object? _myState, newValue;
// int _counter = 0;
// Future<Directory> getApplicationDocumentsDirectory() async => Directory('');
// late AnimationController animation;

class _DebugOnly {
  const _DebugOnly();
}

/// An annotation used by test_analysis package to verify patterns are followed
/// that allow for tree-shaking of both fields and their initializers. This
/// annotation has no impact on code by itself, but indicates the following pattern
/// should be followed for a given field:
///
/// ```dart
/// class Bar {
///   final Object? bar = kDebugMode ? Object() : null;
/// }
/// ```
const _DebugOnly _debugOnly = _DebugOnly();

// KEYS

/// A key that takes its identity from the object used as its value.
///
/// Used to tie the identity of a widget to the identity of an object used to
/// generate that widget.
///
/// See also:
///
///  * [Key], the base class for all keys.
///  * The discussion at [Widget.key] for more information about how widgets use
///    keys.
class ObjectKey extends LocalKey {
  /// Creates a key that uses [identical] on [value] for its [operator==].
  const ObjectKey(this.value);

  /// The object whose identity is used by this key's [operator==].
  final Object? value;

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is ObjectKey && identical(other.value, value);
  }

  @override
  int get hashCode => Object.hash(runtimeType, identityHashCode(value));

  @override
  String toString() {
    if (runtimeType == ObjectKey) {
      return '[${describeIdentity(value)}]';
    }
    return '[${objectRuntimeType(this, 'ObjectKey')} ${describeIdentity(value)}]';
  }
}

/// A key that is unique across the entire app.
///
/// Global keys uniquely identify elements. Global keys provide access to other
/// objects that are associated with those elements, such as [BuildContext].
/// For [StatefulWidget]s, global keys also provide access to [State].
///
/// Widgets that have global keys reparent their subtrees when they are moved
/// from one location in the tree to another location in the tree. In order to
/// reparent its subtree, a widget must arrive at its new location in the tree
/// in the same animation frame in which it was removed from its old location in
/// the tree.
///
/// Reparenting an [Element] using a global key is relatively expensive, as
/// this operation will trigger a call to [State.deactivate] on the associated
/// [State] and all of its descendants; then force all widgets that depends
/// on an [InheritedWidget] to rebuild.
///
/// If you don't need any of the features listed above, consider using a [Key],
/// [ValueKey], [ObjectKey], or [UniqueKey] instead.
///
/// You cannot simultaneously include two widgets in the tree with the same
/// global key. Attempting to do so will assert at runtime.
///
/// ## Pitfalls
///
/// GlobalKeys should not be re-created on every build. They should usually be
/// long-lived objects owned by a [State] object, for example.
///
/// Creating a new GlobalKey on every build will throw away the state of the
/// subtree associated with the old key and create a new fresh subtree for the
/// new key. Besides harming performance, this can also cause unexpected
/// behavior in widgets in the subtree. For example, a [GestureDetector] in the
/// subtree will be unable to track ongoing gestures since it will be recreated
/// on each build.
///
/// Instead, a good practice is to let a State object own the GlobalKey, and
/// instantiate it outside the build method, such as in [State.initState].
///
/// See also:
///
///  * The discussion at [Widget.key] for more information about how widgets use
///    keys.
@optionalTypeArgs
abstract class GlobalKey<T extends State<StatefulWidget>> extends Key {
  /// Creates a [LabeledGlobalKey], which is a [GlobalKey] with a label used for
  /// debugging.
  ///
  /// The label is purely for debugging and not used for comparing the identity
  /// of the key.
  factory GlobalKey({String? debugLabel}) => LabeledGlobalKey<T>(debugLabel);

  /// Creates a global key without a label.
  ///
  /// Used by subclasses because the factory constructor shadows the implicit
  /// constructor.
  const GlobalKey.constructor() : super.empty();

  Element? get _currentElement => WidgetsBinding.instance.buildOwner!._globalKeyRegistry[this];

  /// The build context in which the widget with this key builds.
  ///
  /// The current context is null if there is no widget in the tree that matches
  /// this global key.
  BuildContext? get currentContext => _currentElement;

  /// The widget in the tree that currently has this global key.
  ///
  /// The current widget is null if there is no widget in the tree that matches
  /// this global key.
  Widget? get currentWidget => _currentElement?.widget;

  /// The [State] for the widget in the tree that currently has this global key.
  ///
  /// The current state is null if (1) there is no widget in the tree that
  /// matches this global key, (2) that widget is not a [StatefulWidget], or the
  /// associated [State] object is not a subtype of `T`.
  T? get currentState => switch (_currentElement) {
    StatefulElement(:final T state) => state,
    _ => null,
  };
}

/// A global key with a debugging label.
///
/// The debug label is useful for documentation and for debugging. The label
/// does not affect the key's identity.
@optionalTypeArgs
class LabeledGlobalKey<T extends State<StatefulWidget>> extends GlobalKey<T> {
  /// Creates a global key with a debugging label.
  ///
  /// The label does not affect the key's identity.
  // ignore: prefer_const_constructors_in_immutables , never use const for this class
  LabeledGlobalKey(this._debugLabel) : super.constructor();

  final String? _debugLabel;

  @override
  String toString() {
    final label = _debugLabel != null ? ' $_debugLabel' : '';
    if (runtimeType == LabeledGlobalKey) {
      return '[GlobalKey#${shortHash(this)}$label]';
    }
    return '[${describeIdentity(this)}$label]';
  }
}

/// A global key that takes its identity from the object used as its value.
///
/// Used to tie the identity of a widget to the identity of an object used to
/// generate that widget.
///
/// Any [GlobalObjectKey] created for the same object will match.
///
/// If the object is not private, then it is possible that collisions will occur
/// where independent widgets will reuse the same object as their
/// [GlobalObjectKey] value in a different part of the tree, leading to a global
/// key conflict. To avoid this problem, create a private [GlobalObjectKey]
/// subclass, as in:
///
/// ```dart
/// class _MyKey extends GlobalObjectKey {
///   const _MyKey(super.value);
/// }
/// ```
///
/// Since the [runtimeType] of the key is part of its identity, this will
/// prevent clashes with other [GlobalObjectKey]s even if they have the same
/// value.
@optionalTypeArgs
class GlobalObjectKey<T extends State<StatefulWidget>> extends GlobalKey<T> {
  /// Creates a global key that uses [identical] on [value] for its [operator==].
  const GlobalObjectKey(this.value) : super.constructor();

  /// The object whose identity is used by this key's [operator==].
  final Object value;

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is GlobalObjectKey<T> && identical(other.value, value);
  }

  @override
  int get hashCode => identityHashCode(value);

  @override
  String toString() {
    String selfType = objectRuntimeType(this, 'GlobalObjectKey');
    // The runtimeType string of a GlobalObjectKey() returns 'GlobalObjectKey<State<StatefulWidget>>'
    // because GlobalObjectKey is instantiated to its bounds. To avoid cluttering the output
    // we remove the suffix.
    const suffix = '<State<StatefulWidget>>';
    if (selfType.endsWith(suffix)) {
      selfType = selfType.substring(0, selfType.length - suffix.length);
    }
    return '[$selfType ${describeIdentity(value)}]';
  }
}

/// Describes the configuration for an [Element].
///
/// Widgets are the central class hierarchy in the Flutter framework. A widget
/// is an immutable description of part of a user interface. Widgets can be
/// inflated into elements, which manage the underlying render tree.
///
/// Widgets themselves have no mutable state (all their fields must be final).
/// If you wish to associate mutable state with a widget, consider using a
/// [StatefulWidget], which creates a [State] object (via
/// [StatefulWidget.createState]) whenever it is inflated into an element and
/// incorporated into the tree.
///
/// A given widget can be included in the tree zero or more times. In particular
/// a given widget can be placed in the tree multiple times. Each time a widget
/// is placed in the tree, it is inflated into an [Element], which means a
/// widget that is incorporated into the tree multiple times will be inflated
/// multiple times.
///
/// The [key] property controls how one widget replaces another widget in the
/// tree. If the [runtimeType] and [key] properties of the two widgets are
/// [operator==], respectively, then the new widget replaces the old widget by
/// updating the underlying element (i.e., by calling [Element.update] with the
/// new widget). Otherwise, the old element is removed from the tree, the new
/// widget is inflated into an element, and the new element is inserted into the
/// tree.
///
/// See also:
///
///  * [StatefulWidget] and [State], for widgets that can build differently
///    several times over their lifetime.
///  * [InheritedWidget], for widgets that introduce ambient state that can
///    be read by descendant widgets.
///  * [StatelessWidget], for widgets that always build the same way given a
///    particular configuration and ambient state.
@immutable
abstract class Widget extends DiagnosticableTree {
  /// Initializes [key] for subclasses.
  const Widget({this.key});

  /// Controls how one widget replaces another widget in the tree.
  ///
  /// If the [runtimeType] and [key] properties of the two widgets are
  /// [operator==], respectively, then the new widget replaces the old widget by
  /// updating the underlying element (i.e., by calling [Element.update] with the
  /// new widget). Otherwise, the old element is removed from the tree, the new
  /// widget is inflated into an element, and the new element is inserted into the
  /// tree.
  ///
  /// In addition, using a [GlobalKey] as the widget's [key] allows the element
  /// to be moved around the tree (changing parent) without losing state. When a
  /// new widget is found (its key and type do not match a previous widget in
  /// the same location), but there was a widget with that same global key
  /// elsewhere in the tree in the previous frame, then that widget's element is
  /// moved to the new location.
  ///
  /// Generally, a widget that is the only child of another widget does not need
  /// an explicit key.
  ///
  /// See also:
  ///
  ///  * The discussions at [Key] and [GlobalKey].
  final Key? key;

  /// Inflates this configuration to a concrete instance.
  ///
  /// A given widget can be included in the tree zero or more times. In particular
  /// a given widget can be placed in the tree multiple times. Each time a widget
  /// is placed in the tree, it is inflated into an [Element], which means a
  /// widget that is incorporated into the tree multiple times will be inflated
  /// multiple times.
  @protected
  @factory
  Element createElement();

  /// A short, textual description of this widget.
  @override
  String toStringShort() {
    final String type = objectRuntimeType(this, 'Widget');
    return key == null ? type : '$type-$key';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.defaultDiagnosticsTreeStyle = DiagnosticsTreeStyle.dense;
  }

  @override
  @nonVirtual
  bool operator ==(Object other) => super == other;

  @override
  @nonVirtual
  int get hashCode => super.hashCode;

  /// Whether the `newWidget` can be used to update an [Element] that currently
  /// has the `oldWidget` as its configuration.
  ///
  /// An element that uses a given widget as its configuration can be updated to
  /// use another widget as its configuration if, and only if, the two widgets
  /// have [runtimeType] and [key] properties that are [operator==].
  ///
  /// If the widgets have no key (their key is null), then they are considered a
  /// match if they have the same type, even if their children are completely
  /// different.
  static bool canUpdate(Widget oldWidget, Widget newWidget) {
    return oldWidget.runtimeType == newWidget.runtimeType && oldWidget.key == newWidget.key;
  }

  // Return a numeric encoding of the specific `Widget` concrete subtype.
  // This is used in `Element.updateChild` to determine if a hot reload modified the
  // superclass of a mounted element's configuration. The encoding of each `Widget`
  // must match the corresponding `Element` encoding in `Element._debugConcreteSubtype`.
  static int _debugConcreteSubtype(Widget widget) {
    return widget is StatefulWidget
        ? 1
        : widget is StatelessWidget
        ? 2
        : 0;
  }
}

/// A widget that does not require mutable state.
///
/// A stateless widget is a widget that describes part of the user interface by
/// building a constellation of other widgets that describe the user interface
/// more concretely. The building process continues recursively until the
/// description of the user interface is fully concrete (e.g., consists
/// entirely of [RenderObjectWidget]s, which describe concrete [RenderObject]s).
///
/// {@youtube 560 315 https://www.youtube.com/watch?v=wE7khGHVkYY}
///
/// Stateless widget are useful when the part of the user interface you are
/// describing does not depend on anything other than the configuration
/// information in the object itself and the [BuildContext] in which the widget
/// is inflated. For compositions that can change dynamically, e.g. due to
/// having an internal clock-driven state, or depending on some system state,
/// consider using [StatefulWidget].
///
/// ## Performance considerations
///
/// The [build] method of a stateless widget is typically only called in three
/// situations: the first time the widget is inserted in the tree, when the
/// widget's parent changes its configuration (see [Element.rebuild]), and when
/// an [InheritedWidget] it depends on changes.
///
/// If a widget's parent will regularly change the widget's configuration, or if
/// it depends on inherited widgets that frequently change, then it is important
/// to optimize the performance of the [build] method to maintain a fluid
/// rendering performance.
///
/// There are several techniques one can use to minimize the impact of
/// rebuilding a stateless widget:
///
///  * Minimize the number of nodes transitively created by the build method and
///    any widgets it creates. For example, instead of an elaborate arrangement
///    of [Row]s, [Column]s, [Padding]s, and [SizedBox]es to position a single
///    child in a particularly fancy manner, consider using just an [Align] or a
///    [CustomSingleChildLayout]. Instead of an intricate layering of multiple
///    [Container]s and with [Decoration]s to draw just the right graphical
///    effect, consider a single [CustomPaint] widget.
///
///  * Use `const` widgets where possible, and provide a `const` constructor for
///    the widget so that users of the widget can also do so.
///
///  * Consider refactoring the stateless widget into a stateful widget so that
///    it can use some of the techniques described at [StatefulWidget], such as
///    caching common parts of subtrees and using [GlobalKey]s when changing the
///    tree structure.
///
///  * If the widget is likely to get rebuilt frequently due to the use of
///    [InheritedWidget]s, consider refactoring the stateless widget into
///    multiple widgets, with the parts of the tree that change being pushed to
///    the leaves. For example instead of building a tree with four widgets, the
///    inner-most widget depending on the [Theme], consider factoring out the
///    part of the build function that builds the inner-most widget into its own
///    widget, so that only the inner-most widget needs to be rebuilt when the
///    theme changes.
/// {@template flutter.flutter.widgets.framework.prefer_const_over_helper}
///  * When trying to create a reusable piece of UI, prefer using a widget
///    rather than a helper method. For example, if there was a function used to
///    build a widget, a [State.setState] call would require Flutter to entirely
///    rebuild the returned wrapping widget. If a [Widget] was used instead,
///    Flutter would be able to efficiently re-render only those parts that
///    really need to be updated. Even better, if the created widget is `const`,
///    Flutter would short-circuit most of the rebuild work.
/// {@endtemplate}
///
/// This video gives more explanations on why `const` constructors are important
/// and why a [Widget] is better than a helper method.
///
/// {@youtube 560 315 https://www.youtube.com/watch?v=IOyq-eTRhvo}
///
/// {@tool snippet}
///
/// The following is a skeleton of a stateless widget subclass called `GreenFrog`.
///
/// Normally, widgets have more constructor arguments, each of which corresponds
/// to a `final` property.
///
/// ```dart
/// class GreenFrog extends StatelessWidget {
///   const GreenFrog({ super.key });
///
///   @override
///   Widget build(BuildContext context) {
///     return Container(color: const Color(0xFF2DBD3A));
///   }
/// }
/// ```
/// {@end-tool}
///
/// {@tool snippet}
///
/// This next example shows the more generic widget `Frog` which can be given
/// a color and a child:
///
/// ```dart
/// class Frog extends StatelessWidget {
///   const Frog({
///     super.key,
///     this.color = const Color(0xFF2DBD3A),
///     this.child,
///   });
///
///   final Color color;
///   final Widget? child;
///
///   @override
///   Widget build(BuildContext context) {
///     return ColoredBox(color: color, child: child);
///   }
/// }
/// ```
/// {@end-tool}
///
/// By convention, widget constructors only use named arguments. Also by
/// convention, the first argument is [key], and the last argument is `child`,
/// `children`, or the equivalent.
///
/// See also:
///
///  * [StatefulWidget] and [State], for widgets that can build differently
///    several times over their lifetime.
///  * [InheritedWidget], for widgets that introduce ambient state that can
///    be read by descendant widgets.
abstract class StatelessWidget extends Widget {
  /// Initializes [key] for subclasses.
  const StatelessWidget({super.key});

  /// Creates a [StatelessElement] to manage this widget's location in the tree.
  ///
  /// It is uncommon for subclasses to override this method.
  @override
  StatelessElement createElement() => StatelessElement(this);

  /// Describes the part of the user interface represented by this widget.
  ///
  /// The framework calls this method when this widget is inserted into the tree
  /// in a given [BuildContext] and when the dependencies of this widget change
  /// (e.g., an [InheritedWidget] referenced by this widget changes). This
  /// method can potentially be called in every frame and should not have any side
  /// effects beyond building a widget.
  ///
  /// The framework replaces the subtree below this widget with the widget
  /// returned by this method, either by updating the existing subtree or by
  /// removing the subtree and inflating a new subtree, depending on whether the
  /// widget returned by this method can update the root of the existing
  /// subtree, as determined by calling [Widget.canUpdate].
  ///
  /// Typically implementations return a newly created constellation of widgets
  /// that are configured with information from this widget's constructor and
  /// from the given [BuildContext].
  ///
  /// The given [BuildContext] contains information about the location in the
  /// tree at which this widget is being built. For example, the context
  /// provides the set of inherited widgets for this location in the tree. A
  /// given widget might be built with multiple different [BuildContext]
  /// arguments over time if the widget is moved around the tree or if the
  /// widget is inserted into the tree in multiple places at once.
  ///
  /// The implementation of this method must only depend on:
  ///
  /// * the fields of the widget, which themselves must not change over time,
  ///   and
  /// * any ambient state obtained from the `context` using
  ///   [BuildContext.dependOnInheritedWidgetOfExactType].
  ///
  /// If a widget's [build] method is to depend on anything else, use a
  /// [StatefulWidget] instead.
  ///
  /// See also:
  ///
  ///  * [StatelessWidget], which contains the discussion on performance considerations.
  @protected
  Widget build(BuildContext context);
}

/// A widget that has mutable state.
///
/// State is information that (1) can be read synchronously when the widget is
/// built and (2) might change during the lifetime of the widget. It is the
/// responsibility of the widget implementer to ensure that the [State] is
/// promptly notified when such state changes, using [State.setState].
///
/// A stateful widget is a widget that describes part of the user interface by
/// building a constellation of other widgets that describe the user interface
/// more concretely. The building process continues recursively until the
/// description of the user interface is fully concrete (e.g., consists
/// entirely of [RenderObjectWidget]s, which describe concrete [RenderObject]s).
///
/// Stateful widgets are useful when the part of the user interface you are
/// describing can change dynamically, e.g. due to having an internal
/// clock-driven state, or depending on some system state. For compositions that
/// depend only on the configuration information in the object itself and the
/// [BuildContext] in which the widget is inflated, consider using
/// [StatelessWidget].
///
/// {@youtube 560 315 https://www.youtube.com/watch?v=AqCMFXEmf3w}
///
/// [StatefulWidget] instances themselves are immutable and store their mutable
/// state either in separate [State] objects that are created by the
/// [createState] method, or in objects to which that [State] subscribes, for
/// example [Stream] or [ChangeNotifier] objects, to which references are stored
/// in final fields on the [StatefulWidget] itself.
///
/// The framework calls [createState] whenever it inflates a
/// [StatefulWidget], which means that multiple [State] objects might be
/// associated with the same [StatefulWidget] if that widget has been inserted
/// into the tree in multiple places. Similarly, if a [StatefulWidget] is
/// removed from the tree and later inserted in to the tree again, the framework
/// will call [createState] again to create a fresh [State] object, simplifying
/// the lifecycle of [State] objects.
///
/// A [StatefulWidget] keeps the same [State] object when moving from one
/// location in the tree to another if its creator used a [GlobalKey] for its
/// [key]. Because a widget with a [GlobalKey] can be used in at most one
/// location in the tree, a widget that uses a [GlobalKey] has at most one
/// associated element. The framework takes advantage of this property when
/// moving a widget with a global key from one location in the tree to another
/// by grafting the (unique) subtree associated with that widget from the old
/// location to the new location (instead of recreating the subtree at the new
/// location). The [State] objects associated with [StatefulWidget] are grafted
/// along with the rest of the subtree, which means the [State] object is reused
/// (instead of being recreated) in the new location. However, in order to be
/// eligible for grafting, the widget must be inserted into the new location in
/// the same animation frame in which it was removed from the old location.
///
/// ## Performance considerations
///
/// There are two primary categories of [StatefulWidget]s.
///
/// The first is one which allocates resources in [State.initState] and disposes
/// of them in [State.dispose], but which does not depend on [InheritedWidget]s
/// or call [State.setState]. Such widgets are commonly used at the root of an
/// application or page, and communicate with subwidgets via [ChangeNotifier]s,
/// [Stream]s, or other such objects. Stateful widgets following such a pattern
/// are relatively cheap (in terms of CPU and GPU cycles), because they are
/// built once then never update. They can, therefore, have somewhat complicated
/// and deep build methods.
///
/// The second category is widgets that use [State.setState] or depend on
/// [InheritedWidget]s. These will typically rebuild many times during the
/// application's lifetime, and it is therefore important to minimize the impact
/// of rebuilding such a widget. (They may also use [State.initState] or
/// [State.didChangeDependencies] and allocate resources, but the important part
/// is that they rebuild.)
///
/// There are several techniques one can use to minimize the impact of
/// rebuilding a stateful widget:
///
///  * Push the state to the leaves. For example, if your page has a ticking
///    clock, rather than putting the state at the top of the page and
///    rebuilding the entire page each time the clock ticks, create a dedicated
///    clock widget that only updates itself.
///
///  * Minimize the number of nodes transitively created by the build method and
///    any widgets it creates. Ideally, a stateful widget would only create a
///    single widget, and that widget would be a [RenderObjectWidget].
///    (Obviously this isn't always practical, but the closer a widget gets to
///    this ideal, the more efficient it will be.)
///
///  * If a subtree does not change, cache the widget that represents that
///    subtree and re-use it each time it can be used. To do this, assign
///    a widget to a `final` state variable and re-use it in the build method. It
///    is massively more efficient for a widget to be re-used than for a new (but
///    identically-configured) widget to be created. Another caching strategy
///    consists in extracting the mutable part of the widget into a [StatefulWidget]
///    which accepts a child parameter.
///
///  * Use `const` widgets where possible. (This is equivalent to caching a
///    widget and re-using it.)
///
///  * Avoid changing the depth of any created subtrees or changing the type of
///    any widgets in the subtree. For example, rather than returning either the
///    child or the child wrapped in an [IgnorePointer], always wrap the child
///    widget in an [IgnorePointer] and control the [IgnorePointer.ignoring]
///    property. This is because changing the depth of the subtree requires
///    rebuilding, laying out, and painting the entire subtree, whereas just
///    changing the property will require the least possible change to the
///    render tree (in the case of [IgnorePointer], for example, no layout or
///    repaint is necessary at all).
///
///  * If the depth must be changed for some reason, consider wrapping the
///    common parts of the subtrees in widgets that have a [GlobalKey] that
///    remains consistent for the life of the stateful widget. (The
///    [KeyedSubtree] widget may be useful for this purpose if no other widget
///    can conveniently be assigned the key.)
///
/// {@macro flutter.flutter.widgets.framework.prefer_const_over_helper}
///
/// This video gives more explanations on why `const` constructors are important
/// and why a [Widget] is better than a helper method.
///
/// {@youtube 560 315 https://www.youtube.com/watch?v=IOyq-eTRhvo}
///
/// For more details on the mechanics of rebuilding a widget, see
/// the discussion at [Element.rebuild].
///
/// {@tool snippet}
///
/// This is a skeleton of a stateful widget subclass called `YellowBird`.
///
/// In this example, the [State] has no actual state. State is normally
/// represented as private member fields. Also, normally widgets have more
/// constructor arguments, each of which corresponds to a `final` property.
///
/// ```dart
/// class YellowBird extends StatefulWidget {
///   const YellowBird({ super.key });
///
///   @override
///   State<YellowBird> createState() => _YellowBirdState();
/// }
///
/// class _YellowBirdState extends State<YellowBird> {
///   @override
///   Widget build(BuildContext context) {
///     return Container(color: const Color(0xFFFFE306));
///   }
/// }
/// ```
/// {@end-tool}
/// {@tool snippet}
///
/// This example shows the more generic widget `Bird` which can be given a
/// color and a child, and which has some internal state with a method that
/// can be called to mutate it:
///
/// ```dart
/// class Bird extends StatefulWidget {
///   const Bird({
///     super.key,
///     this.color = const Color(0xFFFFE306),
///     this.child,
///   });
///
///   final Color color;
///   final Widget? child;
///
///   @override
///   State<Bird> createState() => _BirdState();
/// }
///
/// class _BirdState extends State<Bird> {
///   double _size = 1.0;
///
///   void grow() {
///     setState(() { _size += 0.1; });
///   }
///
///   @override
///   Widget build(BuildContext context) {
///     return Container(
///       color: widget.color,
///       transform: Matrix4.diagonal3Values(_size, _size, 1.0),
///       child: widget.child,
///     );
///   }
/// }
/// ```
/// {@end-tool}
///
/// By convention, widget constructors only use named arguments. Also by
/// convention, the first argument is [key], and the last argument is `child`,
/// `children`, or the equivalent.
///
/// See also:
///
///  * [State], where the logic behind a [StatefulWidget] is hosted.
///  * [StatelessWidget], for widgets that always build the same way given a
///    particular configuration and ambient state.
///  * [InheritedWidget], for widgets that introduce ambient state that can
///    be read by descendant widgets.
abstract class StatefulWidget extends Widget {
  /// Initializes [key] for subclasses.
  const StatefulWidget({super.key});

  /// Creates a [StatefulElement] to manage this widget's location in the tree.
  ///
  /// It is uncommon for subclasses to override this method.
  @override
  StatefulElement createElement() => StatefulElement(this);

  /// Creates the mutable state for this widget at a given location in the tree.
  ///
  /// Subclasses should override this method to return a newly created
  /// instance of their associated [State] subclass:
  ///
  /// ```dart
  /// @override
  /// State<SomeWidget> createState() => _SomeWidgetState();
  /// ```
  ///
  /// The framework can call this method multiple times over the lifetime of
  /// a [StatefulWidget]. For example, if the widget is inserted into the tree
  /// in multiple locations, the framework will create a separate [State] object
  /// for each location. Similarly, if the widget is removed from the tree and
  /// later inserted into the tree again, the framework will call [createState]
  /// again to create a fresh [State] object, simplifying the lifecycle of
  /// [State] objects.
  @protected
  @factory
  State createState();
}

/// Tracks the lifecycle of [State] objects when asserts are enabled.
enum _StateLifecycle {
  /// The [State] object has been created. [State.initState] is called at this
  /// time.
  created,

  /// The [State.initState] method has been called but the [State] object is
  /// not yet ready to build. [State.didChangeDependencies] is called at this time.
  initialized,

  /// The [State] object is ready to build and [State.dispose] has not yet been
  /// called.
  ready,

  /// The [State.dispose] method has been called and the [State] object is
  /// no longer able to build.
  defunct,
}

/// The signature of [State.setState] functions.
typedef StateSetter = void Function(VoidCallback fn);

/// The logic and internal state for a [StatefulWidget].
///
/// State is information that (1) can be read synchronously when the widget is
/// built and (2) might change during the lifetime of the widget. It is the
/// responsibility of the widget implementer to ensure that the [State] is
/// promptly notified when such state changes, using [State.setState].
///
/// [State] objects are created by the framework by calling the
/// [StatefulWidget.createState] method when inflating a [StatefulWidget] to
/// insert it into the tree. Because a given [StatefulWidget] instance can be
/// inflated multiple times (e.g., the widget is incorporated into the tree in
/// multiple places at once), there might be more than one [State] object
/// associated with a given [StatefulWidget] instance. Similarly, if a
/// [StatefulWidget] is removed from the tree and later inserted in to the tree
/// again, the framework will call [StatefulWidget.createState] again to create
/// a fresh [State] object, simplifying the lifecycle of [State] objects.
///
/// [State] objects have the following lifecycle:
///
///  * The framework creates a [State] object by calling
///    [StatefulWidget.createState].
///  * The newly created [State] object is associated with a [BuildContext].
///    This association is permanent: the [State] object will never change its
///    [BuildContext]. However, the [BuildContext] itself can be moved around
///    the tree along with its subtree. At this point, the [State] object is
///    considered [mounted].
///  * The framework calls [initState]. Subclasses of [State] should override
///    [initState] to perform one-time initialization that depends on the
///    [BuildContext] or the widget, which are available as the [context] and
///    [widget] properties, respectively, when the [initState] method is
///    called.
///  * The framework calls [didChangeDependencies]. Subclasses of [State] should
///    override [didChangeDependencies] to perform initialization involving
///    [InheritedWidget]s. If [BuildContext.dependOnInheritedWidgetOfExactType] is
///    called, the [didChangeDependencies] method will be called again if the
///    inherited widgets subsequently change or if the widget moves in the tree.
///  * At this point, the [State] object is fully initialized and the framework
///    might call its [build] method any number of times to obtain a
///    description of the user interface for this subtree. [State] objects can
///    spontaneously request to rebuild their subtree by calling their
///    [setState] method, which indicates that some of their internal state
///    has changed in a way that might impact the user interface in this
///    subtree.
///  * During this time, a parent widget might rebuild and request that this
///    location in the tree update to display a new widget with the same
///    [runtimeType] and [Widget.key]. When this happens, the framework will
///    update the [widget] property to refer to the new widget and then call the
///    [didUpdateWidget] method with the previous widget as an argument. [State]
///    objects should override [didUpdateWidget] to respond to changes in their
///    associated widget (e.g., to start implicit animations). The framework
///    always calls [build] after calling [didUpdateWidget], which means any
///    calls to [setState] in [didUpdateWidget] are redundant. (See also the
///    discussion at [Element.rebuild].)
///  * During development, if a hot reload occurs (whether initiated from the
///    command line `flutter` tool by pressing `r`, or from an IDE), the
///    [reassemble] method is called. This provides an opportunity to
///    reinitialize any data that was prepared in the [initState] method.
///  * If the subtree containing the [State] object is removed from the tree
///    (e.g., because the parent built a widget with a different [runtimeType]
///    or [Widget.key]), the framework calls the [deactivate] method. Subclasses
///    should override this method to clean up any links between this object
///    and other elements in the tree (e.g. if you have provided an ancestor
///    with a pointer to a descendant's [RenderObject]).
///  * At this point, the framework might reinsert this subtree into another
///    part of the tree. If that happens, the framework will ensure that it
///    calls [build] to give the [State] object a chance to adapt to its new
///    location in the tree. If the framework does reinsert this subtree, it
///    will do so before the end of the animation frame in which the subtree was
///    removed from the tree. For this reason, [State] objects can defer
///    releasing most resources until the framework calls their [dispose]
///    method.
///  * If the framework does not reinsert this subtree by the end of the current
///    animation frame, the framework will call [dispose], which indicates that
///    this [State] object will never build again. Subclasses should override
///    this method to release any resources retained by this object (e.g.,
///    stop any active animations).
///  * After the framework calls [dispose], the [State] object is considered
///    unmounted and the [mounted] property is false. It is an error to call
///    [setState] at this point. This stage of the lifecycle is terminal: there
///    is no way to remount a [State] object that has been disposed.
///
/// See also:
///
///  * [StatefulWidget], where the current configuration of a [State] is hosted,
///    and whose documentation has sample code for [State].
///  * [StatelessWidget], for widgets that always build the same way given a
///    particular configuration and ambient state.
///  * [InheritedWidget], for widgets that introduce ambient state that can
///    be read by descendant widgets.
///  * [Widget], for an overview of widgets in general.
@optionalTypeArgs
abstract class State<T extends StatefulWidget> with Diagnosticable {
  /// The current configuration.
  ///
  /// A [State] object's configuration is the corresponding [StatefulWidget]
  /// instance. This property is initialized by the framework before calling
  /// [initState]. If the parent updates this location in the tree to a new
  /// widget with the same [runtimeType] and [Widget.key] as the current
  /// configuration, the framework will update this property to refer to the new
  /// widget and then call [didUpdateWidget], passing the old configuration as
  /// an argument.
  T get widget => _widget!;
  T? _widget;

  /// The current stage in the lifecycle for this state object.
  ///
  /// This field is used by the framework when asserts are enabled to verify
  /// that [State] objects move through their lifecycle in an orderly fashion.
  _StateLifecycle _debugLifecycleState = _StateLifecycle.created;

  /// Verifies that the [State] that was created is one that expects to be
  /// created for that particular [Widget].
  bool _debugTypesAreRight(Widget widget) => widget is T;

  /// The location in the tree where this widget builds.
  ///
  /// The framework associates [State] objects with a [BuildContext] after
  /// creating them with [StatefulWidget.createState] and before calling
  /// [initState]. The association is permanent: the [State] object will never
  /// change its [BuildContext]. However, the [BuildContext] itself can be moved
  /// around the tree.
  ///
  /// After calling [dispose], the framework severs the [State] object's
  /// connection with the [BuildContext].
  BuildContext get context {
    assert(() {
      if (_element == null) {
        throw FlutterError(
          'This widget has been unmounted, so the State no longer has a context (and should be considered defunct). \n'
          'Consider canceling any active work during "dispose" or using the "mounted" getter to determine if the State is still active.',
        );
      }
      return true;
    }());
    return _element!;
  }

  StatefulElement? _element;

  /// Whether this [State] object is currently in a tree.
  ///
  /// After creating a [State] object and before calling [initState], the
  /// framework "mounts" the [State] object by associating it with a
  /// [BuildContext]. The [State] object remains mounted until the framework
  /// calls [dispose], after which time the framework will never ask the [State]
  /// object to [build] again.
  ///
  /// It is an error to call [setState] unless [mounted] is true.
  bool get mounted => _element != null;

  /// Called when this object is inserted into the tree.
  ///
  /// The framework will call this method exactly once for each [State] object
  /// it creates.
  ///
  /// Override this method to perform initialization that depends on the
  /// location at which this object was inserted into the tree (i.e., [context])
  /// or on the widget used to configure this object (i.e., [widget]).
  ///
  /// {@template flutter.widgets.State.initState}
  /// If a [State]'s [build] method depends on an object that can itself
  /// change state, for example a [ChangeNotifier] or [Stream], or some
  /// other object to which one can subscribe to receive notifications, then
  /// be sure to subscribe and unsubscribe properly in [initState],
  /// [didUpdateWidget], and [dispose]:
  ///
  ///  * In [initState], subscribe to the object.
  ///  * In [didUpdateWidget] unsubscribe from the old object and subscribe
  ///    to the new one if the updated widget configuration requires
  ///    replacing the object.
  ///  * In [dispose], unsubscribe from the object.
  ///
  /// {@endtemplate}
  ///
  /// You should not use [BuildContext.dependOnInheritedWidgetOfExactType] from this
  /// method. However, [didChangeDependencies] will be called immediately
  /// following this method, and [BuildContext.dependOnInheritedWidgetOfExactType] can
  /// be used there.
  ///
  /// Implementations of this method should start with a call to the inherited
  /// method, as in `super.initState()`.
  @protected
  @mustCallSuper
  void initState() {
    assert(_debugLifecycleState == _StateLifecycle.created);
    assert(debugMaybeDispatchCreated('widgets', 'State', this));
  }

  /// Called whenever the widget configuration changes.
  ///
  /// If the parent widget rebuilds and requests that this location in the tree
  /// update to display a new widget with the same [runtimeType] and
  /// [Widget.key], the framework will update the [widget] property of this
  /// [State] object to refer to the new widget and then call this method
  /// with the previous widget as an argument.
  ///
  /// Override this method to respond when the [widget] changes (e.g., to start
  /// implicit animations).
  ///
  /// The framework always calls [build] after calling [didUpdateWidget], which
  /// means any calls to [setState] in [didUpdateWidget] are redundant.
  ///
  /// {@macro flutter.widgets.State.initState}
  ///
  /// Implementations of this method should start with a call to the inherited
  /// method, as in `super.didUpdateWidget(oldWidget)`.
  ///
  /// _See the discussion at [Element.rebuild] for more information on when this
  /// method is called._
  @mustCallSuper
  @protected
  void didUpdateWidget(covariant T oldWidget) {}

  /// {@macro flutter.widgets.Element.reassemble}
  ///
  /// In addition to this method being invoked, it is guaranteed that the
  /// [build] method will be invoked when a reassemble is signaled. Most
  /// widgets therefore do not need to do anything in the [reassemble] method.
  ///
  /// See also:
  ///
  ///  * [Element.reassemble]
  ///  * [BindingBase.reassembleApplication]
  ///  * [Image], which uses this to reload images.
  @protected
  @mustCallSuper
  void reassemble() {}

  /// Notify the framework that the internal state of this object has changed.
  ///
  /// Whenever you change the internal state of a [State] object, make the
  /// change in a function that you pass to [setState]:
  ///
  /// ```dart
  /// setState(() { _myState = newValue; });
  /// ```
  ///
  /// The provided callback is immediately called synchronously. It must not
  /// return a future (the callback cannot be `async`), since then it would be
  /// unclear when the state was actually being set.
  ///
  /// Calling [setState] notifies the framework that the internal state of this
  /// object has changed in a way that might impact the user interface in this
  /// subtree, which causes the framework to schedule a [build] for this [State]
  /// object.
  ///
  /// If you just change the state directly without calling [setState], the
  /// framework might not schedule a [build] and the user interface for this
  /// subtree might not be updated to reflect the new state.
  ///
  /// Generally it is recommended that the [setState] method only be used to
  /// wrap the actual changes to the state, not any computation that might be
  /// associated with the change. For example, here a value used by the [build]
  /// function is incremented, and then the change is written to disk, but only
  /// the increment is wrapped in the [setState]:
  ///
  /// ```dart
  /// Future<void> _incrementCounter() async {
  ///   setState(() {
  ///     _counter++;
  ///   });
  ///   Directory directory = await getApplicationDocumentsDirectory(); // from path_provider package
  ///   final String dirName = directory.path;
  ///   await File('$dirName/counter.txt').writeAsString('$_counter');
  /// }
  /// ```
  ///
  /// Sometimes, the changed state is in some other object not owned by the
  /// widget [State], but the widget nonetheless needs to be updated to react to
  /// the new state. This is especially common with [Listenable]s, such as
  /// [AnimationController]s.
  ///
  /// In such cases, it is good practice to leave a comment in the callback
  /// passed to [setState] that explains what state changed:
  ///
  /// ```dart
  /// void _update() {
  ///   setState(() { /* The animation changed. */ });
  /// }
  /// //...
  /// animation.addListener(_update);
  /// ```
  ///
  /// It is an error to call this method after the framework calls [dispose].
  /// You can determine whether it is legal to call this method by checking
  /// whether the [mounted] property is true. That said, it is better practice
  /// to cancel whatever work might trigger the [setState] rather than merely
  /// checking for [mounted] before calling [setState], as otherwise CPU cycles
  /// will be wasted.
  ///
  /// ## Design discussion
  ///
  /// The original version of this API was a method called `markNeedsBuild`, for
  /// consistency with [RenderObject.markNeedsLayout],
  /// [RenderObject.markNeedsPaint], _et al_.
  ///
  /// However, early user testing of the Flutter framework revealed that people
  /// would call `markNeedsBuild()` much more often than necessary. Essentially,
  /// people used it like a good luck charm, any time they weren't sure if they
  /// needed to call it, they would call it, just in case.
  ///
  /// Naturally, this led to performance issues in applications.
  ///
  /// When the API was changed to take a callback instead, this practice was
  /// greatly reduced. One hypothesis is that prompting developers to actually
  /// update their state in a callback caused developers to think more carefully
  /// about what exactly was being updated, and thus improved their understanding
  /// of the appropriate times to call the method.
  ///
  /// In practice, the [setState] method's implementation is trivial: it calls
  /// the provided callback synchronously, then calls [Element.markNeedsBuild].
  ///
  /// ## Performance considerations
  ///
  /// There is minimal _direct_ overhead to calling this function, and as it is
  /// expected to be called at most once per frame, the overhead is irrelevant
  /// anyway. Nonetheless, it is best to avoid calling this function redundantly
  /// (e.g. in a tight loop), as it does involve creating a closure and calling
  /// it. The method is idempotent, there is no benefit to calling it more than
  /// once per [State] per frame.
  ///
  /// The _indirect_ cost of causing this function, however, is high: it causes
  /// the widget to rebuild, possibly triggering rebuilds for the entire subtree
  /// rooted at this widget, and further triggering a relayout and repaint of
  /// the entire corresponding [RenderObject] subtree.
  ///
  /// For this reason, this method should only be called when the [build] method
  /// will, as a result of whatever state change was detected, change its result
  /// meaningfully.
  ///
  /// See also:
  ///
  ///  * [StatefulWidget], the API documentation for which has a section on
  ///    performance considerations that are relevant here.
  @protected
  void setState(VoidCallback fn) {
    assert(() {
      if (_debugLifecycleState == _StateLifecycle.defunct) {
        throw FlutterError.fromParts(<DiagnosticsNode>[
          ErrorSummary('setState() called after dispose(): $this'),
          ErrorDescription(
            'This error happens if you call setState() on a State object for a widget that '
            'no longer appears in the widget tree (e.g., whose parent widget no longer '
            'includes the widget in its build). This error can occur when code calls '
            'setState() from a timer or an animation callback.',
          ),
          ErrorHint(
            'The preferred solution is '
            'to cancel the timer or stop listening to the animation in the dispose() '
            'callback. Another solution is to check the "mounted" property of this '
            'object before calling setState() to ensure the object is still in the '
            'tree.',
          ),
          ErrorHint(
            'This error might indicate a memory leak if setState() is being called '
            'because another object is retaining a reference to this State object '
            'after it has been removed from the tree. To avoid memory leaks, '
            'consider breaking the reference to this object during dispose().',
          ),
        ]);
      }
      if (_debugLifecycleState == _StateLifecycle.created && !mounted) {
        throw FlutterError.fromParts(<DiagnosticsNode>[
          ErrorSummary('setState() called in constructor: $this'),
          ErrorHint(
            'This happens when you call setState() on a State object for a widget that '
            "hasn't been inserted into the widget tree yet. It is not necessary to call "
            'setState() in the constructor, since the state is already assumed to be dirty '
            'when it is initially created.',
          ),
        ]);
      }
      return true;
    }());
    final Object? result = fn() as dynamic;
    assert(() {
      if (result is Future) {
        throw FlutterError.fromParts(<DiagnosticsNode>[
          ErrorSummary('setState() callback argument returned a Future.'),
          ErrorDescription(
            'The setState() method on $this was called with a closure or method that '
            'returned a Future. Maybe it is marked as "async".',
          ),
          ErrorHint(
            'Instead of performing asynchronous work inside a call to setState(), first '
            'execute the work (without updating the widget state), and then synchronously '
            'update the state inside a call to setState().',
          ),
        ]);
      }
      // We ignore other types of return values so that you can do things like:
      //   setState(() => x = 3);
      return true;
    }());
    _element!.markNeedsBuild();
  }

  /// Called when this object is removed from the tree.
  ///
  /// The framework calls this method whenever it removes this [State] object
  /// from the tree. In some cases, the framework will reinsert the [State]
  /// object into another part of the tree (e.g., if the subtree containing this
  /// [State] object is grafted from one location in the tree to another due to
  /// the use of a [GlobalKey]). If that happens, the framework will call
  /// [activate] to give the [State] object a chance to reacquire any resources
  /// that it released in [deactivate]. It will then also call [build] to give
  /// the [State] object a chance to adapt to its new location in the tree. If
  /// the framework does reinsert this subtree, it will do so before the end of
  /// the animation frame in which the subtree was removed from the tree. For
  /// this reason, [State] objects can defer releasing most resources until the
  /// framework calls their [dispose] method.
  ///
  /// Subclasses should override this method to clean up any links between
  /// this object and other elements in the tree (e.g. if you have provided an
  /// ancestor with a pointer to a descendant's [RenderObject]).
  ///
  /// Implementations of this method should end with a call to the inherited
  /// method, as in `super.deactivate()`.
  ///
  /// See also:
  ///
  ///  * [dispose], which is called after [deactivate] if the widget is removed
  ///    from the tree permanently.
  @protected
  @mustCallSuper
  void deactivate() {}

  /// Called when this object is reinserted into the tree after having been
  /// removed via [deactivate].
  ///
  /// In most cases, after a [State] object has been deactivated, it is _not_
  /// reinserted into the tree, and its [dispose] method will be called to
  /// signal that it is ready to be garbage collected.
  ///
  /// In some cases, however, after a [State] object has been deactivated, the
  /// framework will reinsert it into another part of the tree (e.g., if the
  /// subtree containing this [State] object is grafted from one location in
  /// the tree to another due to the use of a [GlobalKey]). If that happens,
  /// the framework will call [activate] to give the [State] object a chance to
  /// reacquire any resources that it released in [deactivate]. It will then
  /// also call [build] to give the object a chance to adapt to its new
  /// location in the tree. If the framework does reinsert this subtree, it
  /// will do so before the end of the animation frame in which the subtree was
  /// removed from the tree. For this reason, [State] objects can defer
  /// releasing most resources until the framework calls their [dispose] method.
  ///
  /// The framework does not call this method the first time a [State] object
  /// is inserted into the tree. Instead, the framework calls [initState] in
  /// that situation.
  ///
  /// Implementations of this method should start with a call to the inherited
  /// method, as in `super.activate()`.
  ///
  /// See also:
  ///
  ///  * [Element.activate], the corresponding method when an element
  ///    transitions from the "inactive" to the "active" lifecycle state.
  @protected
  @mustCallSuper
  void activate() {}

  /// Called when this object is removed from the tree permanently.
  ///
  /// The framework calls this method when this [State] object will never
  /// build again. After the framework calls [dispose], the [State] object is
  /// considered unmounted and the [mounted] property is false. It is an error
  /// to call [setState] at this point. This stage of the lifecycle is terminal:
  /// there is no way to remount a [State] object that has been disposed.
  ///
  /// Subclasses should override this method to release any resources retained
  /// by this object (e.g., stop any active animations).
  ///
  /// {@macro flutter.widgets.State.initState}
  ///
  /// Implementations of this method should end with a call to the inherited
  /// method, as in `super.dispose()`.
  ///
  /// ## Caveats
  ///
  /// This method is _not_ invoked at times where a developer might otherwise
  /// expect it, such as application shutdown or dismissal via platform
  /// native methods.
  ///
  /// ### Application shutdown
  ///
  /// There is no way to predict when application shutdown will happen. For
  /// example, a user's battery could catch fire, or the user could drop the
  /// device into a swimming pool, or the operating system could unilaterally
  /// terminate the application process due to memory pressure.
  ///
  /// Applications are responsible for ensuring that they are well-behaved
  /// even in the face of a rapid unscheduled termination.
  ///
  /// To artificially cause the entire widget tree to be disposed, consider
  /// calling [runApp] with a widget such as [SizedBox.shrink].
  ///
  /// To listen for platform shutdown messages (and other lifecycle changes),
  /// consider the [AppLifecycleListener] API.
  ///
  /// {@macro flutter.widgets.runApp.dismissal}
  ///
  /// See the method used to bootstrap the app (e.g. [runApp] or [runWidget])
  /// for suggestions on how to release resources more eagerly.
  ///
  /// See also:
  ///
  ///  * [deactivate], which is called prior to [dispose].
  @protected
  @mustCallSuper
  void dispose() {
    assert(_debugLifecycleState == _StateLifecycle.ready);
    assert(() {
      _debugLifecycleState = _StateLifecycle.defunct;
      return true;
    }());
    assert(debugMaybeDispatchDisposed(this));
  }

  /// Describes the part of the user interface represented by this widget.
  ///
  /// The framework calls this method in a number of different situations. For
  /// example:
  ///
  ///  * After calling [initState].
  ///  * After calling [didUpdateWidget].
  ///  * After receiving a call to [setState].
  ///  * After a dependency of this [State] object changes (e.g., an
  ///    [InheritedWidget] referenced by the previous [build] changes).
  ///  * After calling [deactivate] and then reinserting the [State] object into
  ///    the tree at another location.
  ///
  /// This method can potentially be called in every frame and should not have
  /// any side effects beyond building a widget.
  ///
  /// The framework replaces the subtree below this widget with the widget
  /// returned by this method, either by updating the existing subtree or by
  /// removing the subtree and inflating a new subtree, depending on whether the
  /// widget returned by this method can update the root of the existing
  /// subtree, as determined by calling [Widget.canUpdate].
  ///
  /// Typically implementations return a newly created constellation of widgets
  /// that are configured with information from this widget's constructor, the
  /// given [BuildContext], and the internal state of this [State] object.
  ///
  /// The given [BuildContext] contains information about the location in the
  /// tree at which this widget is being built. For example, the context
  /// provides the set of inherited widgets for this location in the tree. The
  /// [BuildContext] argument is always the same as the [context] property of
  /// this [State] object and will remain the same for the lifetime of this
  /// object. The [BuildContext] argument is provided redundantly here so that
  /// this method matches the signature for a [WidgetBuilder].
  ///
  /// ## Design discussion
  ///
  /// ### Why is the [build] method on [State], and not [StatefulWidget]?
  ///
  /// Putting a `Widget build(BuildContext context)` method on [State] rather
  /// than putting a `Widget build(BuildContext context, State state)` method
  /// on [StatefulWidget] gives developers more flexibility when subclassing
  /// [StatefulWidget].
  ///
  /// For example, [AnimatedWidget] is a subclass of [StatefulWidget] that
  /// introduces an abstract `Widget build(BuildContext context)` method for its
  /// subclasses to implement. If [StatefulWidget] already had a [build] method
  /// that took a [State] argument, [AnimatedWidget] would be forced to provide
  /// its [State] object to subclasses even though its [State] object is an
  /// internal implementation detail of [AnimatedWidget].
  ///
  /// Conceptually, [StatelessWidget] could also be implemented as a subclass of
  /// [StatefulWidget] in a similar manner. If the [build] method were on
  /// [StatefulWidget] rather than [State], that would not be possible anymore.
  ///
  /// Putting the [build] function on [State] rather than [StatefulWidget] also
  /// helps avoid a category of bugs related to closures implicitly capturing
  /// `this`. If you defined a closure in a [build] function on a
  /// [StatefulWidget], that closure would implicitly capture `this`, which is
  /// the current widget instance, and would have the (immutable) fields of that
  /// instance in scope:
  ///
  /// ```dart
  /// // (this is not valid Flutter code)
  /// class MyButton extends StatefulWidgetX {
  ///   MyButton({super.key, required this.color});
  ///
  ///   final Color color;
  ///
  ///   @override
  ///   Widget build(BuildContext context, State state) {
  ///     return SpecialWidget(
  ///       handler: () { print('color: $color'); },
  ///     );
  ///   }
  /// }
  /// ```
  ///
  /// For example, suppose the parent builds `MyButton` with `color` being blue,
  /// the `$color` in the print function refers to blue, as expected. Now,
  /// suppose the parent rebuilds `MyButton` with green. The closure created by
  /// the first build still implicitly refers to the original widget and the
  /// `$color` still prints blue even through the widget has been updated to
  /// green; should that closure outlive its widget, it would print outdated
  /// information.
  ///
  /// In contrast, with the [build] function on the [State] object, closures
  /// created during [build] implicitly capture the [State] instance instead of
  /// the widget instance:
  ///
  /// ```dart
  /// class MyButton extends StatefulWidget {
  ///   const MyButton({super.key, this.color = Colors.teal});
  ///
  ///   final Color color;
  ///   // ...
  /// }
  ///
  /// class MyButtonState extends State<MyButton> {
  ///   // ...
  ///   @override
  ///   Widget build(BuildContext context) {
  ///     return SpecialWidget(
  ///       handler: () { print('color: ${widget.color}'); },
  ///     );
  ///   }
  /// }
  /// ```
  ///
  /// Now when the parent rebuilds `MyButton` with green, the closure created by
  /// the first build still refers to [State] object, which is preserved across
  /// rebuilds, but the framework has updated that [State] object's [widget]
  /// property to refer to the new `MyButton` instance and `${widget.color}`
  /// prints green, as expected.
  ///
  /// See also:
  ///
  ///  * [StatefulWidget], which contains the discussion on performance considerations.
  @protected
  Widget build(BuildContext context);

  /// Called when a dependency of this [State] object changes.
  ///
  /// For example, if the previous call to [build] referenced an
  /// [InheritedWidget] that later changed, the framework would call this
  /// method to notify this object about the change.
  ///
  /// This method is also called immediately after [initState]. It is safe to
  /// call [BuildContext.dependOnInheritedWidgetOfExactType] from this method.
  ///
  /// Subclasses rarely override this method because the framework always
  /// calls [build] after a dependency changes. Some subclasses do override
  /// this method because they need to do some expensive work (e.g., network
  /// fetches) when their dependencies change, and that work would be too
  /// expensive to do for every build.
  @protected
  @mustCallSuper
  void didChangeDependencies() {}

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    assert(() {
      properties.add(
        EnumProperty<_StateLifecycle>(
          'lifecycle state',
          _debugLifecycleState,
          defaultValue: _StateLifecycle.ready,
        ),
      );
      return true;
    }());
    properties.add(ObjectFlagProperty<T>('_widget', _widget, ifNull: 'no widget'));
    properties.add(
      ObjectFlagProperty<StatefulElement>('_element', _element, ifNull: 'not mounted'),
    );
  }

  // If @protected State methods are added or removed, the analysis rule should be
  // updated accordingly (dev/bots/custom_rules/protect_public_state_subtypes.dart)
}

/// A widget that has a child widget provided to it, instead of building a new
/// widget.
///
/// Useful as a base class for other widgets, such as [InheritedWidget] and
/// [ParentDataWidget].
///
/// See also:
///
///  * [InheritedWidget], for widgets that introduce ambient state that can
///    be read by descendant widgets.
///  * [ParentDataWidget], for widgets that populate the
///    [RenderObject.parentData] slot of their child's [RenderObject] to
///    configure the parent widget's layout.
///  * [StatefulWidget] and [State], for widgets that can build differently
///    several times over their lifetime.
///  * [StatelessWidget], for widgets that always build the same way given a
///    particular configuration and ambient state.
///  * [Widget], for an overview of widgets in general.
abstract class ProxyWidget extends Widget {
  /// Creates a widget that has exactly one child widget.
  const ProxyWidget({super.key, required this.child});

  /// The widget below this widget in the tree.
  ///
  /// {@template flutter.widgets.ProxyWidget.child}
  /// This widget can only have one child. To lay out multiple children, let this
  /// widget's child be a widget such as [Row], [Column], or [Stack], which have a
  /// `children` property, and then provide the children to that widget.
  /// {@endtemplate}
  final Widget child;
}

/// Base class for widgets that hook [ParentData] information to children of
/// [RenderObjectWidget]s.
///
/// This can be used to provide per-child configuration for
/// [RenderObjectWidget]s with more than one child. For example, [Stack] uses
/// the [Positioned] parent data widget to position each child.
///
/// A [ParentDataWidget] is specific to a particular kind of [ParentData]. That
/// class is `T`, the [ParentData] type argument.
///
/// {@tool snippet}
///
/// This example shows how you would build a [ParentDataWidget] to configure a
/// `FrogJar` widget's children by specifying a [Size] for each one.
///
/// ```dart
/// class FrogSize extends ParentDataWidget<FrogJarParentData> {
///   const FrogSize({
///     super.key,
///     required this.size,
///     required super.child,
///   });
///
///   final Size size;
///
///   @override
///   void applyParentData(RenderObject renderObject) {
///     final FrogJarParentData parentData = renderObject.parentData! as FrogJarParentData;
///     if (parentData.size != size) {
///       parentData.size = size;
///       final RenderFrogJar targetParent = renderObject.parent! as RenderFrogJar;
///       targetParent.markNeedsLayout();
///     }
///   }
///
///   @override
///   Type get debugTypicalAncestorWidgetClass => FrogJar;
/// }
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [RenderObject], the superclass for layout algorithms.
///  * [RenderObject.parentData], the slot that this class configures.
///  * [ParentData], the superclass of the data that will be placed in
///    [RenderObject.parentData] slots. The `T` type parameter for
///    [ParentDataWidget] is a [ParentData].
///  * [RenderObjectWidget], the class for widgets that wrap [RenderObject]s.
///  * [StatefulWidget] and [State], for widgets that can build differently
///    several times over their lifetime.
abstract class ParentDataWidget<T extends ParentData> extends ProxyWidget {
  /// Abstract const constructor. This constructor enables subclasses to provide
  /// const constructors so that they can be used in const expressions.
  const ParentDataWidget({super.key, required super.child});

  @override
  ParentDataElement<T> createElement() => ParentDataElement<T>(this);

  /// Checks if this widget can apply its parent data to the provided
  /// `renderObject`.
  ///
  /// The [RenderObject.parentData] of the provided `renderObject` is
  /// typically set up by an ancestor [RenderObjectWidget] of the type returned
  /// by [debugTypicalAncestorWidgetClass].
  ///
  /// This is called just before [applyParentData] is invoked with the same
  /// [RenderObject] provided to that method.
  bool debugIsValidRenderObject(RenderObject renderObject) {
    assert(T != dynamic);
    assert(T != ParentData);
    return renderObject.parentData is T;
  }

  /// Describes the [RenderObjectWidget] that is typically used to set up the
  /// [ParentData] that [applyParentData] will write to.
  ///
  /// This is only used in error messages to tell users what widget typically
  /// wraps this [ParentDataWidget] through
  /// [debugTypicalAncestorWidgetDescription].
  ///
  /// ## Implementations
  ///
  /// The returned Type should describe a subclass of `RenderObjectWidget`. If
  /// more than one Type is supported, use
  /// [debugTypicalAncestorWidgetDescription], which typically inserts this
  /// value but can be overridden to describe more than one Type.
  ///
  /// ```dart
  ///   @override
  ///   Type get debugTypicalAncestorWidgetClass => FrogJar;
  /// ```
  ///
  /// If the "typical" parent is generic (`Foo<T>`), consider specifying either
  /// a typical type argument (e.g. `Foo<int>` if `int` is typically how the
  /// type is specialized), or specifying the upper bound (e.g. `Foo<Object?>`).
  Type get debugTypicalAncestorWidgetClass;

  /// Describes the [RenderObjectWidget] that is typically used to set up the
  /// [ParentData] that [applyParentData] will write to.
  ///
  /// This is only used in error messages to tell users what widget typically
  /// wraps this [ParentDataWidget].
  ///
  /// Returns [debugTypicalAncestorWidgetClass] by default as a String. This can
  /// be overridden to describe more than one Type of valid parent.
  String get debugTypicalAncestorWidgetDescription => '$debugTypicalAncestorWidgetClass';

  Iterable<DiagnosticsNode> _debugDescribeIncorrectParentDataType({
    required ParentData? parentData,
    RenderObjectWidget? parentDataCreator,
    DiagnosticsNode? ownershipChain,
  }) {
    assert(T != dynamic);
    assert(T != ParentData);

    final description =
        'The ParentDataWidget $this wants to apply ParentData of type $T to a RenderObject';
    return <DiagnosticsNode>[
      if (parentData == null)
        ErrorDescription('$description, which has not been set up to receive any ParentData.')
      else
        ErrorDescription(
          '$description, which has been set up to accept ParentData of incompatible type ${parentData.runtimeType}.',
        ),
      ErrorHint(
        'Usually, this means that the $runtimeType widget has the wrong ancestor RenderObjectWidget. '
        'Typically, $runtimeType widgets are placed directly inside $debugTypicalAncestorWidgetDescription widgets.',
      ),
      if (parentDataCreator != null)
        ErrorHint(
          'The offending $runtimeType is currently placed inside a ${parentDataCreator.runtimeType} widget.',
        ),
      if (ownershipChain != null)
        ErrorDescription(
          'The ownership chain for the RenderObject that received the incompatible parent data was:\n  $ownershipChain',
        ),
    ];
  }

  /// Write the data from this widget into the given render object's parent data.
  ///
  /// The framework calls this function whenever it detects that the
  /// [RenderObject] associated with the [child] has outdated
  /// [RenderObject.parentData]. For example, if the render object was recently
  /// inserted into the render tree, the render object's parent data might not
  /// match the data in this widget.
  ///
  /// Subclasses are expected to override this function to copy data from their
  /// fields into the [RenderObject.parentData] field of the given render
  /// object. The render object's parent is guaranteed to have been created by a
  /// widget of type `T`, which usually means that this function can assume that
  /// the render object's parent data object inherits from a particular class.
  ///
  /// If this function modifies data that can change the parent's layout or
  /// painting, this function is responsible for calling
  /// [RenderObject.markNeedsLayout] or [RenderObject.markNeedsPaint] on the
  /// parent, as appropriate.
  @protected
  void applyParentData(RenderObject renderObject);

  /// Whether the [ParentDataElement.applyWidgetOutOfTurn] method is allowed
  /// with this widget.
  ///
  /// This should only return true if this widget represents a [ParentData]
  /// configuration that will have no impact on the layout or paint phase.
  ///
  /// See also:
  ///
  ///  * [ParentDataElement.applyWidgetOutOfTurn], which verifies this in debug
  ///    mode.
  @protected
  bool debugCanApplyOutOfTurn() => false;
}

/// Base class for widgets that efficiently propagate information down the tree.
///
/// {@youtube 560 315 https://www.youtube.com/watch?v=og-vJqLzg2c}
///
/// To obtain the nearest instance of a particular type of inherited widget from
/// a build context, use [BuildContext.dependOnInheritedWidgetOfExactType].
///
/// Inherited widgets, when referenced in this way, will cause the consumer to
/// rebuild when the inherited widget itself changes state.
///
/// {@youtube 560 315 https://www.youtube.com/watch?v=Zbm3hjPjQMk}
///
/// {@tool snippet}
///
/// The following is a skeleton of an inherited widget called `FrogColor`:
///
/// ```dart
/// class FrogColor extends InheritedWidget {
///   const FrogColor({
///     super.key,
///     required this.color,
///     required super.child,
///   });
///
///   final Color color;
///
///   static FrogColor? maybeOf(BuildContext context) {
///     return context.dependOnInheritedWidgetOfExactType<FrogColor>();
///   }
///
///   static FrogColor of(BuildContext context) {
///     final FrogColor? result = maybeOf(context);
///     assert(result != null, 'No FrogColor found in context');
///     return result!;
///   }
///
///   @override
///   bool updateShouldNotify(FrogColor oldWidget) => color != oldWidget.color;
/// }
/// ```
/// {@end-tool}
///
/// ## Implementing the `of` and `maybeOf` methods
///
/// The convention is to provide two static methods, `of` and `maybeOf`, on the
/// [InheritedWidget] which call
/// [BuildContext.dependOnInheritedWidgetOfExactType]. This allows the class to
/// define its own fallback logic in case there isn't a widget in scope.
///
/// The `of` method typically returns a non-nullable instance and asserts if the
/// [InheritedWidget] isn't found, and the `maybeOf` method returns a nullable
/// instance, and returns null if the [InheritedWidget] isn't found. The `of`
/// method is typically implemented by calling `maybeOf` internally.
///
/// Sometimes, the `of` and `maybeOf` methods return some data rather than the
/// inherited widget itself; for example, in this case it could have returned a
/// [Color] instead of the `FrogColor` widget.
///
/// Occasionally, the inherited widget is an implementation detail of another
/// class, and is therefore private. The `of` and `maybeOf` methods in that case
/// are typically implemented on the public class instead. For example, [Theme]
/// is implemented as a [StatelessWidget] that builds a private inherited
/// widget; [Theme.of] looks for that private inherited widget using
/// [BuildContext.dependOnInheritedWidgetOfExactType] and then returns the
/// [ThemeData] inside it.
///
/// ## Calling the `of` or `maybeOf` methods
///
/// When using the `of` or `maybeOf` methods, the `context` must be a descendant
/// of the [InheritedWidget], meaning it must be "below" the [InheritedWidget]
/// in the tree.
///
/// {@tool snippet}
///
/// In this example, the `context` used is the one from the [Builder], which is
/// a child of the `FrogColor` widget, so this works.
///
/// ```dart
/// // continuing from previous example...
/// class MyPage extends StatelessWidget {
///   const MyPage({super.key});
///
///   @override
///   Widget build(BuildContext context) {
///     return Scaffold(
///       body: FrogColor(
///         color: Colors.green,
///         child: Builder(
///           builder: (BuildContext innerContext) {
///             return Text(
///               'Hello Frog',
///               style: TextStyle(color: FrogColor.of(innerContext).color),
///             );
///           },
///         ),
///       ),
///     );
///   }
/// }
/// ```
/// {@end-tool}
///
/// {@tool snippet}
///
/// In this example, the `context` used is the one from the `MyOtherPage`
/// widget, which is a parent of the `FrogColor` widget, so this does not work,
/// and will assert when `FrogColor.of` is called.
///
/// ```dart
/// // continuing from previous example...
///
/// class MyOtherPage extends StatelessWidget {
///   const MyOtherPage({super.key});
///
///   @override
///   Widget build(BuildContext context) {
///     return Scaffold(
///       body: FrogColor(
///         color: Colors.green,
///         child: Text(
///           'Hello Frog',
///           style: TextStyle(color: FrogColor.of(context).color),
///         ),
///       ),
///     );
///   }
/// }
/// ```
/// {@end-tool} {@youtube 560 315 https://www.youtube.com/watch?v=1t-8rBCGBYw}
///
/// See also:
///
/// * [StatefulWidget] and [State], for widgets that can build differently
///   several times over their lifetime.
/// * [StatelessWidget], for widgets that always build the same way given a
///   particular configuration and ambient state.
/// * [Widget], for an overview of widgets in general.
/// * [InheritedNotifier], an inherited widget whose value can be a
///   [Listenable], and which will notify dependents whenever the value sends
///   notifications.
/// * [InheritedModel], an inherited widget that allows clients to subscribe to
///   changes for subparts of the value.
abstract class InheritedWidget extends ProxyWidget {
  /// Abstract const constructor. This constructor enables subclasses to provide
  /// const constructors so that they can be used in const expressions.
  const InheritedWidget({super.key, required super.child});

  @override
  InheritedElement createElement() => InheritedElement(this);

  /// Whether the framework should notify widgets that inherit from this widget.
  ///
  /// When this widget is rebuilt, sometimes we need to rebuild the widgets that
  /// inherit from this widget but sometimes we do not. For example, if the data
  /// held by this widget is the same as the data held by `oldWidget`, then we
  /// do not need to rebuild the widgets that inherited the data held by
  /// `oldWidget`.
  ///
  /// The framework distinguishes these cases by calling this function with the
  /// widget that previously occupied this location in the tree as an argument.
  /// The given widget is guaranteed to have the same [runtimeType] as this
  /// object.
  @protected
  bool updateShouldNotify(covariant InheritedWidget oldWidget);
}

/// [RenderObjectWidget]s provide the configuration for [RenderObjectElement]s,
/// which wrap [RenderObject]s, which provide the actual rendering of the
/// application.
///
/// Usually, rather than subclassing [RenderObjectWidget] directly, render
/// object widgets subclass one of:
///
///  * [LeafRenderObjectWidget], if the widget has no children.
///  * [SingleChildRenderObjectWidget], if the widget has exactly one child.
///  * [MultiChildRenderObjectWidget], if the widget takes a list of children.
///  * [SlottedMultiChildRenderObjectWidget], if the widget organizes its
///    children in different named slots.
///
/// Subclasses must implement [createRenderObject] and [updateRenderObject].
abstract class RenderObjectWidget extends Widget {
  /// Abstract const constructor. This constructor enables subclasses to provide
  /// const constructors so that they can be used in const expressions.
  const RenderObjectWidget({super.key});

  /// RenderObjectWidgets always inflate to a [RenderObjectElement] subclass.
  @override
  @factory
  RenderObjectElement createElement();

  /// Creates an instance of the [RenderObject] class that this
  /// [RenderObjectWidget] represents, using the configuration described by this
  /// [RenderObjectWidget].
  ///
  /// This method should not do anything with the children of the render object.
  /// That should instead be handled by the method that overrides
  /// [RenderObjectElement.mount] in the object rendered by this object's
  /// [createElement] method. See, for example,
  /// [SingleChildRenderObjectElement.mount].
  @protected
  @factory
  RenderObject createRenderObject(BuildContext context);

  /// Copies the configuration described by this [RenderObjectWidget] to the
  /// given [RenderObject], which will be of the same type as returned by this
  /// object's [createRenderObject].
  ///
  /// This method should not do anything to update the children of the render
  /// object. That should instead be handled by the method that overrides
  /// [RenderObjectElement.update] in the object rendered by this object's
  /// [createElement] method. See, for example,
  /// [SingleChildRenderObjectElement.update].
  @protected
  void updateRenderObject(BuildContext context, covariant RenderObject renderObject) {}

  /// This method is called when a RenderObject that was previously
  /// associated with this widget is removed from the render tree.
  /// The provided [RenderObject] will be of the same type as the one created by
  /// this widget's [createRenderObject] method.
  @protected
  void didUnmountRenderObject(covariant RenderObject renderObject) {}
}

/// A superclass for [RenderObjectWidget]s that configure [RenderObject] subclasses
/// that have no children.
///
/// Subclasses must implement [createRenderObject] and [updateRenderObject].
abstract class LeafRenderObjectWidget extends RenderObjectWidget {
  /// Abstract const constructor. This constructor enables subclasses to provide
  /// const constructors so that they can be used in const expressions.
  const LeafRenderObjectWidget({super.key});

  @override
  LeafRenderObjectElement createElement() => LeafRenderObjectElement(this);
}

/// A superclass for [RenderObjectWidget]s that configure [RenderObject] subclasses
/// that have a single child slot.
///
/// The render object assigned to this widget should make use of
/// [RenderObjectWithChildMixin] to implement a single-child model. The mixin
/// exposes a [RenderObjectWithChildMixin.child] property that allows retrieving
/// the render object belonging to the [child] widget.
///
/// Subclasses must implement [createRenderObject] and [updateRenderObject].
abstract class SingleChildRenderObjectWidget extends RenderObjectWidget {
  /// Abstract const constructor. This constructor enables subclasses to provide
  /// const constructors so that they can be used in const expressions.
  const SingleChildRenderObjectWidget({super.key, this.child});

  /// The widget below this widget in the tree.
  ///
  /// {@macro flutter.widgets.ProxyWidget.child}
  final Widget? child;

  @override
  SingleChildRenderObjectElement createElement() => SingleChildRenderObjectElement(this);
}

/// A superclass for [RenderObjectWidget]s that configure [RenderObject] subclasses
/// that have a single list of children. (This superclass only provides the
/// storage for that child list, it doesn't actually provide the updating
/// logic.)
///
/// Subclasses must use a [RenderObject] that mixes in
/// [ContainerRenderObjectMixin], which provides the necessary functionality to
/// visit the children of the container render object (the render object
/// belonging to the [children] widgets). Typically, subclasses will use a
/// [RenderBox] that mixes in both [ContainerRenderObjectMixin] and
/// [RenderBoxContainerDefaultsMixin].
///
/// Subclasses must implement [createRenderObject] and [updateRenderObject].
///
/// See also:
///
///  * [Stack], which uses [MultiChildRenderObjectWidget].
///  * [RenderStack], for an example implementation of the associated render
///    object.
///  * [SlottedMultiChildRenderObjectWidget], which configures a
///    [RenderObject] that instead of having a single list of children organizes
///    its children in named slots.
abstract class MultiChildRenderObjectWidget extends RenderObjectWidget {
  /// Initializes fields for subclasses.
  const MultiChildRenderObjectWidget({super.key, this.children = const <Widget>[]});

  /// The widgets below this widget in the tree.
  ///
  /// If this list is going to be mutated, it is usually wise to put a [Key] on
  /// each of the child widgets, so that the framework can match old
  /// configurations to new configurations and maintain the underlying render
  /// objects.
  ///
  /// Also, a [Widget] in Flutter is immutable, so directly modifying the
  /// [children] such as `someMultiChildRenderObjectWidget.children.add(...)` or
  /// as the example code below will result in incorrect behaviors. Whenever the
  /// children list is modified, a new list object should be provided.
  ///
  /// ```dart
  /// // This code is incorrect.
  /// class SomeWidgetState extends State<SomeWidget> {
  ///   final List<Widget> _children = <Widget>[];
  ///
  ///   void someHandler() {
  ///     setState(() {
  ///       _children.add(const ChildWidget());
  ///     });
  ///   }
  ///
  ///   @override
  ///   Widget build(BuildContext context) {
  ///     // Reusing `List<Widget> _children` here is problematic.
  ///     return Row(children: _children);
  ///   }
  /// }
  /// ```
  ///
  /// The following code corrects the problem mentioned above.
  ///
  /// ```dart
  /// class SomeWidgetState extends State<SomeWidget> {
  ///   final List<Widget> _children = <Widget>[];
  ///
  ///   void someHandler() {
  ///     setState(() {
  ///       // The key here allows Flutter to reuse the underlying render
  ///       // objects even if the children list is recreated.
  ///       _children.add(ChildWidget(key: UniqueKey()));
  ///     });
  ///   }
  ///
  ///   @override
  ///   Widget build(BuildContext context) {
  ///     // Always create a new list of children as a Widget is immutable.
  ///     return Row(children: _children.toList());
  ///   }
  /// }
  /// ```
  final List<Widget> children;

  @override
  MultiChildRenderObjectElement createElement() => MultiChildRenderObjectElement(this);
}

// ELEMENTS

enum _ElementLifecycle {
  /// The [Element] is created but has not yet been incorporated into the element
  /// tree.
  initial,

  /// The [Element] is incorporated into the Element tree, either via
  /// [Element.mount] or [Element.activate].
  active,

  /// The previously `active` [Element] is removed from the Element tree via
  /// [Element.deactivate].
  ///
  /// This [Element] may become `active` again if a parent reclaims it using
  /// a [GlobalKey], or `defunct` if no parent reclaims it at the end of the
  /// build phase.
  inactive,

  /// The [Element] encountered an unrecoverable error while being rebuilt when it
  /// was `active` or while being incorporated in the tree.
  ///
  /// This indicates the [Element]'s subtree is in an inconsistent state and must
  /// not be re-incorporated into the tree again.
  ///
  /// When an unrecoverable error is encountered, the framework calls
  /// [Element.deactivate] on this [Element] and sets its state to `failed`. This
  /// process is done on a best-effort basis and does not surface any additional
  /// errors.
  ///
  /// This is one of the two final stages of the element lifecycle and is not
  /// reversible. Reaching this state typically means that a widget implementation
  /// is throwing unhandled exceptions that need to be properly handled.
  failed,

  /// The [Element] is disposed and should not be interacted with.
  ///
  /// The [Element] must be `inactive` before transitioning into this state,
  /// and the state transition occurs in [BuildOwner.finalizeTree] which signals
  /// the end of the build phase.
  ///
  /// This is the final stage of the element lifecycle and is not reversible.
  defunct,
}

class _InactiveElements {
  bool _locked = false;
  final Set<Element> _elements = HashSet<Element>();

  static void _unmount(Element element) {
    assert(element._lifecycleState == _ElementLifecycle.inactive);
    assert(() {
      if (debugPrintGlobalKeyedWidgetLifecycle) {
        if (element.widget.key is GlobalKey) {
          debugPrint('Discarding $element from inactive elements list.');
        }
      }
      return true;
    }());
    element.visitChildren((Element child) {
      assert(child._parent == element);
      _unmount(child);
    });
    element.unmount();
    assert(element._lifecycleState == _ElementLifecycle.defunct);
  }

  void _unmountAll() {
    _locked = true;
    final List<Element> elements = _elements.toList()..sort(Element._sort);
    _elements.clear();
    try {
      elements.reversed.forEach(_unmount);
    } finally {
      assert(_elements.isEmpty);
      _locked = false;
    }
  }

  static void _deactivateRecursively(Element element) {
    assert(element._lifecycleState == _ElementLifecycle.active);
    try {
      element.deactivate();
    } catch (_) {
      Element._deactivateFailedSubtreeRecursively(element);
      rethrow;
    }
    element.visitChildren(_deactivateRecursively);
    assert(() {
      element.debugDeactivated();
      return true;
    }());
  }

  void add(Element element) {
    assert(!_locked);
    assert(!_elements.contains(element));
    assert(element._parent == null);

    switch (element._lifecycleState) {
      case _ElementLifecycle.active:
        _deactivateRecursively(element);
        // This element is only added to _elements if the whole subtree is
        // successfully deactivated.
        _elements.add(element);
      case _ElementLifecycle.inactive:
        _elements.add(element);
      case _ElementLifecycle.initial || _ElementLifecycle.failed || _ElementLifecycle.defunct:
        assert(false, '$element must not be deactivated when in ${element._lifecycleState} state.');
    }
  }

  void remove(Element element) {
    assert(!_locked);
    assert(_elements.contains(element));
    assert(element._parent == null);
    _elements.remove(element);
    assert(element._lifecycleState == _ElementLifecycle.inactive);
  }

  bool debugContains(Element element) {
    late bool result;
    assert(() {
      result = _elements.contains(element);
      return true;
    }());
    return result;
  }
}

/// Signature for the callback to [BuildContext.visitChildElements].
///
/// The argument is the child being visited.
///
/// It is safe to call `element.visitChildElements` reentrantly within
/// this callback.
typedef ElementVisitor = void Function(Element element);

/// Signature for the callback to [BuildContext.visitAncestorElements].
///
/// The argument is the ancestor being visited.
///
/// Return false to stop the walk.
typedef ConditionalElementVisitor = bool Function(Element element);

/// A handle to the location of a widget in the widget tree.
///
/// This class presents a set of methods that can be used from
/// [StatelessWidget.build] methods and from methods on [State] objects.
///
/// [BuildContext] objects are passed to [WidgetBuilder] functions (such as
/// [StatelessWidget.build]), and are available from the [State.context] member.
/// Some static functions (e.g. [showDialog], [Theme.of], and so forth) also
/// take build contexts so that they can act on behalf of the calling widget, or
/// obtain data specifically for the given context.
///
/// Each widget has its own [BuildContext], which becomes the parent of the
/// widget returned by the [StatelessWidget.build] or [State.build] function.
/// (And similarly, the parent of any children for [RenderObjectWidget]s.)
///
/// In particular, this means that within a build method, the build context of
/// the widget which has the build method is not the same as the build context
/// of the widgets returned by the build method. This can lead to some tricky cases.
/// For example, [Theme.of(context)] looks for the nearest enclosing [Theme] of
/// the given build context. If a build method for a widget Q includes a [Theme]
/// within its returned widget tree, and attempts to use [Theme.of] passing its
/// own context, the build method for Q will not find that [Theme] object. It
/// will instead find whatever [Theme] was an ancestor to the widget Q. If the
/// build context for a subpart of the returned tree is needed, a [Builder]
/// widget can be used: the build context passed to the [Builder.builder]
/// callback will be that of the [Builder] itself.
///
/// For example, in the following snippet, the [ScaffoldState.showBottomSheet]
/// method is called on the [Scaffold] widget that the build method itself
/// creates. If a [Builder] had not been used, and instead the `context`
/// argument of the build method itself had been used, no [Scaffold] would have
/// been found, and the [Scaffold.of] function would have returned null.
///
/// ```dart
/// @override
/// Widget build(BuildContext context) {
///   // here, Scaffold.of(context) returns null
///   return Scaffold(
///     appBar: AppBar(title: const Text('Demo')),
///     body: Builder(
///       builder: (BuildContext context) {
///         return TextButton(
///           child: const Text('BUTTON'),
///           onPressed: () {
///             Scaffold.of(context).showBottomSheet(
///               (BuildContext context) {
///                 return Container(
///                   alignment: Alignment.center,
///                   height: 200,
///                   color: Colors.amber,
///                   child: Center(
///                     child: Column(
///                       mainAxisSize: MainAxisSize.min,
///                       children: <Widget>[
///                         const Text('BottomSheet'),
///                         ElevatedButton(
///                           child: const Text('Close BottomSheet'),
///                           onPressed: () {
///                             Navigator.pop(context);
///                           },
///                         )
///                       ],
///                     ),
///                   ),
///                 );
///               },
///             );
///           },
///         );
///       },
///     )
///   );
/// }
/// ```
///
/// The [BuildContext] for a particular widget can change location over time as
/// the widget is moved around the tree. Because of this, values returned from
/// the methods on this class should not be cached beyond the execution of a
/// single synchronous function.
///
/// {@youtube 560 315 https://www.youtube.com/watch?v=rIaaH87z1-g}
///
/// Avoid storing instances of [BuildContext]s because they may become invalid
/// if the widget they are associated with is unmounted from the widget tree.
/// {@template flutter.widgets.BuildContext.asynchronous_gap}
/// If a [BuildContext] is used across an asynchronous gap (i.e. after performing
/// an asynchronous operation), consider checking [mounted] to determine whether
/// the context is still valid before interacting with it:
///
/// ```dart
///   @override
///   Widget build(BuildContext context) {
///     return OutlinedButton(
///       onPressed: () async {
///         await Future<void>.delayed(const Duration(seconds: 1));
///         if (context.mounted) {
///           Navigator.of(context).pop();
///         }
///       },
///       child: const Text('Delayed pop'),
///     );
///   }
/// ```
/// {@endtemplate}
///
/// [BuildContext] objects are actually [Element] objects. The [BuildContext]
/// interface is used to discourage direct manipulation of [Element] objects.
abstract class BuildContext {
  /// The current configuration of the [Element] that is this [BuildContext].
  Widget get widget;

  /// The [BuildOwner] for this context. The [BuildOwner] is in charge of
  /// managing the rendering pipeline for this context.
  BuildOwner? get owner;

  /// Whether the [Widget] this context is associated with is currently
  /// mounted in the widget tree.
  ///
  /// Accessing the properties of the [BuildContext] or calling any methods on
  /// it is only valid while mounted is true. If mounted is false, assertions
  /// will trigger.
  ///
  /// Once unmounted, a given [BuildContext] will never become mounted again.
  ///
  /// {@macro flutter.widgets.BuildContext.asynchronous_gap}
  bool get mounted;

  /// Whether the [widget] is currently updating the widget or render tree.
  ///
  /// For [StatefulWidget]s and [StatelessWidget]s this flag is true while
  /// their respective build methods are executing.
  /// [RenderObjectWidget]s set this to true while creating or configuring their
  /// associated [RenderObject]s.
  /// Other [Widget] types may set this to true for conceptually similar phases
  /// of their lifecycle.
  ///
  /// When this is true, it is safe for [widget] to establish a dependency to an
  /// [InheritedWidget] by calling [dependOnInheritedElement] or
  /// [dependOnInheritedWidgetOfExactType].
  ///
  /// Accessing this flag in release mode is not valid.
  bool get debugDoingBuild;

  /// The current [RenderObject] for the widget. If the widget is a
  /// [RenderObjectWidget], this is the render object that the widget created
  /// for itself. Otherwise, it is the render object of the first descendant
  /// [RenderObjectWidget].
  ///
  /// This method will only return a valid result after the build phase is
  /// complete. It is therefore not valid to call this from a build method.
  /// It should only be called from interaction event handlers (e.g.
  /// gesture callbacks) or layout or paint callbacks. It is also not valid to
  /// call if [State.mounted] returns false.
  ///
  /// If the render object is a [RenderBox], which is the common case, then the
  /// size of the render object can be obtained from the [size] getter. This is
  /// only valid after the layout phase, and should therefore only be examined
  /// from paint callbacks or interaction event handlers (e.g. gesture
  /// callbacks).
  ///
  /// For details on the different phases of a frame, see the discussion at
  /// [WidgetsBinding.drawFrame].
  ///
  /// Calling this method is theoretically relatively expensive (O(N) in the
  /// depth of the tree), but in practice is usually cheap because the tree
  /// usually has many render objects and therefore the distance to the nearest
  /// render object is usually short.
  RenderObject? findRenderObject();

  /// The size of the [RenderBox] returned by [findRenderObject].
  ///
  /// This getter will only return a valid result after the layout phase is
  /// complete. It is therefore not valid to call this from a build method.
  /// It should only be called from paint callbacks or interaction event
  /// handlers (e.g. gesture callbacks).
  ///
  /// For details on the different phases of a frame, see the discussion at
  /// [WidgetsBinding.drawFrame].
  ///
  /// This getter will only return a valid result if [findRenderObject] actually
  /// returns a [RenderBox]. If [findRenderObject] returns a render object that
  /// is not a subtype of [RenderBox] (e.g., [RenderView]), this getter will
  /// throw an exception in debug mode and will return null in release mode.
  ///
  /// Calling this getter is theoretically relatively expensive (O(N) in the
  /// depth of the tree), but in practice is usually cheap because the tree
  /// usually has many render objects and therefore the distance to the nearest
  /// render object is usually short.
  Size? get size;

  /// Registers this build context with [ancestor] such that when
  /// [ancestor]'s widget changes this build context is rebuilt.
  ///
  /// Returns `ancestor.widget`.
  ///
  /// This method is rarely called directly. Most applications should use
  /// [dependOnInheritedWidgetOfExactType], which calls this method after finding
  /// the appropriate [InheritedElement] ancestor.
  ///
  /// All of the qualifications about when [dependOnInheritedWidgetOfExactType] can
  /// be called apply to this method as well.
  InheritedWidget dependOnInheritedElement(InheritedElement ancestor, {Object? aspect});

  /// Returns the nearest widget of the given type `T` and creates a dependency
  /// on it, or null if no appropriate widget is found.
  ///
  /// The widget found will be a concrete [InheritedWidget] subclass, and
  /// calling [dependOnInheritedWidgetOfExactType] registers this build context
  /// with the returned widget. When that widget changes (or a new widget of
  /// that type is introduced, or the widget goes away), this build context is
  /// rebuilt so that it can obtain new values from that widget.
  ///
  /// {@template flutter.widgets.BuildContext.dependOnInheritedWidgetOfExactType}
  /// This is typically called implicitly from `of()` static methods, e.g.
  /// [Theme.of].
  ///
  /// This method should not be called from widget constructors or from
  /// [State.initState] methods, because those methods would not get called
  /// again if the inherited value were to change. To ensure that the widget
  /// correctly updates itself when the inherited value changes, only call this
  /// (directly or indirectly) from build methods, layout and paint callbacks,
  /// or from [State.didChangeDependencies] (which is called immediately after
  /// [State.initState]).
  ///
  /// This method should not be called from [State.dispose] because the element
  /// tree is no longer stable at that time. To refer to an ancestor from that
  /// method, save a reference to the ancestor in [State.didChangeDependencies].
  /// It is safe to use this method from [State.deactivate], which is called
  /// whenever the widget is removed from the tree.
  ///
  /// It is also possible to call this method from interaction event handlers
  /// (e.g. gesture callbacks) or timers, to obtain a value once, as long as
  /// that value is not cached and/or reused later.
  ///
  /// Calling this method is O(1) with a small constant factor, but will lead to
  /// the widget being rebuilt more often.
  ///
  /// Once a widget registers a dependency on a particular type by calling this
  /// method, it will be rebuilt, and [State.didChangeDependencies] will be
  /// called, whenever changes occur relating to that widget until the next time
  /// the widget or one of its ancestors is moved (for example, because an
  /// ancestor is added or removed).
  ///
  /// The [aspect] parameter is only used when `T` is an
  /// [InheritedWidget] subclasses that supports partial updates, like
  /// [InheritedModel]. It specifies what "aspect" of the inherited
  /// widget this context depends on.
  /// {@endtemplate}
  T? dependOnInheritedWidgetOfExactType<T extends InheritedWidget>({Object? aspect});

  /// Returns the nearest widget of the given [InheritedWidget] subclass `T` or
  /// null if an appropriate ancestor is not found.
  ///
  /// {@template flutter.widgets.BuildContext.getInheritedWidgetOfExactType}
  /// This method does not introduce a dependency the way that the more typical
  /// [dependOnInheritedWidgetOfExactType] does, so this context will not be
  /// rebuilt if the [InheritedWidget] changes. This function is meant for those
  /// uncommon use cases where a dependency is undesirable.
  ///
  /// This method should not be called from [State.dispose] because the element
  /// tree is no longer stable at that time. To refer to an ancestor from that
  /// method, save a reference to the ancestor in [State.didChangeDependencies].
  /// It is safe to use this method from [State.deactivate], which is called
  /// whenever the widget is removed from the tree.
  ///
  /// It is also possible to call this method from interaction event handlers
  /// (e.g. gesture callbacks) or timers, to obtain a value once, as long as
  /// that value is not cached and/or reused later.
  ///
  /// Calling this method is O(1) with a small constant factor.
  /// {@endtemplate}
  T? getInheritedWidgetOfExactType<T extends InheritedWidget>();

  /// Obtains the element corresponding to the nearest widget of the given type `T`,
  /// which must be the type of a concrete [InheritedWidget] subclass.
  ///
  /// Returns null if no such element is found.
  ///
  /// {@template flutter.widgets.BuildContext.getElementForInheritedWidgetOfExactType}
  /// Calling this method is O(1) with a small constant factor.
  ///
  /// This method does not establish a relationship with the target in the way
  /// that [dependOnInheritedWidgetOfExactType] does.
  ///
  /// This method should not be called from [State.dispose] because the element
  /// tree is no longer stable at that time. To refer to an ancestor from that
  /// method, save a reference to the ancestor by calling
  /// [dependOnInheritedWidgetOfExactType] in [State.didChangeDependencies]. It is
  /// safe to use this method from [State.deactivate], which is called whenever
  /// the widget is removed from the tree.
  /// {@endtemplate}
  InheritedElement? getElementForInheritedWidgetOfExactType<T extends InheritedWidget>();

  /// Returns the nearest ancestor widget of the given type `T`, which must be the
  /// type of a concrete [Widget] subclass.
  ///
  /// {@template flutter.widgets.BuildContext.findAncestorWidgetOfExactType}
  /// In general, [dependOnInheritedWidgetOfExactType] is more useful, since
  /// inherited widgets will trigger consumers to rebuild when they change. This
  /// method is appropriate when used in interaction event handlers (e.g.
  /// gesture callbacks) or for performing one-off tasks such as asserting that
  /// you have or don't have a widget of a specific type as an ancestor. The
  /// return value of a Widget's build method should not depend on the value
  /// returned by this method, because the build context will not rebuild if the
  /// return value of this method changes. This could lead to a situation where
  /// data used in the build method changes, but the widget is not rebuilt.
  ///
  /// Calling this method is relatively expensive (O(N) in the depth of the
  /// tree). Only call this method if the distance from this widget to the
  /// desired ancestor is known to be small and bounded.
  ///
  /// This method should not be called from [State.deactivate] or [State.dispose]
  /// because the widget tree is no longer stable at that time. To refer to
  /// an ancestor from one of those methods, save a reference to the ancestor
  /// by calling [findAncestorWidgetOfExactType] in [State.didChangeDependencies].
  ///
  /// Returns null if a widget of the requested type does not appear in the
  /// ancestors of this context.
  /// {@endtemplate}
  T? findAncestorWidgetOfExactType<T extends Widget>();

  /// Returns the [State] object of the nearest ancestor [StatefulWidget] widget
  /// that is an instance of the given type `T`.
  ///
  /// {@template flutter.widgets.BuildContext.findAncestorStateOfType}
  /// This should not be used from build methods, because the build context will
  /// not be rebuilt if the value that would be returned by this method changes.
  /// In general, [dependOnInheritedWidgetOfExactType] is more appropriate for such
  /// cases. This method is useful for changing the state of an ancestor widget in
  /// a one-off manner, for example, to cause an ancestor scrolling list to
  /// scroll this build context's widget into view, or to move the focus in
  /// response to user interaction.
  ///
  /// In general, though, consider using a callback that triggers a stateful
  /// change in the ancestor rather than using the imperative style implied by
  /// this method. This will usually lead to more maintainable and reusable code
  /// since it decouples widgets from each other.
  ///
  /// Calling this method is relatively expensive (O(N) in the depth of the
  /// tree). Only call this method if the distance from this widget to the
  /// desired ancestor is known to be small and bounded.
  ///
  /// This method should not be called from [State.deactivate] or [State.dispose]
  /// because the widget tree is no longer stable at that time. To refer to
  /// an ancestor from one of those methods, save a reference to the ancestor
  /// by calling [findAncestorStateOfType] in [State.didChangeDependencies].
  /// {@endtemplate}
  ///
  /// {@tool snippet}
  ///
  /// ```dart
  /// ScrollableState? scrollable = context.findAncestorStateOfType<ScrollableState>();
  /// ```
  /// {@end-tool}
  T? findAncestorStateOfType<T extends State>();

  /// Returns the [State] object of the furthest ancestor [StatefulWidget] widget
  /// that is an instance of the given type `T`.
  ///
  /// {@template flutter.widgets.BuildContext.findRootAncestorStateOfType}
  /// Functions the same way as [findAncestorStateOfType] but keeps visiting subsequent
  /// ancestors until there are none of the type instance of `T` remaining.
  /// Then returns the last one found.
  ///
  /// This operation is O(N) as well though N is the entire widget tree rather than
  /// a subtree.
  /// {@endtemplate}
  T? findRootAncestorStateOfType<T extends State>();

  /// Returns the [RenderObject] object of the nearest ancestor [RenderObjectWidget] widget
  /// that is an instance of the given type `T`.
  ///
  /// {@template flutter.widgets.BuildContext.findAncestorRenderObjectOfType}
  /// This should not be used from build methods, because the build context will
  /// not be rebuilt if the value that would be returned by this method changes.
  /// In general, [dependOnInheritedWidgetOfExactType] is more appropriate for such
  /// cases. This method is useful only in esoteric cases where a widget needs
  /// to cause an ancestor to change its layout or paint behavior. For example,
  /// it is used by [Material] so that [InkWell] widgets can trigger the ink
  /// splash on the [Material]'s actual render object.
  ///
  /// Calling this method is relatively expensive (O(N) in the depth of the
  /// tree). Only call this method if the distance from this widget to the
  /// desired ancestor is known to be small and bounded.
  ///
  /// This method should not be called from [State.deactivate] or [State.dispose]
  /// because the widget tree is no longer stable at that time. To refer to
  /// an ancestor from one of those methods, save a reference to the ancestor
  /// by calling [findAncestorRenderObjectOfType] in [State.didChangeDependencies].
  /// {@endtemplate}
  T? findAncestorRenderObjectOfType<T extends RenderObject>();

  /// Walks the ancestor chain, starting with the parent of this build context's
  /// widget, invoking the argument for each ancestor.
  ///
  /// {@template flutter.widgets.BuildContext.visitAncestorElements}
  /// The callback is given a reference to the ancestor widget's corresponding
  /// [Element] object. The walk stops when it reaches the root widget or when
  /// the callback returns false. The callback must not return null.
  ///
  /// This is useful for inspecting the widget tree.
  ///
  /// Calling this method is relatively expensive (O(N) in the depth of the tree).
  ///
  /// This method should not be called from [State.deactivate] or [State.dispose]
  /// because the element tree is no longer stable at that time. To refer to
  /// an ancestor from one of those methods, save a reference to the ancestor
  /// by calling [visitAncestorElements] in [State.didChangeDependencies].
  /// {@endtemplate}
  void visitAncestorElements(ConditionalElementVisitor visitor);

  /// Walks the children of this widget.
  ///
  /// {@template flutter.widgets.BuildContext.visitChildElements}
  /// This is useful for applying changes to children after they are built
  /// without waiting for the next frame, especially if the children are known,
  /// and especially if there is exactly one child (as is always the case for
  /// [StatefulWidget]s or [StatelessWidget]s).
  ///
  /// Calling this method is very cheap for build contexts that correspond to
  /// [StatefulWidget]s or [StatelessWidget]s (O(1), since there's only one
  /// child).
  ///
  /// Calling this method is potentially expensive for build contexts that
  /// correspond to [RenderObjectWidget]s (O(N) in the number of children).
  ///
  /// Calling this method recursively is extremely expensive (O(N) in the number
  /// of descendants), and should be avoided if possible. Generally it is
  /// significantly cheaper to use an [InheritedWidget] and have the descendants
  /// pull data down, than it is to use [visitChildElements] recursively to push
  /// data down to them.
  /// {@endtemplate}
  void visitChildElements(ElementVisitor visitor);

  /// Start bubbling this notification at the given build context.
  ///
  /// The notification will be delivered to any [NotificationListener] widgets
  /// with the appropriate type parameters that are ancestors of the given
  /// [BuildContext].
  void dispatchNotification(Notification notification);

  /// Returns a description of the [Element] associated with the current build context.
  ///
  /// The `name` is typically something like "The element being rebuilt was".
  ///
  /// See also:
  ///
  ///  * [Element.describeElements], which can be used to describe a list of elements.
  DiagnosticsNode describeElement(
    String name, {
    DiagnosticsTreeStyle style = DiagnosticsTreeStyle.errorProperty,
  });

  /// Returns a description of the [Widget] associated with the current build context.
  ///
  /// The `name` is typically something like "The widget being rebuilt was".
  DiagnosticsNode describeWidget(
    String name, {
    DiagnosticsTreeStyle style = DiagnosticsTreeStyle.errorProperty,
  });

  /// Adds a description of a specific type of widget missing from the current
  /// build context's ancestry tree.
  ///
  /// You can find an example of using this method in [debugCheckHasMaterial].
  List<DiagnosticsNode> describeMissingAncestor({required Type expectedAncestorType});

  /// Adds a description of the ownership chain from a specific [Element]
  /// to the error report.
  ///
  /// The ownership chain is useful for debugging the source of an element.
  DiagnosticsNode describeOwnershipChain(String name);
}

/// A class that determines the scope of a [BuildOwner.buildScope] operation.
///
/// The [BuildOwner.buildScope] method rebuilds all dirty [Element]s who share
/// the same [Element.buildScope] as its `context` argument, and skips those
/// with a different [Element.buildScope].
///
/// [Element]s by default have the same `buildScope` as their parents. Special
/// [Element]s may override [Element.buildScope] to create an isolated build scope
/// for its descendants. The [LayoutBuilder] widget, for example, establishes its
/// own [BuildScope] such that no descendant [Element]s may rebuild prematurely
/// until the incoming constraints are known.
final class BuildScope {
  /// Creates a [BuildScope] with an optional [scheduleRebuild] callback.
  BuildScope({this.scheduleRebuild});

  // Whether `scheduleRebuild` is called.
  bool _buildScheduled = false;
  // Whether [BuildOwner.buildScope] is actively running in this [BuildScope].
  bool _building = false;

  /// An optional [VoidCallback] that will be called when [Element]s in this
  /// [BuildScope] are marked as dirty for the first time.
  ///
  /// This callback usually signifies that the [BuildOwner.buildScope] method
  /// must be called at a later time in this frame to rebuild dirty elements in
  /// this [BuildScope]. It will **not** be called if this scope is actively being
  /// built by [BuildOwner.buildScope], since the [BuildScope] will be clean when
  /// [BuildOwner.buildScope] returns.
  final VoidCallback? scheduleRebuild;

  /// Whether [_dirtyElements] need to be sorted again as a result of more
  /// elements becoming dirty during the build.
  ///
  /// This is necessary to preserve the sort order defined by [Element._sort].
  ///
  /// This field is set to null when [BuildOwner.buildScope] is not actively
  /// rebuilding the widget tree.
  bool? _dirtyElementsNeedsResorting;
  final List<Element> _dirtyElements = <Element>[];

  @pragma('dart2js:tryInline')
  @pragma('vm:prefer-inline')
  @pragma('wasm:prefer-inline')
  void _scheduleBuildFor(Element element) {
    assert(identical(element.buildScope, this));
    if (!element._inDirtyList) {
      _dirtyElements.add(element);
      element._inDirtyList = true;
    }
    if (!_buildScheduled && !_building) {
      _buildScheduled = true;
      scheduleRebuild?.call();
    }
    if (_dirtyElementsNeedsResorting != null) {
      _dirtyElementsNeedsResorting = true;
    }
  }

  @pragma('dart2js:tryInline')
  @pragma('vm:prefer-inline')
  @pragma('wasm:prefer-inline')
  @pragma('vm:notify-debugger-on-exception')
  void _tryRebuild(Element element) {
    assert(element._inDirtyList);
    assert(identical(element.buildScope, this));
    final bool isTimelineTracked = !kReleaseMode && _isProfileBuildsEnabledFor(element.widget);
    if (isTimelineTracked) {
      Map<String, String>? debugTimelineArguments;
      assert(() {
        if (kDebugMode && debugEnhanceBuildTimelineArguments) {
          debugTimelineArguments = element.widget.toDiagnosticsNode().toTimelineArguments();
        }
        return true;
      }());
      FlutterTimeline.startSync('${element.widget.runtimeType}', arguments: debugTimelineArguments);
    }
    try {
      element.rebuild();
    } catch (e, stack) {
      _reportException(
        ErrorDescription('while rebuilding dirty elements'),
        e,
        stack,
        informationCollector: () => <DiagnosticsNode>[
          if (kDebugMode) DiagnosticsDebugCreator(DebugCreator(element)),
          element.describeElement('The element being rebuilt at the time was'),
        ],
      );
    }
    if (isTimelineTracked) {
      FlutterTimeline.finishSync();
    }
  }

  bool _debugAssertElementInScope(Element element, Element debugBuildRoot) {
    final bool isInScope = element._debugIsDescendantOf(debugBuildRoot) || !element.debugIsActive;
    if (isInScope) {
      return true;
    }
    throw FlutterError.fromParts(<DiagnosticsNode>[
      ErrorSummary('Tried to build dirty widget in the wrong build scope.'),
      ErrorDescription(
        'A widget which was marked as dirty and is still active was scheduled to be built, '
        'but the current build scope unexpectedly does not contain that widget.',
      ),
      ErrorHint(
        'Sometimes this is detected when an element is removed from the widget tree, but the '
        'element somehow did not get marked as inactive. In that case, it might be caused by '
        'an ancestor element failing to implement visitChildren correctly, thus preventing '
        'some or all of its descendants from being correctly deactivated.',
      ),
      DiagnosticsProperty<Element>(
        'The root of the build scope was',
        debugBuildRoot,
        style: DiagnosticsTreeStyle.errorProperty,
      ),
      DiagnosticsProperty<Element>(
        'The offending element (which does not appear to be a descendant of the root of the build scope) was',
        element,
        style: DiagnosticsTreeStyle.errorProperty,
      ),
    ]);
  }

  @pragma('vm:notify-debugger-on-exception')
  void _flushDirtyElements({required Element debugBuildRoot}) {
    assert(_dirtyElementsNeedsResorting == null, '_flushDirtyElements must be non-reentrant');
    _dirtyElements.sort(Element._sort);
    _dirtyElementsNeedsResorting = false;
    try {
      for (var index = 0; index < _dirtyElements.length; index = _dirtyElementIndexAfter(index)) {
        final Element element = _dirtyElements[index];
        if (identical(element.buildScope, this)) {
          assert(_debugAssertElementInScope(element, debugBuildRoot));
          _tryRebuild(element);
        }
      }
      assert(() {
        final Iterable<Element> missedElements = _dirtyElements.where(
          (Element element) =>
              element.debugIsActive && element.dirty && identical(element.buildScope, this),
        );
        if (missedElements.isNotEmpty) {
          throw FlutterError.fromParts(<DiagnosticsNode>[
            ErrorSummary('buildScope missed some dirty elements.'),
            ErrorHint(
              'This probably indicates that the dirty list should have been resorted but was not.',
            ),
            DiagnosticsProperty<Element>(
              'The context argument of the buildScope call was',
              debugBuildRoot,
              style: DiagnosticsTreeStyle.errorProperty,
            ),
            Element.describeElements(
              'The list of missed elements at the end of the buildScope call was',
              missedElements,
            ),
          ]);
        }
        return true;
      }());
    } finally {
      for (final Element element in _dirtyElements) {
        if (identical(element.buildScope, this)) {
          element._inDirtyList = false;
        }
      }
      _dirtyElements.clear();
      _dirtyElementsNeedsResorting = null;
      _buildScheduled = false;
    }
  }

  @pragma('dart2js:tryInline')
  @pragma('vm:prefer-inline')
  @pragma('wasm:prefer-inline')
  int _dirtyElementIndexAfter(int index) {
    if (!_dirtyElementsNeedsResorting!) {
      return index + 1;
    }
    index += 1;
    _dirtyElements.sort(Element._sort);
    _dirtyElementsNeedsResorting = false;
    while (index > 0 && _dirtyElements[index - 1].dirty) {
      // It is possible for previously dirty but inactive widgets to move right in the list.
      // We therefore have to move the index left in the list to account for this.
      // We don't know how many could have moved. However, we do know that the only possible
      // change to the list is that nodes that were previously to the left of the index have
      // now moved to be to the right of the right-most cleaned node, and we do know that
      // all the clean nodes were to the left of the index. So we move the index left
      // until just after the right-most clean node.
      index -= 1;
    }
    assert(() {
      for (int i = index - 1; i >= 0; i -= 1) {
        final Element element = _dirtyElements[i];
        assert(!element.dirty || element._lifecycleState != _ElementLifecycle.active);
      }
      return true;
    }());
    return index;
  }
}

/// Manager class for the widgets framework.
///
/// This class tracks which widgets need rebuilding, and handles other tasks
/// that apply to widget trees as a whole, such as managing the inactive element
/// list for the tree and triggering the "reassemble" command when necessary
/// during hot reload when debugging.
///
/// The main build owner is typically owned by the [WidgetsBinding], and is
/// driven from the operating system along with the rest of the
/// build/layout/paint pipeline.
///
/// Additional build owners can be built to manage off-screen widget trees.
///
/// To assign a build owner to a tree, use the
/// [RootElementMixin.assignOwner] method on the root element of the
/// widget tree.
///
/// {@tool dartpad}
/// This example shows how to build an off-screen widget tree used to measure
/// the layout size of the rendered tree. For some use cases, the simpler
/// [Offstage] widget may be a better alternative to this approach.
///
/// ** See code in examples/api/lib/widgets/framework/build_owner.0.dart **
/// {@end-tool}
class BuildOwner {
  /// Creates an object that manages widgets.
  ///
  /// If the `focusManager` argument is not specified or is null, this will
  /// construct a new [FocusManager] and register its global input handlers
  /// via [FocusManager.registerGlobalHandlers], which will modify static
  /// state. Callers wishing to avoid altering this state can explicitly pass
  /// a focus manager here.
  BuildOwner({this.onBuildScheduled, FocusManager? focusManager})
    : focusManager = focusManager ?? (FocusManager()..registerGlobalHandlers());

  /// Called on each build pass when the first buildable element is marked
  /// dirty.
  VoidCallback? onBuildScheduled;

  final _InactiveElements _inactiveElements = _InactiveElements();

  bool _scheduledFlushDirtyElements = false;

  /// The object in charge of the focus tree.
  ///
  /// Rarely used directly. Instead, consider using [FocusScope.of] to obtain
  /// the [FocusScopeNode] for a given [BuildContext].
  ///
  /// See [FocusManager] for more details.
  ///
  /// This field will default to a [FocusManager] that has registered its
  /// global input handlers via [FocusManager.registerGlobalHandlers]. Callers
  /// wishing to avoid registering those handlers (and modifying the associated
  /// static state) can explicitly pass a focus manager to the [BuildOwner.new]
  /// constructor.
  FocusManager focusManager;

  /// Adds an element to the dirty elements list so that it will be rebuilt
  /// when [WidgetsBinding.drawFrame] calls [buildScope].
  void scheduleBuildFor(Element element) {
    assert(element.owner == this);
    assert(element._parentBuildScope != null);
    assert(() {
      if (debugPrintScheduleBuildForStacks) {
        debugPrintStack(
          label:
              'scheduleBuildFor() called for $element${element.buildScope._dirtyElements.contains(element) ? " (ALREADY IN LIST)" : ""}',
        );
      }
      if (!element.dirty) {
        throw FlutterError.fromParts(<DiagnosticsNode>[
          ErrorSummary('scheduleBuildFor() called for a widget that is not marked as dirty.'),
          element.describeElement('The method was called for the following element'),
          ErrorDescription(
            'This element is not current marked as dirty. Make sure to set the dirty flag before '
            'calling scheduleBuildFor().',
          ),
          ErrorHint(
            'If you did not attempt to call scheduleBuildFor() yourself, then this probably '
            'indicates a bug in the widgets framework. Please report it:\n'
            '  https://github.com/flutter/flutter/issues/new?template=02_bug.yml',
          ),
        ]);
      }
      return true;
    }());
    final BuildScope buildScope = element.buildScope;
    assert(() {
      if (debugPrintScheduleBuildForStacks && element._inDirtyList) {
        debugPrintStack(
          label:
              'BuildOwner.scheduleBuildFor() called; '
              '_dirtyElementsNeedsResorting was ${buildScope._dirtyElementsNeedsResorting} (now true); '
              'The dirty list for the current build scope is: ${buildScope._dirtyElements}',
        );
      }
      if (!_debugBuilding && element._inDirtyList) {
        throw FlutterError.fromParts(<DiagnosticsNode>[
          ErrorSummary('BuildOwner.scheduleBuildFor() called inappropriately.'),
          ErrorHint(
            'The BuildOwner.scheduleBuildFor() method called on an Element '
            'that is already in the dirty list.',
          ),
          element.describeElement('the dirty Element was'),
        ]);
      }
      return true;
    }());
    if (!_scheduledFlushDirtyElements && onBuildScheduled != null) {
      _scheduledFlushDirtyElements = true;
      onBuildScheduled!();
    }
    buildScope._scheduleBuildFor(element);
    assert(() {
      if (debugPrintScheduleBuildForStacks) {
        debugPrint("...the build scope's dirty list is now: ${buildScope._dirtyElements}");
      }
      return true;
    }());
  }

  int _debugStateLockLevel = 0;
  bool get _debugStateLocked => _debugStateLockLevel > 0;

  /// Whether this widget tree is in the build phase.
  ///
  /// Only valid when asserts are enabled.
  bool get debugBuilding => _debugBuilding;
  bool _debugBuilding = false;
  Element? _debugCurrentBuildTarget;

  /// Establishes a scope in which calls to [State.setState] are forbidden, and
  /// calls the given `callback`.
  ///
  /// This mechanism is used to ensure that, for instance, [State.dispose] does
  /// not call [State.setState].
  void lockState(VoidCallback callback) {
    assert(_debugStateLockLevel >= 0);
    assert(() {
      _debugStateLockLevel += 1;
      return true;
    }());
    try {
      callback();
    } finally {
      assert(() {
        _debugStateLockLevel -= 1;
        return true;
      }());
    }
    assert(_debugStateLockLevel >= 0);
  }

  /// Establishes a scope for updating the widget tree, and calls the given
  /// `callback`, if any. Then, builds all the elements that were marked as
  /// dirty using [scheduleBuildFor], in depth order.
  ///
  /// This mechanism prevents build methods from transitively requiring other
  /// build methods to run, potentially causing infinite loops.
  ///
  /// The dirty list is processed after `callback` returns, building all the
  /// elements that were marked as dirty using [scheduleBuildFor], in depth
  /// order. If elements are marked as dirty while this method is running, they
  /// must be deeper than the `context` node, and deeper than any
  /// previously-built node in this pass.
  ///
  /// To flush the current dirty list without performing any other work, this
  /// function can be called with no callback. This is what the framework does
  /// each frame, in [WidgetsBinding.drawFrame].
  ///
  /// Only one [buildScope] can be active at a time.
  ///
  /// A [buildScope] implies a [lockState] scope as well.
  ///
  /// To print a console message every time this method is called, set
  /// [debugPrintBuildScope] to true. This is useful when debugging problems
  /// involving widgets not getting marked dirty, or getting marked dirty too
  /// often.
  @pragma('vm:notify-debugger-on-exception')
  void buildScope(Element context, [VoidCallback? callback]) {
    final BuildScope buildScope = context.buildScope;
    if (callback == null && buildScope._dirtyElements.isEmpty) {
      return;
    }
    assert(_debugStateLockLevel >= 0);
    assert(!_debugBuilding);
    assert(() {
      if (debugPrintBuildScope) {
        debugPrint(
          'buildScope called with context $context; '
          "its build scope's dirty list is: ${buildScope._dirtyElements}",
        );
      }
      _debugStateLockLevel += 1;
      _debugBuilding = true;
      return true;
    }());
    if (!kReleaseMode) {
      Map<String, String>? debugTimelineArguments;
      assert(() {
        if (debugEnhanceBuildTimelineArguments) {
          debugTimelineArguments = <String, String>{
            'build scope dirty count': '${buildScope._dirtyElements.length}',
            'build scope dirty list': '${buildScope._dirtyElements}',
            'lock level': '$_debugStateLockLevel',
            'scope context': '$context',
          };
        }
        return true;
      }());
      FlutterTimeline.startSync('BUILD', arguments: debugTimelineArguments);
    }
    try {
      _scheduledFlushDirtyElements = true;
      buildScope._building = true;
      if (callback != null) {
        assert(_debugStateLocked);
        Element? debugPreviousBuildTarget;
        assert(() {
          debugPreviousBuildTarget = _debugCurrentBuildTarget;
          _debugCurrentBuildTarget = context;
          return true;
        }());
        try {
          callback();
        } finally {
          assert(() {
            assert(_debugCurrentBuildTarget == context);
            _debugCurrentBuildTarget = debugPreviousBuildTarget;
            _debugElementWasRebuilt(context);
            return true;
          }());
        }
      }
      buildScope._flushDirtyElements(debugBuildRoot: context);
    } finally {
      buildScope._building = false;
      _scheduledFlushDirtyElements = false;
      if (!kReleaseMode) {
        FlutterTimeline.finishSync();
      }
      assert(_debugBuilding);
      assert(() {
        _debugBuilding = false;
        _debugStateLockLevel -= 1;
        if (debugPrintBuildScope) {
          debugPrint('buildScope finished');
        }
        return true;
      }());
    }
    assert(_debugStateLockLevel >= 0);
  }

  Map<Element, Set<GlobalKey>>? _debugElementsThatWillNeedToBeRebuiltDueToGlobalKeyShenanigans;

  void _debugTrackElementThatWillNeedToBeRebuiltDueToGlobalKeyShenanigans(
    Element node,
    GlobalKey key,
  ) {
    final Map<Element, Set<GlobalKey>> map =
        _debugElementsThatWillNeedToBeRebuiltDueToGlobalKeyShenanigans ??=
            HashMap<Element, Set<GlobalKey>>();
    final Set<GlobalKey> keys = map.putIfAbsent(node, () => HashSet<GlobalKey>());
    keys.add(key);
  }

  void _debugElementWasRebuilt(Element node) {
    _debugElementsThatWillNeedToBeRebuiltDueToGlobalKeyShenanigans?.remove(node);
  }

  final Map<GlobalKey, Element> _globalKeyRegistry = <GlobalKey, Element>{};

  // In Profile/Release mode this field is initialized to `null`. The Dart compiler can
  // eliminate unused fields, but not their initializers.
  @_debugOnly
  final Set<Element>? _debugIllFatedElements = kDebugMode ? HashSet<Element>() : null;

  // This map keeps track which child reserves the global key with the parent.
  // Parent, child -> global key.
  // This provides us a way to remove old reservation while parent rebuilds the
  // child in the same slot.
  //
  // In Profile/Release mode this field is initialized to `null`. The Dart compiler can
  // eliminate unused fields, but not their initializers.
  @_debugOnly
  final Map<Element, Map<Element, GlobalKey>>? _debugGlobalKeyReservations = kDebugMode
      ? <Element, Map<Element, GlobalKey>>{}
      : null;

  /// The number of [GlobalKey] instances that are currently associated with
  /// [Element]s that have been built by this build owner.
  int get globalKeyCount => _globalKeyRegistry.length;

  void _debugRemoveGlobalKeyReservationFor(Element parent, Element child) {
    assert(() {
      _debugGlobalKeyReservations?[parent]?.remove(child);
      return true;
    }());
  }

  void _registerGlobalKey(GlobalKey key, Element element) {
    assert(() {
      if (_globalKeyRegistry.containsKey(key)) {
        final Element oldElement = _globalKeyRegistry[key]!;
        assert(element.widget.runtimeType != oldElement.widget.runtimeType);
        _debugIllFatedElements?.add(oldElement);
      }
      return true;
    }());
    _globalKeyRegistry[key] = element;
  }

  void _unregisterGlobalKey(GlobalKey key, Element element) {
    assert(() {
      if (_globalKeyRegistry.containsKey(key) && _globalKeyRegistry[key] != element) {
        final Element oldElement = _globalKeyRegistry[key]!;
        assert(element.widget.runtimeType != oldElement.widget.runtimeType);
      }
      return true;
    }());
    if (_globalKeyRegistry[key] == element) {
      _globalKeyRegistry.remove(key);
    }
  }

  void _debugReserveGlobalKeyFor(Element parent, Element child, GlobalKey key) {
    assert(() {
      _debugGlobalKeyReservations?[parent] ??= <Element, GlobalKey>{};
      _debugGlobalKeyReservations?[parent]![child] = key;
      return true;
    }());
  }

  void _debugVerifyGlobalKeyReservation() {
    assert(() {
      final keyToParent = <GlobalKey, Element>{};
      _debugGlobalKeyReservations?.forEach((Element parent, Map<Element, GlobalKey> childToKey) {
        // We ignore parent that are unmounted or detached.
        if (parent._lifecycleState == _ElementLifecycle.defunct ||
            parent.renderObject?.attached == false) {
          return;
        }
        childToKey.forEach((Element child, GlobalKey key) {
          // If parent = null, the node is deactivated by its parent and is
          // not re-attached to other part of the tree. We should ignore this
          // node.
          if (child._parent == null) {
            return;
          }
          // It is possible the same key registers to the same parent twice
          // with different children. That is illegal, but it is not in the
          // scope of this check. Such error will be detected in
          // _debugVerifyIllFatedPopulation or
          // _debugElementsThatWillNeedToBeRebuiltDueToGlobalKeyShenanigans.
          if (keyToParent.containsKey(key) && keyToParent[key] != parent) {
            // We have duplication reservations for the same global key.
            final Element older = keyToParent[key]!;
            final newer = parent;
            final FlutterError error;
            if (older.toString() != newer.toString()) {
              error = FlutterError.fromParts(<DiagnosticsNode>[
                ErrorSummary('Multiple widgets used the same GlobalKey.'),
                ErrorDescription(
                  'The key $key was used by multiple widgets. The parents of those widgets were:\n'
                  '- $older\n'
                  '- $newer\n'
                  'A GlobalKey can only be specified on one widget at a time in the widget tree.',
                ),
              ]);
            } else {
              error = FlutterError.fromParts(<DiagnosticsNode>[
                ErrorSummary('Multiple widgets used the same GlobalKey.'),
                ErrorDescription(
                  'The key $key was used by multiple widgets. The parents of those widgets were '
                  'different widgets that both had the following description:\n'
                  '  $parent\n'
                  'A GlobalKey can only be specified on one widget at a time in the widget tree.',
                ),
              ]);
            }
            // Fix the tree by removing the duplicated child from one of its
            // parents to resolve the duplicated key issue. This allows us to
            // tear down the tree during testing without producing additional
            // misleading exceptions.
            if (child._parent != older) {
              older.visitChildren((Element currentChild) {
                if (currentChild == child) {
                  older.forgetChild(child);
                }
              });
            }
            if (child._parent != newer) {
              newer.visitChildren((Element currentChild) {
                if (currentChild == child) {
                  newer.forgetChild(child);
                }
              });
            }
            throw error;
          } else {
            keyToParent[key] = parent;
          }
        });
      });
      _debugGlobalKeyReservations?.clear();
      return true;
    }());
  }

  void _debugVerifyIllFatedPopulation() {
    assert(() {
      Map<GlobalKey, Set<Element>>? duplicates;
      for (final Element element in _debugIllFatedElements ?? const <Element>{}) {
        if (element._lifecycleState != _ElementLifecycle.defunct) {
          assert(element.widget.key != null);
          final key = element.widget.key! as GlobalKey;
          assert(_globalKeyRegistry.containsKey(key));
          duplicates ??= <GlobalKey, Set<Element>>{};
          // Uses ordered set to produce consistent error message.
          final Set<Element> elements = duplicates.putIfAbsent(key, () => <Element>{});
          elements.add(element);
          elements.add(_globalKeyRegistry[key]!);
        }
      }
      _debugIllFatedElements?.clear();
      if (duplicates != null) {
        final information = <DiagnosticsNode>[];
        information.add(ErrorSummary('Multiple widgets used the same GlobalKey.'));
        for (final GlobalKey key in duplicates.keys) {
          final Set<Element> elements = duplicates[key]!;
          // TODO(jacobr): this will omit the '- ' before each widget name and
          // use the more standard whitespace style instead. Please let me know
          // if the '- ' style is a feature we want to maintain and we can add
          // another tree style that supports it. I also see '* ' in some places
          // so it would be nice to unify and normalize.
          information.add(
            Element.describeElements(
              'The key $key was used by ${elements.length} widgets',
              elements,
            ),
          );
        }
        information.add(
          ErrorDescription(
            'A GlobalKey can only be specified on one widget at a time in the widget tree.',
          ),
        );
        throw FlutterError.fromParts(information);
      }
      return true;
    }());
  }

  /// Complete the element build pass by unmounting any elements that are no
  /// longer active.
  ///
  /// This is called by [WidgetsBinding.drawFrame].
  ///
  /// In debug mode, this also runs some sanity checks, for example checking for
  /// duplicate global keys.
  @pragma('vm:notify-debugger-on-exception')
  void finalizeTree() {
    if (!kReleaseMode) {
      FlutterTimeline.startSync('FINALIZE TREE');
    }
    try {
      lockState(_inactiveElements._unmountAll); // this unregisters the GlobalKeys
      assert(() {
        try {
          _debugVerifyGlobalKeyReservation();
          _debugVerifyIllFatedPopulation();
          if (_debugElementsThatWillNeedToBeRebuiltDueToGlobalKeyShenanigans?.isNotEmpty ?? false) {
            final Set<GlobalKey> keys = HashSet<GlobalKey>();
            for (final Element element
                in _debugElementsThatWillNeedToBeRebuiltDueToGlobalKeyShenanigans!.keys) {
              if (element._lifecycleState != _ElementLifecycle.defunct) {
                keys.addAll(
                  _debugElementsThatWillNeedToBeRebuiltDueToGlobalKeyShenanigans![element]!,
                );
              }
            }
            if (keys.isNotEmpty) {
              final Map<String, int> keyStringCount = HashMap<String, int>();
              for (final String key in keys.map<String>((GlobalKey key) => key.toString())) {
                if (keyStringCount.containsKey(key)) {
                  keyStringCount.update(key, (int value) => value + 1);
                } else {
                  keyStringCount[key] = 1;
                }
              }
              final keyLabels = <String>[
                for (final MapEntry<String, int>(:String key, value: int count)
                    in keyStringCount.entries)
                  if (count == 1)
                    key
                  else
                    '$key ($count different affected keys had this toString representation)',
              ];
              final Iterable<Element> elements =
                  _debugElementsThatWillNeedToBeRebuiltDueToGlobalKeyShenanigans!.keys;
              final Map<String, int> elementStringCount = HashMap<String, int>();
              for (final String element in elements.map<String>(
                (Element element) => element.toString(),
              )) {
                if (elementStringCount.containsKey(element)) {
                  elementStringCount.update(element, (int value) => value + 1);
                } else {
                  elementStringCount[element] = 1;
                }
              }
              final elementLabels = <String>[
                for (final MapEntry<String, int>(key: String element, value: int count)
                    in elementStringCount.entries)
                  if (count == 1)
                    element
                  else
                    '$element ($count different affected elements had this toString representation)',
              ];
              assert(keyLabels.isNotEmpty);
              final the = keys.length == 1 ? ' the' : '';
              final s = keys.length == 1 ? '' : 's';
              final were = keys.length == 1 ? 'was' : 'were';
              final their = keys.length == 1 ? 'its' : 'their';
              final respective = elementLabels.length == 1 ? '' : ' respective';
              final those = keys.length == 1 ? 'that' : 'those';
              final s2 = elementLabels.length == 1 ? '' : 's';
              final those2 = elementLabels.length == 1 ? 'that' : 'those';
              final they = elementLabels.length == 1 ? 'it' : 'they';
              final think = elementLabels.length == 1 ? 'thinks' : 'think';
              final are = elementLabels.length == 1 ? 'is' : 'are';
              // TODO(jacobr): make this error more structured to better expose which widgets had problems.
              throw FlutterError.fromParts(<DiagnosticsNode>[
                ErrorSummary('Duplicate GlobalKey$s detected in widget tree.'),
                // TODO(jacobr): refactor this code so the elements are clickable
                // in GUI debug tools.
                ErrorDescription(
                  'The following GlobalKey$s $were specified multiple times in the widget tree. This will lead to '
                  'parts of the widget tree being truncated unexpectedly, because the second time a key is seen, '
                  'the previous instance is moved to the new location. The key$s $were:\n'
                  '- ${keyLabels.join("\n  ")}\n'
                  'This was determined by noticing that after$the widget$s with the above global key$s $were moved '
                  'out of $their$respective previous parent$s2, $those2 previous parent$s2 never updated during this frame, meaning '
                  'that $they either did not update at all or updated before the widget$s $were moved, in either case '
                  'implying that $they still $think that $they should have a child with $those global key$s.\n'
                  'The specific parent$s2 that did not update after having one or more children forcibly removed '
                  'due to GlobalKey reparenting $are:\n'
                  '- ${elementLabels.join("\n  ")}'
                  '\nA GlobalKey can only be specified on one widget at a time in the widget tree.',
                ),
              ]);
            }
          }
        } finally {
          _debugElementsThatWillNeedToBeRebuiltDueToGlobalKeyShenanigans?.clear();
        }
        return true;
      }());
    } catch (e, stack) {
      // Catching the exception directly to avoid activating the ErrorWidget.
      // Since the tree is in a broken state, adding the ErrorWidget would
      // cause more exceptions.
      _reportException(ErrorSummary('while finalizing the widget tree'), e, stack);
    } finally {
      if (!kReleaseMode) {
        FlutterTimeline.finishSync();
      }
    }
  }

  /// Cause the entire subtree rooted at the given [Element] to be entirely
  /// rebuilt. This is used by development tools when the application code has
  /// changed and is being hot-reloaded, to cause the widget tree to pick up any
  /// changed implementations.
  ///
  /// This is expensive and should not be called except during development.
  void reassemble(Element root) {
    if (!kReleaseMode) {
      FlutterTimeline.startSync('Preparing Hot Reload (widgets)');
    }
    try {
      assert(root._parent == null);
      assert(root.owner == this);
      root.reassemble();
    } finally {
      if (!kReleaseMode) {
        FlutterTimeline.finishSync();
      }
    }
  }
}

/// Mixin this class to allow receiving [Notification] objects dispatched by
/// child elements.
///
/// See also:
///   * [NotificationListener], for a widget that allows consuming notifications.
mixin NotifiableElementMixin on Element {
  /// Called when a notification of the appropriate type arrives at this
  /// location in the tree.
  ///
  /// Return true to cancel the notification bubbling. Return false to
  /// allow the notification to continue to be dispatched to further ancestors.
  bool onNotification(Notification notification);

  @override
  void attachNotificationTree() {
    _notificationTree = _NotificationNode(_parent?._notificationTree, this);
  }
}

class _NotificationNode {
  _NotificationNode(this.parent, this.current);

  NotifiableElementMixin? current;
  _NotificationNode? parent;

  void dispatchNotification(Notification notification) {
    if (current?.onNotification(notification) ?? true) {
      return;
    }
    parent?.dispatchNotification(notification);
  }
}

bool _isProfileBuildsEnabledFor(Widget widget) {
  return debugProfileBuildsEnabled ||
      (debugProfileBuildsEnabledUserWidgets && debugIsWidgetLocalCreation(widget));
}

/// An instantiation of a [Widget] at a particular location in the tree.
///
/// Widgets describe how to configure a subtree but the same widget can be used
/// to configure multiple subtrees simultaneously because widgets are immutable.
/// An [Element] represents the use of a widget to configure a specific location
/// in the tree. Over time, the widget associated with a given element can
/// change, for example, if the parent widget rebuilds and creates a new widget
/// for this location.
///
/// Elements form a tree. Most elements have a unique child, but some widgets
/// (e.g., subclasses of [RenderObjectElement]) can have multiple children.
///
/// Elements have the following lifecycle:
///
///  * The framework creates an element by calling [Widget.createElement] on the
///    widget that will be used as the element's initial configuration.
///  * The framework calls [mount] to add the newly created element to the tree
///    at a given slot in a given parent. The [mount] method is responsible for
///    inflating any child widgets and calling [attachRenderObject] as
///    necessary to attach any associated render objects to the render tree.
///  * At this point, the element is considered "active" and might appear on
///    screen.
///  * At some point, the parent might decide to change the widget used to
///    configure this element, for example because the parent rebuilt with new
///    state. When this happens, the framework will call [update] with the new
///    widget. The new widget will always have the same [runtimeType] and key as
///    old widget. If the parent wishes to change the [runtimeType] or key of
///    the widget at this location in the tree, it can do so by unmounting this
///    element and inflating the new widget at this location.
///  * At some point, an ancestor might decide to remove this element (or an
///    intermediate ancestor) from the tree, which the ancestor does by calling
///    [deactivateChild] on itself. Deactivating the intermediate ancestor will
///    remove that element's render object from the render tree and add this
///    element to the [owner]'s list of inactive elements, causing the framework
///    to call [deactivate] on this element.
///  * At this point, the element is considered "inactive" and will not appear
///    on screen. An element can remain in the inactive state only until
///    the end of the current animation frame. At the end of the animation
///    frame, any elements that are still inactive will be unmounted.
///  * If the element gets reincorporated into the tree (e.g., because it or one
///    of its ancestors has a global key that is reused), the framework will
///    remove the element from the [owner]'s list of inactive elements, call
///    [activate] on the element, and reattach the element's render object to
///    the render tree. (At this point, the element is again considered "active"
///    and might appear on screen.)
///  * If the element does not get reincorporated into the tree by the end of
///    the current animation frame, the framework will call [unmount] on the
///    element.
///  * At this point, the element is considered "defunct" and will not be
///    incorporated into the tree in the future.
abstract class Element extends DiagnosticableTree implements BuildContext {
  /// Creates an element that uses the given widget as its configuration.
  ///
  /// Typically called by an override of [Widget.createElement].
  Element(Widget widget) : _widget = widget {
    assert(debugMaybeDispatchCreated('widgets', 'Element', this));
  }

  Element? _parent;
  _NotificationNode? _notificationTree;

  /// Compare two widgets for equality.
  ///
  /// When a widget is rebuilt with another that compares equal according
  /// to `operator ==`, it is assumed that the update is redundant and the
  /// work to update that branch of the tree is skipped.
  ///
  /// It is generally discouraged to override `operator ==` on any widget that
  /// has children, since a correct implementation would have to defer to the
  /// children's equality operator also, and that is an O(N²) operation: each
  /// child would need to itself walk all its children, each step of the tree.
  ///
  /// It is sometimes reasonable for a leaf widget (one with no children) to
  /// implement this method, if rebuilding the widget is known to be much more
  /// expensive than checking the widgets' parameters for equality and if the
  /// widget is expected to often be rebuilt with identical parameters.
  ///
  /// In general, however, it is more efficient to cache the widgets used
  /// in a build method if it is known that they will not change.
  @nonVirtual
  @override
  // ignore: avoid_equals_and_hash_code_on_mutable_classes, hash_and_equals
  bool operator ==(Object other) => identical(this, other);

  /// Information set by parent to define where this child fits in its parent's
  /// child list.
  ///
  /// A child widget's slot is determined when the parent's [updateChild] method
  /// is called to inflate the child widget. See [RenderObjectElement] for more
  /// details on slots.
  Object? get slot => _slot;
  Object? _slot;

  /// An integer that is guaranteed to be greater than the parent's, if any.
  /// The element at the root of the tree must have a depth greater than 0.
  int get depth {
    assert(() {
      if (_lifecycleState == _ElementLifecycle.initial) {
        throw FlutterError('Depth is only available when element has been mounted.');
      }
      return true;
    }());
    return _depth;
  }

  late int _depth;

  /// Returns result < 0 when [a] < [b], result == 0 when [a] == [b], result > 0
  /// when [a] > [b].
  static int _sort(Element a, Element b) {
    final int diff = a.depth - b.depth;
    // If depths are not equal, return the difference.
    if (diff != 0) {
      return diff;
    }
    // If the `dirty` values are not equal, sort with non-dirty elements being
    // less than dirty elements.
    final bool isBDirty = b.dirty;
    if (a.dirty != isBDirty) {
      return isBDirty ? -1 : 1;
    }
    // Otherwise, `depth`s and `dirty`s are equal.
    return 0;
  }

  // Return a numeric encoding of the specific `Element` concrete subtype.
  // This is used in `Element.updateChild` to determine if a hot reload modified the
  // superclass of a mounted element's configuration. The encoding of each `Element`
  // must match the corresponding `Widget` encoding in `Widget._debugConcreteSubtype`.
  static int _debugConcreteSubtype(Element element) {
    return element is StatefulElement
        ? 1
        : element is StatelessElement
        ? 2
        : 0;
  }

  /// The configuration for this element.
  ///
  /// Avoid overriding this field on [Element] subtypes to provide a more
  /// specific widget type (i.e. [StatelessElement] and [StatelessWidget]).
  /// Instead, cast at any call sites where the more specific type is required.
  /// This avoids significant cast overhead on the getter which is accessed
  /// throughout the framework internals during the build phase - and for which
  /// the more specific type information is not used.
  @override
  Widget get widget => _widget!;
  Widget? _widget;

  @override
  bool get mounted => _widget != null;

  /// Returns true if the Element is defunct.
  ///
  /// This getter always returns false in profile and release builds.
  /// See the lifecycle documentation for [Element] for additional information.
  bool get debugIsDefunct {
    var isDefunct = false;
    assert(() {
      isDefunct = _lifecycleState == _ElementLifecycle.defunct;
      return true;
    }());
    return isDefunct;
  }

  /// Returns true if the Element is active.
  ///
  /// This getter always returns false in profile and release builds.
  /// See the lifecycle documentation for [Element] for additional information.
  bool get debugIsActive {
    var isActive = false;
    assert(() {
      isActive = _lifecycleState == _ElementLifecycle.active;
      return true;
    }());
    return isActive;
  }

  /// The object that manages the lifecycle of this element.
  @override
  BuildOwner? get owner => _owner;
  BuildOwner? _owner;

  /// A [BuildScope] whose dirty [Element]s can only be rebuilt by
  /// [BuildOwner.buildScope] calls whose `context` argument is an [Element]
  /// within this [BuildScope].
  ///
  /// The getter typically is only safe to access when this [Element] is [mounted].
  ///
  /// The default implementation returns the parent [Element]'s [buildScope],
  /// as in most cases an [Element] is ready to rebuild as soon as its ancestors
  /// are no longer dirty. One notable exception is [LayoutBuilder]'s
  /// descendants, which must not rebuild until the incoming constraints become
  /// available. [LayoutBuilder]'s [Element] overrides [buildScope] to make none
  /// of its descendants can rebuild until the incoming constraints are known.
  ///
  /// If you choose to override this getter to establish your own [BuildScope],
  /// to flush the dirty [Element]s in the [BuildScope] you need to manually call
  /// [BuildOwner.buildScope] with the root [Element] of your [BuildScope] when
  /// appropriate, as the Flutter framework does not try to register or manage
  /// custom [BuildScope]s.
  ///
  /// Always return the same [BuildScope] instance if you override this getter.
  /// Changing the value returned by this getter at runtime is not
  /// supported.
  ///
  /// The [updateChild] method ignores [buildScope]: if the parent [Element]
  /// calls [updateChild] on a child with a different [BuildScope], the child may
  /// still rebuild.
  ///
  /// See also:
  ///
  ///  * [LayoutBuilder], a widget that establishes a custom [BuildScope].
  BuildScope get buildScope => _parentBuildScope!;
  // The cached value of the parent Element's build scope. The cache is updated
  // when this Element mounts or reparents.
  BuildScope? _parentBuildScope;

  /// {@template flutter.widgets.Element.reassemble}
  /// Called whenever the application is reassembled during debugging, for
  /// example during hot reload.
  ///
  /// This method should rerun any initialization logic that depends on global
  /// state, for example, image loading from asset bundles (since the asset
  /// bundle may have changed).
  ///
  /// This function will only be called during development. In release builds,
  /// the `ext.flutter.reassemble` hook is not available, and so this code will
  /// never execute.
  ///
  /// Implementers should not rely on any ordering for hot reload source update,
  /// reassemble, and build methods after a hot reload has been initiated. It is
  /// possible that a [Timer] (e.g. an [Animation]) or a debugging session
  /// attached to the isolate could trigger a build with reloaded code _before_
  /// reassemble is called. Code that expects preconditions to be set by
  /// reassemble after a hot reload must be resilient to being called out of
  /// order, e.g. by fizzling instead of throwing. That said, once reassemble is
  /// called, build will be called after it at least once.
  /// {@endtemplate}
  ///
  /// See also:
  ///
  ///  * [State.reassemble]
  ///  * [BindingBase.reassembleApplication]
  ///  * [Image], which uses this to reload images.
  @mustCallSuper
  @protected
  void reassemble() {
    markNeedsBuild();
    visitChildren((Element child) {
      child.reassemble();
    });
  }

  bool _debugIsDescendantOf(Element target) {
    Element? element = this;
    while (element != null && element.depth > target.depth) {
      element = element._parent;
    }
    return element == target;
  }

  /// The render object at (or below) this location in the tree.
  ///
  /// If this object is a [RenderObjectElement], the render object is the one at
  /// this location in the tree. Otherwise, this getter will walk down the tree
  /// until it finds a [RenderObjectElement].
  ///
  /// Some locations in the tree are not backed by a render object. In those
  /// cases, this getter returns null. This can happen, if the element is
  /// located outside of a [View] since only the element subtree rooted in a
  /// view has a render tree associated with it.
  RenderObject? get renderObject {
    Element? current = this;
    while (current != null) {
      if (current._lifecycleState == _ElementLifecycle.defunct) {
        break;
      } else if (current is RenderObjectElement) {
        return current.renderObject;
      } else {
        current = current.renderObjectAttachingChild;
      }
    }
    return null;
  }

  /// Returns the child of this [Element] that will insert a [RenderObject] into
  /// an ancestor of this Element to construct the render tree.
  ///
  /// Returns null if this Element doesn't have any children who need to attach
  /// a [RenderObject] to an ancestor of this [Element]. A [RenderObjectElement]
  /// will therefore return null because its children insert their
  /// [RenderObject]s into the [RenderObjectElement] itself and not into an
  /// ancestor of the [RenderObjectElement].
  ///
  /// Furthermore, this may return null for [Element]s that hoist their own
  /// independent render tree and do not extend the ancestor render tree.
  @protected
  Element? get renderObjectAttachingChild {
    Element? next;
    visitChildren((Element child) {
      assert(next == null); // This verifies that there's only one child.
      next = child;
    });
    return next;
  }

  @override
  List<DiagnosticsNode> describeMissingAncestor({required Type expectedAncestorType}) {
    final information = <DiagnosticsNode>[];
    final ancestors = <Element>[];
    visitAncestorElements((Element element) {
      ancestors.add(element);
      return true;
    });

    information.add(
      DiagnosticsProperty<Element>(
        'The specific widget that could not find a $expectedAncestorType ancestor was',
        this,
        style: DiagnosticsTreeStyle.errorProperty,
      ),
    );

    if (ancestors.isNotEmpty) {
      information.add(describeElements('The ancestors of this widget were', ancestors));
    } else {
      information.add(
        ErrorDescription(
          'This widget is the root of the tree, so it has no '
          'ancestors, let alone a "$expectedAncestorType" ancestor.',
        ),
      );
    }
    return information;
  }

  /// Returns a list of [Element]s from the current build context to the error report.
  static DiagnosticsNode describeElements(String name, Iterable<Element> elements) {
    return DiagnosticsBlock(
      name: name,
      children: elements
          .map<DiagnosticsNode>((Element element) => DiagnosticsProperty<Element>('', element))
          .toList(),
      allowTruncate: true,
    );
  }

  @override
  DiagnosticsNode describeElement(
    String name, {
    DiagnosticsTreeStyle style = DiagnosticsTreeStyle.errorProperty,
  }) {
    return DiagnosticsProperty<Element>(name, this, style: style);
  }

  @override
  DiagnosticsNode describeWidget(
    String name, {
    DiagnosticsTreeStyle style = DiagnosticsTreeStyle.errorProperty,
  }) {
    return DiagnosticsProperty<Element>(name, this, style: style);
  }

  @override
  DiagnosticsNode describeOwnershipChain(String name) {
    // TODO(jacobr): make this structured so clients can support clicks on
    // individual entries. For example, is this an iterable with arrows as
    // separators?
    return StringProperty(name, debugGetCreatorChain(10));
  }

  // This is used to verify that Element objects move through life in an
  // orderly fashion.
  _ElementLifecycle _lifecycleState = _ElementLifecycle.initial;

  /// Calls the argument for each child. Must be overridden by subclasses that
  /// support having children.
  ///
  /// There is no guaranteed order in which the children will be visited, though
  /// it should be consistent over time.
  ///
  /// Calling this during build is dangerous: the child list might still be
  /// being updated at that point, so the children might not be constructed yet,
  /// or might be old children that are going to be replaced. This method should
  /// only be called if it is provable that the children are available.
  void visitChildren(ElementVisitor visitor) {}

  /// Calls the argument for each child considered onstage.
  ///
  /// Classes like [Offstage] and [Overlay] override this method to hide their
  /// children.
  ///
  /// Being onstage affects the element's discoverability during testing when
  /// you use Flutter's [Finder] objects. For example, when you instruct the
  /// test framework to tap on a widget, by default the finder will look for
  /// onstage elements and ignore the offstage ones.
  ///
  /// The default implementation defers to [visitChildren] and therefore treats
  /// the element as onstage.
  ///
  /// See also:
  ///
  ///  * [Offstage] widget that hides its children.
  ///  * [Finder] that skips offstage widgets by default.
  ///  * [RenderObject.visitChildrenForSemantics], in contrast to this method,
  ///    designed specifically for excluding parts of the UI from the semantics
  ///    tree.
  void debugVisitOnstageChildren(ElementVisitor visitor) => visitChildren(visitor);

  /// Wrapper around [visitChildren] for [BuildContext].
  @override
  void visitChildElements(ElementVisitor visitor) {
    assert(() {
      if (owner == null || !owner!._debugStateLocked) {
        return true;
      }
      throw FlutterError.fromParts(<DiagnosticsNode>[
        ErrorSummary('visitChildElements() called during build.'),
        ErrorDescription(
          "The BuildContext.visitChildElements() method can't be called during "
          'build because the child list is still being updated at that point, '
          'so the children might not be constructed yet, or might be old children '
          'that are going to be replaced.',
        ),
      ]);
    }());
    visitChildren(visitor);
  }

  /// Update the given child with the given new configuration.
  ///
  /// This method is the core of the widgets system. It is called each time we
  /// are to add, update, or remove a child based on an updated configuration.
  ///
  /// The `newSlot` argument specifies the new value for this element's [slot].
  ///
  /// If the `child` is null, and the `newWidget` is not null, then we have a new
  /// child for which we need to create an [Element], configured with `newWidget`.
  ///
  /// If the `newWidget` is null, and the `child` is not null, then we need to
  /// remove it because it no longer has a configuration.
  ///
  /// If neither are null, then we need to update the `child`'s configuration to
  /// be the new configuration given by `newWidget`. If `newWidget` can be given
  /// to the existing child (as determined by [Widget.canUpdate]), then it is so
  /// given. Otherwise, the old child needs to be disposed and a new child
  /// created for the new configuration.
  ///
  /// If both are null, then we don't have a child and won't have a child, so we
  /// do nothing.
  ///
  /// The [updateChild] method returns the new child, if it had to create one,
  /// or the child that was passed in, if it just had to update the child, or
  /// null, if it removed the child and did not replace it.
  ///
  /// The following table summarizes the above:
  ///
  /// |                     | **newWidget == null**  | **newWidget != null**   |
  /// | :-----------------: | :--------------------- | :---------------------- |
  /// |  **child == null**  |  Returns null.         |  Returns new [Element]. |
  /// |  **child != null**  |  Old child is removed, returns null. | Old child updated if possible, returns child or new [Element]. |
  ///
  /// The `newSlot` argument is used only if `newWidget` is not null. If `child`
  /// is null (or if the old child cannot be updated), then the `newSlot` is
  /// given to the new [Element] that is created for the child, via
  /// [inflateWidget]. If `child` is not null (and the old child _can_ be
  /// updated), then the `newSlot` is given to [updateSlotForChild] to update
  /// its slot, in case it has moved around since it was last built.
  ///
  /// See the [RenderObjectElement] documentation for more information on slots.
  @protected
  @pragma('dart2js:tryInline')
  @pragma('vm:prefer-inline')
  @pragma('wasm:prefer-inline')
  Element? updateChild(Element? child, Widget? newWidget, Object? newSlot) {
    if (newWidget == null) {
      if (child != null) {
        deactivateChild(child);
      }
      return null;
    }

    final Element newChild;
    if (child != null) {
      var hasSameSuperclass = true;
      // When the type of a widget is changed between Stateful and Stateless via
      // hot reload, the element tree will end up in a partially invalid state.
      // That is, if the widget was a StatefulWidget and is now a StatelessWidget,
      // then the element tree currently contains a StatefulElement that is incorrectly
      // referencing a StatelessWidget (and likewise with StatelessElement).
      //
      // To avoid crashing due to type errors, we need to gently guide the invalid
      // element out of the tree. To do so, we ensure that the `hasSameSuperclass` condition
      // returns false which prevents us from trying to update the existing element
      // incorrectly.
      //
      // For the case where the widget becomes Stateful, we also need to avoid
      // accessing `StatelessElement.widget` as the cast on the getter will
      // cause a type error to be thrown. Here we avoid that by short-circuiting
      // the `Widget.canUpdate` check once `hasSameSuperclass` is false.
      assert(() {
        final int oldElementClass = Element._debugConcreteSubtype(child);
        final int newWidgetClass = Widget._debugConcreteSubtype(newWidget);
        hasSameSuperclass = oldElementClass == newWidgetClass;
        return true;
      }());
      if (hasSameSuperclass && child.widget == newWidget) {
        // We don't insert a timeline event here, because otherwise it's
        // confusing that widgets that "don't update" (because they didn't
        // change) get "charged" on the timeline.
        if (child.slot != newSlot) {
          updateSlotForChild(child, newSlot);
        }
        newChild = child;
      } else if (hasSameSuperclass && Widget.canUpdate(child.widget, newWidget)) {
        if (child.slot != newSlot) {
          updateSlotForChild(child, newSlot);
        }
        final bool isTimelineTracked = !kReleaseMode && _isProfileBuildsEnabledFor(newWidget);
        if (isTimelineTracked) {
          Map<String, String>? debugTimelineArguments;
          assert(() {
            if (kDebugMode && debugEnhanceBuildTimelineArguments) {
              debugTimelineArguments = newWidget.toDiagnosticsNode().toTimelineArguments();
            }
            return true;
          }());
          FlutterTimeline.startSync('${newWidget.runtimeType}', arguments: debugTimelineArguments);
        }
        child.update(newWidget);
        if (isTimelineTracked) {
          FlutterTimeline.finishSync();
        }
        assert(child.widget == newWidget);
        assert(() {
          child.owner!._debugElementWasRebuilt(child);
          return true;
        }());
        newChild = child;
      } else {
        deactivateChild(child);
        assert(child._parent == null);
        // The [debugProfileBuildsEnabled] code for this branch is inside
        // [inflateWidget], since some [Element]s call [inflateWidget] directly
        // instead of going through [updateChild].
        newChild = inflateWidget(newWidget, newSlot);
      }
    } else {
      // The [debugProfileBuildsEnabled] code for this branch is inside
      // [inflateWidget], since some [Element]s call [inflateWidget] directly
      // instead of going through [updateChild].
      newChild = inflateWidget(newWidget, newSlot);
    }

    assert(() {
      if (child != null) {
        _debugRemoveGlobalKeyReservation(child);
      }
      final Key? key = newWidget.key;
      if (key is GlobalKey) {
        assert(owner != null);
        owner!._debugReserveGlobalKeyFor(this, newChild, key);
      }
      return true;
    }());

    return newChild;
  }

  /// Updates the children of this element to use new widgets.
  ///
  /// Attempts to update the given old children list using the given new
  /// widgets, removing obsolete elements and introducing new ones as necessary,
  /// and then returns the new child list.
  ///
  /// During this function the `oldChildren` list must not be modified. If the
  /// caller wishes to remove elements from `oldChildren` reentrantly while
  /// this function is on the stack, the caller can supply a `forgottenChildren`
  /// argument, which can be modified while this function is on the stack.
  /// Whenever this function reads from `oldChildren`, this function first
  /// checks whether the child is in `forgottenChildren`. If it is, the function
  /// acts as if the child was not in `oldChildren`.
  ///
  /// This function is a convenience wrapper around [updateChild], which updates
  /// each individual child. If `slots` is non-null, the value for the `newSlot`
  /// argument of [updateChild] is retrieved from that list using the index that
  /// the currently processed `child` corresponds to in the `newWidgets` list
  /// (`newWidgets` and `slots` must have the same length). If `slots` is null,
  /// an [IndexedSlot<Element>] is used as the value for the `newSlot` argument.
  /// In that case, [IndexedSlot.index] is set to the index that the currently
  /// processed `child` corresponds to in the `newWidgets` list and
  /// [IndexedSlot.value] is set to the [Element] of the previous widget in that
  /// list (or null if it is the first child).
  ///
  /// When the [slot] value of an [Element] changes, its
  /// associated [renderObject] needs to move to a new position in the child
  /// list of its parents. If that [RenderObject] organizes its children in a
  /// linked list (as is done by the [ContainerRenderObjectMixin]) this can
  /// be implemented by re-inserting the child [RenderObject] into the
  /// list after the [RenderObject] associated with the [Element] provided as
  /// [IndexedSlot.value] in the [slot] object.
  ///
  /// Using the previous sibling as a [slot] is not enough, though, because
  /// child [RenderObject]s are only moved around when the [slot] of their
  /// associated [RenderObjectElement]s is updated. When the order of child
  /// [Element]s is changed, some elements in the list may move to a new index
  /// but still have the same previous sibling. For example, when
  /// `[e1, e2, e3, e4]` is changed to `[e1, e3, e4, e2]` the element e4
  /// continues to have e3 as a previous sibling even though its index in the list
  /// has changed and its [RenderObject] needs to move to come before e2's
  /// [RenderObject]. In order to trigger this move, a new [slot] value needs to
  /// be assigned to its [Element] whenever its index in its
  /// parent's child list changes. Using an [IndexedSlot<Element>] achieves
  /// exactly that and also ensures that the underlying parent [RenderObject]
  /// knows where a child needs to move to in a linked list by providing its new
  /// previous sibling.
  @protected
  List<Element> updateChildren(
    List<Element> oldChildren,
    List<Widget> newWidgets, {
    Set<Element>? forgottenChildren,
    List<Object?>? slots,
  }) {
    assert(slots == null || newWidgets.length == slots.length);

    Element? replaceWithNullIfForgotten(Element child) {
      return (forgottenChildren?.contains(child) ?? false) ? null : child;
    }

    Object? slotFor(int newChildIndex, Element? previousChild) {
      return slots != null
          ? slots[newChildIndex]
          : IndexedSlot<Element?>(newChildIndex, previousChild);
    }

    // This attempts to diff the new child list (newWidgets) with
    // the old child list (oldChildren), and produce a new list of elements to
    // be the new list of child elements of this element. The called of this
    // method is expected to update this render object accordingly.

    // The cases it tries to optimize for are:
    //  - the old list is empty
    //  - the lists are identical
    //  - there is an insertion or removal of one or more widgets in
    //    only one place in the list
    // If a widget with a key is in both lists, it will be synced.
    // Widgets without keys might be synced but there is no guarantee.

    // The general approach is to sync the entire new list backwards, as follows:
    // 1. Walk the lists from the top, syncing nodes, until you no longer have
    //    matching nodes.
    // 2. Walk the lists from the bottom, without syncing nodes, until you no
    //    longer have matching nodes. We'll sync these nodes at the end. We
    //    don't sync them now because we want to sync all the nodes in order
    //    from beginning to end.
    // At this point we narrowed the old and new lists to the point
    // where the nodes no longer match.
    // 3. Walk the narrowed part of the old list to get the list of
    //    keys and sync null with non-keyed items.
    // 4. Walk the narrowed part of the new list forwards:
    //     * Sync non-keyed items with null
    //     * Sync keyed items with the source if it exists, else with null.
    // 5. Walk the bottom of the list again, syncing the nodes.
    // 6. Sync null with any items in the list of keys that are still
    //    mounted.

    var newChildrenTop = 0;
    var oldChildrenTop = 0;
    int newChildrenBottom = newWidgets.length - 1;
    int oldChildrenBottom = oldChildren.length - 1;

    final newChildren = List<Element>.filled(newWidgets.length, _NullElement.instance);

    Element? previousChild;

    // Update the top of the list.
    while ((oldChildrenTop <= oldChildrenBottom) && (newChildrenTop <= newChildrenBottom)) {
      final Element? oldChild = replaceWithNullIfForgotten(oldChildren[oldChildrenTop]);
      final Widget newWidget = newWidgets[newChildrenTop];
      assert(oldChild == null || oldChild._lifecycleState == _ElementLifecycle.active);
      if (oldChild == null || !Widget.canUpdate(oldChild.widget, newWidget)) {
        break;
      }
      final Element newChild = updateChild(
        oldChild,
        newWidget,
        slotFor(newChildrenTop, previousChild),
      )!;
      assert(newChild._lifecycleState == _ElementLifecycle.active);
      newChildren[newChildrenTop] = newChild;
      previousChild = newChild;
      newChildrenTop += 1;
      oldChildrenTop += 1;
    }

    // Scan the bottom of the list.
    while ((oldChildrenTop <= oldChildrenBottom) && (newChildrenTop <= newChildrenBottom)) {
      final Element? oldChild = replaceWithNullIfForgotten(oldChildren[oldChildrenBottom]);
      final Widget newWidget = newWidgets[newChildrenBottom];
      assert(oldChild == null || oldChild._lifecycleState == _ElementLifecycle.active);
      if (oldChild == null || !Widget.canUpdate(oldChild.widget, newWidget)) {
        break;
      }
      oldChildrenBottom -= 1;
      newChildrenBottom -= 1;
    }

    // Scan the old children in the middle of the list.
    final bool haveOldChildren = oldChildrenTop <= oldChildrenBottom;
    Map<Key, Element>? oldKeyedChildren;
    if (haveOldChildren) {
      oldKeyedChildren = <Key, Element>{};
      while (oldChildrenTop <= oldChildrenBottom) {
        final Element? oldChild = replaceWithNullIfForgotten(oldChildren[oldChildrenTop]);
        assert(oldChild == null || oldChild._lifecycleState == _ElementLifecycle.active);
        if (oldChild != null) {
          if (oldChild.widget.key != null) {
            oldKeyedChildren[oldChild.widget.key!] = oldChild;
          } else {
            deactivateChild(oldChild);
          }
        }
        oldChildrenTop += 1;
      }
    }

    // Update the middle of the list.
    while (newChildrenTop <= newChildrenBottom) {
      Element? oldChild;
      final Widget newWidget = newWidgets[newChildrenTop];
      if (haveOldChildren) {
        final Key? key = newWidget.key;
        if (key != null) {
          oldChild = oldKeyedChildren![key];
          if (oldChild != null) {
            if (Widget.canUpdate(oldChild.widget, newWidget)) {
              // we found a match!
              // remove it from oldKeyedChildren so we don't unsync it later
              oldKeyedChildren.remove(key);
            } else {
              // Not a match, let's pretend we didn't see it for now.
              oldChild = null;
            }
          }
        }
      }
      assert(oldChild == null || Widget.canUpdate(oldChild.widget, newWidget));
      final Element newChild = updateChild(
        oldChild,
        newWidget,
        slotFor(newChildrenTop, previousChild),
      )!;
      assert(newChild._lifecycleState == _ElementLifecycle.active);
      assert(
        oldChild == newChild ||
            oldChild == null ||
            oldChild._lifecycleState != _ElementLifecycle.active,
      );
      newChildren[newChildrenTop] = newChild;
      previousChild = newChild;
      newChildrenTop += 1;
    }

    // We've scanned the whole list.
    assert(oldChildrenTop == oldChildrenBottom + 1);
    assert(newChildrenTop == newChildrenBottom + 1);
    assert(newWidgets.length - newChildrenTop == oldChildren.length - oldChildrenTop);
    newChildrenBottom = newWidgets.length - 1;
    oldChildrenBottom = oldChildren.length - 1;

    // Update the bottom of the list.
    while ((oldChildrenTop <= oldChildrenBottom) && (newChildrenTop <= newChildrenBottom)) {
      final Element oldChild = oldChildren[oldChildrenTop];
      assert(replaceWithNullIfForgotten(oldChild) != null);
      assert(oldChild._lifecycleState == _ElementLifecycle.active);
      final Widget newWidget = newWidgets[newChildrenTop];
      assert(Widget.canUpdate(oldChild.widget, newWidget));
      final Element newChild = updateChild(
        oldChild,
        newWidget,
        slotFor(newChildrenTop, previousChild),
      )!;
      assert(newChild._lifecycleState == _ElementLifecycle.active);
      assert(oldChild == newChild || oldChild._lifecycleState != _ElementLifecycle.active);
      newChildren[newChildrenTop] = newChild;
      previousChild = newChild;
      newChildrenTop += 1;
      oldChildrenTop += 1;
    }

    // Clean up any of the remaining middle nodes from the old list.
    if (haveOldChildren && oldKeyedChildren!.isNotEmpty) {
      for (final Element oldChild in oldKeyedChildren.values) {
        if (forgottenChildren == null || !forgottenChildren.contains(oldChild)) {
          deactivateChild(oldChild);
        }
      }
    }
    assert(newChildren.every((Element element) => element is! _NullElement));
    return newChildren;
  }

  /// Add this element to the tree in the given slot of the given parent.
  ///
  /// The framework calls this function when a newly created element is added to
  /// the tree for the first time. Use this method to initialize state that
  /// depends on having a parent. State that is independent of the parent can
  /// more easily be initialized in the constructor.
  ///
  /// This method transitions the element from the "initial" lifecycle state to
  /// the "active" lifecycle state.
  ///
  /// Subclasses that override this method are likely to want to also override
  /// [update], [visitChildren], [RenderObjectElement.insertRenderObjectChild],
  /// [RenderObjectElement.moveRenderObjectChild], and
  /// [RenderObjectElement.removeRenderObjectChild].
  ///
  /// Implementations of this method should start with a call to the inherited
  /// method, as in `super.mount(parent, newSlot)`.
  @mustCallSuper
  void mount(Element? parent, Object? newSlot) {
    assert(
      _lifecycleState == _ElementLifecycle.initial,
      'This element is no longer in its initial state (${_lifecycleState.name})',
    );
    assert(
      _parent == null,
      "This element already has a parent ($_parent) and it shouldn't have one yet.",
    );
    assert(
      parent == null || parent._lifecycleState == _ElementLifecycle.active,
      'Parent ($parent) should be null or in the active state (${parent._lifecycleState.name})',
    );
    assert(slot == null, "This element already has a slot ($slot) and it shouldn't");
    _parent = parent;
    _slot = newSlot;
    _lifecycleState = _ElementLifecycle.active;
    _depth = 1 + (_parent?.depth ?? 0);
    if (parent != null) {
      // Only assign ownership if the parent is non-null. If parent is null
      // (the root node), the owner should have already been assigned.
      // See RootRenderObjectElement.assignOwner().
      _owner = parent.owner;
      _parentBuildScope = parent.buildScope;
    }
    assert(owner != null);
    final Key? key = widget.key;
    if (key is GlobalKey) {
      owner!._registerGlobalKey(key, this);
    }
    _updateInheritance();
    attachNotificationTree();
  }

  void _debugRemoveGlobalKeyReservation(Element child) {
    assert(owner != null);
    owner!._debugRemoveGlobalKeyReservationFor(this, child);
  }

  /// Change the widget used to configure this element.
  ///
  /// The framework calls this function when the parent wishes to use a
  /// different widget to configure this element. The new widget is guaranteed
  /// to have the same [runtimeType] as the old widget.
  ///
  /// This function is called only during the "active" lifecycle state.
  @mustCallSuper
  void update(covariant Widget newWidget) {
    // This code is hot when hot reloading, so we try to
    // only call _AssertionError._evaluateAssertion once.
    assert(
      _lifecycleState == _ElementLifecycle.active &&
          newWidget != widget &&
          Widget.canUpdate(widget, newWidget),
    );
    // This Element was told to update and we can now release all the global key
    // reservations of forgotten children. We cannot do this earlier because the
    // forgotten children still represent global key duplications if the element
    // never updates (the forgotten children are not removed from the tree
    // until the call to update happens)
    assert(() {
      _debugForgottenChildrenWithGlobalKey?.forEach(_debugRemoveGlobalKeyReservation);
      _debugForgottenChildrenWithGlobalKey?.clear();
      return true;
    }());
    _widget = newWidget;
  }

  /// Change the slot that the given child occupies in its parent.
  ///
  /// Called by [MultiChildRenderObjectElement], and other [RenderObjectElement]
  /// subclasses that have multiple children, when child moves from one position
  /// to another in this element's child list.
  @protected
  void updateSlotForChild(Element child, Object? newSlot) {
    assert(_lifecycleState == _ElementLifecycle.active);
    assert(child._parent == this);
    void visit(Element element) {
      element.updateSlot(newSlot);
      final Element? descendant = element.renderObjectAttachingChild;
      if (descendant != null) {
        visit(descendant);
      }
    }

    visit(child);
  }

  /// Called by [updateSlotForChild] when the framework needs to change the slot
  /// that this [Element] occupies in its ancestor.
  @protected
  @mustCallSuper
  void updateSlot(Object? newSlot) {
    assert(_lifecycleState == _ElementLifecycle.active);
    assert(_parent != null);
    assert(_parent!._lifecycleState == _ElementLifecycle.active);
    _slot = newSlot;
  }

  void _updateDepth(int parentDepth) {
    final int expectedDepth = parentDepth + 1;
    if (_depth < expectedDepth) {
      _depth = expectedDepth;
      visitChildren((Element child) {
        child._updateDepth(expectedDepth);
      });
    }
  }

  void _updateBuildScopeRecursively() {
    if (identical(buildScope, _parent?.buildScope)) {
      return;
    }
    // Unset the _inDirtyList flag so this Element can be added to the dirty list
    // of the new build scope if it's dirty.
    _inDirtyList = false;
    _parentBuildScope = _parent?.buildScope;
    visitChildren((Element child) {
      child._updateBuildScopeRecursively();
    });
  }

  /// Remove [renderObject] from the render tree.
  ///
  /// The default implementation of this function calls
  /// [detachRenderObject] recursively on each child. The
  /// [RenderObjectElement.detachRenderObject] override does the actual work of
  /// removing [renderObject] from the render tree.
  ///
  /// This is called by [deactivateChild].
  void detachRenderObject() {
    visitChildren((Element child) {
      child.detachRenderObject();
    });
    _slot = null;
  }

  /// Add [renderObject] to the render tree at the location specified by `newSlot`.
  ///
  /// The default implementation of this function calls
  /// [attachRenderObject] recursively on each child. The
  /// [RenderObjectElement.attachRenderObject] override does the actual work of
  /// adding [renderObject] to the render tree.
  ///
  /// The `newSlot` argument specifies the new value for this element's [slot].
  void attachRenderObject(Object? newSlot) {
    assert(slot == null);
    visitChildren((Element child) {
      child.attachRenderObject(newSlot);
    });
    _slot = newSlot;
  }

  Element? _retakeInactiveElement(GlobalKey key, Widget newWidget) {
    // The "inactivity" of the element being retaken here may be forward-looking: if
    // we are taking an element with a GlobalKey from an element that currently has
    // it as a child, then we know that element will soon no longer have that
    // element as a child. The only way that assumption could be false is if the
    // global key is being duplicated, and we'll try to track that using the
    // _debugTrackElementThatWillNeedToBeRebuiltDueToGlobalKeyShenanigans call below.
    final Element? element = key._currentElement;
    if (element == null) {
      return null;
    }
    if (!Widget.canUpdate(element.widget, newWidget)) {
      return null;
    }
    assert(() {
      if (debugPrintGlobalKeyedWidgetLifecycle) {
        debugPrint(
          'Attempting to take $element from ${element._parent ?? "inactive elements list"} to put in $this.',
        );
      }
      return true;
    }());
    final Element? parent = element._parent;
    if (parent != null) {
      assert(() {
        if (parent == this) {
          throw FlutterError.fromParts(<DiagnosticsNode>[
            ErrorSummary("A GlobalKey was used multiple times inside one widget's child list."),
            DiagnosticsProperty<GlobalKey>('The offending GlobalKey was', key),
            parent.describeElement('The parent of the widgets with that key was'),
            element.describeElement('The first child to get instantiated with that key became'),
            DiagnosticsProperty<Widget>(
              'The second child that was to be instantiated with that key was',
              widget,
              style: DiagnosticsTreeStyle.errorProperty,
            ),
            ErrorDescription(
              'A GlobalKey can only be specified on one widget at a time in the widget tree.',
            ),
          ]);
        }
        parent.owner!._debugTrackElementThatWillNeedToBeRebuiltDueToGlobalKeyShenanigans(
          parent,
          key,
        );
        return true;
      }());
      parent.forgetChild(element);
      parent.deactivateChild(element);
    }
    assert(element._parent == null);
    owner!._inactiveElements.remove(element);
    return element;
  }

  /// Create an element for the given widget and add it as a child of this
  /// element in the given slot.
  ///
  /// This method is typically called by [updateChild] but can be called
  /// directly by subclasses that need finer-grained control over creating
  /// elements.
  ///
  /// If the given widget has a global key and an element already exists that
  /// has a widget with that global key, this function will reuse that element
  /// (potentially grafting it from another location in the tree or reactivating
  /// it from the list of inactive elements) rather than creating a new element.
  ///
  /// The `newSlot` argument specifies the new value for this element's [slot].
  ///
  /// The element returned by this function will already have been mounted and
  /// will be in the "active" lifecycle state.
  @protected
  @pragma('dart2js:tryInline')
  @pragma('vm:prefer-inline')
  @pragma('wasm:prefer-inline')
  Element inflateWidget(Widget newWidget, Object? newSlot) {
    final bool isTimelineTracked = !kReleaseMode && _isProfileBuildsEnabledFor(newWidget);
    if (isTimelineTracked) {
      Map<String, String>? debugTimelineArguments;
      assert(() {
        if (kDebugMode && debugEnhanceBuildTimelineArguments) {
          debugTimelineArguments = newWidget.toDiagnosticsNode().toTimelineArguments();
        }
        return true;
      }());
      FlutterTimeline.startSync('${newWidget.runtimeType}', arguments: debugTimelineArguments);
    }

    try {
      final Key? key = newWidget.key;
      final Element? inactiveChild = key is GlobalKey
          ? _retakeInactiveElement(key, newWidget)
          : null;
      final Element newChild = inactiveChild ?? newWidget.createElement();
      assert(() {
        _debugCheckForCycles(newChild);
        return true;
      }());
      try {
        if (inactiveChild != null) {
          assert(inactiveChild._parent == null);
          inactiveChild._activateWithParent(this, newSlot);
          final Element? updatedChild = updateChild(inactiveChild, newWidget, newSlot);
          assert(inactiveChild == updatedChild);
          return updatedChild!;
        } else {
          newChild.mount(this, newSlot);
          assert(newChild._lifecycleState == _ElementLifecycle.active);
          return newChild;
        }
      } catch (_) {
        // Attempt to do some clean-up if activation or mount fails
        // to leave tree in a reasonable state.
        _deactivateFailedChildSilently(newChild);
        rethrow;
      }
    } finally {
      if (isTimelineTracked) {
        FlutterTimeline.finishSync();
      }
    }
  }

  void _debugCheckForCycles(Element newChild) {
    assert(newChild._parent == null);
    assert(() {
      var node = this;
      while (node._parent != null) {
        node = node._parent!;
      }
      assert(node != newChild); // indicates we are about to create a cycle
      return true;
    }());
  }

  /// Move the given element to the list of inactive elements and detach its
  /// render object from the render tree.
  ///
  /// This method stops the given element from being a child of this element by
  /// detaching its render object from the render tree and moving the element to
  /// the list of inactive elements.
  ///
  /// This method (indirectly) calls [deactivate] on the child.
  ///
  /// The caller is responsible for removing the child from its child model.
  /// Typically [deactivateChild] is called by the element itself while it is
  /// updating its child model; however, during [GlobalKey] reparenting, the new
  /// parent proactively calls the old parent's [deactivateChild], first using
  /// [forgetChild] to cause the old parent to update its child model.
  @protected
  @mustCallSuper
  void deactivateChild(Element child) {
    assert(child._parent == this);
    child._parent = null;
    child.detachRenderObject();
    owner!._inactiveElements.add(child); // this eventually calls child.deactivate()
    assert(() {
      if (debugPrintGlobalKeyedWidgetLifecycle) {
        if (child.widget.key is GlobalKey) {
          debugPrint('Deactivated $child (keyed child of $this)');
        }
      }
      return true;
    }());
  }

  void _deactivateFailedChildSilently(Element child) {
    try {
      child._parent = null;
      child.detachRenderObject();
      _deactivateFailedSubtreeRecursively(child);
    } catch (_) {
      // Do not rethrow:
      // The subtree has already thrown a different error and the framework is
      // cleaning up on a best-effort basis.
    }
  }

  // This method calls _ensureDeactivated for the subtree rooted at `element`,
  // supressing all exceptions thrown.
  //
  // This method will attempt to keep doing treewalk even one of the nodes
  // failed to deactivate.
  //
  // The subtree has already thrown a different error and the framework is
  // cleaning up on a best-effort basis.
  static void _deactivateFailedSubtreeRecursively(Element element) {
    try {
      element.deactivate();
    } catch (_) {
      element._ensureDeactivated();
    }
    element._lifecycleState = _ElementLifecycle.failed;
    try {
      element.visitChildren(_deactivateFailedSubtreeRecursively);
    } catch (_) {}
  }

  // The children that have been forgotten by forgetChild. This will be used in
  // [update] to remove the global key reservations of forgotten children.
  //
  // In Profile/Release mode this field is initialized to `null`. The Dart compiler can
  // eliminate unused fields, but not their initializers.
  @_debugOnly
  final Set<Element>? _debugForgottenChildrenWithGlobalKey = kDebugMode ? HashSet<Element>() : null;

  /// Remove the given child from the element's child list, in preparation for
  /// the child being reused elsewhere in the element tree.
  ///
  /// This updates the child model such that, e.g., [visitChildren] does not
  /// walk that child anymore.
  ///
  /// The element will still have a valid parent when this is called, and the
  /// child's [Element.slot] value will be valid in the context of that parent.
  /// After this is called, [deactivateChild] is called to sever the link to
  /// this object.
  ///
  /// The [update] is responsible for updating or creating the new child that
  /// will replace this [child].
  @protected
  @mustCallSuper
  void forgetChild(Element child) {
    // This method is called on the old parent when the given child (with a
    // global key) is given a new parent. We cannot remove the global key
    // reservation directly in this method because the forgotten child is not
    // removed from the tree until this Element is updated in [update]. If
    // [update] is never called, the forgotten child still represents a global
    // key duplication that we need to catch.
    assert(() {
      if (child.widget.key is GlobalKey) {
        _debugForgottenChildrenWithGlobalKey?.add(child);
      }
      return true;
    }());
  }

  void _activateWithParent(Element parent, Object? newSlot) {
    assert(_lifecycleState == _ElementLifecycle.inactive);
    _parent = parent;
    _owner = parent.owner;
    assert(() {
      if (debugPrintGlobalKeyedWidgetLifecycle) {
        debugPrint('Reactivating $this (now child of $_parent).');
      }
      return true;
    }());
    _updateDepth(_parent!.depth);
    _updateBuildScopeRecursively();
    _activateRecursively(this);
    attachRenderObject(newSlot);
    assert(_lifecycleState == _ElementLifecycle.active);
  }

  static void _activateRecursively(Element element) {
    assert(element._lifecycleState == _ElementLifecycle.inactive);
    element.activate();
    assert(element._lifecycleState == _ElementLifecycle.active);
    element.visitChildren(_activateRecursively);
  }

  /// Transition from the "inactive" to the "active" lifecycle state.
  ///
  /// The framework calls this method when a previously deactivated element has
  /// been reincorporated into the tree. The framework does not call this method
  /// the first time an element becomes active (i.e., from the "initial"
  /// lifecycle state). Instead, the framework calls [mount] in that situation.
  ///
  /// See the lifecycle documentation for [Element] for additional information.
  ///
  /// Implementations of this method should start with a call to the inherited
  /// method, as in `super.activate()`.
  @mustCallSuper
  @visibleForOverriding
  void activate() {
    assert(_lifecycleState == _ElementLifecycle.inactive);
    assert(owner != null);
    final bool hadDependencies =
        (_dependencies?.isNotEmpty ?? false) || _hadUnsatisfiedDependencies;
    _lifecycleState = _ElementLifecycle.active;
    // We unregistered our dependencies in deactivate, but never cleared the list.
    // Since we're going to be reused, let's clear our list now.
    _dependencies?.clear();
    _hadUnsatisfiedDependencies = false;
    _updateInheritance();
    attachNotificationTree();
    if (_dirty) {
      owner!.scheduleBuildFor(this);
    }
    if (hadDependencies) {
      didChangeDependencies();
    }
  }

  /// Transition from the "active" to the "inactive" lifecycle state.
  ///
  /// The framework calls this method when a previously active element is moved
  /// to the list of inactive elements. While in the inactive state, the element
  /// will not appear on screen. The element can remain in the inactive state
  /// only until the end of the current animation frame. At the end of the
  /// animation frame, if the element has not be reactivated, the framework will
  /// unmount the element.
  ///
  /// In case of an uncaught exception when rebuild a widget subtree, the
  /// framework also calls this method on the failing subtree to make sure the
  /// widget tree is in a relatively consistent state. The deactivation of such
  /// subtrees are performed only on a best-effort basis, and the errors thrown
  /// during deactivation will not be rethrown.
  ///
  /// This is indirectly called by [deactivateChild].
  ///
  /// See the lifecycle documentation for [Element] for additional information.
  ///
  /// Implementations of this method should end with a call to the inherited
  /// method, as in `super.deactivate()`.
  @mustCallSuper
  @visibleForOverriding
  void deactivate() {
    assert(_lifecycleState == _ElementLifecycle.active);
    assert(_widget != null); // Use the private property to avoid a CastError during hot reload.
    _ensureDeactivated();
  }

  /// Removes dependencies and sets the lifecycle state of this [Element] to
  /// inactive.
  ///
  /// This method is immediately called after [Element.deactivate], even if that
  /// call throws an exception.
  void _ensureDeactivated() {
    if (_dependencies case final Set<InheritedElement> dependencies? when dependencies.isNotEmpty) {
      for (final dependency in dependencies) {
        dependency.removeDependent(this);
      }
      // For expediency, we don't actually clear the list here, even though it's
      // no longer representative of what we are registered with. If we never
      // get re-used, it doesn't matter. If we do, then we'll clear the list in
      // activate(). The benefit of this is that it allows Element's activate()
      // implementation to decide whether to rebuild based on whether we had
      // dependencies here.
    }
    _inheritedElements = null;
    _lifecycleState = _ElementLifecycle.inactive;
  }

  /// Called, in debug mode, after children have been deactivated (see [deactivate]).
  ///
  /// This method is not called in release builds.
  @mustCallSuper
  void debugDeactivated() {
    assert(_lifecycleState == _ElementLifecycle.inactive);
  }

  /// Transition from the "inactive" to the "defunct" lifecycle state.
  ///
  /// Called when the framework determines that an inactive element will never
  /// be reactivated. At the end of each animation frame, the framework calls
  /// [unmount] on any remaining inactive elements, preventing inactive elements
  /// from remaining inactive for longer than a single animation frame.
  ///
  /// After this function is called, the element will not be incorporated into
  /// the tree again.
  ///
  /// Any resources this element holds should be released at this point. For
  /// example, [RenderObjectElement.unmount] calls [RenderObject.dispose] and
  /// nulls out its reference to the render object.
  ///
  /// See the lifecycle documentation for [Element] for additional information.
  ///
  /// Implementations of this method should end with a call to the inherited
  /// method, as in `super.unmount()`.
  @mustCallSuper
  void unmount() {
    assert(_lifecycleState == _ElementLifecycle.inactive);
    assert(_widget != null); // Use the private property to avoid a CastError during hot reload.
    assert(owner != null);
    assert(debugMaybeDispatchDisposed(this));
    // Use the private property to avoid a CastError during hot reload.
    final Key? key = _widget?.key;
    if (key is GlobalKey) {
      owner!._unregisterGlobalKey(key, this);
    }
    // Release resources to reduce the severity of memory leaks caused by
    // defunct, but accidentally retained Elements.
    _widget = null;
    _dependencies = null;
    _lifecycleState = _ElementLifecycle.defunct;
  }

  /// Whether the child in the provided `slot` (or one of its descendants) must
  /// insert a [RenderObject] into its ancestor [RenderObjectElement] by calling
  /// [RenderObjectElement.insertRenderObjectChild] on it.
  ///
  /// This method is used to define non-rendering zones in the element tree (see
  /// [WidgetsBinding] for an explanation of rendering and non-rendering zones):
  ///
  /// Most branches of the [Element] tree are expected to eventually insert a
  /// [RenderObject] into their [RenderObjectElement] ancestor to construct the
  /// render tree. However, there is a notable exception: an [Element] may
  /// expect that the occupant of a certain child slot creates a new independent
  /// render tree and therefore is not allowed to insert a render object into
  /// the existing render tree. Those elements must return false from this
  /// method for the slot in question to signal to the child in that slot that
  /// it must not call [RenderObjectElement.insertRenderObjectChild] on its
  /// ancestor.
  ///
  /// As an example, the element backing the [ViewAnchor] returns false from
  /// this method for the [ViewAnchor.view] slot to enforce that it is occupied
  /// by e.g. a [View] widget, which will ultimately bootstrap a separate
  /// render tree for that view. Another example is the [ViewCollection] widget,
  /// which returns false for all its slots for the same reason.
  ///
  /// Overriding this method is not common, as elements behaving in the way
  /// described above are rare.
  bool debugExpectsRenderObjectForSlot(Object? slot) => true;

  @override
  RenderObject? findRenderObject() {
    assert(() {
      if (_lifecycleState != _ElementLifecycle.active) {
        throw FlutterError.fromParts(<DiagnosticsNode>[
          ErrorSummary('Cannot get renderObject of inactive element.'),
          ErrorDescription(
            'In order for an element to have a valid renderObject, it must be '
            'active, which means it is part of the tree.\n'
            'Instead, this element is in the $_lifecycleState state.\n'
            'If you called this method from a State object, consider guarding '
            'it with State.mounted.',
          ),
          describeElement('The findRenderObject() method was called for the following element'),
        ]);
      }
      return true;
    }());
    return renderObject;
  }

  @override
  Size? get size {
    assert(() {
      if (_lifecycleState != _ElementLifecycle.active) {
        // TODO(jacobr): is this a good separation into contract and violation?
        // I have added a line of white space.
        throw FlutterError.fromParts(<DiagnosticsNode>[
          ErrorSummary('Cannot get size of inactive element.'),
          ErrorDescription(
            'In order for an element to have a valid size, the element must be '
            'active, which means it is part of the tree.\n'
            'Instead, this element is in the $_lifecycleState state.',
          ),
          describeElement('The size getter was called for the following element'),
        ]);
      }
      if (owner!._debugBuilding) {
        throw FlutterError.fromParts(<DiagnosticsNode>[
          ErrorSummary('Cannot get size during build.'),
          ErrorDescription(
            'The size of this render object has not yet been determined because '
            'the framework is still in the process of building widgets, which '
            'means the render tree for this frame has not yet been determined. '
            'The size getter should only be called from paint callbacks or '
            'interaction event handlers (e.g. gesture callbacks).',
          ),
          ErrorSpacer(),
          ErrorHint(
            'If you need some sizing information during build to decide which '
            'widgets to build, consider using a LayoutBuilder widget, which can '
            'tell you the layout constraints at a given location in the tree. See '
            '<https://api.flutter.dev/flutter/widgets/LayoutBuilder-class.html> '
            'for more details.',
          ),
          ErrorSpacer(),
          describeElement('The size getter was called for the following element'),
        ]);
      }
      return true;
    }());
    final RenderObject? renderObject = findRenderObject();
    assert(() {
      if (renderObject == null) {
        throw FlutterError.fromParts(<DiagnosticsNode>[
          ErrorSummary('Cannot get size without a render object.'),
          ErrorHint(
            'In order for an element to have a valid size, the element must have '
            'an associated render object. This element does not have an associated '
            'render object, which typically means that the size getter was called '
            'too early in the pipeline (e.g., during the build phase) before the '
            'framework has created the render tree.',
          ),
          describeElement('The size getter was called for the following element'),
        ]);
      }
      if (renderObject is RenderSliver) {
        throw FlutterError.fromParts(<DiagnosticsNode>[
          ErrorSummary('Cannot get size from a RenderSliver.'),
          ErrorHint(
            'The render object associated with this element is a '
            '${renderObject.runtimeType}, which is a subtype of RenderSliver. '
            'Slivers do not have a size per se. They have a more elaborate '
            'geometry description, which can be accessed by calling '
            'findRenderObject and then using the "geometry" getter on the '
            'resulting object.',
          ),
          describeElement('The size getter was called for the following element'),
          renderObject.describeForError('The associated render sliver was'),
        ]);
      }
      if (renderObject is! RenderBox) {
        throw FlutterError.fromParts(<DiagnosticsNode>[
          ErrorSummary('Cannot get size from a render object that is not a RenderBox.'),
          ErrorHint(
            'Instead of being a subtype of RenderBox, the render object associated '
            'with this element is a ${renderObject.runtimeType}. If this type of '
            'render object does have a size, consider calling findRenderObject '
            'and extracting its size manually.',
          ),
          describeElement('The size getter was called for the following element'),
          renderObject.describeForError('The associated render object was'),
        ]);
      }
      final RenderBox box = renderObject;
      if (!box.hasSize) {
        throw FlutterError.fromParts(<DiagnosticsNode>[
          ErrorSummary('Cannot get size from a render object that has not been through layout.'),
          ErrorHint(
            'The size of this render object has not yet been determined because '
            'this render object has not yet been through layout, which typically '
            'means that the size getter was called too early in the pipeline '
            '(e.g., during the build phase) before the framework has determined '
            'the size and position of the render objects during layout.',
          ),
          describeElement('The size getter was called for the following element'),
          box.describeForError('The render object from which the size was to be obtained was'),
        ]);
      }
      if (box.debugNeedsLayout) {
        throw FlutterError.fromParts(<DiagnosticsNode>[
          ErrorSummary(
            'Cannot get size from a render object that has been marked dirty for layout.',
          ),
          ErrorHint(
            'The size of this render object is ambiguous because this render object has '
            'been modified since it was last laid out, which typically means that the size '
            'getter was called too early in the pipeline (e.g., during the build phase) '
            'before the framework has determined the size and position of the render '
            'objects during layout.',
          ),
          describeElement('The size getter was called for the following element'),
          box.describeForError('The render object from which the size was to be obtained was'),
          ErrorHint(
            'Consider using debugPrintMarkNeedsLayoutStacks to determine why the render '
            'object in question is dirty, if you did not expect this.',
          ),
        ]);
      }
      return true;
    }());
    if (renderObject is RenderBox) {
      return renderObject.size;
    }
    return null;
  }

  PersistentHashMap<Type, InheritedElement>? _inheritedElements;
  Set<InheritedElement>? _dependencies;
  bool _hadUnsatisfiedDependencies = false;

  bool _debugCheckStateIsActiveForAncestorLookup() {
    assert(() {
      if (_lifecycleState != _ElementLifecycle.active) {
        throw FlutterError.fromParts(<DiagnosticsNode>[
          ErrorSummary("Looking up a deactivated widget's ancestor is unsafe."),
          ErrorDescription(
            "At this point the state of the widget's element tree is no longer "
            'stable.',
          ),
          ErrorHint(
            "To safely refer to a widget's ancestor in its dispose() method, "
            'save a reference to the ancestor by calling dependOnInheritedWidgetOfExactType() '
            "in the widget's didChangeDependencies() method.",
          ),
        ]);
      }
      return true;
    }());
    return true;
  }

  /// Returns `true` if [dependOnInheritedElement] was previously called with [ancestor].
  @protected
  bool doesDependOnInheritedElement(InheritedElement ancestor) {
    return _dependencies?.contains(ancestor) ?? false;
  }

  @override
  InheritedWidget dependOnInheritedElement(InheritedElement ancestor, {Object? aspect}) {
    (_dependencies ??= HashSet<InheritedElement>()).add(ancestor);
    ancestor.updateDependencies(this, aspect);
    return ancestor.widget as InheritedWidget;
  }

  @override
  T? dependOnInheritedWidgetOfExactType<T extends InheritedWidget>({Object? aspect}) {
    assert(_debugCheckStateIsActiveForAncestorLookup());
    final InheritedElement? ancestor = _inheritedElements?[T];
    if (ancestor != null) {
      return dependOnInheritedElement(ancestor, aspect: aspect) as T;
    }
    _hadUnsatisfiedDependencies = true;
    return null;
  }

  @override
  T? getInheritedWidgetOfExactType<T extends InheritedWidget>() {
    return getElementForInheritedWidgetOfExactType<T>()?.widget as T?;
  }

  @override
  InheritedElement? getElementForInheritedWidgetOfExactType<T extends InheritedWidget>() {
    assert(_debugCheckStateIsActiveForAncestorLookup());
    return _inheritedElements?[T];
  }

  /// Called in [Element.mount] and [Element.activate] to register this element in
  /// the notification tree.
  ///
  /// This method is only exposed so that [NotifiableElementMixin] can be implemented.
  /// Subclasses of [Element] that wish to respond to notifications should mix that
  /// in instead.
  ///
  /// See also:
  ///   * [NotificationListener], a widget that allows listening to notifications.
  @protected
  void attachNotificationTree() {
    _notificationTree = _parent?._notificationTree;
  }

  void _updateInheritance() {
    assert(_lifecycleState == _ElementLifecycle.active);
    _inheritedElements = _parent?._inheritedElements;
  }

  @override
  T? findAncestorWidgetOfExactType<T extends Widget>() {
    assert(_debugCheckStateIsActiveForAncestorLookup());
    Element? ancestor = _parent;
    while (ancestor != null && ancestor.widget.runtimeType != T) {
      ancestor = ancestor._parent;
    }
    return ancestor?.widget as T?;
  }

  @override
  T? findAncestorStateOfType<T extends State<StatefulWidget>>() {
    assert(_debugCheckStateIsActiveForAncestorLookup());
    Element? ancestor = _parent;
    while (ancestor != null) {
      if (ancestor is StatefulElement && ancestor.state is T) {
        break;
      }
      ancestor = ancestor._parent;
    }
    final statefulAncestor = ancestor as StatefulElement?;
    return statefulAncestor?.state as T?;
  }

  @override
  T? findRootAncestorStateOfType<T extends State<StatefulWidget>>() {
    assert(_debugCheckStateIsActiveForAncestorLookup());
    Element? ancestor = _parent;
    StatefulElement? statefulAncestor;
    while (ancestor != null) {
      if (ancestor is StatefulElement && ancestor.state is T) {
        statefulAncestor = ancestor;
      }
      ancestor = ancestor._parent;
    }
    return statefulAncestor?.state as T?;
  }

  @override
  T? findAncestorRenderObjectOfType<T extends RenderObject>() {
    assert(_debugCheckStateIsActiveForAncestorLookup());
    Element? ancestor = _parent;
    while (ancestor != null) {
      if (ancestor is RenderObjectElement && ancestor.renderObject is T) {
        return ancestor.renderObject as T;
      }
      ancestor = ancestor._parent;
    }
    return null;
  }

  @override
  void visitAncestorElements(ConditionalElementVisitor visitor) {
    assert(_debugCheckStateIsActiveForAncestorLookup());
    Element? ancestor = _parent;
    while (ancestor != null && visitor(ancestor)) {
      ancestor = ancestor._parent;
    }
  }

  /// Called when a dependency of this element changes.
  ///
  /// The [dependOnInheritedWidgetOfExactType] registers this element as depending on
  /// inherited information of the given type. When the information of that type
  /// changes at this location in the tree (e.g., because the [InheritedElement]
  /// updated to a new [InheritedWidget] and
  /// [InheritedWidget.updateShouldNotify] returned true), the framework calls
  /// this function to notify this element of the change.
  @mustCallSuper
  void didChangeDependencies() {
    assert(_lifecycleState == _ElementLifecycle.active); // otherwise markNeedsBuild is a no-op
    assert(_debugCheckOwnerBuildTargetExists('didChangeDependencies'));
    markNeedsBuild();
  }

  bool _debugCheckOwnerBuildTargetExists(String methodName) {
    assert(() {
      if (owner!._debugCurrentBuildTarget == null) {
        throw FlutterError.fromParts(<DiagnosticsNode>[
          ErrorSummary(
            '$methodName for ${widget.runtimeType} was called at an '
            'inappropriate time.',
          ),
          ErrorDescription('It may only be called while the widgets are being built.'),
          ErrorHint(
            'A possible cause of this error is when $methodName is called during '
            'one of:\n'
            ' * network I/O event\n'
            ' * file I/O event\n'
            ' * timer\n'
            ' * microtask (caused by Future.then, async/await, scheduleMicrotask)',
          ),
        ]);
      }
      return true;
    }());
    return true;
  }

  /// Returns a description of what caused this element to be created.
  ///
  /// Useful for debugging the source of an element.
  String debugGetCreatorChain(int limit) {
    final chain = <String>[];
    Element? node = this;
    while (chain.length < limit && node != null) {
      chain.add(node.toStringShort());
      node = node._parent;
    }
    if (node != null) {
      chain.add('\u22EF');
    }
    return chain.join(' \u2190 ');
  }

  /// Returns the parent chain from this element back to the root of the tree.
  ///
  /// Useful for debug display of a tree of Elements with only nodes in the path
  /// from the root to this Element expanded.
  List<Element> debugGetDiagnosticChain() {
    final chain = <Element>[this];
    Element? node = _parent;
    while (node != null) {
      chain.add(node);
      node = node._parent;
    }
    return chain;
  }

  @override
  void dispatchNotification(Notification notification) {
    _notificationTree?.dispatchNotification(notification);
  }

  /// A short, textual description of this element.
  @override
  String toStringShort() => _widget?.toStringShort() ?? '${describeIdentity(this)}(DEFUNCT)';

  @override
  DiagnosticsNode toDiagnosticsNode({String? name, DiagnosticsTreeStyle? style}) {
    return _ElementDiagnosticableTreeNode(name: name, value: this, style: style);
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.defaultDiagnosticsTreeStyle = DiagnosticsTreeStyle.dense;
    if (_lifecycleState != _ElementLifecycle.initial) {
      properties.add(ObjectFlagProperty<int>('depth', depth, ifNull: 'no depth'));
    }
    properties.add(ObjectFlagProperty<Widget>('widget', _widget, ifNull: 'no widget'));
    properties.add(
      DiagnosticsProperty<Key>(
        'key',
        _widget?.key,
        showName: false,
        defaultValue: null,
        level: DiagnosticLevel.hidden,
      ),
    );
    _widget?.debugFillProperties(properties);
    properties.add(FlagProperty('dirty', value: dirty, ifTrue: 'dirty'));
    final Set<InheritedElement>? deps = _dependencies;
    if (deps != null && deps.isNotEmpty) {
      final List<InheritedElement> sortedDependencies = deps.toList()
        ..sort(
          (InheritedElement a, InheritedElement b) =>
              a.toStringShort().compareTo(b.toStringShort()),
        );
      final List<DiagnosticsNode> diagnosticsDependencies = sortedDependencies
          .map(
            (InheritedElement element) =>
                element.widget.toDiagnosticsNode(style: DiagnosticsTreeStyle.sparse),
          )
          .toList();
      properties.add(
        DiagnosticsProperty<Set<InheritedElement>>(
          'dependencies',
          deps,
          description: diagnosticsDependencies.toString(),
        ),
      );
    }
  }

  @override
  List<DiagnosticsNode> debugDescribeChildren() {
    final children = <DiagnosticsNode>[];
    visitChildren((Element child) {
      children.add(child.toDiagnosticsNode());
    });
    return children;
  }

  /// Returns true if the element has been marked as needing rebuilding.
  ///
  /// The flag is true when the element is first created and after
  /// [markNeedsBuild] has been called. The flag is typically reset to false in
  /// the [performRebuild] implementation, but certain elements (that of the
  /// [LayoutBuilder] widget, for example) may choose to override [markNeedsBuild]
  /// such that it does not set the [dirty] flag to `true` when called.
  bool get dirty => _dirty;
  bool _dirty = true;

  // Whether this is in _buildScope._dirtyElements. This is used to know whether
  // we should be adding the element back into the list when it's reactivated.
  bool _inDirtyList = false;

  // Whether we've already built or not. Set in [rebuild].
  bool _debugBuiltOnce = false;

  /// Marks the element as dirty and adds it to the global list of widgets to
  /// rebuild in the next frame.
  ///
  /// Since it is inefficient to build an element twice in one frame,
  /// applications and widgets should be structured so as to only mark
  /// widgets dirty during event handlers before the frame begins, not during
  /// the build itself.
  void markNeedsBuild() {
    assert(_lifecycleState != _ElementLifecycle.defunct);
    if (_lifecycleState != _ElementLifecycle.active) {
      return;
    }
    assert(owner != null);
    assert(_lifecycleState == _ElementLifecycle.active);
    assert(() {
      if (owner!._debugBuilding) {
        assert(owner!._debugCurrentBuildTarget != null);
        assert(owner!._debugStateLocked);
        if (_debugIsDescendantOf(owner!._debugCurrentBuildTarget!)) {
          return true;
        }
        final information = <DiagnosticsNode>[
          ErrorSummary('setState() or markNeedsBuild() called during build.'),
          ErrorDescription(
            'This ${widget.runtimeType} widget cannot be marked as needing to build because the framework '
            'is already in the process of building widgets. A widget can be marked as '
            'needing to be built during the build phase only if one of its ancestors '
            'is currently building. This exception is allowed because the framework '
            'builds parent widgets before children, which means a dirty descendant '
            'will always be built. Otherwise, the framework might not visit this '
            'widget during this build phase.',
          ),
          describeElement('The widget on which setState() or markNeedsBuild() was called was'),
        ];
        if (owner!._debugCurrentBuildTarget != null) {
          information.add(
            owner!._debugCurrentBuildTarget!.describeWidget(
              'The widget which was currently being built when the offending call was made was',
            ),
          );
        }
        throw FlutterError.fromParts(information);
      } else if (owner!._debugStateLocked) {
        throw FlutterError.fromParts(<DiagnosticsNode>[
          ErrorSummary('setState() or markNeedsBuild() called when widget tree was locked.'),
          ErrorDescription(
            'This ${widget.runtimeType} widget cannot be marked as needing to build '
            'because the framework is locked.',
          ),
          describeElement('The widget on which setState() or markNeedsBuild() was called was'),
        ]);
      }
      return true;
    }());
    if (dirty) {
      return;
    }
    _dirty = true;
    owner!.scheduleBuildFor(this);
  }

  /// Cause the widget to update itself. In debug builds, also verify various
  /// invariants.
  ///
  /// Called by the [BuildOwner] when [BuildOwner.scheduleBuildFor] has been
  /// called to mark this element dirty, by [mount] when the element is first
  /// built, and by [update] when the widget has changed.
  ///
  /// The method will only rebuild if [dirty] is true. To rebuild regardless
  /// of the [dirty] flag, set `force` to true. Forcing a rebuild is convenient
  /// from [update], during which [dirty] is false.
  ///
  /// ## When rebuilds happen
  ///
  /// ### Terminology
  ///
  /// [Widget]s represent the configuration of [Element]s. Each [Element] has a
  /// widget, specified in [Element.widget]. The term "widget" is often used
  /// when strictly speaking "element" would be more correct.
  ///
  /// While an [Element] has a current [Widget], over time, that widget may be
  /// replaced by others. For example, the element backing a [ColoredBox] may
  /// first have as its widget a [ColoredBox] whose [ColoredBox.color] is blue,
  /// then later be given a new [ColoredBox] whose color is green.
  ///
  /// At any particular time, multiple [Element]s in the same tree may have the
  /// same [Widget]. For example, the same [ColoredBox] with the green color may
  /// be used in multiple places in the widget tree at the same time, each being
  /// backed by a different [Element].
  ///
  /// ### Marking an element dirty
  ///
  /// An [Element] can be marked dirty between frames. This can happen for various
  /// reasons, including the following:
  ///
  /// * The [State] of a [StatefulWidget] can cause its [Element] to be marked
  ///   dirty by calling the [State.setState] method.
  ///
  /// * When an [InheritedWidget] changes, descendants that have previously
  ///   subscribed to it will be marked dirty.
  ///
  /// * During a hot reload, every element is marked dirty (using [Element.reassemble]).
  ///
  /// ### Rebuilding
  ///
  /// Dirty elements are rebuilt during the next frame. Precisely how this is
  /// done depends on the kind of element. A [StatelessElement] rebuilds by
  /// using its widget's [StatelessWidget.build] method. A [StatefulElement]
  /// rebuilds by using its widget's state's [State.build] method. A
  /// [RenderObjectElement] rebuilds by updating its [RenderObject].
  ///
  /// In many cases, the end result of rebuilding is a single child widget
  /// or (for [MultiChildRenderObjectElement]s) a list of children widgets.
  ///
  /// These child widgets are used to update the [widget] property of the
  /// element's child (or children) elements. The new [Widget] is considered to
  /// correspond to an existing [Element] if it has the same [Type] and [Key].
  /// (In the case of [MultiChildRenderObjectElement]s, some effort is put into
  /// tracking widgets even when they change order; see
  /// [RenderObjectElement.updateChildren].)
  ///
  /// If there was no corresponding previous child, this results in a new
  /// [Element] being created (using [Widget.createElement]); that element is
  /// then itself built, recursively.
  ///
  /// If there was a child previously but the build did not provide a
  /// corresponding child to update it, then the old child is discarded (or, in
  /// cases involving [GlobalKey] reparenting, reused elsewhere in the element
  /// tree).
  ///
  /// The most common case, however, is that there was a corresponding previous
  /// child. This is handled by asking the child [Element] to update itself
  /// using the new child [Widget]. In the case of [StatefulElement]s, this
  /// is what triggers [State.didUpdateWidget].
  ///
  /// ### Not rebuilding
  ///
  /// Before an [Element] is told to update itself with a new [Widget], the old
  /// and new objects are compared using `operator ==`.
  ///
  /// In general, this is equivalent to doing a comparison using [identical] to
  /// see if the two objects are in fact the exact same instance. If they are,
  /// and if the element is not already marked dirty for other reasons, then the
  /// element skips updating itself as it can determine with certainty that
  /// there would be no value in updating itself or its descendants.
  ///
  /// It is strongly advised to avoid overriding `operator ==` on [Widget]
  /// objects. While doing so seems like it could improve performance, in
  /// practice, for non-leaf widgets, it results in O(N²) behavior. This is
  /// because by necessity the comparison would have to include comparing child
  /// widgets, and if those child widgets also implement `operator ==`, it
  /// ultimately results in a complete walk of the widget tree... which is then
  /// repeated at each level of the tree. In practice, just rebuilding is
  /// cheaper. (Additionally, if _any_ subclass of [Widget] used in an
  /// application implements `operator ==`, then the compiler cannot inline the
  /// comparison anywhere, because it has to treat the call as virtual just in
  /// case the instance happens to be one that has an overridden operator.)
  ///
  /// Instead, the best way to avoid unnecessary rebuilds is to cache the
  /// widgets that are returned from [State.build], so that each frame the same
  /// widgets are used until such time as they change. Several mechanisms exist
  /// to encourage this: `const` widgets, for example, are a form of automatic
  /// caching (if a widget is constructed using the `const` keyword, the same
  /// instance is returned each time it is constructed with the same arguments).
  ///
  /// Another example is the [AnimatedBuilder.child] property, which allows the
  /// non-animating parts of a subtree to remain static even as the
  /// [AnimatedBuilder.builder] callback recreates the other components.
  @pragma('dart2js:tryInline')
  @pragma('vm:prefer-inline')
  @pragma('wasm:prefer-inline')
  void rebuild({bool force = false}) {
    assert(_lifecycleState != _ElementLifecycle.initial);
    if (_lifecycleState != _ElementLifecycle.active || (!_dirty && !force)) {
      return;
    }
    assert(() {
      debugOnRebuildDirtyWidget?.call(this, _debugBuiltOnce);
      if (debugPrintRebuildDirtyWidgets) {
        if (!_debugBuiltOnce) {
          debugPrint('Building $this');
          _debugBuiltOnce = true;
        } else {
          debugPrint('Rebuilding $this');
        }
      }
      return true;
    }());
    assert(_lifecycleState == _ElementLifecycle.active);
    assert(owner!._debugStateLocked);
    Element? debugPreviousBuildTarget;
    assert(() {
      debugPreviousBuildTarget = owner!._debugCurrentBuildTarget;
      owner!._debugCurrentBuildTarget = this;
      return true;
    }());
    try {
      performRebuild();
    } finally {
      assert(() {
        owner!._debugElementWasRebuilt(this);
        assert(owner!._debugCurrentBuildTarget == this);
        owner!._debugCurrentBuildTarget = debugPreviousBuildTarget;
        return true;
      }());
    }
    assert(!_dirty);
  }

  /// Cause the widget to update itself.
  ///
  /// Called by [rebuild] after the appropriate checks have been made.
  ///
  /// The base implementation only clears the [dirty] flag.
  @protected
  @mustCallSuper
  void performRebuild() {
    _dirty = false;
  }
}

class _ElementDiagnosticableTreeNode extends DiagnosticableTreeNode {
  _ElementDiagnosticableTreeNode({
    super.name,
    required Element super.value,
    required super.style,
    this.stateful = false,
  });

  final bool stateful;

  @override
  Map<String, Object?> toJsonMap(DiagnosticsSerializationDelegate delegate) {
    final Map<String, Object?> json = super.toJsonMap(delegate);
    final element = value as Element;
    if (!element.debugIsDefunct) {
      json['widgetRuntimeType'] = element.widget.runtimeType.toString();
    }
    json['stateful'] = stateful;
    return json;
  }
}

/// Signature for the constructor that is called when an error occurs while
/// building a widget.
///
/// The argument provides information regarding the cause of the error.
///
/// See also:
///
///  * [ErrorWidget.builder], which can be set to override the default
///    [ErrorWidget] builder.
///  * [FlutterError.reportError], which is typically called with the same
///    [FlutterErrorDetails] object immediately prior to [ErrorWidget.builder]
///    being called.
typedef ErrorWidgetBuilder = Widget Function(FlutterErrorDetails details);

/// A widget that renders an exception's message.
///
/// This widget is used when a build method fails, to help with determining
/// where the problem lies. Exceptions are also logged to the console, which you
/// can read using `flutter logs`. The console will also include additional
/// information such as the stack trace for the exception.
///
/// It is possible to override this widget.
///
/// {@tool dartpad}
/// This example shows how to override the standard error widget builder in release
/// mode, but use the standard one in debug mode.
///
/// The error occurs when you click the "Error Prone" button.
///
/// ** See code in examples/api/lib/widgets/framework/error_widget.0.dart **
/// {@end-tool}
///
/// See also:
///
///  * [FlutterError.onError], which can be set to a method that exits the
///    application if that is preferable to showing an error message.
///  * <https://docs.flutter.dev/testing/errors>, more information about error
///    handling in Flutter.
class ErrorWidget extends LeafRenderObjectWidget {
  /// Creates a widget that displays the given exception.
  ///
  /// The message will be the stringification of the given exception, unless
  /// computing that value itself throws an exception, in which case it will
  /// be the string "Error".
  ///
  /// If this object is inspected from an IDE or the devtools, and the original
  /// exception is a [FlutterError] object, the original exception itself will
  /// be shown in the inspection output.
  ErrorWidget(Object exception)
    : message = _stringify(exception),
      _flutterError = exception is FlutterError ? exception : null,
      super(key: UniqueKey());

  /// Creates a widget that displays the given error message.
  ///
  /// An explicit [FlutterError] can be provided to be reported to inspection
  /// tools. It need not match the message.
  ErrorWidget.withDetails({this.message = '', FlutterError? error})
    : _flutterError = error,
      super(key: UniqueKey());

  /// The configurable factory for [ErrorWidget].
  ///
  /// When an error occurs while building a widget, the broken widget is
  /// replaced by the widget returned by this function. By default, an
  /// [ErrorWidget] is returned.
  ///
  /// The system is typically in an unstable state when this function is called.
  /// An exception has just been thrown in the middle of build (and possibly
  /// layout), so surrounding widgets and render objects may be in a rather
  /// fragile state. The framework itself (especially the [BuildOwner]) may also
  /// be confused, and additional exceptions are quite likely to be thrown.
  ///
  /// Because of this, it is highly recommended that the widget returned from
  /// this function perform the least amount of work possible. A
  /// [LeafRenderObjectWidget] is the best choice, especially one that
  /// corresponds to a [RenderBox] that can handle the most absurd of incoming
  /// constraints. The default constructor maps to a [RenderErrorBox].
  ///
  /// The default behavior is to show the exception's message in debug mode,
  /// and to show nothing but a gray background in release builds.
  ///
  /// See also:
  ///
  ///  * [FlutterError.onError], which is typically called with the same
  ///    [FlutterErrorDetails] object immediately prior to this callback being
  ///    invoked, and which can also be configured to control how errors are
  ///    reported.
  ///  * <https://docs.flutter.dev/testing/errors>, more information about error
  ///    handling in Flutter.
  static ErrorWidgetBuilder builder = _defaultErrorWidgetBuilder;

  static Widget _defaultErrorWidgetBuilder(FlutterErrorDetails details) {
    var message = '';
    assert(() {
      message =
          '${_stringify(details.exception)}\nSee also: https://docs.flutter.dev/testing/errors';
      return true;
    }());
    final Object exception = details.exception;
    return ErrorWidget.withDetails(
      message: message,
      error: exception is FlutterError ? exception : null,
    );
  }

  static String _stringify(Object? exception) {
    try {
      return exception.toString();
    } catch (error) {
      // If we get here, it means things have really gone off the rails, and we're better
      // off just returning a simple string and letting the developer find out what the
      // root cause of all their problems are by looking at the console logs.
    }
    return 'Error';
  }

  /// The message to display.
  final String message;
  final FlutterError? _flutterError;

  @override
  RenderBox createRenderObject(BuildContext context) => RenderErrorBox(message);

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    if (_flutterError == null) {
      properties.add(StringProperty('message', message, quoted: false));
    } else {
      properties.add(_flutterError.toDiagnosticsNode(style: DiagnosticsTreeStyle.whitespace));
    }
  }
}

/// Signature for a function that creates a widget, e.g. [StatelessWidget.build]
/// or [State.build].
///
/// Used by [Builder.builder], [OverlayEntry.builder], etc.
///
/// See also:
///
///  * [IndexedWidgetBuilder], which is similar but also takes an index.
///  * [TransitionBuilder], which is similar but also takes a child.
///  * [ValueWidgetBuilder], which is similar but takes a value and a child.
typedef WidgetBuilder = Widget Function(BuildContext context);

/// Signature for a function that creates a widget for a given index, e.g., in a
/// list.
///
/// Used by [ListView.builder] and other APIs that use lazily-generated widgets.
///
/// See also:
///
///  * [WidgetBuilder], which is similar but only takes a [BuildContext].
///  * [TransitionBuilder], which is similar but also takes a child.
///  * [NullableIndexedWidgetBuilder], which is similar but may return null.
typedef IndexedWidgetBuilder = Widget Function(BuildContext context, int index);

/// Signature for a function that creates a widget for a given index, e.g., in a
/// list, but may return null.
///
/// Used by [SliverChildBuilderDelegate.builder] and other APIs that
/// use lazily-generated widgets where the child count is not known
/// ahead of time.
///
/// Unlike most builders, this callback can return null, indicating the index
/// is out of range. Whether and when this is valid depends on the semantics
/// of the builder. For example, [SliverChildBuilderDelegate.builder] returns
/// null when the index is out of range, where the range is defined by the
/// [SliverChildBuilderDelegate.childCount]; so in that case the `index`
/// parameter's value may determine whether returning null is valid or not.
///
/// See also:
///
///  * [WidgetBuilder], which is similar but only takes a [BuildContext].
///  * [TransitionBuilder], which is similar but also takes a child.
///  * [IndexedWidgetBuilder], which is similar but not nullable.
typedef NullableIndexedWidgetBuilder = Widget? Function(BuildContext context, int index);

/// A builder that builds a widget given a child.
///
/// The child should typically be part of the returned widget tree.
///
/// Used by [AnimatedBuilder.builder], [ListenableBuilder.builder],
/// [WidgetsApp.builder], and [MaterialApp.builder].
///
/// See also:
///
/// * [WidgetBuilder], which is similar but only takes a [BuildContext].
/// * [IndexedWidgetBuilder], which is similar but also takes an index.
/// * [ValueWidgetBuilder], which is similar but takes a value and a child.
typedef TransitionBuilder = Widget Function(BuildContext context, Widget? child);

/// An [Element] that composes other [Element]s.
///
/// Rather than creating a [RenderObject] directly, a [ComponentElement] creates
/// [RenderObject]s indirectly by creating other [Element]s.
///
/// Contrast with [RenderObjectElement].
abstract class ComponentElement extends Element {
  /// Creates an element that uses the given widget as its configuration.
  ComponentElement(super.widget);

  Element? _child;

  bool _debugDoingBuild = false;
  @override
  bool get debugDoingBuild => _debugDoingBuild;

  @override
  Element? get renderObjectAttachingChild => _child;

  @override
  void mount(Element? parent, Object? newSlot) {
    super.mount(parent, newSlot);
    assert(_child == null);
    assert(_lifecycleState == _ElementLifecycle.active);
    _firstBuild();
    assert(_child != null);
  }

  void _firstBuild() {
    // StatefulElement overrides this to also call state.didChangeDependencies.
    rebuild(); // This eventually calls performRebuild.
  }

  /// Calls the [StatelessWidget.build] method of the [StatelessWidget] object
  /// (for stateless widgets) or the [State.build] method of the [State] object
  /// (for stateful widgets) and then updates the widget tree.
  ///
  /// Called automatically during [mount] to generate the first build, and by
  /// [rebuild] when the element needs updating.
  @override
  @pragma('vm:notify-debugger-on-exception')
  void performRebuild() {
    Widget built;
    try {
      assert(() {
        _debugDoingBuild = true;
        return true;
      }());
      built = build();
      assert(() {
        _debugDoingBuild = false;
        return true;
      }());
      debugWidgetBuilderValue(widget, built);
    } catch (e, stack) {
      _debugDoingBuild = false;
      built = ErrorWidget.builder(
        _reportException(
          ErrorDescription('building $this'),
          e,
          stack,
          informationCollector: () => <DiagnosticsNode>[
            if (kDebugMode) DiagnosticsDebugCreator(DebugCreator(this)),
          ],
        ),
      );
    } finally {
      // We delay marking the element as clean until after calling build() so
      // that attempts to markNeedsBuild() during build() will be ignored.
      super.performRebuild(); // clears the "dirty" flag
    }
    try {
      _child = updateChild(_child, built, slot);
      assert(_child != null);
    } catch (e, stack) {
      built = ErrorWidget.builder(
        _reportException(
          ErrorDescription('building $this'),
          e,
          stack,
          informationCollector: () => <DiagnosticsNode>[
            if (kDebugMode) DiagnosticsDebugCreator(DebugCreator(this)),
          ],
        ),
      );
      // _Make sure the old child subtree are deactivated and disposed.
      try {
        _child?.deactivate();
      } catch (_) {}
      _child = updateChild(null, built, slot);
    }
  }

  /// Subclasses should override this function to actually call the appropriate
  /// `build` function (e.g., [StatelessWidget.build] or [State.build]) for
  /// their widget.
  @protected
  Widget build();

  @override
  void visitChildren(ElementVisitor visitor) {
    if (_child != null) {
      visitor(_child!);
    }
  }

  @override
  void forgetChild(Element child) {
    assert(child == _child);
    _child = null;
    super.forgetChild(child);
  }
}

/// An [Element] that uses a [StatelessWidget] as its configuration.
class StatelessElement extends ComponentElement {
  /// Creates an element that uses the given widget as its configuration.
  StatelessElement(StatelessWidget super.widget);

  @override
  Widget build() => (widget as StatelessWidget).build(this);

  @override
  void update(StatelessWidget newWidget) {
    super.update(newWidget);
    assert(widget == newWidget);
    rebuild(force: true);
  }
}

/// An [Element] that uses a [StatefulWidget] as its configuration.
class StatefulElement extends ComponentElement {
  /// Creates an element that uses the given widget as its configuration.
  StatefulElement(StatefulWidget widget) : _state = widget.createState(), super(widget) {
    assert(() {
      if (!state._debugTypesAreRight(widget)) {
        throw FlutterError.fromParts(<DiagnosticsNode>[
          ErrorSummary(
            'StatefulWidget.createState must return a subtype of State<${widget.runtimeType}>',
          ),
          ErrorDescription(
            'The createState function for ${widget.runtimeType} returned a state '
            'of type ${state.runtimeType}, which is not a subtype of '
            'State<${widget.runtimeType}>, violating the contract for createState.',
          ),
        ]);
      }
      return true;
    }());
    assert(state._element == null);
    state._element = this;
    assert(
      state._widget == null,
      'The createState function for $widget returned an old or invalid state '
      'instance: ${state._widget}, which is not null, violating the contract '
      'for createState.',
    );
    state._widget = widget;
    assert(state._debugLifecycleState == _StateLifecycle.created);
  }

  @override
  Widget build() => state.build(this);

  /// The [State] instance associated with this location in the tree.
  ///
  /// There is a one-to-one relationship between [State] objects and the
  /// [StatefulElement] objects that hold them. The [State] objects are created
  /// by [StatefulElement] in [mount].
  State<StatefulWidget> get state => _state!;
  State<StatefulWidget>? _state;

  @override
  void reassemble() {
    state.reassemble();
    super.reassemble();
  }

  @override
  void _firstBuild() {
    assert(state._debugLifecycleState == _StateLifecycle.created);
    final Object? debugCheckForReturnedFuture = state.initState() as dynamic;
    assert(() {
      if (debugCheckForReturnedFuture is Future) {
        throw FlutterError.fromParts(<DiagnosticsNode>[
          ErrorSummary('${state.runtimeType}.initState() returned a Future.'),
          ErrorDescription('State.initState() must be a void method without an `async` keyword.'),
          ErrorHint(
            'Rather than awaiting on asynchronous work directly inside of initState, '
            'call a separate method to do this work without awaiting it.',
          ),
        ]);
      }
      return true;
    }());
    assert(() {
      state._debugLifecycleState = _StateLifecycle.initialized;
      return true;
    }());
    state.didChangeDependencies();
    assert(() {
      state._debugLifecycleState = _StateLifecycle.ready;
      return true;
    }());
    super._firstBuild();
  }

  @override
  void performRebuild() {
    if (_didChangeDependencies) {
      state.didChangeDependencies();
      _didChangeDependencies = false;
    }
    super.performRebuild();
  }

  @override
  void update(StatefulWidget newWidget) {
    super.update(newWidget);
    assert(widget == newWidget);
    final StatefulWidget oldWidget = state._widget!;
    state._widget = widget as StatefulWidget;
    final Object? debugCheckForReturnedFuture = state.didUpdateWidget(oldWidget) as dynamic;
    assert(() {
      if (debugCheckForReturnedFuture is Future) {
        throw FlutterError.fromParts(<DiagnosticsNode>[
          ErrorSummary('${state.runtimeType}.didUpdateWidget() returned a Future.'),
          ErrorDescription(
            'State.didUpdateWidget() must be a void method without an `async` keyword.',
          ),
          ErrorHint(
            'Rather than awaiting on asynchronous work directly inside of didUpdateWidget, '
            'call a separate method to do this work without awaiting it.',
          ),
        ]);
      }
      return true;
    }());
    rebuild(force: true);
  }

  @override
  void activate() {
    super.activate();
    state.activate();
    // Since the State could have observed the deactivate() and thus disposed of
    // resources allocated in the build method, we have to rebuild the widget
    // so that its State can reallocate its resources.
    assert(_lifecycleState == _ElementLifecycle.active); // otherwise markNeedsBuild is a no-op
    markNeedsBuild();
  }

  @override
  void deactivate() {
    state.deactivate();
    super.deactivate();
  }

  @override
  void unmount() {
    super.unmount();
    state.dispose();
    assert(() {
      if (state._debugLifecycleState == _StateLifecycle.defunct) {
        return true;
      }
      throw FlutterError.fromParts(<DiagnosticsNode>[
        ErrorSummary('${state.runtimeType}.dispose failed to call super.dispose.'),
        ErrorDescription(
          'dispose() implementations must always call their superclass dispose() method, to ensure '
          'that all the resources used by the widget are fully released.',
        ),
      ]);
    }());
    state._element = null;
    // Release resources to reduce the severity of memory leaks caused by
    // defunct, but accidentally retained Elements.
    _state = null;
  }

  @override
  InheritedWidget dependOnInheritedElement(Element ancestor, {Object? aspect}) {
    assert(() {
      final Type targetType = ancestor.widget.runtimeType;
      if (state._debugLifecycleState == _StateLifecycle.created) {
        throw FlutterError.fromParts(<DiagnosticsNode>[
          ErrorSummary(
            'dependOnInheritedWidgetOfExactType<$targetType>() or dependOnInheritedElement() was called before ${state.runtimeType}.initState() completed.',
          ),
          ErrorDescription(
            'When an inherited widget changes, for example if the value of Theme.of() changes, '
            "its dependent widgets are rebuilt. If the dependent widget's reference to "
            'the inherited widget is in a constructor or an initState() method, '
            'then the rebuilt dependent widget will not reflect the changes in the '
            'inherited widget.',
          ),
          ErrorHint(
            'Typically references to inherited widgets should occur in widget build() methods. Alternatively, '
            'initialization based on inherited widgets can be placed in the didChangeDependencies method, which '
            'is called after initState and whenever the dependencies change thereafter.',
          ),
        ]);
      }
      if (state._debugLifecycleState == _StateLifecycle.defunct) {
        throw FlutterError.fromParts(<DiagnosticsNode>[
          ErrorSummary(
            'dependOnInheritedWidgetOfExactType<$targetType>() or dependOnInheritedElement() was called after dispose(): $this',
          ),
          ErrorDescription(
            'This error happens if you call dependOnInheritedWidgetOfExactType() on the '
            'BuildContext for a widget that no longer appears in the widget tree '
            '(e.g., whose parent widget no longer includes the widget in its '
            'build). This error can occur when code calls '
            'dependOnInheritedWidgetOfExactType() from a timer or an animation callback.',
          ),
          ErrorHint(
            'The preferred solution is to cancel the timer or stop listening to the '
            'animation in the dispose() callback. Another solution is to check the '
            '"mounted" property of this object before calling '
            'dependOnInheritedWidgetOfExactType() to ensure the object is still in the '
            'tree.',
          ),
          ErrorHint(
            'This error might indicate a memory leak if '
            'dependOnInheritedWidgetOfExactType() is being called because another object '
            'is retaining a reference to this State object after it has been '
            'removed from the tree. To avoid memory leaks, consider breaking the '
            'reference to this object during dispose().',
          ),
        ]);
      }
      return true;
    }());
    return super.dependOnInheritedElement(ancestor as InheritedElement, aspect: aspect);
  }

  /// This controls whether we should call [State.didChangeDependencies] from
  /// the start of [build], to avoid calls when the [State] will not get built.
  /// This can happen when the widget has dropped out of the tree, but depends
  /// on an [InheritedWidget] that is still in the tree.
  ///
  /// It is set initially to false, since [_firstBuild] makes the initial call
  /// on the [state]. When it is true, [build] will call
  /// `state.didChangeDependencies` and then sets it to false. Subsequent calls
  /// to [didChangeDependencies] set it to true.
  bool _didChangeDependencies = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _didChangeDependencies = true;
  }

  @override
  DiagnosticsNode toDiagnosticsNode({String? name, DiagnosticsTreeStyle? style}) {
    return _ElementDiagnosticableTreeNode(name: name, value: this, style: style, stateful: true);
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<State<StatefulWidget>>('state', _state, defaultValue: null));
  }
}

/// An [Element] that uses a [ProxyWidget] as its configuration.
abstract class ProxyElement extends ComponentElement {
  /// Initializes fields for subclasses.
  ProxyElement(ProxyWidget super.widget);

  @override
  Widget build() => (widget as ProxyWidget).child;

  @override
  void update(ProxyWidget newWidget) {
    final oldWidget = widget as ProxyWidget;
    assert(widget != newWidget);
    super.update(newWidget);
    assert(widget == newWidget);
    updated(oldWidget);
    rebuild(force: true);
  }

  /// Called during build when the [widget] has changed.
  ///
  /// By default, calls [notifyClients]. Subclasses may override this method to
  /// avoid calling [notifyClients] unnecessarily (e.g. if the old and new
  /// widgets are equivalent).
  @protected
  void updated(covariant ProxyWidget oldWidget) {
    notifyClients(oldWidget);
  }

  /// Notify other objects that the widget associated with this element has
  /// changed.
  ///
  /// Called during [update] (via [updated]) after changing the widget
  /// associated with this element but before rebuilding this element.
  @protected
  void notifyClients(covariant ProxyWidget oldWidget);
}

/// An [Element] that uses a [ParentDataWidget] as its configuration.
class ParentDataElement<T extends ParentData> extends ProxyElement {
  /// Creates an element that uses the given widget as its configuration.
  ParentDataElement(ParentDataWidget<T> super.widget);

  /// Returns the [Type] of [ParentData] that this element has been configured
  /// for.
  ///
  /// This is only available in debug mode. It will throw in profile and
  /// release modes.
  Type get debugParentDataType {
    Type? type;
    assert(() {
      type = T;
      return true;
    }());
    if (type != null) {
      return type!;
    }
    throw UnsupportedError('debugParentDataType is only supported in debug builds');
  }

  void _applyParentData(ParentDataWidget<T> widget) {
    void applyParentDataToChild(Element child) {
      if (child is RenderObjectElement) {
        child._updateParentData(widget);
      } else if (child.renderObjectAttachingChild != null) {
        applyParentDataToChild(child.renderObjectAttachingChild!);
      }
    }

    if (renderObjectAttachingChild != null) {
      applyParentDataToChild(renderObjectAttachingChild!);
    }
  }

  /// Calls [ParentDataWidget.applyParentData] on the given widget, passing it
  /// the [RenderObject] whose parent data this element is ultimately
  /// responsible for.
  ///
  /// This allows a render object's [RenderObject.parentData] to be modified
  /// without triggering a build. This is generally ill-advised, but makes sense
  /// in situations such as the following:
  ///
  ///  * Build and layout are currently under way, but the [ParentData] in question
  ///    does not affect layout, and the value to be applied could not be
  ///    determined before build and layout (e.g. it depends on the layout of a
  ///    descendant).
  ///
  ///  * Paint is currently under way, but the [ParentData] in question does not
  ///    affect layout or paint, and the value to be applied could not be
  ///    determined before paint (e.g. it depends on the compositing phase).
  ///
  /// In either case, the next build is expected to cause this element to be
  /// configured with the given new widget (or a widget with equivalent data).
  ///
  /// Only [ParentDataWidget]s that return true for
  /// [ParentDataWidget.debugCanApplyOutOfTurn] can be applied this way.
  ///
  /// The new widget must have the same child as the current widget.
  ///
  /// An example of when this is used is the [AutomaticKeepAlive] widget. If it
  /// receives a notification during the build of one of its descendants saying
  /// that its child must be kept alive, it will apply a [KeepAlive] widget out
  /// of turn. This is safe, because by definition the child is already alive,
  /// and therefore this will not change the behavior of the parent this frame.
  /// It is more efficient than requesting an additional frame just for the
  /// purpose of updating the [KeepAlive] widget.
  void applyWidgetOutOfTurn(ParentDataWidget<T> newWidget) {
    assert(newWidget.debugCanApplyOutOfTurn());
    assert(newWidget.child == (widget as ParentDataWidget<T>).child);
    _applyParentData(newWidget);
  }

  @override
  void notifyClients(ParentDataWidget<T> oldWidget) {
    _applyParentData(widget as ParentDataWidget<T>);
  }
}

/// An [Element] that uses an [InheritedWidget] as its configuration.
class InheritedElement extends ProxyElement {
  /// Creates an element that uses the given widget as its configuration.
  InheritedElement(InheritedWidget super.widget);

  final Map<Element, Object?> _dependents = HashMap<Element, Object?>();

  @override
  void _updateInheritance() {
    assert(_lifecycleState == _ElementLifecycle.active);
    final PersistentHashMap<Type, InheritedElement> incomingWidgets =
        _parent?._inheritedElements ?? const PersistentHashMap<Type, InheritedElement>.empty();
    _inheritedElements = incomingWidgets.put(widget.runtimeType, this);
  }

  @override
  void debugDeactivated() {
    assert(_dependents.isEmpty);
    super.debugDeactivated();
  }

  /// Returns the dependencies value recorded for [dependent]
  /// with [setDependencies].
  ///
  /// Each dependent element is mapped to a single object value
  /// which represents how the element depends on this
  /// [InheritedElement]. This value is null by default and by default
  /// dependent elements are rebuilt unconditionally.
  ///
  /// Subclasses can manage these values with [updateDependencies]
  /// so that they can selectively rebuild dependents in
  /// [notifyDependent].
  ///
  /// This method is typically only called in overrides of [updateDependencies].
  ///
  /// See also:
  ///
  ///  * [updateDependencies], which is called each time a dependency is
  ///    created with [dependOnInheritedWidgetOfExactType].
  ///  * [setDependencies], which sets dependencies value for a dependent
  ///    element.
  ///  * [notifyDependent], which can be overridden to use a dependent's
  ///    dependencies value to decide if the dependent needs to be rebuilt.
  ///  * [InheritedModel], which is an example of a class that uses this method
  ///    to manage dependency values.
  @protected
  Object? getDependencies(Element dependent) {
    return _dependents[dependent];
  }

  /// Sets the value returned by [getDependencies] value for [dependent].
  ///
  /// Each dependent element is mapped to a single object value
  /// which represents how the element depends on this
  /// [InheritedElement]. The [updateDependencies] method sets this value to
  /// null by default so that dependent elements are rebuilt unconditionally.
  ///
  /// Subclasses can manage these values with [updateDependencies]
  /// so that they can selectively rebuild dependents in [notifyDependent].
  ///
  /// This method is typically only called in overrides of [updateDependencies].
  ///
  /// See also:
  ///
  ///  * [updateDependencies], which is called each time a dependency is
  ///    created with [dependOnInheritedWidgetOfExactType].
  ///  * [getDependencies], which returns the current value for a dependent
  ///    element.
  ///  * [notifyDependent], which can be overridden to use a dependent's
  ///    [getDependencies] value to decide if the dependent needs to be rebuilt.
  ///  * [InheritedModel], which is an example of a class that uses this method
  ///    to manage dependency values.
  @protected
  void setDependencies(Element dependent, Object? value) {
    _dependents[dependent] = value;
  }

  /// Called by [dependOnInheritedWidgetOfExactType] when a new [dependent] is added.
  ///
  /// Each dependent element can be mapped to a single object value with
  /// [setDependencies]. This method can lookup the existing dependencies with
  /// [getDependencies].
  ///
  /// By default this method sets the inherited dependencies for [dependent]
  /// to null. This only serves to record an unconditional dependency on
  /// [dependent].
  ///
  /// Subclasses can manage their own dependencies values so that they
  /// can selectively rebuild dependents in [notifyDependent].
  ///
  /// See also:
  ///
  ///  * [getDependencies], which returns the current value for a dependent
  ///    element.
  ///  * [setDependencies], which sets the value for a dependent element.
  ///  * [notifyDependent], which can be overridden to use a dependent's
  ///    dependencies value to decide if the dependent needs to be rebuilt.
  ///  * [InheritedModel], which is an example of a class that uses this method
  ///    to manage dependency values.
  @protected
  void updateDependencies(Element dependent, Object? aspect) {
    setDependencies(dependent, null);
  }

  /// Called by [notifyClients] for each dependent.
  ///
  /// Calls `dependent.didChangeDependencies()` by default.
  ///
  /// Subclasses can override this method to selectively call
  /// [didChangeDependencies] based on the value of [getDependencies].
  ///
  /// See also:
  ///
  ///  * [updateDependencies], which is called each time a dependency is
  ///    created with [dependOnInheritedWidgetOfExactType].
  ///  * [getDependencies], which returns the current value for a dependent
  ///    element.
  ///  * [setDependencies], which sets the value for a dependent element.
  ///  * [InheritedModel], which is an example of a class that uses this method
  ///    to manage dependency values.
  @protected
  void notifyDependent(covariant InheritedWidget oldWidget, Element dependent) {
    dependent.didChangeDependencies();
  }

  /// Called by [Element.deactivate] to remove the provided `dependent` [Element] from this [InheritedElement].
  ///
  /// After the dependent is removed, [Element.didChangeDependencies] will no
  /// longer be called on it when this [InheritedElement] notifies its dependents.
  ///
  /// Subclasses can override this method to release any resources retained for
  /// a given [dependent].
  @protected
  @mustCallSuper
  void removeDependent(Element dependent) {
    _dependents.remove(dependent);
  }

  /// Calls [Element.didChangeDependencies] of all dependent elements, if
  /// [InheritedWidget.updateShouldNotify] returns true.
  ///
  /// Called by [update], immediately prior to [build].
  ///
  /// Calls [notifyClients] to actually trigger the notifications.
  @override
  void updated(InheritedWidget oldWidget) {
    if ((widget as InheritedWidget).updateShouldNotify(oldWidget)) {
      super.updated(oldWidget);
    }
  }

  /// Notifies all dependent elements that this inherited widget has changed, by
  /// calling [Element.didChangeDependencies].
  ///
  /// This method must only be called during the build phase. Usually this
  /// method is called automatically when an inherited widget is rebuilt, e.g.
  /// as a result of calling [State.setState] above the inherited widget.
  ///
  /// See also:
  ///
  ///  * [InheritedNotifier], a subclass of [InheritedWidget] that also calls
  ///    this method when its [Listenable] sends a notification.
  @override
  void notifyClients(InheritedWidget oldWidget) {
    assert(_debugCheckOwnerBuildTargetExists('notifyClients'));
    for (final Element dependent in _dependents.keys) {
      assert(() {
        // check that it really is our descendant
        Element? ancestor = dependent._parent;
        while (ancestor != this && ancestor != null) {
          ancestor = ancestor._parent;
        }
        return ancestor == this;
      }());
      // check that it really depends on us
      assert(dependent._dependencies!.contains(this));
      notifyDependent(oldWidget, dependent);
    }
  }
}

/// An [Element] that uses a [RenderObjectWidget] as its configuration.
///
/// [RenderObjectElement] objects have an associated [RenderObject] widget in
/// the render tree, which handles concrete operations like laying out,
/// painting, and hit testing.
///
/// Contrast with [ComponentElement].
///
/// For details on the lifecycle of an element, see the discussion at [Element].
///
/// ## Writing a RenderObjectElement subclass
///
/// There are three common child models used by most [RenderObject]s:
///
/// * Leaf render objects, with no children: The [LeafRenderObjectElement] class
///   handles this case.
///
/// * A single child: The [SingleChildRenderObjectElement] class handles this
///   case.
///
/// * A linked list of children: The [MultiChildRenderObjectElement] class
///   handles this case.
///
/// Sometimes, however, a render object's child model is more complicated. Maybe
/// it has a two-dimensional array of children. Maybe it constructs children on
/// demand. Maybe it features multiple lists. In such situations, the
/// corresponding [Element] for the [Widget] that configures that [RenderObject]
/// will be a new subclass of [RenderObjectElement].
///
/// Such a subclass is responsible for managing children, specifically the
/// [Element] children of this object, and the [RenderObject] children of its
/// corresponding [RenderObject].
///
/// ### Specializing the getters
///
/// [RenderObjectElement] objects spend much of their time acting as
/// intermediaries between their [widget] and their [renderObject]. It is
/// generally recommended against specializing the [widget] getter and
/// instead casting at the various call sites to avoid adding overhead
/// outside of this particular implementation.
///
/// ```dart
/// class FooElement extends RenderObjectElement {
///   FooElement(super.widget);
///
///   // Specializing the renderObject getter is fine because
///   // it is not performance sensitive.
///   @override
///   RenderFoo get renderObject => super.renderObject as RenderFoo;
///
///   void _foo() {
///     // For the widget getter, though, we prefer to cast locally
///     // since that results in better overall performance where the
///     // casting isn't needed:
///     final Foo foo = widget as Foo;
///     // ...
///   }
///
///   // ...
/// }
/// ```
///
/// ### Slots
///
/// Each child [Element] corresponds to a [RenderObject] which should be
/// attached to this element's render object as a child.
///
/// However, the immediate children of the element may not be the ones that
/// eventually produce the actual [RenderObject] that they correspond to. For
/// example, a [StatelessElement] (the element of a [StatelessWidget])
/// corresponds to whatever [RenderObject] its child (the element returned by
/// its [StatelessWidget.build] method) corresponds to.
///
/// Each child is therefore assigned a _[slot]_ token. This is an identifier whose
/// meaning is private to this [RenderObjectElement] node. When the descendant
/// that finally produces the [RenderObject] is ready to attach it to this
/// node's render object, it passes that slot token back to this node, and that
/// allows this node to cheaply identify where to put the child render object
/// relative to the others in the parent render object.
///
/// A child's [slot] is determined when the parent calls [updateChild] to
/// inflate the child (see the next section). It can be updated by calling
/// [updateSlotForChild].
///
/// ### Updating children
///
/// Early in the lifecycle of an element, the framework calls the [mount]
/// method. This method should call [updateChild] for each child, passing in
/// the widget for that child, and the slot for that child, thus obtaining a
/// list of child [Element]s.
///
/// Subsequently, the framework will call the [update] method. In this method,
/// the [RenderObjectElement] should call [updateChild] for each child, passing
/// in the [Element] that was obtained during [mount] or the last time [update]
/// was run (whichever happened most recently), the new [Widget], and the slot.
/// This provides the object with a new list of [Element] objects.
///
/// Where possible, the [update] method should attempt to map the elements from
/// the last pass to the widgets in the new pass. For example, if one of the
/// elements from the last pass was configured with a particular [Key], and one
/// of the widgets in this new pass has that same key, they should be paired up,
/// and the old element should be updated with the widget (and the slot
/// corresponding to the new widget's new position, also). The [updateChildren]
/// method may be useful in this regard.
///
/// [updateChild] should be called for children in their logical order. The
/// order can matter; for example, if two of the children use [PageStorage]'s
/// `writeState` feature in their build method (and neither has a [Widget.key]),
/// then the state written by the first will be overwritten by the second.
///
/// #### Dynamically determining the children during the build phase
///
/// The child widgets need not necessarily come from this element's widget
/// verbatim. They could be generated dynamically from a callback, or generated
/// in other more creative ways.
///
/// #### Dynamically determining the children during layout
///
/// If the widgets are to be generated at layout time, then generating them in
/// the [mount] and [update] methods won't work: layout of this element's render
/// object hasn't started yet at that point. Instead, the [update] method can
/// mark the render object as needing layout (see
/// [RenderObject.markNeedsLayout]), and then the render object's
/// [RenderObject.performLayout] method can call back to the element to have it
/// generate the widgets and call [updateChild] accordingly.
///
/// For a render object to call an element during layout, it must use
/// [RenderObject.invokeLayoutCallback]. For an element to call [updateChild]
/// outside of its [update] method, it must use [BuildOwner.buildScope].
///
/// The framework provides many more checks in normal operation than it does
/// when doing a build during layout. For this reason, creating widgets with
/// layout-time build semantics should be done with great care.
///
/// #### Handling errors when building
///
/// If an element calls a builder function to obtain widgets for its children,
/// it may find that the build throws an exception. Such exceptions should be
/// caught and reported using [FlutterError.reportError]. If a child is needed
/// but a builder has failed in this way, an instance of [ErrorWidget] can be
/// used instead.
///
/// ### Detaching children
///
/// It is possible, when using [GlobalKey]s, for a child to be proactively
/// removed by another element before this element has been updated.
/// (Specifically, this happens when the subtree rooted at a widget with a
/// particular [GlobalKey] is being moved from this element to an element
/// processed earlier in the build phase.) When this happens, this element's
/// [forgetChild] method will be called with a reference to the affected child
/// element.
///
/// The [forgetChild] method of a [RenderObjectElement] subclass must remove the
/// child element from its child list, so that when it next [update]s its
/// children, the removed child is not considered.
///
/// For performance reasons, if there are many elements, it may be quicker to
/// track which elements were forgotten by storing them in a [Set], rather than
/// proactively mutating the local record of the child list and the identities
/// of all the slots. For example, see the implementation of
/// [MultiChildRenderObjectElement].
///
/// ### Maintaining the render object tree
///
/// Once a descendant produces a render object, it will call
/// [insertRenderObjectChild]. If the descendant's slot changes identity, it
/// will call [moveRenderObjectChild]. If a descendant goes away, it will call
/// [removeRenderObjectChild].
///
/// These three methods should update the render tree accordingly, attaching,
/// moving, and detaching the given child render object from this element's own
/// render object respectively.
///
/// ### Walking the children
///
/// If a [RenderObjectElement] object has any children [Element]s, it must
/// expose them in its implementation of the [visitChildren] method. This method
/// is used by many of the framework's internal mechanisms, and so should be
/// fast. It is also used by the test framework and [debugDumpApp].
abstract class RenderObjectElement extends Element {
  /// Creates an element that uses the given widget as its configuration.
  RenderObjectElement(RenderObjectWidget super.widget);

  /// The underlying [RenderObject] for this element.
  ///
  /// If this element has been [unmount]ed, this getter will throw.
  @override
  RenderObject get renderObject {
    assert(_renderObject != null, '$runtimeType unmounted');
    return _renderObject!;
  }

  RenderObject? _renderObject;

  @override
  Element? get renderObjectAttachingChild => null;

  bool _debugDoingBuild = false;
  @override
  bool get debugDoingBuild => _debugDoingBuild;

  RenderObjectElement? _ancestorRenderObjectElement;

  RenderObjectElement? _findAncestorRenderObjectElement() {
    Element? ancestor = _parent;
    while (ancestor != null && ancestor is! RenderObjectElement) {
      // In debug mode we check whether the ancestor accepts RenderObjects to
      // produce a better error message in attachRenderObject. In release mode,
      // we assume only correct trees are built (i.e.
      // debugExpectsRenderObjectForSlot always returns true) and don't check
      // explicitly.
      assert(() {
        if (!ancestor!.debugExpectsRenderObjectForSlot(slot)) {
          ancestor = null;
        }
        return true;
      }());
      ancestor = ancestor?._parent;
    }
    assert(() {
      if (ancestor?.debugExpectsRenderObjectForSlot(slot) == false) {
        ancestor = null;
      }
      return true;
    }());
    return ancestor as RenderObjectElement?;
  }

  void _debugCheckCompetingAncestors(
    List<ParentDataElement<ParentData>> result,
    Set<Type> debugAncestorTypes,
    Set<Type> debugParentDataTypes,
    List<Type> debugAncestorCulprits,
  ) {
    assert(() {
      // Check that no other ParentDataWidgets of the same
      // type want to provide parent data.
      if (debugAncestorTypes.length != result.length ||
          debugParentDataTypes.length != result.length) {
        // This can only occur if the Sets of ancestors and parent data types was
        // provided a dupe and did not add it.
        assert(
          debugAncestorTypes.length < result.length || debugParentDataTypes.length < result.length,
        );
        try {
          // We explicitly throw here (even though we immediately redirect the
          // exception elsewhere) so that debuggers will notice it when they
          // have "break on exception" enabled.
          throw FlutterError.fromParts(<DiagnosticsNode>[
            ErrorSummary('Incorrect use of ParentDataWidget.'),
            ErrorDescription(
              'Competing ParentDataWidgets are providing parent data to the '
              'same RenderObject:',
            ),
            for (final ParentDataElement<ParentData> ancestor in result.where((
              ParentDataElement<ParentData> ancestor,
            ) {
              return debugAncestorCulprits.contains(ancestor.runtimeType);
            }))
              ErrorDescription(
                '- ${ancestor.widget}, which writes ParentData of type '
                '${ancestor.debugParentDataType}, (typically placed directly '
                'inside a '
                '${(ancestor.widget as ParentDataWidget<ParentData>).debugTypicalAncestorWidgetClass} '
                'widget)',
              ),
            ErrorDescription(
              'A RenderObject can receive parent data from multiple '
              'ParentDataWidgets, but the Type of ParentData must be unique to '
              'prevent one overwriting another.',
            ),
            ErrorHint(
              'Usually, this indicates that one or more of the offending '
              "ParentDataWidgets listed above isn't placed inside a dedicated "
              "compatible ancestor widget that it isn't sharing with another "
              'ParentDataWidget of the same type.',
            ),
            ErrorHint(
              'Otherwise, separating aspects of ParentData to prevent '
              'conflicts can be done using mixins, mixing them all in on the '
              'full ParentData Object, such as KeepAlive does with '
              'KeepAliveParentDataMixin.',
            ),
            ErrorDescription(
              'The ownership chain for the RenderObject that received the '
              'parent data was:\n  ${debugGetCreatorChain(10)}',
            ),
          ]);
        } on FlutterError catch (error) {
          _reportException(ErrorSummary('while looking for parent data.'), error, error.stackTrace);
        }
      }
      return true;
    }());
  }

  List<ParentDataElement<ParentData>> _findAncestorParentDataElements() {
    Element? ancestor = _parent;
    final result = <ParentDataElement<ParentData>>[];
    final debugAncestorTypes = <Type>{};
    final debugParentDataTypes = <Type>{};
    final debugAncestorCulprits = <Type>[];

    // More than one ParentDataWidget can contribute ParentData, but there are
    // some constraints.
    // 1. ParentData can only be written by unique ParentDataWidget types.
    //    For example, two KeepAlive ParentDataWidgets trying to write to the
    //    same child is not allowed.
    // 2. Each contributing ParentDataWidget must contribute to a unique
    //    ParentData type, less ParentData be overwritten.
    //    For example, there cannot be two ParentDataWidgets that both write
    //    ParentData of type KeepAliveParentDataMixin, if the first check was
    //    subverted by a subclassing of the KeepAlive ParentDataWidget.
    // 3. The ParentData itself must be compatible with all ParentDataWidgets
    //    writing to it.
    //    For example, TwoDimensionalViewportParentData uses the
    //    KeepAliveParentDataMixin, so it could be compatible with both
    //    KeepAlive, and another ParentDataWidget with ParentData type
    //    TwoDimensionalViewportParentData or a subclass thereof.
    // The first and second cases are verified here. The third is verified in
    // debugIsValidRenderObject.

    while (ancestor != null && ancestor is! RenderObjectElement) {
      if (ancestor is ParentDataElement<ParentData>) {
        assert((ParentDataElement<ParentData> ancestor) {
          if (!debugAncestorTypes.add(ancestor.runtimeType) ||
              !debugParentDataTypes.add(ancestor.debugParentDataType)) {
            debugAncestorCulprits.add(ancestor.runtimeType);
          }
          return true;
        }(ancestor));
        result.add(ancestor);
      }
      ancestor = ancestor._parent;
    }
    assert(() {
      if (result.isEmpty || ancestor == null) {
        return true;
      }
      // Validate points 1 and 2 from above.
      _debugCheckCompetingAncestors(
        result,
        debugAncestorTypes,
        debugParentDataTypes,
        debugAncestorCulprits,
      );
      return true;
    }());
    return result;
  }

  @override
  void mount(Element? parent, Object? newSlot) {
    super.mount(parent, newSlot);
    assert(() {
      _debugDoingBuild = true;
      return true;
    }());
    _renderObject = (widget as RenderObjectWidget).createRenderObject(this);
    assert(!_renderObject!.debugDisposed!);
    assert(() {
      _debugDoingBuild = false;
      return true;
    }());
    assert(() {
      _debugUpdateRenderObjectOwner();
      return true;
    }());
    assert(slot == newSlot);
    attachRenderObject(newSlot);
    super.performRebuild(); // clears the "dirty" flag
  }

  @override
  void update(covariant RenderObjectWidget newWidget) {
    super.update(newWidget);
    assert(widget == newWidget);
    assert(() {
      _debugUpdateRenderObjectOwner();
      return true;
    }());
    _performRebuild(); // calls widget.updateRenderObject()
  }

  void _debugUpdateRenderObjectOwner() {
    assert(() {
      renderObject.debugCreator = DebugCreator(this);
      return true;
    }());
  }

  @override
  // ignore: must_call_super, _performRebuild calls super.
  void performRebuild() {
    _performRebuild(); // calls widget.updateRenderObject()
  }

  @pragma('dart2js:tryInline')
  @pragma('vm:prefer-inline')
  @pragma('wasm:prefer-inline')
  void _performRebuild() {
    assert(() {
      _debugDoingBuild = true;
      return true;
    }());
    (widget as RenderObjectWidget).updateRenderObject(this, renderObject);
    assert(() {
      _debugDoingBuild = false;
      return true;
    }());
    super.performRebuild(); // clears the "dirty" flag
  }

  @override
  @visibleForOverriding
  void deactivate() {
    super.deactivate();
    assert(
      !renderObject.attached,
      'A RenderObject was still attached when attempting to deactivate its '
      'RenderObjectElement: $renderObject',
    );
  }

  @override
  @visibleForOverriding
  void unmount() {
    assert(
      !renderObject.debugDisposed!,
      'A RenderObject was disposed prior to its owning element being unmounted: '
      '$renderObject',
    );
    final oldWidget = widget as RenderObjectWidget;
    super.unmount();
    assert(
      !renderObject.attached,
      'A RenderObject was still attached when attempting to unmount its '
      'RenderObjectElement: $renderObject',
    );
    oldWidget.didUnmountRenderObject(renderObject);
    _renderObject!.dispose();
    _renderObject = null;
  }

  void _updateParentData(ParentDataWidget<ParentData> parentDataWidget) {
    var applyParentData = true;
    assert(() {
      try {
        if (!parentDataWidget.debugIsValidRenderObject(renderObject)) {
          applyParentData = false;
          throw FlutterError.fromParts(<DiagnosticsNode>[
            ErrorSummary('Incorrect use of ParentDataWidget.'),
            ...parentDataWidget._debugDescribeIncorrectParentDataType(
              parentData: renderObject.parentData,
              parentDataCreator: _ancestorRenderObjectElement?.widget as RenderObjectWidget?,
              ownershipChain: ErrorDescription(debugGetCreatorChain(10)),
            ),
          ]);
        }
      } on FlutterError catch (e) {
        // We catch the exception directly to avoid activating the ErrorWidget,
        // while still allowing debuggers to break on exception. Since the tree
        // is in a broken state, adding the ErrorWidget would likely cause more
        // exceptions, which is not good for the debugging experience.
        _reportException(ErrorSummary('while applying parent data.'), e, e.stackTrace);
      }
      return true;
    }());
    if (applyParentData) {
      parentDataWidget.applyParentData(renderObject);
    }
  }

  @override
  void updateSlot(Object? newSlot) {
    final Object? oldSlot = slot;
    assert(oldSlot != newSlot);
    super.updateSlot(newSlot);
    assert(slot == newSlot);
    assert(_ancestorRenderObjectElement == _findAncestorRenderObjectElement());
    _ancestorRenderObjectElement?.moveRenderObjectChild(renderObject, oldSlot, slot);
  }

  @override
  void attachRenderObject(Object? newSlot) {
    assert(_ancestorRenderObjectElement == null);
    _slot = newSlot;
    _ancestorRenderObjectElement = _findAncestorRenderObjectElement();
    assert(() {
      if (_ancestorRenderObjectElement == null) {
        FlutterError.reportError(
          FlutterErrorDetails(
            exception: FlutterError.fromParts(<DiagnosticsNode>[
              ErrorSummary(
                'The render object for ${toStringShort()} cannot find ancestor render object to attach to.',
              ),
              ErrorDescription(
                'The ownership chain for the RenderObject in question was:\n  ${debugGetCreatorChain(10)}',
              ),
              ErrorHint(
                'Try wrapping your widget in a View widget or any other widget that is backed by '
                'a $RenderTreeRootElement to serve as the root of the render tree.',
              ),
            ]),
          ),
        );
      }
      return true;
    }());
    _ancestorRenderObjectElement?.insertRenderObjectChild(renderObject, newSlot);
    final List<ParentDataElement<ParentData>> parentDataElements =
        _findAncestorParentDataElements();
    for (final parentDataElement in parentDataElements) {
      _updateParentData(parentDataElement.widget as ParentDataWidget<ParentData>);
    }
  }

  @override
  void detachRenderObject() {
    if (_ancestorRenderObjectElement != null) {
      _ancestorRenderObjectElement!.removeRenderObjectChild(renderObject, slot);
      _ancestorRenderObjectElement = null;
    }
    _slot = null;
  }

  /// Insert the given child into [renderObject] at the given slot.
  ///
  /// {@template flutter.widgets.RenderObjectElement.insertRenderObjectChild}
  /// The semantics of `slot` are determined by this element. For example, if
  /// this element has a single child, the slot should always be null. If this
  /// element has a list of children, the previous sibling element wrapped in an
  /// [IndexedSlot] is a convenient value for the slot.
  /// {@endtemplate}
  @protected
  void insertRenderObjectChild(covariant RenderObject child, covariant Object? slot);

  /// Move the given child from the given old slot to the given new slot.
  ///
  /// The given child is guaranteed to have [renderObject] as its parent.
  ///
  /// {@macro flutter.widgets.RenderObjectElement.insertRenderObjectChild}
  ///
  /// This method is only ever called if [updateChild] can end up being called
  /// with an existing [Element] child and a `slot` that differs from the slot
  /// that element was previously given. [MultiChildRenderObjectElement] does this,
  /// for example. [SingleChildRenderObjectElement] does not (since the `slot` is
  /// always null). An [Element] that has a specific set of slots with each child
  /// always having the same slot (and where children in different slots are never
  /// compared against each other for the purposes of updating one slot with the
  /// element from another slot) would never call this.
  @protected
  void moveRenderObjectChild(
    covariant RenderObject child,
    covariant Object? oldSlot,
    covariant Object? newSlot,
  );

  /// Remove the given child from [renderObject].
  ///
  /// The given child is guaranteed to have been inserted at the given `slot`
  /// and have [renderObject] as its parent.
  @protected
  void removeRenderObjectChild(covariant RenderObject child, covariant Object? slot);

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(
      DiagnosticsProperty<RenderObject>('renderObject', _renderObject, defaultValue: null),
    );
  }
}

/// Deprecated. Unused in the framework and will be removed in a future version
/// of Flutter.
///
/// Classes that extend this class can extend [RenderObjectElement] and mixin
/// [RootElementMixin] instead.
@Deprecated(
  'Use RootElementMixin instead. '
  'This feature was deprecated after v3.9.0-16.0.pre.',
)
abstract class RootRenderObjectElement extends RenderObjectElement with RootElementMixin {
  /// Initializes fields for subclasses.
  @Deprecated(
    'Use RootElementMixin instead. '
    'This feature was deprecated after v3.9.0-16.0.pre.',
  )
  RootRenderObjectElement(super.widget);
}

/// Mixin for the element at the root of the tree.
///
/// Only root elements may have their owner set explicitly. All other
/// elements inherit their owner from their parent.
mixin RootElementMixin on Element {
  /// Set the owner of the element. The owner will be propagated to all the
  /// descendants of this element.
  ///
  /// The owner manages the dirty elements list.
  ///
  /// The [WidgetsBinding] introduces the primary owner,
  /// [WidgetsBinding.buildOwner], and assigns it to the widget tree in the call
  /// to [runApp]. The binding is responsible for driving the build pipeline by
  /// calling the build owner's [BuildOwner.buildScope] method. See
  /// [WidgetsBinding.drawFrame].
  void assignOwner(BuildOwner owner) {
    _owner = owner;
    _parentBuildScope = BuildScope();
  }

  @override
  void mount(Element? parent, Object? newSlot) {
    // Root elements should never have parents.
    assert(parent == null);
    assert(newSlot == null);
    super.mount(parent, newSlot);
  }
}

/// An [Element] that uses a [LeafRenderObjectWidget] as its configuration.
class LeafRenderObjectElement extends RenderObjectElement {
  /// Creates an element that uses the given widget as its configuration.
  LeafRenderObjectElement(LeafRenderObjectWidget super.widget);

  @override
  void forgetChild(Element child) {
    assert(false);
    super.forgetChild(child);
  }

  @override
  void insertRenderObjectChild(RenderObject child, Object? slot) {
    assert(false);
  }

  @override
  void moveRenderObjectChild(RenderObject child, Object? oldSlot, Object? newSlot) {
    assert(false);
  }

  @override
  void removeRenderObjectChild(RenderObject child, Object? slot) {
    assert(false);
  }

  @override
  List<DiagnosticsNode> debugDescribeChildren() {
    return widget.debugDescribeChildren();
  }
}

/// An [Element] that uses a [SingleChildRenderObjectWidget] as its configuration.
///
/// The child is optional.
///
/// This element subclass can be used for [RenderObjectWidget]s whose
/// [RenderObject]s use the [RenderObjectWithChildMixin] mixin. Such widgets are
/// expected to inherit from [SingleChildRenderObjectWidget].
class SingleChildRenderObjectElement extends RenderObjectElement {
  /// Creates an element that uses the given widget as its configuration.
  SingleChildRenderObjectElement(SingleChildRenderObjectWidget super.widget);

  Element? _child;

  @override
  void visitChildren(ElementVisitor visitor) {
    if (_child != null) {
      visitor(_child!);
    }
  }

  @override
  void forgetChild(Element child) {
    assert(child == _child);
    _child = null;
    super.forgetChild(child);
  }

  @override
  void mount(Element? parent, Object? newSlot) {
    super.mount(parent, newSlot);
    _child = updateChild(_child, (widget as SingleChildRenderObjectWidget).child, null);
  }

  @override
  void update(SingleChildRenderObjectWidget newWidget) {
    super.update(newWidget);
    assert(widget == newWidget);
    _child = updateChild(_child, (widget as SingleChildRenderObjectWidget).child, null);
  }

  @override
  void insertRenderObjectChild(RenderObject child, Object? slot) {
    final renderObject = this.renderObject as RenderObjectWithChildMixin<RenderObject>;
    assert(slot == null);
    assert(renderObject.debugValidateChild(child));
    renderObject.child = child;
    assert(renderObject == this.renderObject);
  }

  @override
  void moveRenderObjectChild(RenderObject child, Object? oldSlot, Object? newSlot) {
    assert(false);
  }

  @override
  void removeRenderObjectChild(RenderObject child, Object? slot) {
    final renderObject = this.renderObject as RenderObjectWithChildMixin<RenderObject>;
    assert(slot == null);
    assert(renderObject.child == child);
    renderObject.child = null;
    assert(renderObject == this.renderObject);
  }
}

/// An [Element] that uses a [MultiChildRenderObjectWidget] as its configuration.
///
/// This element subclass can be used for [RenderObjectWidget]s whose
/// [RenderObject]s use the [ContainerRenderObjectMixin] mixin with a parent data
/// type that implements [ContainerParentDataMixin<RenderObject>]. Such widgets
/// are expected to inherit from [MultiChildRenderObjectWidget].
///
/// See also:
///
/// * [IndexedSlot], which is used as [Element.slot]s for the children of a
///   [MultiChildRenderObjectElement].
/// * [RenderObjectElement.updateChildren], which discusses why [IndexedSlot]
///   is used for the slots of the children.
class MultiChildRenderObjectElement extends RenderObjectElement {
  /// Creates an element that uses the given widget as its configuration.
  MultiChildRenderObjectElement(MultiChildRenderObjectWidget super.widget)
    : assert(!debugChildrenHaveDuplicateKeys(widget, widget.children));

  @override
  ContainerRenderObjectMixin<RenderObject, ContainerParentDataMixin<RenderObject>>
  get renderObject {
    return super.renderObject
        as ContainerRenderObjectMixin<RenderObject, ContainerParentDataMixin<RenderObject>>;
  }

  /// The current list of children of this element.
  ///
  /// This list is filtered to hide elements that have been forgotten (using
  /// [forgetChild]).
  @protected
  @visibleForTesting
  Iterable<Element> get children =>
      _children.where((Element child) => !_forgottenChildren.contains(child));

  late List<Element> _children;
  // We keep a set of forgotten children to avoid O(n^2) work walking _children
  // repeatedly to remove children.
  final Set<Element> _forgottenChildren = HashSet<Element>();

  @override
  void insertRenderObjectChild(RenderObject child, IndexedSlot<Element?> slot) {
    final ContainerRenderObjectMixin<RenderObject, ContainerParentDataMixin<RenderObject>>
    renderObject = this.renderObject;
    assert(renderObject.debugValidateChild(child));
    renderObject.insert(child, after: slot.value?.renderObject);
    assert(renderObject == this.renderObject);
  }

  @override
  void moveRenderObjectChild(
    RenderObject child,
    IndexedSlot<Element?> oldSlot,
    IndexedSlot<Element?> newSlot,
  ) {
    final ContainerRenderObjectMixin<RenderObject, ContainerParentDataMixin<RenderObject>>
    renderObject = this.renderObject;
    assert(child.parent == renderObject);
    renderObject.move(child, after: newSlot.value?.renderObject);
    assert(renderObject == this.renderObject);
  }

  @override
  void removeRenderObjectChild(RenderObject child, Object? slot) {
    final ContainerRenderObjectMixin<RenderObject, ContainerParentDataMixin<RenderObject>>
    renderObject = this.renderObject;
    assert(child.parent == renderObject);
    renderObject.remove(child);
    assert(renderObject == this.renderObject);
  }

  @override
  void visitChildren(ElementVisitor visitor) {
    for (final Element child in _children) {
      if (!_forgottenChildren.contains(child)) {
        visitor(child);
      }
    }
  }

  @override
  void forgetChild(Element child) {
    assert(_children.contains(child));
    assert(!_forgottenChildren.contains(child));
    _forgottenChildren.add(child);
    super.forgetChild(child);
  }

  bool _debugCheckHasAssociatedRenderObject(Element newChild) {
    assert(() {
      if (newChild.renderObject == null) {
        FlutterError.reportError(
          FlutterErrorDetails(
            exception: FlutterError.fromParts(<DiagnosticsNode>[
              ErrorSummary(
                'The children of `MultiChildRenderObjectElement` must each has an associated render object.',
              ),
              ErrorHint(
                'This typically means that the `${newChild.widget}` or its children\n'
                'are not a subtype of `RenderObjectWidget`.',
              ),
              newChild.describeElement(
                'The following element does not have an associated render object',
              ),
              DiagnosticsDebugCreator(DebugCreator(newChild)),
            ]),
          ),
        );
      }
      return true;
    }());
    return true;
  }

  @override
  Element inflateWidget(Widget newWidget, Object? newSlot) {
    final Element newChild = super.inflateWidget(newWidget, newSlot);
    assert(_debugCheckHasAssociatedRenderObject(newChild));
    return newChild;
  }

  @override
  void mount(Element? parent, Object? newSlot) {
    super.mount(parent, newSlot);
    final multiChildRenderObjectWidget = widget as MultiChildRenderObjectWidget;
    final children = List<Element>.filled(
      multiChildRenderObjectWidget.children.length,
      _NullElement.instance,
    );
    Element? previousChild;
    for (var i = 0; i < children.length; i += 1) {
      final Element newChild = inflateWidget(
        multiChildRenderObjectWidget.children[i],
        IndexedSlot<Element?>(i, previousChild),
      );
      children[i] = newChild;
      previousChild = newChild;
    }
    _children = children;
  }

  @override
  void update(MultiChildRenderObjectWidget newWidget) {
    super.update(newWidget);
    final multiChildRenderObjectWidget = widget as MultiChildRenderObjectWidget;
    assert(widget == newWidget);
    assert(!debugChildrenHaveDuplicateKeys(widget, multiChildRenderObjectWidget.children));
    _children = updateChildren(
      _children,
      multiChildRenderObjectWidget.children,
      forgottenChildren: _forgottenChildren,
    );
    _forgottenChildren.clear();
  }
}

/// A [RenderObjectElement] used to manage the root of a render tree.
///
/// Unlike any other render object element this element does not attempt to
/// attach its [renderObject] to the closest ancestor [RenderObjectElement].
/// Instead, subclasses must override [attachRenderObject] and
/// [detachRenderObject] to attach/detach the [renderObject] to whatever
/// instance manages the render tree (e.g. by assigning it to
/// [PipelineOwner.rootNode]).
abstract class RenderTreeRootElement extends RenderObjectElement {
  /// Creates an element that uses the given widget as its configuration.
  RenderTreeRootElement(super.widget);

  @override
  @mustCallSuper
  void attachRenderObject(Object? newSlot) {
    _slot = newSlot;
    assert(_debugCheckMustNotAttachRenderObjectToAncestor());
  }

  @override
  @mustCallSuper
  void detachRenderObject() {
    _slot = null;
  }

  @override
  void updateSlot(Object? newSlot) {
    super.updateSlot(newSlot);
    assert(_debugCheckMustNotAttachRenderObjectToAncestor());
  }

  bool _debugCheckMustNotAttachRenderObjectToAncestor() {
    if (!kDebugMode) {
      return true;
    }
    if (_findAncestorRenderObjectElement() != null) {
      throw FlutterError.fromParts(<DiagnosticsNode>[
        ErrorSummary(
          'The RenderObject for ${toStringShort()} cannot maintain an independent render tree at its current location.',
        ),
        ErrorDescription(
          'The ownership chain for the RenderObject in question was:\n  ${debugGetCreatorChain(10)}',
        ),
        ErrorDescription(
          'This RenderObject is the root of an independent render tree and it cannot '
          'attach itself to an ancestor in an existing tree. The ancestor RenderObject, '
          'however, expects that a child will be attached.',
        ),
        ErrorHint(
          'Try moving the subtree that contains the ${toStringShort()} widget '
          'to a location where it is not expected to attach its RenderObject '
          'to a parent. This could mean moving the subtree into the view '
          'property of a "ViewAnchor" widget or - if the subtree is the root of '
          'your widget tree - passing it to "runWidget" instead of "runApp".',
        ),
        ErrorHint(
          'If you are seeing this error in a test and the subtree containing '
          'the ${toStringShort()} widget is passed to "WidgetTester.pumpWidget", '
          'consider setting the "wrapWithView" parameter of that method to false.',
        ),
      ]);
    }
    return true;
  }
}

/// A wrapper class for the [Element] that is the creator of a [RenderObject].
///
/// Setting a [DebugCreator] as [RenderObject.debugCreator] will lead to better
/// error messages.
class DebugCreator {
  /// Create a [DebugCreator] instance with input [Element].
  DebugCreator(this.element);

  /// The creator of the [RenderObject].
  final Element element;

  @override
  String toString() => element.debugGetCreatorChain(12);
}

FlutterErrorDetails _reportException(
  DiagnosticsNode context,
  Object exception,
  StackTrace? stack, {
  InformationCollector? informationCollector,
}) {
  final details = FlutterErrorDetails(
    exception: exception,
    stack: stack,
    library: 'widgets library',
    context: context,
    informationCollector: informationCollector,
  );
  FlutterError.reportError(details);
  return details;
}

/// A value for [Element.slot] used for children of
/// [MultiChildRenderObjectElement]s.
///
/// A slot for a [MultiChildRenderObjectElement] consists of an [index]
/// identifying where the child occupying this slot is located in the
/// [MultiChildRenderObjectElement]'s child list and an arbitrary [value] that
/// can further define where the child occupying this slot fits in its
/// parent's child list.
///
/// See also:
///
///  * [RenderObjectElement.updateChildren], which discusses why this class is
///    used as slot values for the children of a [MultiChildRenderObjectElement].
@immutable
class IndexedSlot<T extends Element?> {
  /// Creates an [IndexedSlot] with the provided [index] and slot [value].
  const IndexedSlot(this.index, this.value);

  /// Information to define where the child occupying this slot fits in its
  /// parent's child list.
  final T value;

  /// The index of this slot in the parent's child list.
  final int index;

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is IndexedSlot && index == other.index && value == other.value;
  }

  @override
  int get hashCode => Object.hash(index, value);
}

/// Used as a placeholder in [List<Element>] objects when the actual
/// elements are not yet determined.
class _NullElement extends Element {
  _NullElement() : super(const _NullWidget());

  static _NullElement instance = _NullElement();

  @override
  bool get debugDoingBuild => throw UnimplementedError();
}

class _NullWidget extends Widget {
  const _NullWidget();

  @override
  Element createElement() => throw UnimplementedError();
}
```

// ============================================================
// 📁 Project: deprecated.dart
// 📁 /home/user/flutter/packages/flutter_test/lib/src/deprecated.dart
// ============================================================

```dart
// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// @docImport 'test_default_binary_messenger.dart';
library;

import 'package:flutter/services.dart';

import 'binding.dart';

/// Shim to support the obsolete [setMockMessageHandler] and
/// [checkMockMessageHandler] methods on [BinaryMessenger] in tests.
///
/// The implementations defer to [TestDefaultBinaryMessengerBinding.defaultBinaryMessenger].
///
/// Rather than calling [setMockMessageHandler] on the
/// `ServicesBinding.defaultBinaryMessenger`, use
/// `tester.binding.defaultBinaryMessenger.setMockMessageHandler` directly. This
/// more accurately represents the actual method invocation.
extension TestBinaryMessengerExtension on BinaryMessenger {
  /// Shim for [TestDefaultBinaryMessenger.setMockMessageHandler].
  @Deprecated(
    'Use tester.binding.defaultBinaryMessenger.setMockMessageHandler or '
    'TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMessageHandler instead. '
    'For the first argument, pass channel.name. '
    'This feature was deprecated after v3.9.0-19.0.pre.',
  )
  void setMockMessageHandler(String channel, MessageHandler? handler) {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMessageHandler(
      channel,
      handler,
    );
  }

  /// Shim for [TestDefaultBinaryMessenger.checkMockMessageHandler].
  @Deprecated(
    'Use tester.binding.defaultBinaryMessenger.checkMockMessageHandler or '
    'TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.checkMockMessageHandler instead. '
    'For the first argument, pass channel.name. '
    'This feature was deprecated after v3.9.0-19.0.pre.',
  )
  bool checkMockMessageHandler(String channel, Object? handler) {
    return TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .checkMockMessageHandler(channel, handler);
  }
}

/// Shim to support the obsolete [setMockMessageHandler] and
/// [checkMockMessageHandler] methods on [BasicMessageChannel] in tests.
///
/// The implementations defer to [TestDefaultBinaryMessengerBinding.defaultBinaryMessenger].
///
/// Rather than calling [setMockMessageHandler] on the message channel, use
/// `tester.binding.defaultBinaryMessenger.setMockDecodedMessageHandler`
/// directly. This more accurately represents the actual method invocation.
extension TestBasicMessageChannelExtension<T> on BasicMessageChannel<T> {
  /// Shim for [TestDefaultBinaryMessenger.setMockDecodedMessageHandler].
  @Deprecated(
    'Use tester.binding.defaultBinaryMessenger.setMockDecodedMessageHandler or '
    'TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockDecodedMessageHandler instead. '
    'Pass the channel as the first argument. '
    'This feature was deprecated after v3.9.0-19.0.pre.',
  )
  void setMockMessageHandler(Future<T> Function(T? message)? handler) {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockDecodedMessageHandler<T>(this, handler);
  }

  /// Shim for [TestDefaultBinaryMessenger.checkMockMessageHandler].
  @Deprecated(
    'Use tester.binding.defaultBinaryMessenger.checkMockMessageHandler or '
    'TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.checkMockMessageHandler instead. '
    'For the first argument, pass channel.name. '
    'This feature was deprecated after v3.9.0-19.0.pre.',
  )
  bool checkMockMessageHandler(Object? handler) {
    return TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .checkMockMessageHandler(name, handler);
  }
}

/// Shim to support the obsolete [setMockMethodCallHandler] and
/// [checkMockMethodCallHandler] methods on [MethodChannel] in tests.
///
/// The implementations defer to [TestDefaultBinaryMessengerBinding.defaultBinaryMessenger].
///
/// Rather than calling [setMockMethodCallHandler] on the method channel, use
/// `tester.binding.defaultBinaryMessenger.setMockMethodCallHandler` directly.
/// This more accurately represents the actual method invocation.
extension TestMethodChannelExtension on MethodChannel {
  /// Shim for [TestDefaultBinaryMessenger.setMockMethodCallHandler].
  @Deprecated(
    'Use tester.binding.defaultBinaryMessenger.setMockMethodCallHandler or '
    'TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler instead. '
    'Pass the channel as the first argument. '
    'This feature was deprecated after v3.9.0-19.0.pre.',
  )
  void setMockMethodCallHandler(Future<dynamic>? Function(MethodCall call)? handler) {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      this,
      handler,
    );
  }

  /// Shim for [TestDefaultBinaryMessenger.checkMockMessageHandler].
  @Deprecated(
    'Use tester.binding.defaultBinaryMessenger.checkMockMessageHandler or '
    'TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.checkMockMessageHandler instead. '
    'For the first argument, pass channel.name. '
    'This feature was deprecated after v3.9.0-19.0.pre.',
  )
  bool checkMockMethodCallHandler(Object? handler) {
    return TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .checkMockMessageHandler(name, handler);
  }
}
```

// ============================================================
// 📦 Package: iterable_extensions.dart
// 📁 /home/user/.pub-cache/hosted/pub.dev/collection-1.19.1/lib/src/iterable_extensions.dart
// ============================================================

```dart
// Copyright (c) 2020, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:math' show Random;

import 'algorithms.dart';
import 'functions.dart' as functions;
import 'utils.dart';

/// Extensions that apply to all iterables.
///
/// These extensions provide direct access to some of the
/// algorithms expose by this package,
/// as well as some generally useful convenience methods.
///
/// More specialized extension methods that only apply to
/// iterables with specific element types include those of
/// [IterableComparableExtension] and [IterableNullableExtension].
extension IterableExtension<T> on Iterable<T> {
  /// Selects [count] elements at random from this iterable.
  ///
  /// The returned list contains [count] different elements of the iterable.
  /// If the iterable contains fewer that [count] elements,
  /// the result will contain all of them, but will be shorter than [count].
  /// If the same value occurs more than once in the iterable,
  /// it can also occur more than once in the chosen elements.
  ///
  /// Each element of the iterable has the same chance of being chosen.
  /// The chosen elements are not in any specific order.
  List<T> sample(int count, [Random? random]) {
    RangeError.checkNotNegative(count, 'count');
    var iterator = this.iterator;
    var chosen = <T>[];
    random ??= Random();
    while (chosen.length < count) {
      if (iterator.moveNext()) {
        var nextElement = iterator.current;
        var position = random.nextInt(chosen.length + 1);
        if (position == chosen.length) {
          chosen.add(nextElement);
        } else {
          chosen.add(chosen[position]);
          chosen[position] = nextElement;
        }
      } else {
        return chosen;
      }
    }
    var index = count;
    while (iterator.moveNext()) {
      index++;
      var position = random.nextInt(index);
      if (position < count) chosen[position] = iterator.current;
    }
    return chosen;
  }

  /// The elements that do not satisfy [test].
  Iterable<T> whereNot(bool Function(T element) test) =>
      where((element) => !test(element));

  /// Creates a sorted list of the elements of the iterable.
  ///
  /// The elements are ordered by the [compare] [Comparator].
  List<T> sorted(Comparator<T> compare) => [...this]..sort(compare);

  /// Creates a shuffled list of the elements of the iterable.
  List<T> shuffled([Random? random]) => [...this]..shuffle(random);

  /// Creates a sorted list of the elements of the iterable.
  ///
  /// The elements are ordered by the natural ordering of the
  /// property [keyOf] of the element.
  List<T> sortedBy<K extends Comparable<K>>(K Function(T element) keyOf) {
    var elements = [...this];
    mergeSortBy<T, K>(elements, keyOf, compareComparable);
    return elements;
  }

  /// Creates a sorted list of the elements of the iterable.
  ///
  /// The elements are ordered by the [compare] [Comparator] of the
  /// property [keyOf] of the element.
  List<T> sortedByCompare<K>(
      K Function(T element) keyOf, Comparator<K> compare) {
    var elements = [...this];
    mergeSortBy<T, K>(elements, keyOf, compare);
    return elements;
  }

  /// Whether the elements are sorted by the [compare] ordering.
  ///
  /// Compares pairs of elements using `compare` to check that
  /// the elements of this iterable to check
  /// that earlier elements always compare
  /// smaller than or equal to later elements.
  ///
  /// An single-element or empty iterable is trivially in sorted order.
  bool isSorted(Comparator<T> compare) {
    var iterator = this.iterator;
    if (!iterator.moveNext()) return true;
    var previousElement = iterator.current;
    while (iterator.moveNext()) {
      var element = iterator.current;
      if (compare(previousElement, element) > 0) return false;
      previousElement = element;
    }
    return true;
  }

  /// Whether the elements are sorted by their [keyOf] property.
  ///
  /// Applies [keyOf] to each element in iteration order,
  /// then checks whether the results are in non-decreasing [Comparable] order.
  bool isSortedBy<K extends Comparable<K>>(K Function(T element) keyOf) {
    var iterator = this.iterator;
    if (!iterator.moveNext()) return true;
    var previousKey = keyOf(iterator.current);
    while (iterator.moveNext()) {
      var key = keyOf(iterator.current);
      if (previousKey.compareTo(key) > 0) return false;
      previousKey = key;
    }
    return true;
  }

  /// Whether the elements are [compare]-sorted by their [keyOf] property.
  ///
  /// Applies [keyOf] to each element in iteration order,
  /// then checks whether the results are in non-decreasing order
  /// using the [compare] [Comparator]..
  bool isSortedByCompare<K>(
      K Function(T element) keyOf, Comparator<K> compare) {
    var iterator = this.iterator;
    if (!iterator.moveNext()) return true;
    var previousKey = keyOf(iterator.current);
    while (iterator.moveNext()) {
      var key = keyOf(iterator.current);
      if (compare(previousKey, key) > 0) return false;
      previousKey = key;
    }
    return true;
  }

  /// Takes an action for each element.
  ///
  /// Calls [action] for each element along with the index in the
  /// iteration order.
  void forEachIndexed(void Function(int index, T element) action) {
    var index = 0;
    for (var element in this) {
      action(index++, element);
    }
  }

  /// Takes an action for each element as long as desired.
  ///
  /// Calls [action] for each element.
  /// Stops iteration if [action] returns `false`.
  void forEachWhile(bool Function(T element) action) {
    for (var element in this) {
      if (!action(element)) break;
    }
  }

  /// Takes an action for each element and index as long as desired.
  ///
  /// Calls [action] for each element along with the index in the
  /// iteration order.
  /// Stops iteration if [action] returns `false`.
  void forEachIndexedWhile(bool Function(int index, T element) action) {
    var index = 0;
    for (var element in this) {
      if (!action(index++, element)) break;
    }
  }

  /// Maps each element and its index to a new value.
  Iterable<R> mapIndexed<R>(R Function(int index, T element) convert) sync* {
    var index = 0;
    for (var element in this) {
      yield convert(index++, element);
    }
  }

  /// The elements whose value and index satisfies [test].
  Iterable<T> whereIndexed(bool Function(int index, T element) test) sync* {
    var index = 0;
    for (var element in this) {
      if (test(index++, element)) yield element;
    }
  }

  /// The elements whose value and index do not satisfy [test].
  Iterable<T> whereNotIndexed(bool Function(int index, T element) test) sync* {
    var index = 0;
    for (var element in this) {
      if (!test(index++, element)) yield element;
    }
  }

  /// Expands each element and index to a number of elements in a new iterable.
  Iterable<R> expandIndexed<R>(
      Iterable<R> Function(int index, T element) expand) sync* {
    var index = 0;
    for (var element in this) {
      yield* expand(index++, element);
    }
  }

  /// Combine the elements with each other and the current index.
  ///
  /// Calls [combine] for each element except the first.
  /// The call passes the index of the current element, the result of the
  /// previous call, or the first element for the first call, and
  /// the current element.
  ///
  /// Returns the result of the last call, or the first element if
  /// there is only one element.
  /// There must be at least one element.
  T reduceIndexed(T Function(int index, T previous, T element) combine) {
    var iterator = this.iterator;
    if (!iterator.moveNext()) {
      throw StateError('no elements');
    }
    var index = 1;
    var result = iterator.current;
    while (iterator.moveNext()) {
      result = combine(index++, result, iterator.current);
    }
    return result;
  }

  /// Combine the elements with a value and the current index.
  ///
  /// Calls [combine] for each element with the current index,
  /// the result of the previous call, or [initialValue] for the first element,
  /// and the current element.
  ///
  /// Returns the result of the last call to [combine],
  /// or [initialValue] if there are no elements.
  R foldIndexed<R>(
      R initialValue, R Function(int index, R previous, T element) combine) {
    var result = initialValue;
    var index = 0;
    for (var element in this) {
      result = combine(index++, result, element);
    }
    return result;
  }

  /// The first element satisfying [test], or `null` if there are none.
  T? firstWhereOrNull(bool Function(T element) test) {
    for (var element in this) {
      if (test(element)) return element;
    }
    return null;
  }

  /// The first element whose value and index satisfies [test].
  ///
  /// Returns `null` if there are no element and index satisfying [test].
  T? firstWhereIndexedOrNull(bool Function(int index, T element) test) {
    var index = 0;
    for (var element in this) {
      if (test(index++, element)) return element;
    }
    return null;
  }

  /// The first element, or `null` if the iterable is empty.
  T? get firstOrNull {
    var iterator = this.iterator;
    if (iterator.moveNext()) return iterator.current;
    return null;
  }

  /// The last element satisfying [test], or `null` if there are none.
  T? lastWhereOrNull(bool Function(T element) test) {
    T? result;
    for (var element in this) {
      if (test(element)) result = element;
    }
    return result;
  }

  /// The last element whose index and value satisfies [test].
  ///
  /// Returns `null` if no element and index satisfies [test].
  T? lastWhereIndexedOrNull(bool Function(int index, T element) test) {
    T? result;
    var index = 0;
    for (var element in this) {
      if (test(index++, element)) result = element;
    }
    return result;
  }

  /// The last element, or `null` if the iterable is empty.
  T? get lastOrNull {
    if (isEmpty) return null;
    return last;
  }

  /// The single element satisfying [test].
  ///
  /// Returns `null` if there are either no elements
  /// or more than one element satisfying [test].
  ///
  /// **Notice**: This behavior differs from [Iterable.singleWhere]
  /// which always throws if there are more than one match,
  /// and only calls the `orElse` function on zero matches.
  T? singleWhereOrNull(bool Function(T element) test) {
    T? result;
    var found = false;
    for (var element in this) {
      if (test(element)) {
        if (!found) {
          result = element;
          found = true;
        } else {
          return null;
        }
      }
    }
    return result;
  }

  /// The single element satisfying [test].
  ///
  /// Returns `null` if there are either none
  /// or more than one element and index satisfying [test].
  T? singleWhereIndexedOrNull(bool Function(int index, T element) test) {
    T? result;
    var found = false;
    var index = 0;
    for (var element in this) {
      if (test(index++, element)) {
        if (!found) {
          result = element;
          found = true;
        } else {
          return null;
        }
      }
    }
    return result;
  }

  /// The single element of the iterable, or `null`.
  ///
  /// The value is `null` if the iterable is empty
  /// or it contains more than one element.
  T? get singleOrNull {
    var iterator = this.iterator;
    if (iterator.moveNext()) {
      var result = iterator.current;
      if (!iterator.moveNext()) {
        return result;
      }
    }
    return null;
  }

  /// The [index]th element, or `null` if there is no such element.
  ///
  /// Returns the element at position [index] of this iterable,
  /// just like [elementAt], if this iterable has such an element.
  /// If this iterable does not have enough elements to have one with the given
  /// [index], the `null` value is returned, unlike [elementAt] which throws
  /// instead.
  ///
  /// The [index] must not be negative.
  T? elementAtOrNull(int index) => skip(index).firstOrNull;

  /// Associates the elements in `this` by the value returned by [key].
  ///
  /// Returns a map from keys computed by [key] to the last value for which
  /// [key] returns that key.
  Map<K, T> lastBy<K>(K Function(T) key) => functions.lastBy(this, key);

  /// Groups elements by [keyOf] then folds the elements in each group.
  ///
  /// A key is found for each element using [keyOf].
  /// Then the elements with the same key are all folded using [combine].
  /// The first call to [combine] for a particular key receives `null` as
  /// the previous value, the remaining ones receive the result of the previous
  /// call.
  ///
  /// Can be used to _group_ elements into arbitrary collections.
  /// For example [groupSetsBy] could be written as:
  /// ```dart
  /// iterable.groupFoldBy(keyOf,
  ///     (Set<T>? previous, T element) => (previous ?? <T>{})..add(element));
  /// ````
  Map<K, G> groupFoldBy<K, G>(
      K Function(T element) keyOf, G Function(G? previous, T element) combine) {
    var result = <K, G>{};
    for (var element in this) {
      var key = keyOf(element);
      result[key] = combine(result[key], element);
    }
    return result;
  }

  /// Groups elements into sets by [keyOf].
  Map<K, Set<T>> groupSetsBy<K>(K Function(T element) keyOf) {
    var result = <K, Set<T>>{};
    for (var element in this) {
      (result[keyOf(element)] ??= <T>{}).add(element);
    }
    return result;
  }

  /// Groups elements into lists by [keyOf].
  Map<K, List<T>> groupListsBy<K>(K Function(T element) keyOf) {
    var result = <K, List<T>>{};
    for (var element in this) {
      (result[keyOf(element)] ??= []).add(element);
    }
    return result;
  }

  /// Splits the elements into chunks before some elements.
  ///
  /// Each element except the first is checked using [test]
  /// for whether it should be the first element in a new chunk.
  /// If so, the elements since the previous chunk-starting element
  /// are emitted as a list.
  /// Any remaining elements are emitted at the end.
  ///
  /// Example:
  /// Example:
  /// ```dart
  /// var parts = [1, 0, 2, 1, 5, 7, 6, 8, 9].splitBefore(isPrime);
  /// print(parts); // ([1, 0], [2, 1], [5], [7, 6, 8, 9])
  /// ```
  Iterable<List<T>> splitBefore(bool Function(T element) test) =>
      splitBeforeIndexed((_, element) => test(element));

  /// Splits the elements into chunks after some elements.
  ///
  /// Each element is checked using [test] for whether it should end a chunk.
  /// If so, the elements following the previous chunk-ending element,
  /// including the element that satisfied [test],
  /// are emitted as a list.
  /// Any remaining elements are emitted at the end,
  /// whether the last element should be split after or not.
  ///
  /// Example:
  /// ```dart
  /// var parts = [1, 0, 2, 1, 5, 7, 6, 8, 9].splitAfter(isPrime);
  /// print(parts); // ([1, 0, 2], [1, 5], [7], [6, 8, 9])
  /// ```
  Iterable<List<T>> splitAfter(bool Function(T element) test) =>
      splitAfterIndexed((_, element) => test(element));

  /// Splits the elements into chunks between some elements.
  ///
  /// Each pair of adjacent elements are checked using [test]
  /// for whether a chunk should end between them.
  /// If so, the elements since the previous chunk-splitting elements
  /// are emitted as a list.
  /// Any remaining elements are emitted at the end.
  ///
  /// Example:
  /// ```dart
  /// var parts = [1, 0, 2, 1, 5, 7, 6, 8, 9].splitBetween((v1, v2) => v1 > v2);
  /// print(parts); // ([1], [0, 2], [1, 5, 7], [6, 8, 9])
  /// ```
  Iterable<List<T>> splitBetween(bool Function(T first, T second) test) =>
      splitBetweenIndexed((_, first, second) => test(first, second));

  /// Splits the elements into chunks before some elements and indices.
  ///
  /// Each element and index except the first is checked using [test]
  /// for whether it should start a new chunk.
  /// If so, the elements since the previous chunk-starting element
  /// are emitted as a list.
  /// Any remaining elements are emitted at the end.
  ///
  /// Example:
  /// ```dart
  /// var parts = [1, 0, 2, 1, 5, 7, 6, 8, 9]
  ///     .splitBeforeIndexed((i, v) => i < v);
  /// print(parts); // ([1], [0, 2], [1, 5, 7], [6, 8, 9])
  /// ```
  Iterable<List<T>> splitBeforeIndexed(
      bool Function(int index, T element) test) sync* {
    var iterator = this.iterator;
    if (!iterator.moveNext()) {
      return;
    }
    var index = 1;
    var chunk = [iterator.current];
    while (iterator.moveNext()) {
      var element = iterator.current;
      if (test(index++, element)) {
        yield chunk;
        chunk = [];
      }
      chunk.add(element);
    }
    yield chunk;
  }

  /// Splits the elements into chunks after some elements and indices.
  ///
  /// Each element and index is checked using [test]
  /// for whether it should end the current chunk.
  /// If so, the elements since the previous chunk-ending element,
  /// including the element that satisfied [test],
  /// are emitted as a list.
  /// Any remaining elements are emitted at the end, whether the last
  /// element should be split after or not.
  ///
  /// Example:
  /// ```dart
  /// var parts = [1, 0, 2, 1, 5, 7, 6, 8, 9]
  ///   .splitAfterIndexed((i, v) => i < v);
  /// print(parts); // ([1, 0], [2, 1], [5, 7, 6], [8, 9])
  /// ```
  Iterable<List<T>> splitAfterIndexed(
      bool Function(int index, T element) test) sync* {
    var index = 0;
    List<T>? chunk;
    for (var element in this) {
      (chunk ??= []).add(element);
      if (test(index++, element)) {
        yield chunk;
        chunk = null;
      }
    }
    if (chunk != null) yield chunk;
  }

  /// Splits the elements into chunks between some elements and indices.
  ///
  /// Each pair of adjacent elements and the index of the latter are
  /// checked using [test] for whether a chunk should end between them.
  /// If so, the elements since the previous chunk-splitting elements
  /// are emitted as a list.
  /// Any remaining elements are emitted at the end.
  ///
  /// Example:
  /// ```dart
  /// var parts = [1, 0, 2, 1, 5, 7, 6, 8, 9]
  ///    .splitBetweenIndexed((i, v1, v2) => v1 > v2);
  /// print(parts); // ([1], [0, 2], [1, 5, 7], [6, 8, 9])
  /// ```
  Iterable<List<T>> splitBetweenIndexed(
      bool Function(int index, T first, T second) test) sync* {
    var iterator = this.iterator;
    if (!iterator.moveNext()) return;
    var previous = iterator.current;
    var chunk = <T>[previous];
    var index = 1;
    while (iterator.moveNext()) {
      var element = iterator.current;
      if (test(index++, previous, element)) {
        yield chunk;
        chunk = [];
      }
      chunk.add(element);
      previous = element;
    }
    yield chunk;
  }

  /// Whether no element satisfies [test].
  ///
  /// Returns true if no element satisfies [test],
  /// and false if at least one does.
  ///
  /// Equivalent to `iterable.every((x) => !test(x))` or
  /// `!iterable.any(test)`.
  bool none(bool Function(T) test) {
    for (var element in this) {
      if (test(element)) return false;
    }
    return true;
  }

  /// Contiguous slices of `this` with the given [length].
  ///
  /// Each slice is [length] elements long, except for the last one which may be
  /// shorter if `this` contains too few elements. Each slice begins after the
  /// last one ends. The [length] must be greater than zero.
  ///
  /// For example, `{1, 2, 3, 4, 5}.slices(2)` returns `([1, 2], [3, 4], [5])`.
  Iterable<List<T>> slices(int length) sync* {
    if (length < 1) throw RangeError.range(length, 1, null, 'length');

    var iterator = this.iterator;
    while (iterator.moveNext()) {
      var slice = [iterator.current];
      for (var i = 1; i < length && iterator.moveNext(); i++) {
        slice.add(iterator.current);
      }
      yield slice;
    }
  }
}

/// Extensions that apply to iterables with a nullable element type.
extension IterableNullableExtension<T extends Object> on Iterable<T?> {
  /// The non-`null` elements of this `Iterable`.
  ///
  /// Returns an iterable which emits all the non-`null` elements
  /// of this iterable, in their original iteration order.
  ///
  /// For an `Iterable<X?>`, this method is equivalent to `.whereType<X>()`.
  @Deprecated('Use .nonNulls instead.')
  Iterable<T> whereNotNull() sync* {
    for (var element in this) {
      if (element != null) yield element;
    }
  }
}

/// Extensions that apply to iterables of numbers.
///
/// Specialized version of some extensions of [IterableComparableExtension]
/// since doubles require special handling of [double.nan].
extension IterableNumberExtension on Iterable<num> {
  /// A minimal element of the iterable, or `null` it the iterable is empty.
  ///
  /// If any element is [NaN](double.nan), the result is NaN.
  num? get minOrNull {
    var iterator = this.iterator;
    if (iterator.moveNext()) {
      var value = iterator.current;
      if (value.isNaN) {
        return value;
      }
      while (iterator.moveNext()) {
        var newValue = iterator.current;
        if (newValue.isNaN) {
          return newValue;
        }
        if (newValue < value) {
          value = newValue;
        }
      }
      return value;
    }
    return null;
  }

  /// A minimal element of the iterable.
  ///
  /// If any element is [NaN](double.nan), the result is NaN.
  ///
  /// The iterable must not be empty.
  num get min => minOrNull ?? (throw StateError('No element'));

  /// A maximal element of the iterable, or `null` if the iterable is empty.
  ///
  /// If any element is [NaN](double.nan), the result is NaN.
  num? get maxOrNull {
    var iterator = this.iterator;
    if (iterator.moveNext()) {
      var value = iterator.current;
      if (value.isNaN) {
        return value;
      }
      while (iterator.moveNext()) {
        var newValue = iterator.current;
        if (newValue.isNaN) {
          return newValue;
        }
        if (newValue > value) {
          value = newValue;
        }
      }
      return value;
    }
    return null;
  }

  /// A maximal element of the iterable.
  ///
  /// If any element is [NaN](double.nan), the result is NaN.
  ///
  /// The iterable must not be empty.
  num get max => maxOrNull ?? (throw StateError('No element'));

  /// The sum of the elements.
  ///
  /// The sum is zero if the iterable is empty.
  num get sum {
    num result = 0;
    for (var value in this) {
      result += value;
    }
    return result;
  }

  /// The arithmetic mean of the elements of a non-empty iterable.
  ///
  /// The arithmetic mean is the sum of the elements
  /// divided by the number of elements.
  ///
  /// The iterable must not be empty.
  double get average {
    var result = 0.0;
    var count = 0;
    for (var value in this) {
      count += 1;
      result += (value - result) / count;
    }
    if (count == 0) throw StateError('No elements');
    return result;
  }
}

/// Extension on iterables of integers.
///
/// Specialized version of some extensions of [IterableNumberExtension] or
/// [IterableComparableExtension] since integers are only `Comparable<num>`.
extension IterableIntegerExtension on Iterable<int> {
  /// A minimal element of the iterable, or `null` it the iterable is empty.
  int? get minOrNull {
    var iterator = this.iterator;
    if (iterator.moveNext()) {
      var value = iterator.current;
      while (iterator.moveNext()) {
        var newValue = iterator.current;
        if (newValue < value) {
          value = newValue;
        }
      }
      return value;
    }
    return null;
  }

  /// A minimal element of the iterable.
  ///
  /// The iterable must not be empty.
  int get min => minOrNull ?? (throw StateError('No element'));

  /// A maximal element of the iterable, or `null` if the iterable is empty.
  int? get maxOrNull {
    var iterator = this.iterator;
    if (iterator.moveNext()) {
      var value = iterator.current;
      while (iterator.moveNext()) {
        var newValue = iterator.current;
        if (newValue > value) {
          value = newValue;
        }
      }
      return value;
    }
    return null;
  }

  /// A maximal element of the iterable.
  ///
  /// The iterable must not be empty.
  int get max => maxOrNull ?? (throw StateError('No element'));

  /// The sum of the elements.
  ///
  /// The sum is zero if the iterable is empty.
  int get sum {
    var result = 0;
    for (var value in this) {
      result += value;
    }
    return result;
  }

  /// The arithmetic mean of the elements of a non-empty iterable.
  ///
  /// The arithmetic mean is the sum of the elements
  /// divided by the number of elements.
  /// This method is specialized for integers,
  /// and may give a different result than [IterableNumberExtension.average]
  /// for the same values, because the the number algorithm
  /// converts all numbers to doubles.
  ///
  /// The iterable must not be empty.
  double get average {
    var average = 0;
    var remainder = 0;
    var count = 0;
    for (var value in this) {
      // Invariant: Sum of values so far = average * count + remainder.
      // (Unless overflow has occurred).
      count += 1;
      var delta = value - average + remainder;
      average += delta ~/ count;
      remainder = delta.remainder(count);
    }
    if (count == 0) throw StateError('No elements');
    return average + remainder / count;
  }
}

/// Extension on iterables of double.
///
/// Specialized version of some extensions of [IterableNumberExtension] or
/// [IterableComparableExtension] since doubles are only `Comparable<num>`.
extension IterableDoubleExtension on Iterable<double> {
  /// A minimal element of the iterable, or `null` it the iterable is empty.
  ///
  /// If any element is [NaN](double.nan), the result is NaN.
  double? get minOrNull {
    var iterator = this.iterator;
    if (iterator.moveNext()) {
      var value = iterator.current;
      if (value.isNaN) {
        return value;
      }
      while (iterator.moveNext()) {
        var newValue = iterator.current;
        if (newValue.isNaN) {
          return newValue;
        }
        if (newValue < value) {
          value = newValue;
        }
      }
      return value;
    }
    return null;
  }

  /// A minimal element of the iterable.
  ///
  /// If any element is [NaN](double.nan), the result is NaN.
  ///
  /// The iterable must not be empty.
  double get min => minOrNull ?? (throw StateError('No element'));

  /// A maximal element of the iterable, or `null` if the iterable is empty.
  ///
  /// If any element is [NaN](double.nan), the result is NaN.
  double? get maxOrNull {
    var iterator = this.iterator;
    if (iterator.moveNext()) {
      var value = iterator.current;
      if (value.isNaN) {
        return value;
      }
      while (iterator.moveNext()) {
        var newValue = iterator.current;
        if (newValue.isNaN) {
          return newValue;
        }
        if (newValue > value) {
          value = newValue;
        }
      }
      return value;
    }
    return null;
  }

  /// A maximal element of the iterable.
  ///
  /// If any element is [NaN](double.nan), the result is NaN.
  ///
  /// The iterable must not be empty.
  double get max => maxOrNull ?? (throw StateError('No element'));

  /// The sum of the elements.
  ///
  /// The sum is zero if the iterable is empty.
  double get sum {
    var result = 0.0;
    for (var value in this) {
      result += value;
    }
    return result;
  }
}

/// Extensions on iterables whose elements are also iterables.
extension IterableIterableExtension<T> on Iterable<Iterable<T>> {
  /// The sequential elements of each iterable in this iterable.
  ///
  /// Iterates the elements of this iterable.
  /// For each one, which is itself an iterable,
  /// all the elements of that are emitted
  /// on the returned iterable, before moving on to the next element.
  Iterable<T> get flattened sync* {
    for (var elements in this) {
      yield* elements;
    }
  }

  /// The sequential elements of each iterable in this iterable.
  ///
  /// Iterates the elements of this iterable.
  /// For each one, which is itself an iterable,
  /// all the elements of that are added
  /// to the returned list, before moving on to the next element.
  List<T> get flattenedToList => [
        for (final elements in this) ...elements,
      ];

  /// The unique sequential elements of each iterable in this iterable.
  ///
  /// Iterates the elements of this iterable.
  /// For each one, which is itself an iterable,
  /// all the elements of that are added
  /// to the returned set, before moving on to the next element.
  Set<T> get flattenedToSet => {
        for (final elements in this) ...elements,
      };
}

/// Extensions that apply to iterables of [Comparable] elements.
///
/// These operations can assume that the elements have a natural ordering,
/// and can therefore omit, or make it optional, for the user to provide
/// a [Comparator].
extension IterableComparableExtension<T extends Comparable<T>> on Iterable<T> {
  /// A minimal element of the iterable, or `null` it the iterable is empty.
  T? get minOrNull {
    var iterator = this.iterator;
    if (iterator.moveNext()) {
      var value = iterator.current;
      while (iterator.moveNext()) {
        var newValue = iterator.current;
        if (value.compareTo(newValue) > 0) {
          value = newValue;
        }
      }
      return value;
    }
    return null;
  }

  /// A minimal element of the iterable.
  ///
  /// The iterable must not be empty.
  T get min => minOrNull ?? (throw StateError('No element'));

  /// A maximal element of the iterable, or `null` if the iterable is empty.
  T? get maxOrNull {
    var iterator = this.iterator;
    if (iterator.moveNext()) {
      var value = iterator.current;
      while (iterator.moveNext()) {
        var newValue = iterator.current;
        if (value.compareTo(newValue) < 0) {
          value = newValue;
        }
      }
      return value;
    }
    return null;
  }

  /// A maximal element of the iterable.
  ///
  /// The iterable must not be empty.
  T get max => maxOrNull ?? (throw StateError('No element'));

  /// Creates a sorted list of the elements of the iterable.
  ///
  /// If the [compare] function is not supplied, the sorting uses the
  /// natural [Comparable] ordering of the elements.
  List<T> sorted([Comparator<T>? compare]) => [...this]..sort(compare);

  /// Whether the elements are sorted by the [compare] ordering.
  ///
  /// If [compare] is omitted, it defaults to comparing the
  /// elements using their natural [Comparable] ordering.
  bool isSorted([Comparator<T>? compare]) {
    if (compare != null) {
      return IterableExtension(this).isSorted(compare);
    }
    var iterator = this.iterator;
    if (!iterator.moveNext()) return true;
    var previousElement = iterator.current;
    while (iterator.moveNext()) {
      var element = iterator.current;
      if (previousElement.compareTo(element) > 0) return false;
      previousElement = element;
    }
    return true;
  }
}

/// Extensions on comparator functions.
extension ComparatorExtension<T> on Comparator<T> {
  /// The inverse ordering of this comparator.
  Comparator<T> get inverse => (T a, T b) => this(b, a);

  /// Makes a comparator on [R] values using this comparator.
  ///
  /// Compares [R] values by comparing their [keyOf] value
  /// using this comparator.
  Comparator<R> compareBy<R>(T Function(R) keyOf) =>
      (R a, R b) => this(keyOf(a), keyOf(b));

  /// Combine comparators sequentially.
  ///
  /// Creates a comparator which orders elements the same way as
  /// this comparator, except that when two elements are considered
  /// equal, the [tieBreaker] comparator is used instead.
  Comparator<T> then(Comparator<T> tieBreaker) => (T a, T b) {
        var result = this(a, b);
        if (result == 0) result = tieBreaker(a, b);
        return result;
      };
}
```

// ============================================================
// 📦 Package: consumer.dart
// 📁 /home/user/.pub-cache/hosted/pub.dev/flutter_riverpod-3.3.2/lib/src/core/consumer.dart
// ============================================================

```dart
part of '../core.dart';

/// A function that can also listen to providers
///
/// See also [Consumer]
@internal
typedef ConsumerBuilder =
    Widget Function(BuildContext context, WidgetRef ref, Widget? child);

/// {@template riverpod.consumer}
/// Build a widget tree while listening to providers.
///
/// [Consumer]'s main use-case is for reducing the number of rebuilt widgets.
/// when a provider changes.
///
/// As an example, consider:
///
/// ```dart
/// @riverpod
/// Future<User> fetchUser(Ref ref) async {
///   // ...
/// }
/// ```
///
/// Normally, we would use a [ConsumerWidget] as followed:
///
/// ```dart
/// class Example extends ConsumerWidget {
///   @override
///   Widget build(BuildContext context, WidgetRef ref) {
///     return Scaffold(
///      appBar: AppBar(title: Text('User')),
///      body: switch (ref.watch(userProvider) {
///        AsyncValue(:final value?) => Text(value.name),
///        AsyncValue(hasError: true) => Text('Error'),
///        _ => CircularProgressIndicator(),
///      },
///   }
/// }
/// ```
///
/// However, this would rebuild the entire `Scaffold` when the user changes.
/// If we are looking to reduce this, have two options:
/// - Extract the `body` into a separate [ConsumerWidget]. Then only the `body` will rebuild.
///   This is the recommended approach, but is a bit more verbose.
/// - Use [Consumer] to only rebuild the `body` when the user changes.
///   This is less recommended, but avoids creating a new widget.
///
/// Using [Consumer], the resulting code would look like:
/// ```dart
/// class Example extends StatelessWidget {
///   @override
///   Widget build(BuildContext context) {
///     return Scaffold(
///      appBar: AppBar(title: Text('User')),
///      body: Consumer(
///        builder: (context, ref, child) {
///          return switch (ref.watch(userProvider) {
///            AsyncValue(:final value?) => Text(value.name),
///            AsyncValue(hasError: true) => Text('Error'),
///            _ => CircularProgressIndicator(),
///          };
///        }),
///      );
///   }
/// }
/// ```
///
/// ## Performance considerations
///
/// To optimize performance by avoiding unnecessary network requests and
/// pausing unused streams, [Consumer] will temporarily stop listening to
/// providers when the widget stops being visible.
///
/// This is determined using [TickerMode.of], and will invoke
/// [ProviderSubscription.pause] on all currently active subscriptions.
///
/// See also:
///
/// - [ConsumerWidget], a base-class for widgets that wants to listen to providers.
/// - [child], a way to optimize the widget tree by passing a child widget that
///   won't rebuild when the provider changes.
/// {@endtemplate}
/// {@category Core}
final class Consumer extends ConsumerWidget {
  /// {@macro riverpod.consumer}
  const Consumer({super.key, required this.builder, this.child});

  /// The builder that will be called when the provider is updated.
  ///
  /// The `child` parameter will be the same as [child] if specified, or null otherwise.
  ///
  /// **Note**
  /// You can watch as many providers inside [Consumer] as you want to:
  /// ```dart
  /// Consumer(
  ///   builder: (context, ref, child) {
  ///     final value = ref.watch(someProvider);
  ///     final another = ref.watch(anotherProvider);
  ///     ...
  ///   },
  /// );
  /// ```
  ///
  /// See also [child].
  final ConsumerBuilder builder;

  /// The [child] parameter is an optional parameter for the sole purpose of
  /// further performance optimizations.
  ///
  /// If your `builder` function contains a subtree that does not depend on the
  /// animation, it is more efficient to build that subtree once instead of
  /// rebuilding it on every provider update.
  ///
  /// If you pass the pre-built subtree as the `child` parameter, the
  /// Consumer will pass it back to your builder function so that you
  /// can incorporate it into your build.
  ///
  /// Using this pre-built child is entirely optional, but can improve
  /// performance significantly in some cases and is therefore a good practice.
  ///
  /// This sample shows how you could use a [Consumer]
  ///
  /// ```dart
  /// final counterProvider = NotifierProvider<Counter, int>(Counter.new);
  /// class Counter extends Notifier<int> {
  ///   @override
  ///   int build() => 0;
  ///
  ///   void increment() => state++;
  /// }
  ///
  /// class MyHomePage extends ConsumerWidget {
  ///   MyHomePage({Key? key, required this.title}) : super(key: key);
  ///   final String title;
  ///
  ///   @override
  ///   Widget build(BuildContext context, WidgetRef ref) {
  ///     return Scaffold(
  ///       appBar: AppBar(
  ///         title: Text(title)
  ///       ),
  ///       body: Center(
  ///         child: Column(
  ///           mainAxisAlignment: MainAxisAlignment.center,
  ///           children: <Widget>[
  ///             Text('You have pushed the button this many times:'),
  ///             Consumer(
  ///               builder: (BuildContext context, WidgetRef ref, Widget? child) {
  ///                 // This builder will only get called when the counterProvider
  ///                 // is updated.
  ///                 final count = ref.watch(counterProvider);
  ///
  ///                 return Row(
  ///                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  ///                   children: <Widget>[
  ///                     Text('$count'),
  ///                     child!,
  ///                   ],
  ///                 );
  ///               },
  ///               // The child parameter is most helpful if the child is
  ///               // expensive to build and does not depend on the value from
  ///               // the notifier.
  ///               child: Text('Good job!'),
  ///             )
  ///           ],
  ///         ),
  ///       ),
  ///       floatingActionButton: FloatingActionButton(
  ///         child: Icon(Icons.plus_one),
  ///         onPressed: () => ref.read(counterProvider.notifier).increment(),
  ///       ),
  ///     );
  ///   }
  /// }
  /// ```
  final Widget? child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return builder(context, ref, child);
  }
}

/// {@template riverpod.consumer_widget}
/// The equivalent of a [StatelessWidget] that can listen to providers.
///
/// Using [ConsumerWidget], this allows the widget tree to listen to changes on
/// provider, so that the UI automatically updates when needed.
///
/// Do not modify any state or start any http request inside [build].
///
/// As a usage example, consider:
///
/// ```dart
/// final helloWorldProvider = Provider((_) => 'Hello world');
/// ```
///
/// We can then subclass [ConsumerWidget] to listen to `helloWorldProvider` like so:
///
/// ```dart
/// class Example extends ConsumerWidget {
///   const Example({Key? key}): super(key: key);
///
///   @override
///   Widget build(BuildContext context, WidgetRef ref) {
///     final value = ref.watch(helloWorldProvider);
///     return Text(value); // Hello world
///   }
/// }
/// ```
///
/// **Note**
/// You can watch as many providers inside [build] as you want to:
///
/// ```dart
/// @override
/// Widget build(BuildContext context, WidgetRef ref) {
///   final value = ref.watch(someProvider);
///   final another = ref.watch(anotherProvider);
///   return Text(value); // Hello world
/// }
/// ```
///
/// See also:
/// - [ConsumerStatefulWidget], for a [StatefulWidget] variant.
/// - [Consumer], to help reducing the number of rebuilt widgets without making
///   a new widget.
/// {@endtemplate}
/// {@category Core}
abstract class ConsumerWidget extends ConsumerStatefulWidget {
  /// {@macro riverpod.consumer_widget}
  const ConsumerWidget({super.key});

  /// Describes the part of the user interface represented by this widget.
  ///
  /// The framework calls this method when this widget is inserted into the tree
  /// in a given [BuildContext] and when the dependencies of this widget change
  /// (e.g., an [InheritedWidget] referenced by this widget changes). This
  /// method can potentially be called in every frame and should not have any side
  /// effects beyond building a widget.
  ///
  /// The framework replaces the subtree below this widget with the widget
  /// returned by this method, either by updating the existing subtree or by
  /// removing the subtree and inflating a new subtree, depending on whether the
  /// widget returned by this method can update the root of the existing
  /// subtree, as determined by calling [Widget.canUpdate].
  ///
  /// Typically implementations return a newly created constellation of widgets
  /// that are configured with information from this widget's constructor and
  /// from the given [BuildContext].
  ///
  /// The given [BuildContext] contains information about the location in the
  /// tree at which this widget is being built. For example, the context
  /// provides the set of inherited widgets for this location in the tree. A
  /// given widget might be built with multiple different [BuildContext]
  /// arguments over time if the widget is moved around the tree or if the
  /// widget is inserted into the tree in multiple places at once.
  ///
  /// The implementation of this method must only depend on:
  ///
  /// * the fields of the widget, which themselves must not change over time,
  ///   and
  /// * any ambient state obtained from the `context` using
  ///   [BuildContext.dependOnInheritedWidgetOfExactType].
  ///
  /// If a widget's [build] method is to depend on anything else, use a
  /// [StatefulWidget] instead.
  ///
  /// See also:
  ///
  ///  * [StatelessWidget], which contains the discussion on performance considerations.
  Widget build(BuildContext context, WidgetRef ref);

  @override
  // ignore: library_private_types_in_public_api
  _ConsumerState createState() => _ConsumerState();
}

class _ConsumerState extends ConsumerState<ConsumerWidget> {
  @override
  Widget build(BuildContext context) => widget.build(context, ref);
}

/// {@template riverpod.consumer_stateful_widget}
/// A [StatefulWidget] that has a [State] capable of reading providers.
///
/// This is used exactly like a [StatefulWidget], but with a [State] that must
/// subclass [ConsumerState] :
///
/// ```dart
/// class MyConsumer extends ConsumerStatefulWidget {
///  const MyConsumer({Key? key}): super(key: key);
///
///   @override
///   ConsumerState<MyConsumer> createState() => _MyConsumerState();
/// }
///
/// class _MyConsumerState extends ConsumerState<MyConsumer> {
///   @override
///   void initState() {
///     // All State life-cycles can be used
///     super.initState();
///   }
///
///   @override
///   Widget build(BuildContext context) {
///     // "ref" is a property of ConsumerState and can be used to read providers
///     ref.watch(someProvider);
///   }
/// }
/// ```
/// {@endtemplate}
/// {@category Core}
abstract class ConsumerStatefulWidget extends StatefulWidget {
  /// {@macro riverpod.consumer_stateful_widget}
  const ConsumerStatefulWidget({super.key});

  @override
  ConsumerState createState();

  @override
  ConsumerStatefulElement createElement() => ConsumerStatefulElement(this);
}

/// The [State] for a [ConsumerStatefulWidget].
///
/// It has all the life-cycles if a normal [State], with the only difference
/// being that it has a [ref] property.
///
/// It must be used in conjunction with a [ConsumerStatefulWidget] :
///
/// ```dart
/// class MyConsumer extends ConsumerStatefulWidget {
///  const MyConsumer({Key? key}): super(key: key);
///
///   @override
///   ConsumerState<MyConsumer> createState() => _MyConsumerState();
/// }
///
/// class _MyConsumerState extends ConsumerState<MyConsumer> {
///   @override
///   void initState() {
///     // All State life-cycles can be used
///     super.initState();
///   }
///
///   @override
///   Widget build(BuildContext context) {
///     // "ref" is a property of ConsumerState and can be used to read providers
///     ref.watch(someProvider);
///   }
/// }
/// ```
/// {@category Core}
abstract class ConsumerState<WidgetT extends ConsumerStatefulWidget>
    extends State<WidgetT> {
  /// {@macro flutter_riverpod.widget_ref}
  late final ref = context as WidgetRef;
}

/// The [Element] for a [ConsumerStatefulWidget]
@internal
base class ConsumerStatefulElement extends StatefulElement
    implements WidgetRef {
  /// The [Element] for a [ConsumerStatefulWidget]
  ConsumerStatefulElement(ConsumerStatefulWidget super.widget);

  @override
  BuildContext get context => this;

  @override
  late ProviderContainer container = ProviderScope.containerOf(
    this,
    listen: false,
  );
  var _dependencies =
      <ProviderListenable<Object?>, ProviderSubscription<Object?>>{};
  Map<ProviderListenable<Object?>, ProviderSubscription<Object?>>?
  _oldDependencies;
  final _listeners = <ProviderSubscription<Object?>>[];
  List<ProviderSubscription<Object?>>? _manualListeners;
  ValueListenable<bool>? _tickerModeNotifier;
  bool? _isActive;

  @override
  void mount(Element? parent, Object? newSlot) {
    super.mount(parent, newSlot);
    try {
      // Forcibly listen to the container, to guarantee that didChangeDependencies
      // is called when the container changes.
      ProviderScope.containerOf(this);
    } catch (e) {
      // Silence 'no scope' error. It is already reported by the container variable.
    }
  }

  @override
  void activate() {
    super.activate();
    _updateTickerModeNotifier();
  }

  void _applyTickerMode(ProviderSubscription sub) {
    if (_isActive == false) sub.pause();
  }

  void _updateTickerModeNotifier() {
    final newTickerModeNotifier = TickerMode.getNotifier(context);

    if (_tickerModeNotifier != newTickerModeNotifier) {
      _tickerModeNotifier?.removeListener(_updateTickerMode);
      newTickerModeNotifier.addListener(_updateTickerMode);
      _tickerModeNotifier = newTickerModeNotifier;
      _updateTickerMode();
    }
  }

  void _updateTickerMode() {
    final isActive = _tickerModeNotifier!.value;
    if (isActive != _isActive) {
      _isActive = isActive;
      for (final sub in _dependencies.values) {
        if (isActive) {
          sub.resume();
        } else {
          sub.pause();
        }
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final newContainer = ProviderScope.containerOf(this);
    if (container != newContainer) {
      container = newContainer;
      for (final dependency in _dependencies.values) {
        dependency.close();
      }
      _dependencies.clear();
    }
  }

  @override
  Widget build() {
    if (_tickerModeNotifier == null) {
      _updateTickerModeNotifier();
    }

    try {
      _oldDependencies = _dependencies;
      for (var i = 0; i < _listeners.length; i++) {
        _listeners[i].close();
      }
      _listeners.clear();
      _dependencies = {};
      return super.build();
    } finally {
      for (final dep in _oldDependencies!.values) {
        dep.close();
      }
      _oldDependencies = null;
    }
  }

  void _assertNotDisposed() {
    if (!context.mounted) {
      throw StateError(
        'Using "ref" when a widget is about to or has been unmounted is unsafe.\n'
        'Ref relies on BuildContext, and BuildContext is unsafe to use when the widget is deactivated.\n'
        'To safely refer to the state of providers inside State.dispose(), save the provider state in a field of your State class.',
      );
    }
  }

  @override
  StateT watch<StateT>(ProviderListenable<StateT> target) {
    _assertNotDisposed();
    return _dependencies
            .putIfAbsent(target, () {
              final oldDependency = _oldDependencies?.remove(target);

              if (oldDependency != null) {
                return oldDependency;
              }

              final sub = container.listen<StateT>(
                target,
                (_, _) => markNeedsBuild(),
              );
              _applyTickerMode(sub);
              return sub;
            })
            .readSafe()
            .valueOrProviderException
        as StateT;
  }

  @override
  void unmount() {
    /// Calling `super.unmount()` will call `dispose` on the state
    /// And [ListenManual] subscriptions should be closed after `dispose`
    super.unmount();
    _tickerModeNotifier?.removeListener(_updateTickerMode);

    for (final dependency in _dependencies.values) {
      dependency.close();
    }
    for (var i = 0; i < _listeners.length; i++) {
      _listeners[i].close();
    }
    final manualListeners = _manualListeners?.toList();
    if (manualListeners != null) {
      for (final listener in manualListeners) {
        listener.close();
      }
      _manualListeners = null;
    }
  }

  @override
  void listen<StateT>(
    ProviderListenable<StateT> provider,
    void Function(StateT? previous, StateT value) listener, {
    void Function(Object error, StackTrace stackTrace)? onError,
    bool weak = false,
  }) {
    _assertNotDisposed();
    assert(
      debugDoingBuild,
      'ref.listen can only be used within the build method of a ConsumerWidget',
    );

    // We can't implement a fireImmediately flag because we wouldn't know
    // which listen call was preserved between widget rebuild, and we wouldn't
    // want to call the listener on every rebuild.
    final sub = container.listen<StateT>(
      provider,
      listener,
      onError: onError,
      weak: weak,
    );
    _listeners.add(sub);
  }

  @override
  bool exists(ProviderBase<Object?> provider) {
    _assertNotDisposed();
    return ProviderScope.containerOf(this, listen: false).exists(provider);
  }

  @override
  StateT read<StateT>(ProviderListenable<StateT> provider) {
    _assertNotDisposed();
    return ProviderScope.containerOf(this, listen: false).read(provider);
  }

  @override
  ValueT refresh<ValueT>(Refreshable<ValueT> provider) {
    _assertNotDisposed();
    return ProviderScope.containerOf(this, listen: false).refresh(provider);
  }

  @override
  void invalidate(ProviderOrFamily provider, {bool asReload = false}) {
    _assertNotDisposed();
    container.invalidate(provider, asReload: asReload);
  }

  @override
  ProviderSubscription<ValueT> listenManual<ValueT>(
    ProviderListenable<ValueT> provider,
    void Function(ValueT? previous, ValueT next) listener, {
    void Function(Object error, StackTrace stackTrace)? onError,
    bool fireImmediately = false,
    bool weak = false,
  }) {
    _assertNotDisposed();
    final listeners = _manualListeners ??= [];

    // Reading the container using "listen:false" to guarantee that this can
    // be used inside initState.
    final container = ProviderScope.containerOf(this, listen: false);

    final sub = container.listen<ValueT>(
      provider,
      listener,
      onError: onError,
      fireImmediately: fireImmediately,
      weak: weak,
    );

    // Hook-up on onClose to avoid memory leaks.
    final previousOnClose = sub.impl.onClose;
    sub.impl.onClose = () {
      previousOnClose?.call();
      // If the subscription is closed, we remove it from the manual listeners
      // so that it doesn't leak.
      _manualListeners?.remove(sub);
    };

    listeners.add(sub);

    return sub;
  }
}
```

// ============================================================
// 📦 Package: provider_scope.dart
// 📁 /home/user/.pub-cache/hosted/pub.dev/flutter_riverpod-3.3.2/lib/src/core/provider_scope.dart
// ============================================================

```dart
// ignore_for_file: invalid_use_of_internal_member
part of '../core.dart';

/// {@template riverpod.provider_scope}
/// A widget that stores the state of providers.
///
/// All Flutter applications using Riverpod must contain a [ProviderScope] at
/// the root of their widget tree. It is done as followed:
///
/// ```dart
/// void main() {
///   runApp(
///     // Enabled Riverpod for the entire application
///     ProviderScope(
///       child: MyApp(),
///     ),
///   );
/// }
/// ```
///
/// It's optionally possible to specify `overrides` to change the behavior of
/// some providers. This can be useful for testing purposes:
///
/// ```dart
/// testWidgets('Test example', (tester) async {
///   await tester.pumpWidget(
///     ProviderScope(
///       overrides: [
///         // override the behavior of repositoryProvider to provide a fake
///         // implementation for test purposes.
///         repositoryProvider.overrideWithValue(FakeRepository()),
///       ],
///       child: MyApp(),
///     ),
///   );
/// });
/// ```
///
///
/// Similarly, it is possible to insert other [ProviderScope] anywhere inside
/// the widget tree to override the behavior of a provider for only a part of the
/// application:
///
/// ```dart
/// final themeProvider = Provider((ref) => MyTheme.light());
///
/// void main() {
///   runApp(
///     ProviderScope(
///       child: MaterialApp(
///         // Home uses the default behavior for all providers.
///         home: Home(),
///         routes: {
///           // Overrides themeProvider for the /gallery route only
///           '/gallery': (_) => ProviderScope(
///             overrides: [
///               themeProvider.overrideWithValue(MyTheme.dark()),
///             ],
///           ),
///         },
///       ),
///     ),
///   );
/// }
/// ```
///
/// See also:
/// - [ProviderContainer], a Dart-only class that allows manipulating providers
/// - [UncontrolledProviderScope], which exposes a [ProviderContainer] to the widget
///   tree without managing its life-cycles.
/// {@endtemplate}
/// {@category Core}
final class ProviderScope extends StatefulWidget {
  /// {@macro riverpod.provider_scope}
  const ProviderScope({
    super.key,
    this.overrides = const [],
    this.observers,
    this.retry,
    required this.child,
  });

  /// Read the current [ProviderContainer] for a [BuildContext].
  static ProviderContainer containerOf(
    BuildContext context, {
    bool listen = true,
  }) {
    _UncontrolledProviderScope? scope;

    if (listen) {
      scope =
          context //
              .dependOnInheritedWidgetOfExactType<_UncontrolledProviderScope>();
    } else {
      scope =
          context
                  .getElementForInheritedWidgetOfExactType<
                    _UncontrolledProviderScope
                  >()
                  ?.widget
              as _UncontrolledProviderScope?;
    }

    if (scope == null) {
      throw StateError('No ProviderScope found');
    }

    return scope.container;
  }

  /// The retry logic used by providers associated to this container.
  ///
  /// See [ProviderContainer.defaultRetry] for information about the
  /// default retry logic.
  final Retry? retry;

  /// The part of the widget tree that can use Riverpod and has overridden providers.
  final Widget child;

  /// The listeners that subscribes to changes on providers stored on this [ProviderScope].
  final List<ProviderObserver>? observers;

  /// Information on how to override a provider/family.
  ///
  /// Overrides are created using methods such as [Provider.overrideWith]/[Provider.overrideWithValue].
  ///
  /// This can be used for:
  /// - testing, by mocking a provider.
  /// - dependency injection, to avoid having to pass a value to many
  ///   widgets in the widget tree.
  /// - performance optimization: By using this to inject values to widgets
  ///   using `ref` inside of their constructor, widgets may be able to use
  ///   `const` constructors, which can improve performance.
  ///
  /// **Note**: Overrides only apply to this [ProviderScope] and its descendants.
  /// Ancestors of this [ProviderScope] will not be affected by the overrides.
  final List<Override> overrides;

  @override
  ProviderScopeState createState() => ProviderScopeState();
}

/// Do not use: The [State] of [ProviderScope]
@internal
final class ProviderScopeState extends State<ProviderScope> {
  /// The [ProviderContainer] exposed to [ProviderScope.child].
  @visibleForTesting
  late final ProviderContainer container;
  ProviderContainer? _debugParentOwner;
  var _dirty = false;

  @override
  void initState() {
    super.initState();

    final parent = _getParent();
    if (kDebugMode) {
      _debugParentOwner = parent;
    }

    container = ProviderContainer(
      parent: parent,
      overrides: widget.overrides,
      observers: widget.observers,
      retry: widget.retry,
      onError: (err, stack) {
        FlutterError.reportError(
          FlutterErrorDetails(
            exception: err,
            stack: stack,
            library: 'riverpod',
          ),
        );
      },
    );
  }

  ProviderContainer? _getParent() {
    final scope =
        context
                .getElementForInheritedWidgetOfExactType<
                  _UncontrolledProviderScope
                >()
                ?.widget
            as _UncontrolledProviderScope?;

    return scope?.container;
  }

  @override
  void didUpdateWidget(ProviderScope oldWidget) {
    super.didUpdateWidget(oldWidget);
    _dirty = true;
  }

  void _debugAssertParentDidNotChange() {
    final parent = _getParent();

    if (parent != _debugParentOwner) {
      throw UnsupportedError(
        'ProviderScope was rebuilt with a different ProviderScope ancestor',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (kDebugMode) _debugAssertParentDidNotChange();

    if (_dirty) {
      _dirty = false;
      container.updateOverrides(widget.overrides);
    }

    return UncontrolledProviderScope(container: container, child: widget.child);
  }

  @override
  void dispose() {
    container.dispose();
    super.dispose();
  }
}

/// {@template riverpod.UncontrolledProviderScope}
/// Expose a [ProviderContainer] to the widget tree.
///
/// This is what makes [Consumer] work.
///
/// **Note**: The [container] will _not_ be disposed when using this widget.
/// It is the caller's responsibility to dispose of it when no longer needed.
/// Alternatively, use [ProviderScope] to automatically manage the lifecycle of
/// the [ProviderContainer].
///
/// {@endtemplate}
/// {@category Core}
class UncontrolledProviderScope extends StatefulWidget {
  /// {@macro riverpod.UncontrolledProviderScope}
  const UncontrolledProviderScope({
    super.key,
    required this.container,
    required this.child,
  });

  /// The [ProviderContainer] exposed to the widget tree.
  final ProviderContainer container;

  /// The part of the widget tree that can use Riverpod.
  final Widget child;

  @override
  State<UncontrolledProviderScope> createState() =>
      _UncontrolledProviderScopeState();
}

final class _UncontrolledProviderScopeState
    extends State<UncontrolledProviderScope>
    implements Vsync {
  Task? _task;
  Timer? _vsyncTimer;
  Timer? _vsyncTimOutTimer;
  void Function()? _cancelAsyncTask;

  @override
  void initState() {
    super.initState();

    if (kDebugMode) debugCanModifyProviders ??= _debugCanModifyProviders;
    assert(
      !widget.container.scheduler.flutterVsyncs.contains(this),
      'Sync already added',
    );
    widget.container.scheduler.flutterVsyncs.add(this);
  }

  @override
  void reassemble() {
    super.reassemble();
    if (kDebugMode) {
      widget.container.debugReassemble();
    }
  }

  void _callTask() {
    if (!mounted) return;

    _cancelAsyncTask?.call();
    _cancelAsyncTask = null;
    _vsyncTimOutTimer?.cancel();
    _vsyncTimOutTimer = null;
    _vsyncTimer?.cancel();
    _vsyncTimer = null;

    final task = _task;
    _task = null;
    task?.call();
  }

  void _debugAssertCanScheduleTask(Task task) {
    assert(
      _task == null
          // Checks for race conditions where a task has been completed in a different scope.
          // If so, it then becomes possible for another task to be scheduled
          // before this scoped had the opportunity to run its task.
          ||
          _task!.completed,
      'Only one task can be scheduled at a time',
    );
    assert(mounted, 'Cannot schedule a task on an unmounted element');
  }

  @override
  void Function()? scheduleRefresh(Task task) {
    _debugAssertCanScheduleTask(task);
    _cancelAsyncTask?.call();
    _cancelAsyncTask = null;

    setState(() {
      _task = task;
    });

    _vsyncTimer?.cancel();
    _vsyncTimer = Timer(Duration.zero, () {
      _vsyncTimer = null;
      if (_task == null) return;
      if (mounted) setState(() {});

      _vsyncTimOutTimer?.cancel();
      _vsyncTimOutTimer = Timer(Duration.zero, () {
        _vsyncTimOutTimer = null;
        _callTask();
      });
    });

    return () {
      _vsyncTimer?.cancel();
      _vsyncTimer = null;
      _vsyncTimOutTimer?.cancel();
      _vsyncTimOutTimer = null;
    };
  }

  @override
  void Function()? scheduleDispose(Task task) {
    _debugAssertCanScheduleTask(task);
    _task = task;

    var canceled = false;
    _cancelAsyncTask?.call();
    _cancelAsyncTask = () => canceled = true;
    Future.microtask(() {
      if (canceled) return;
      _callTask();
    });

    return () {
      canceled = true;
      if (identical(_task, task)) {
        _task = null;
        _cancelAsyncTask = null;
      }
    };
  }

  void _debugCanModifyProviders() {
    if (!kDebugMode) {
      throw StateError(
        'debugCanModifyProviders should not be called outside of debug mode',
      );
    }
    try {
      setState(() {});
    } catch (err) {
      throw FlutterError.fromParts([
        ErrorSummary(
          'Tried to modify a provider while the widget tree was building.',
        ),
        ErrorDescription('''
If you are encountering this error, chances are you tried to modify a provider
in a widget life-cycle, such as but not limited to:
- build
- initState
- dispose
- didUpdateWidget
- didChangeDependencies

Modifying a provider inside those life-cycles is not allowed, as it could
lead to an inconsistent UI state. For example, two widgets could listen to the
same provider, but incorrectly receive different states.


To fix this problem, you have one of two solutions:
- (preferred) Move the logic for modifying your provider outside of a widget
  life-cycle. For example, maybe you could update your provider inside a button's
  onPressed instead.

- Delay your modification, such as by encapsulating the modification
  in a `Future(() {...})`.
  This will perform your update after the widget tree is done building.
'''),
      ]);
    }
  }

  @override
  Widget build(BuildContext context) {
    _callTask();

    return _UncontrolledProviderScope(
      container: widget.container,
      child: widget.child,
    );
  }

  @override
  void dispose() {
    _cancelAsyncTask?.call();
    _cancelAsyncTask = null;
    _vsyncTimer?.cancel();
    _vsyncTimer = null;
    _vsyncTimOutTimer?.cancel();
    _vsyncTimOutTimer = null;
    if (kDebugMode && debugCanModifyProviders == _debugCanModifyProviders) {
      debugCanModifyProviders = null;
    }

    widget.container.scheduler.flutterVsyncs.remove(this);

    super.dispose();
  }
}

final class _UncontrolledProviderScope extends InheritedWidget {
  const _UncontrolledProviderScope({
    super.key,
    required this.container,
    required super.child,
  });

  final ProviderContainer container;
  @override
  bool updateShouldNotify(_UncontrolledProviderScope oldWidget) {
    return container != oldWidget.container;
  }
}

/// Widget testing helpers for flutter_riverpod.
@visibleForTesting
extension RiverpodWidgetTesterX on flutter_test.WidgetTester {
  /// Finds the [ProviderContainer] in the widget tree.
  ///
  /// If [of] is provided, searches for the container within the context of
  /// the specified finder.
  @visibleForTesting
  ProviderContainer container({flutter_test.Finder? of}) {
    if (of != null) {
      final element = this.element(of);
      return ProviderScope.containerOf(element, listen: false);
    }

    final scope = widget(flutter_test.find.byType(UncontrolledProviderScope));
    return (scope as UncontrolledProviderScope).container;
  }
}
```

// ============================================================
// 📦 Package: widget_ref.dart
// 📁 /home/user/.pub-cache/hosted/pub.dev/flutter_riverpod-3.3.2/lib/src/core/widget_ref.dart
// ============================================================

```dart
// ignore_for_file: invalid_use_of_internal_member

part of '../core.dart';

/// {@template flutter_riverpod.widget_ref}
/// An object that allows widgets to interact with providers.
///
/// [WidgetRef]s are typically obtained by using [ConsumerWidget] or its variants:
///
/// ```dart
/// class Example extends ConsumerWidget {
///   @override
///   Widget build(BuildContext context, WidgetRef ref) {
///     // We now have a "ref"
///   }
/// }
/// ```
///
/// Once we have a [WidgetRef], we can use its various methods to interact with
/// providers.
/// The most common use-case is to use [WidgetRef.watch] inside the `build` method of our
/// widgets. This will enable our UI to update whenever the state of a provider
/// changes:
///
/// ```dart
/// @override
/// Widget build(BuildContext context, WidgetRef ref) {
///   final count = ref.watch(counterProvider);
///   // The text will automatically update whenever `counterProvider` emits a new value
///   return Text('$count');
/// }
/// ```
///
/// **Note**:
/// Using a [WidgetRef] is equivalent to writing UI logic.
/// As such, [WidgetRef]s should not leave the widget layer. If you need to
/// interact with providers outside of the widget layer, consider using
/// a [Ref] instead.
/// {@endtemplate}
/// {@category Core}
sealed class WidgetRef implements BaseWidgetRef, MutationTarget {
  /// The [BuildContext] of the widget associated to this [WidgetRef].
  ///
  /// This is strictly identical to the [BuildContext] passed to [ConsumerWidget.build].
  BuildContext get context;

  /// Returns the value exposed by a provider and rebuild the widget when that
  /// value changes.
  ///
  /// This method should only be used at the "root" of the `build` method of a widget.
  ///
  /// **Good**: Use [watch] inside the `build` method.
  /// ```dart
  /// class Example extends ConsumerWidget {
  ///   @override
  ///   Widget build(BuildContext context, WidgetRef ref) {
  ///     // Correct, we are inside the build method and at its root.
  ///     final count = ref.watch(counterProvider);
  ///   }
  /// }
  /// ```
  /// **Good**: It is accepted to use [watch] at the root of "builders" too.
  /// ```dart
  /// class Example extends ConsumerWidget {
  ///   @override
  ///   Widget build(BuildContext context, WidgetRef ref) {
  ///     return ListView.builder(
  ///       itemBuilder: (context) {
  ///          // This is accepted, as we are at the root of a "builder"
  ///          final count = ref.watch(counterProvider);
  ///       },
  ///     );
  ///   }
  /// }
  /// ```
  ///
  /// **Bad**: Don't use [watch] outside of the `build` method.
  /// ```dart
  /// class Example extends ConsumerStatefulWidget {
  ///   @override
  ///   ExampleState createState() => ExampleState();
  /// }
  ///
  /// class ExampleState extends ConsumerState<Example> {
  ///   @override
  ///   void initState() {
  ///     super.initState();
  ///     // Incorrect, we are not inside the build method.
  ///     final count = ref.watch(counterProvider);
  ///   }
  /// }
  /// ```
  ///
  /// **Bad**: Don't use [watch] inside event handles withing `build` method.
  /// ```dart
  /// class Example extends ConsumerWidget {
  ///   @override
  ///   Widget build(BuildContext context, WidgetRef ref) {
  ///     return ElevatedButton(
  ///       onTap: () {
  ///         // Incorrect, we are inside the build method, but neither at its
  ///         // root, nor inside a "builder".
  ///         final count = ref.watch(counterProvider);
  ///       }
  ///     );
  ///   }
  /// }
  /// ```
  ///
  /// See also:
  ///
  /// - [ProviderListenableSelect.select], which allows a widget to filter rebuilds by
  ///   observing only the selected properties.
  /// - [listen], to react to changes on a provider, such as for showing modals.
  @override
  StateT watch<StateT>(ProviderListenable<StateT> provider);

  /// Determines whether a provider is initialized or not.
  ///
  /// Writing logic that conditionally depends on the existence of a provider
  /// is generally unsafe and should be avoided.
  /// The problem is that once the provider gets initialized, logic that
  /// depends on the existence or not of a provider won't be rerun; possibly
  /// causing your state to get out of date.
  ///
  /// But it can be useful in some cases, such as to avoid re-fetching an
  /// object if a different network request already obtained it:
  ///
  /// ```dart
  /// final fetchItemList = FutureProvider<List<Item>>(...);
  ///
  /// final fetchItem = FutureProvider.autoDispose.family<Item, String>((ref, id) async {
  ///   if (ref.exists(fetchItemList)) {
  ///     // If `fetchItemList` is initialized, we look into its state
  ///     // and return the already obtained item.
  ///     final itemFromItemList = await ref.watch(
  ///       fetchItemList.selectAsync((items) => items.firstWhereOrNull((item) => item.id == id)),
  ///     );
  ///     if (itemFromItemList != null) return itemFromItemList;
  ///   }
  ///
  ///   // If `fetchItemList` is not initialized, perform a network request for
  ///   // "id" separately
  ///
  ///   final json = await http.get('api/items/$id');
  ///   return Item.fromJson(json);
  /// });
  /// ```
  @override
  bool exists(ProviderBase<Object?> provider);

  /// Listen to a provider and call `listener` whenever its value changes,
  /// without having to take care of removing the listener.
  ///
  /// The [listen] method should exclusively be used at the root of the `build`:
  ///
  /// **Good**: Use [listen] inside the `build` method.
  /// ```dart
  /// class Example extends ConsumerWidget {
  ///   @override
  ///   Widget build(BuildContext context, WidgetRef ref) {
  ///     // Correct, we are inside the build method and at its root.
  ///     ref.listen(counterProvider, (prev, next) {});
  ///   }
  /// }
  /// ```
  ///
  /// **Bad**: Do not use [listen] inside builders.
  /// ```dart
  /// class Example extends ConsumerWidget {
  ///   @override
  ///   Widget build(BuildContext context, WidgetRef ref) {
  ///     return ListView.builder(
  ///       itemBuilder: (context) {
  ///          // This is accepted, as we are at the root of a "builder"
  ///          ref.listen(counterProvider, (prev, next) {});
  ///       },
  ///     );
  ///   }
  /// }
  /// ```
  ///
  /// **Bad**: Don't use [listen] outside of the `build` method.
  /// ```dart
  /// class Example extends ConsumerStatefulWidget {
  ///   @override
  ///   ExampleState createState() => ExampleState();
  /// }
  ///
  /// class ExampleState extends ConsumerState<Example> {
  ///   @override
  ///   void initState() {
  ///     super.initState();
  ///     // Incorrect, we are not inside the build method.
  ///     ref.listen(counterProvider, (prev, next) {});
  ///   }
  /// }
  /// ```
  ///
  /// **Bad**: Don't use [listen] inside event handles withing `build` method.
  /// ```dart
  /// class Example extends ConsumerWidget {
  ///   @override
  ///   Widget build(BuildContext context, WidgetRef ref) {
  ///     return ElevatedButton(
  ///       onTap: () {
  ///         // Incorrect, we are inside the build method, but neither at its
  ///         // root, nor inside a "builder".
  ///         ref.listen(counterProvider, (prev, next) {});
  ///       }
  ///     );
  ///   }
  /// }
  /// ```
  ///
  /// **Note**:
  /// Listeners will automatically be removed if a widget rebuilds and stops
  /// listening to a provider.
  ///
  /// See also:
  /// - [listenManual], for listening to a provider from outside `build`.
  /// - [watch], to listen to providers in a declarative manner.
  /// - [read], to read a provider without listening to it.
  ///
  /// This is useful for showing modals or other imperative logic.
  @override
  void listen<StateT>(
    ProviderListenable<StateT> provider,
    void Function(StateT? previous, StateT next) listener, {
    void Function(Object error, StackTrace stackTrace)? onError,
    bool weak = false,
  });

  /// Listen to a provider and call `listener` whenever its value changes.
  ///
  /// As opposed to [listen], [listenManual] is not safe to use within the `build`
  /// method of a widget.
  /// Instead, [listenManual] is designed to be used inside [State.initState] or
  /// other [State] life-cycles.
  ///
  /// [listenManual] returns a [ProviderSubscription] which can be used to stop
  /// listening to the provider, or to read the current value exposed by
  /// the provider.
  ///
  /// It is not necessary to call [ProviderSubscription.close] inside [State.dispose].
  /// When the widget that calls [listenManual] is disposed, the subscription
  /// will be disposed automatically.
  @override
  ProviderSubscription<StateT> listenManual<StateT>(
    ProviderListenable<StateT> provider,
    void Function(StateT? previous, StateT next) listener, {
    void Function(Object error, StackTrace stackTrace)? onError,
    bool fireImmediately,
    bool weak = false,
  });

  /// Reads a provider without listening to it.
  ///
  /// **AVOID** calling [read] inside build if the value is used only for events:
  ///
  /// ```dart
  /// Widget build(BuildContext context) {
  ///   // counter is used only for the onPressed of RaisedButton
  ///   final counter = ref.read(counterProvider);
  ///
  ///   return RaisedButton(
  ///     onPressed: () => counter.increment(),
  ///   );
  /// }
  /// ```
  ///
  /// While this code is not bugged in itself, this is an anti-pattern.
  /// It could easily lead to bugs in the future after refactoring the widget
  /// to use `counter` for other things, but forget to change [read] into [Consumer]/`ref.watch(`.
  ///
  /// **CONSIDER** calling [read] inside event handlers:
  ///
  /// ```dart
  /// Widget build(BuildContext context) {
  ///   return RaisedButton(
  ///     onPressed: () {
  ///       // as performant as the previous solution, but resilient to refactoring
  ///       ref.read(counterProvider).increment(),
  ///     },
  ///   );
  /// }
  /// ```
  ///
  /// This has the same efficiency as the previous anti-pattern, but does not
  /// suffer from the drawback of being brittle.
  ///
  /// **AVOID** using [read] for creating widgets with a value that never changes
  ///
  /// ```dart
  /// Widget build(BuildContext context) {
  ///   // using read because we only use a value that never changes.
  ///   final model = ref.read(modelProvider);
  ///
  ///   return Text('${model.valueThatNeverChanges}');
  /// }
  /// ```
  ///
  /// While the idea of not rebuilding the widget if unnecessary is good,
  /// this should not be done with [read].
  /// Relying on [read] for optimizations is very brittle and dependent
  /// on an implementation detail.
  ///
  /// **CONSIDER** using [Provider] or `select` for filtering unwanted rebuilds:
  ///
  /// ```dart
  /// Widget build(BuildContext context) {
  ///   // Using select to listen only to the value that used
  ///   final valueThatNeverChanges = ref.watch(modelProvider.select((model) {
  ///     return model.valueThatNeverChanges;
  ///   }));
  ///
  ///   return Text('$valueThatNeverChanges');
  /// }
  /// ```
  ///
  /// While more verbose than [read], using [Provider]/`select` is a lot safer.
  /// It does not rely on implementation details on `Model`, and it makes
  /// impossible to have a bug where our UI does not refresh.
  @override
  StateT read<StateT>(ProviderListenable<StateT> provider);

  /// Forces a provider to re-evaluate its state immediately, and return the created value.
  ///
  /// Writing:
  ///
  /// ```dart
  /// final newValue = ref.refresh(provider);
  /// ```
  ///
  /// is strictly identical to doing:
  ///
  /// ```dart
  /// ref.invalidate(provider);
  /// final newValue = ref.read(provider);
  /// ```
  ///
  /// If you do not care about the return value of [refresh], use [invalidate] instead.
  /// Doing so has the benefit of:
  /// - making the invalidation logic more resilient by avoiding multiple
  ///   refreshes at once.
  /// - possibly avoiding recomputing a provider if it isn't needed immediately.
  ///
  /// This method is useful for features like "pull to refresh" or "retry on error",
  /// to restart a specific provider.
  ///
  /// For example, a pull-to-refresh may be implemented by combining
  /// [FutureProvider] and a [RefreshIndicator]:
  ///
  /// ```dart
  /// final productsProvider = FutureProvider((ref) async {
  ///   final response = await httpClient.get('https://host.com/products');
  ///   return Products.fromJson(response.data);
  /// });
  ///
  /// class Example extends ConsumerWidget {
  ///   @override
  ///   Widget build(BuildContext context, WidgetRef ref) {
  ///     final Products products = ref.watch(productsProvider);
  ///
  ///     return RefreshIndicator(
  ///       onRefresh: () => ref.refresh(productsProvider.future),
  ///       child: ListView(
  ///         children: [
  ///           for (final product in products.items) ProductItem(product: product),
  ///         ],
  ///       ),
  ///     );
  ///   }
  /// }
  /// ```
  @override
  @useResult
  StateT refresh<StateT>(Refreshable<StateT> provider);

  /// Invalidates the state of the provider, causing it to refresh.
  ///
  /// As opposed to [refresh], the refresh is not immediate and is instead
  /// delayed to the next read or next frame.
  ///
  /// Calling [invalidate] multiple times will refresh the provider only
  /// once.
  ///
  /// Calling [invalidate] will cause the provider to be disposed immediately.
  ///
  /// - [asReload] (false by default) can be optionally passed to tell
  ///   Riverpod to clear the state before refreshing it.
  ///   This is only useful for asynchronous providers, as by default,
  ///   [AsyncValue] keeps a reference on state during loading states.
  ///   Using [asReload] will disable this behavior and count as a
  ///   "hard refresh".
  ///
  /// If used on a provider which is not initialized, this method will have no effect.
  @override
  void invalidate(ProviderOrFamily provider, {bool asReload = false});
}
```

// ============================================================
// 📦 Package: freezed_annotation.dart
// 📁 /home/user/.pub-cache/hosted/pub.dev/freezed_annotation-3.1.0/lib/freezed_annotation.dart
// ============================================================

```dart
import 'package:collection/collection.dart';
import 'package:json_annotation/json_annotation.dart';

export 'package:collection/collection.dart' show DeepCollectionEquality;
export 'package:json_annotation/json_annotation.dart';
export 'package:meta/meta.dart';

part 'freezed_annotation.g.dart';

/// An [UnmodifiableListView] which overrides ==
class EqualUnmodifiableListView<T> extends UnmodifiableListView<T> {
  /// An [UnmodifiableListView] which overrides ==
  EqualUnmodifiableListView(this._source) : super(_source);

  final Iterable<T> _source;

  @override
  bool operator ==(Object other) {
    return other is EqualUnmodifiableListView<T> &&
        other.runtimeType == runtimeType &&
        other._source == _source;
  }

  @override
  int get hashCode => Object.hash(runtimeType, _source);
}

/// An [UnmodifiableSetView] which overrides ==
class EqualUnmodifiableSetView<T> extends UnmodifiableSetView<T> {
  /// An [UnmodifiableSetView] which overrides ==
  EqualUnmodifiableSetView(this._source) : super(_source);

  final Set<T> _source;

  @override
  bool operator ==(Object other) {
    return other is EqualUnmodifiableSetView<T> &&
        other.runtimeType == runtimeType &&
        other._source == _source;
  }

  @override
  int get hashCode => Object.hash(runtimeType, _source);
}

/// An [UnmodifiableMapView] which overrides ==
class EqualUnmodifiableMapView<Key, Value>
    extends UnmodifiableMapView<Key, Value> {
  /// An [UnmodifiableMapView] which overrides ==
  EqualUnmodifiableMapView(this._source) : super(_source);

  final Map<Key, Value> _source;

  @override
  bool operator ==(Object other) {
    return other is EqualUnmodifiableMapView<Key, Value> &&
        other.runtimeType == runtimeType &&
        other._source == _source;
  }

  @override
  int get hashCode => Object.hash(runtimeType, _source);
}

/// Options for enabling/disabling specific `Union.map` features;
@JsonSerializable(
  fieldRename: FieldRename.snake,
  createToJson: false,
  anyMap: true,
)
class FreezedMapOptions {
  /// Options for enabling/disabling specific `Union.map` features;
  const FreezedMapOptions({this.map, this.mapOrNull, this.maybeMap});

  /// Decode a [FreezedMapOptions] from a build.yaml
  factory FreezedMapOptions.fromJson(Map<Object?, Object?> json) =>
      _$FreezedMapOptionsFromJson(json);

  /// Enables the generation of all `Union.map` features
  static const all =
      FreezedMapOptions(map: true, mapOrNull: true, maybeMap: true);

  /// Disables the generation of all `Union.map` features
  static const none =
      FreezedMapOptions(map: false, mapOrNull: false, maybeMap: false);

  /// Whether to generate `Union.map`
  ///
  /// If null, will fallback to the build.yaml configs
  /// If that value is null too, defaults to true.
  final bool? map;

  /// Whether to generate `Union.mapOrNull`
  ///
  /// If null, will fallback to the build.yaml configs
  /// If that value is null too, defaults to true.
  final bool? mapOrNull;

  /// Whether to generate `Union.maybeMap`
  ///
  /// If null, will fallback to the build.yaml configs
  /// If that value is null too, defaults to true.
  final bool? maybeMap;
}

/// Options for enabling/disabling specific `Union.when` features;
@JsonSerializable(
  fieldRename: FieldRename.snake,
  createToJson: false,
  anyMap: true,
)
class FreezedWhenOptions {
  /// Options for enabling/disabling specific `Union.when` features;
  const FreezedWhenOptions({
    this.when,
    this.whenOrNull,
    this.maybeWhen,
  });

  /// Decode a [FreezedWhenOptions] from a build.yaml
  factory FreezedWhenOptions.fromJson(Map<Object?, Object?> json) =>
      _$FreezedWhenOptionsFromJson(json);

  /// Enables the generation of all `Union.when` features
  static const all =
      FreezedWhenOptions(when: true, whenOrNull: true, maybeWhen: true);

  /// Disables the generation of all `Union.when` features
  static const none = FreezedWhenOptions(
    when: false,
    whenOrNull: false,
    maybeWhen: false,
  );

  /// Whether to generate `Union.when`
  ///
  /// If null, will fallback to the build.yaml configs
  /// If that value is null too, defaults to true.
  final bool? when;

  /// Whether to generate `Union.whenOrNull`
  ///
  /// If null, will fallback to the build.yaml configs
  /// If that value is null too, defaults to true.
  final bool? whenOrNull;

  /// Whether to generate `Union.maybeWhen`
  ///
  /// If null, will fallback to the build.yaml configs.
  /// If that value is null too, defaults to true.
  final bool? maybeWhen;
}

class _FreezedWhenOptionsConverter
    implements JsonConverter<FreezedWhenOptions?, Object?> {
  const _FreezedWhenOptionsConverter();

  @override
  FreezedWhenOptions? fromJson(Object? json) {
    if (json == true) return FreezedWhenOptions.all;
    if (json == false) return FreezedWhenOptions.none;
    if (json == null) return null;
    if (json is Map) return FreezedWhenOptions.fromJson(json);

    throw ArgumentError.value(
      json,
      'json',
      'Expected a bool a Map, got ${json.runtimeType}',
    );
  }

  @override
  Object? toJson(FreezedWhenOptions? object) => null;
}

class _FreezedMapOptionsConverter
    implements JsonConverter<FreezedMapOptions?, Object?> {
  const _FreezedMapOptionsConverter();

  @override
  FreezedMapOptions? fromJson(Object? json) {
    if (json == true) return FreezedMapOptions.all;
    if (json == false) return FreezedMapOptions.none;
    if (json == null) return null;
    if (json is Map) return FreezedMapOptions.fromJson(json);

    throw ArgumentError.value(
      json,
      'json',
      'Expected a bool or a Map, got ${json.runtimeType}',
    );
  }

  @override
  Object? toJson(FreezedMapOptions? object) => throw UnimplementedError();
}

/// {@template freezed_annotation.freezed}
/// Flags a class as needing to be processed by Freezed and allows passing options.
/// {@endtemplate}
@JsonSerializable(
  fieldRename: FieldRename.snake,
  createToJson: false,
  anyMap: true,
)
class Freezed {
  /// {@macro freezed_annotation.freezed}
  const Freezed({
    this.unionKey,
    this.unionValueCase,
    this.fallbackUnion,
    this.copyWith,
    this.equal,
    this.toStringOverride,
    this.fromJson,
    this.toJson,
    this.map,
    this.when,
    this.makeCollectionsUnmodifiable,
    this.addImplicitFinal = true,
    this.genericArgumentFactories = false,
  });

  /// Decode the options from a build.yaml
  factory Freezed.fromJson(Map<Object?, Object?> json) =>
      _$FreezedFromJson(json);

  /// Whether to assume that all constructor parameters are marked as final.
  ///
  /// This means that:
  ///
  /// ```dart
  /// @Freezed(addImplicitFinal: true) // default to true
  /// class Person with _$Person {
  ///   factory Person(String name, int age) = _Person;
  /// }
  /// ```
  ///
  /// is strictly equivalent to:
  ///
  /// ```dart
  /// @Freezed(addImplicitFinal: false)
  /// class Person with _$Person {
  ///   factory Person(final String name, final int age) = _Person;
  /// }
  /// ```
  final bool addImplicitFinal;

  /// Determines what key should be used to de/serialize union types.
  ///
  /// Consider:
  ///
  /// {@template freezed_annotation.freezed.example}
  /// ```dart
  /// @freezed
  /// class Union with _$Union {
  ///   factory Union.first() = _First;
  ///   factory Union.second() = _Second;
  ///
  ///   factory Union.fromJson(Map<String, Object> json) => _$UnionFromJson(json);
  /// }
  /// ```
  ///
  /// When serializing or deserializing `Union`, Freezed will ask/demand for an
  /// extra json key, which represents which constructor should be used.
  ///
  /// More specifically, when calling `Union.toJson`, we will have:
  ///
  /// ```dart
  /// void main() {
  ///   print(Union.first().toJson()); // { 'runtimeType': 'first' }
  ///   print(Union.second().toJson()); // { 'runtimeType': 'second' }
  /// }
  /// ```
  /// {@endtemplate}
  ///
  /// This variable allows customizing the key used ("runtimeType" by default).
  ///
  /// For example, we could change our previous `Union` implementation to:
  ///
  /// ```dart
  /// @Freezed(unionKey: 'type')
  /// abstract class Union with _$Union {
  ///   // ...
  /// }
  /// ```
  ///
  /// which changes how `fromJson`/`toJson` behaves:
  ///
  /// ```dart
  /// void main() {
  ///   print(Union.first().toJson()); // { 'type': 'first' }
  ///   print(Union.second().toJson()); // { 'type': 'second' }
  /// }
  /// ```
  @JsonKey(defaultValue: 'runtimeType')
  final String? unionKey;

  /// Determines how the value used to de/serialize union types would be
  /// renamed.
  ///
  /// Consider:
  ///
  /// {@macro freezed_annotation.freezed.example}
  ///
  /// This variable allows customizing the value used (constructor name by
  /// default).
  ///
  /// For example, we could change our previous `Union` implementation to:
  ///
  /// ```dart
  /// @Freezed(unionValueCase: FreezedUnionCase.pascal)
  /// class Union with _$Union {
  ///   // ...
  /// }
  /// ```
  ///
  /// which changes how `fromJson`/`toJson` behaves:
  ///
  /// ```dart
  /// void main() {
  ///   print(Union.first().toJson()); // { 'runtimeType': 'First' }
  ///   print(Union.second().toJson()); // { 'runtimeType': 'Second' }
  /// }
  /// ```
  ///
  /// You can also use [FreezedUnionValue] annotation to customize single
  /// union case.
  final FreezedUnionCase? unionValueCase;

  /// Determines which constructor should be used when there is no matching one
  /// through constructor name or using [FreezedUnionValue]
  ///
  /// By default, Freezed generates code that will throw FallThroughError when type
  /// is not matched through constructor name or using [FreezedUnionValue].
  /// You can override this behavior by providing it's name or `default` to use
  /// default constructor
  ///
  /// ```dart
  /// @Freezed(fallbackUnion: 'fallback')
  /// class MyResponse with _$MyResponse {
  ///   const factory MyResponse.special(String a, int b) = MyResponseSpecial;
  ///   const factory MyResponse.fallback(String a, int b) = MyResponseFallback;
  ///
  ///   factory MyResponse.fromJson(Map<String, dynamic> json) => _$MyResponseFromJson(json);
  /// }
  /// ```
  ///
  /// The constructor will be chosen as follows:
  ///
  /// ```json
  /// [
  ///   {
  ///     "runtimeType": "special",
  ///     "a": "This JSON object will use constructor MyResponse.special()",
  ///     "b": 42
  ///   },
  ///   {
  ///     "runtimeType": "surprise",
  ///     "a": "This JSON object will use constructor MyResponse.fallback()",
  ///     "b": 42
  ///   }
  /// ]
  /// ```
  final String? fallbackUnion;

  /// If true, then this converts [List], [Map] and [Set] into respectively
  /// [UnmodifiableListView], [UnmodifiableMapView] or [UnmodifiableSetView].
  @JsonKey(defaultValue: true)
  final bool? makeCollectionsUnmodifiable;

  /// Whether to generate a `toString` or not
  ///
  /// If null, picks up the default values from the project's `build.yaml`.
  /// If that value is null too, generates a `toString` only if the class
  /// has no custom `toString`.
  final bool? toStringOverride;

  /// Whether to generate a `==/hashcode` or not
  ///
  /// If null, picks up the default values from the project's `build.yaml`.
  /// If that value is null too, generates a ==/hashcode only if the class
  /// does not have a custom ==
  final bool? equal;

  /// Whether to generate a `copyWith` or not
  ///
  /// If null, picks up the default values from the project's `build.yaml`.
  /// If that value is null too, defaults to true.
  final bool? copyWith;

  /// Whether to generate a `fromJson` or not
  ///
  /// If null, picks up the default values from the project's `build.yaml`.
  ///
  /// If that value is null too, will be inferred based on whether the Freezed
  /// class has a `fromJson` constructor`, such that
  ///
  /// ```dart
  /// @freezed
  /// class Example with _$Example {
  ///   factory Example(int a) = _Example;
  ///
  ///   factory Example.fromJson(Map<String, Object?> json) => _$ExampleFromJson(json);
  /// }
  /// ```
  ///
  /// generates a `fromJson`.
  ///
  /// On the other hand, changing `fromJson(Map json) => _$ExampleFromJson(json)`
  /// to no-longer  use `=>` and instead use `{ return }`  will disable the
  /// generation of `fromJson`,
  ///
  /// ```dart
  /// @freezed
  /// class Example with _$Example {
  ///   factory Example(int a) = _Example;
  ///
  ///   factory Example.fromJson(Map<String, Object?> json) {
  ///     // Will not generate a _$ExampleFromJson class as we are using `{ return }`
  ///     return {...};
  ///   }
  /// }
  /// ```
  final bool? fromJson;

  /// Whether to generate a `toJson` or not
  ///
  /// If null, picks up the default values from the project's `build.yaml`.
  ///
  /// If that value is null too, will be inferred based on whether the Freezed
  /// class has a `fromJson` constructor`, such that
  ///
  /// ```dart
  /// @freezed
  /// class Example with _$Example {
  ///   factory Example(int a) = _Example;
  ///
  ///   factory Example.fromJson(Map<String, Object?> json) => _$ExampleFromJson(json);
  /// }
  /// ```
  ///
  /// generates a `toJson`.
  ///
  /// On the other hand, changing `fromJson(Map json) => _$ExampleFromJson(json)`
  /// to no-longer  use `=>` and instead use `{ return }`  will disable the
  /// generation of `toJson`,
  ///
  /// ```dart
  /// @freezed
  /// class Example with _$Example {
  ///   factory Example(int a) = _Example;
  ///
  ///   factory Example.fromJson(Map<String, Object?> json) {
  ///     // Will not generate a _$ExampleFromJson class as we are using `{ return }`
  ///     return {...};
  ///   }
  /// }
  /// ```
  final bool? toJson;

  /// Whether to enable the genericArgumentFactories feature of JsonSerializable
  ///
  /// Defaults to false.
  ///
  /// This changes `fromJson(Map json) => _$ExampleFromJson(json)`
  /// to have an additional parameter for each type parameter for the class
  ///
  /// ```dart
  /// @freezed
  /// class Example<T> with _$Example<T> {
  ///   factory Example<T>(T a) = _Example;
  ///
  ///   factory Example.fromJson(Map<String, Object?> json, T Function(Object?) fromJsonT) => _$ExampleFromJson(json, fromJsonT);
  /// }
  /// ```
  final bool genericArgumentFactories;

  /// Options for customizing the generation of `map` functions
  ///
  /// If null, picks up the default values from the project's `build.yaml`.
  /// If that value is null too, defaults to [FreezedMapOptions.all].
  @_FreezedMapOptionsConverter()
  final FreezedMapOptions? map;

  /// Options for customizing the generation of `when` functions
  ///
  /// If null, picks up the default values from the project's `build.yaml`
  /// If that value is null too, defaults to [FreezedWhenOptions.all].
  @_FreezedWhenOptionsConverter()
  final FreezedWhenOptions? when;
}

/// Defines an immutable data-class.
///
/// This will consider all properties of the object as immutable.
const freezed = Freezed();

/// Defines a potentially mutable data-class.
///
/// As opposed to [freezed], properties of the object can be mutable.
/// On the other hand, they will not implement ==.
const unfreezed = Freezed(
  equal: false,
  addImplicitFinal: false,
  makeCollectionsUnmodifiable: false,
);

/// {@template freezed_annotation.assert}
/// A decorator that allows adding `assert(...)` on the generated classes.
///
/// Usage example:
///
/// ```dart
/// abstract class Person with _$Person {
///   @Assert('name.trim().isNotEmpty', 'name cannot be empty')
///   @Assert('age >= 0')
///   factory Person({
///     String name,
///     int age,
///   }) = _Person;
/// }
/// ```
/// {@endtemplate}
class Assert {
  /// {@macro freezed_annotation.assert}
  const Assert(this.eval, [this.message]);

  /// A string representation of the source code that will be executed by the assert.
  final String eval;

  /// An optional message to show if the assertion failed.
  final String? message;
}

/// Allows passing default values to a constructor:
///
/// ```dart
/// abstract class Example with _$Example {
///   factory Example(@Default(42) int value) = _Example;
/// }
/// ```
///
/// is equivalent to:
///
/// ```dart
/// abstract class Example with _$Example {
///   factory Example(@JsonKey(defaultValue: 42) int value = 42) = _Example;
/// }
/// ```
class Default {
  const Default(this.defaultValue);

  final Object? defaultValue;
}

/// Marks a union type to implement the interface [stringType] or type T.
/// In the case below `City` will implement `AdministrativeArea<House>`.
/// ```dart
/// @freezed
/// abstract class Example with _$Example {
///   const factory Example.person(String name, int age) = Person;
///
///   @Implements<AdministrativeArea<House>>()
///   const factory Example.city(String name, int population) = City;
/// }
/// ```
///
/// If interface is generic the `Implements.fromString` constructor must be used
/// otherwise freezed will generate correct code but dart will throw a load
/// error on the annotation declaration.
///
/// Note: You need to make sure that you comply with the interface requirements
/// by implementing all the abstract members. If the interface has no members or
/// just fields you can fulfil the interface contract by adding them in the
/// constructor of the union type. Keep in mind that if the interface defines a
/// method or a getter, that you implement in the class, you need to use the
/// [Custom getters and methods](#custom-getters-and-methods) instructions.
class Implements<T extends Object?> {
  /// Marks a union type to implement the interface T.
  const Implements() : stringType = null;

  /// Marks a union type to implement the interface [stringType]. This
  /// constructor must be used when implementing a generic class with a generic
  /// type parameter e.g. `AdministrativeArea<T>` otherwise dart will throw a
  /// load error when compiling the annotation.
  const Implements.fromString(this.stringType);

  final String? stringType;
}

/// Marks a union type to mixin the interface [stringType] or type T.
/// In the case below `City` will mixin with `AdministrativeArea<House>`.
/// ```dart
/// @freezed
/// abstract class Example with _$Example {
///   const factory Example.person(String name, int age) = Person;
///
///   @With<AdministrativeArea<House>>()
///   const factory Example.city(String name, int population) = City;
/// }
/// ```
///
/// If interface is generic the `With.fromString` constructor must be used
/// otherwise freezed will generate correct code but dart will throw a load
/// error on the annotation declaration.
///
/// Note: You need to make sure that you comply with the interface requirements
/// by implementing all the abstract members. If the mixin has no members or
/// just fields, you can fulfil the interface contract by adding them in the
/// constructor of the union type. Keep in mind that if the mixin defines a
/// method or a getter, that you implement in the class, you need to use the
/// [Custom getters and methods](#custom-getters-and-methods) instructions.
class With<T extends Object?> {
  /// Marks a union type to mixin the interface T.
  const With() : stringType = null;

  /// Marks a union type to mixin the interface [stringType]. This constructor
  /// must be used when mixing in a generic class with a generic type parameter
  /// e.g. `AdministrativeArea<T>` otherwise dart will throw a load error when
  /// compiling the annotation.
  const With.fromString(this.stringType);

  final String? stringType;
}

/// An annotation used to specify how a union type will be serialized.
///
/// By default, Freezed generates the value based on the name of the
/// constructor. You can override this behavior by annotating constructor and
/// providing custom value.
///
/// ```dart
/// @freezed
/// class MyResponse with _$MyResponse {
///   const factory MyResponse(String a) = MyResponseData;
///
///   @FreezedUnionValue('SpecialCase')
///   const factory MyResponse.special(String a, int b) = MyResponseSpecial;
///
///   factory MyResponse.fromJson(Map<String, dynamic> json) => _$MyResponseFromJson(json);
/// }
/// ```
///
/// The constructor will be chosen as follows:
///
/// ```json
/// [
///   {
///     "runtimeType": "default",
///     "a": "This JSON object will use constructor MyResponse()"
///   },
///   {
///     "runtimeType": "SpecialCase",
///     "a": "This JSON object will use constructor MyResponse.special()",
///     "b": 42
///   }
/// ]
/// ```
class FreezedUnionValue {
  const FreezedUnionValue(this.value);

  final String value;
}

/// Options for automatic union values renaming.
@JsonEnum(fieldRename: FieldRename.snake)
enum FreezedUnionCase {
  /// Use the name without changes.
  none,

  /// Encodes a constructor named `kebabCase` with a JSON value `kebab-case`.
  kebab,

  /// Encodes a constructor named `pascalCase` with a JSON value `PascalCase`.
  pascal,

  /// Encodes a constructor named `snakeCase` with a JSON value `snake_case`.
  snake,

  /// Encodes a constructor named `screamingSnakeCase` with a JSON value `SCREAMING_SNAKE_CASE`.
  screamingSnake,
}
```

// ============================================================
// 📦 Package: async_value.dart
// 📁 /home/user/.pub-cache/hosted/pub.dev/riverpod-3.3.2/lib/src/core/async_value.dart
// ============================================================

```dart
part of '../framework.dart';

@internal
extension AsyncTransition<ValueT> on AsyncValue<ValueT> {
  AsyncValue<NewT> cast<NewT>() => _cast<NewT>();
}

extension<BoxedT> on (BoxedT,)? {
  BoxedT unwrapSentinel(BoxedT fallback) {
    final that = this;
    if (that == null) return fallback;
    return that.$1;
  }
}

extension<ValueT> on _DataRecord<ValueT> {
  _DataRecord<ValueT> copyWith({(DataSource?,)? source}) {
    return ($1, kind: kind, source: source.unwrapSentinel(this.source));
  }
}

@internal
extension AsyncValueInternals<ValueT> on AsyncValue<ValueT> {
  DataFilledRecord<ValueT>? get valueFilled {
    final value = _value;
    if (value == null) return null;

    return (
      value: value.$1,
      kind: value.kind ?? DataKind.live,
      source: value.source ?? DataSource.liveOrRefresh,
    );
  }
}

/// Adds non-state related methods/getters to [AsyncValue].
@publicInRiverpodAndCodegen
extension AsyncValueExtensions<ValueT> on AsyncValue<ValueT> {
  bool get _isMultiState {
    var count = 0;
    if (_loading != null) count++;
    if (_value != null) count++;
    if (_error != null) count++;

    return count > 1;
  }

  _ErrorFilledRecord? get _errorFilled {
    final error = _error;
    if (error == null) return null;

    return (
      error: error.err,
      stackTrace: error.stack,
      retrying: error.retrying ?? false,
    );
  }

  /// If an error was emitted, whether that error is currently being retried.
  ///
  /// [retrying] can be true and [isLoading] false.
  /// This happens when a retry is scheduled, but the delay has not yet elapsed.
  bool get retrying => _errorFilled?.retrying ?? false;

  /// Whether the value was obtained using Riverpod's offline-persistence feature.
  ///
  /// When [isFromCache] is true, [isLoading] should also be true.
  bool get isFromCache => valueFilled?.kind == DataKind.cache;

  /// Whether some new value is currently asynchronously loading.
  ///
  /// Even if [isLoading] is true, it is still possible for [hasValue]/[hasError]
  /// to also be true.
  bool get isLoading => _loading != null;

  bool get _hasState => hasValue || hasError;

  /// Whether the associated provider was forced to recompute even though
  /// none of its dependencies has changed, after at least one [value]/[error] was emitted.
  ///
  /// This is usually the case when rebuilding a provider with either
  /// [Ref.invalidate]/[Ref.refresh].
  ///
  /// If a provider rebuilds because one of its dependencies changes (using [Ref.watch]),
  /// then [isRefreshing] will be false, and instead [isReloading] will be true.
  bool get isRefreshing => _hasState && isLoading && this is! AsyncLoading;

  /// Whether the associated provider was recomputed because of a dependency change
  /// (using [Ref.watch]), after at least one [value]/[error] was emitted.
  ///
  /// If a provider rebuilds because one of its dependencies changed (using [Ref.watch]),
  /// then [isReloading] will be true.
  /// If a provider rebuilds only due to [Ref.invalidate]/[Ref.refresh], then
  /// [isReloading] will be false (and [isRefreshing] will be true).
  ///
  /// See also [isRefreshing] for manual provider rebuild.
  bool get isReloading => _hasState && isLoading && this is AsyncLoading;

  /// The current progress of the asynchronous operation.
  ///
  /// This value must be between 0 and 1.
  ///
  /// By default, the progress will always be `null`.
  /// Notifiers can set this manually as such:
  ///
  /// ```dart
  /// state = AsyncLoading(progress: 0);
  /// await something();
  /// ref.state = AsyncLoading(progress: 1);
  /// ```
  num? get progress => _loading?.progress;

  /// Whether [value] is set.
  ///
  /// Even if [hasValue] is true, it is still possible for [isLoading]/[hasError]
  /// to also be true.
  bool get hasValue => _value != null;

  /// Whether [error] is not null.
  ///
  /// Even if [hasError] is true, it is still possible for [hasValue]/[isLoading]
  /// to also be true.
  // It is safe to check it through `error != null` because `error` is non-nullable
  // on the AsyncError constructor.
  bool get hasError => _error != null;

  /// Upcast [AsyncValue] into an [AsyncData], or return null if the [AsyncValue]
  /// is an [AsyncLoading]/[AsyncError].
  ///
  /// Note that an [AsyncData] may still be in loading/error state, such
  /// as during a pull-to-refresh.
  AsyncData<ValueT>? get asData {
    return map(data: (d) => d, error: (e) => null, loading: (l) => null);
  }

  /// Upcast [AsyncValue] into an [AsyncError], or return null if the [AsyncValue]
  /// is an [AsyncLoading]/[AsyncData].
  ///
  /// Note that an [AsyncError] may still be in loading state, such
  /// as during a pull-to-refresh.
  AsyncError<ValueT>? get asError =>
      map(data: (_) => null, error: (e) => e, loading: (_) => null);

  /// Perform some action based on the current state of the [AsyncValue].
  ///
  /// This allows reading the content of an [AsyncValue] in a type-safe way,
  /// without potentially ignoring to handle a case.
  NewT map<NewT>({
    required NewT Function(AsyncData<ValueT> data) data,
    required NewT Function(AsyncError<ValueT> error) error,
    required NewT Function(AsyncLoading<ValueT> loading) loading,
  }) {
    final that = this;
    switch (that) {
      case AsyncLoading():
        return loading(that);
      case AsyncData():
        return data(that);
      case AsyncError():
        return error(that);
    }
  }

  /// Shorthand for [when] to handle only the `data` case.
  ///
  /// For loading/error cases, creates a new [AsyncValue] with the corresponding
  /// generic type while preserving the error/stacktrace.
  AsyncValue<NewT> whenData<NewT>(NewT Function(ValueT value) cb) {
    return map(
      data: (d) {
        try {
          return AsyncData._(
            (cb(d.value), kind: null, source: null),
            loading: d._loading,
            error: d._error,
          );
        } catch (err, stack) {
          return AsyncError._(
            (err: err, stack: stack, retrying: null),
            loading: d._loading,
            value: null,
          );
        }
      },
      error: (e) => AsyncError._(e._error, loading: e._loading, value: null),
      loading: (l) => AsyncLoading<NewT>(progress: progress),
    );
  }

  /// Switch-case over the state of the [AsyncValue] while purposefully not handling
  /// some cases.
  ///
  /// If [AsyncValue] was in a case that is not handled, will return [orElse].
  ///
  /// {@macro async_value.skip_flags}
  NewT maybeWhen<NewT>({
    bool skipLoadingOnReload = false,
    bool skipLoadingOnRefresh = true,
    bool skipError = false,
    NewT Function(ValueT data)? data,
    NewT Function(Object error, StackTrace stackTrace)? error,
    NewT Function()? loading,
    required NewT Function() orElse,
  }) {
    return when(
      skipError: skipError,
      skipLoadingOnRefresh: skipLoadingOnRefresh,
      skipLoadingOnReload: skipLoadingOnReload,
      data: data ?? (_) => orElse(),
      error: error ?? (err, stack) => orElse(),
      loading: loading ?? () => orElse(),
    );
  }

  /// Performs an action based on the state of the [AsyncValue].
  ///
  /// All cases are required, which allows returning a non-nullable value.
  ///
  /// {@template async_value.skip_flags}
  /// By default, [when] skips "loading" states if triggered by a [Ref.refresh]
  /// or [Ref.invalidate] (but does not skip loading states if triggered by [Ref.watch]).
  ///
  /// In the event that an [AsyncValue] is in multiple states at once (such as
  /// when reloading a provider or emitting an error after a valid data),
  /// [when] offers various flags to customize whether it should call
  /// [loading]/[error]/[data] :
  ///
  /// - [skipLoadingOnReload] (false by default) customizes whether [loading]
  ///   should be invoked if a provider rebuilds because of [Ref.watch].
  ///   In that situation, [when] will try to invoke either [error]/[data]
  ///   with the previous state.
  ///
  /// - [skipLoadingOnRefresh] (true by default) controls whether [loading]
  ///   should be invoked if a provider rebuilds because of [Ref.refresh]
  ///   or [Ref.invalidate].
  ///   In that situation, [when] will try to invoke either [error]/[data]
  ///   with the previous state.
  ///
  /// - [skipError] (false by default) decides whether to invoke [data] instead
  ///   of [error] if a previous [value] is available.
  /// {@endtemplate}
  NewT when<NewT>({
    bool skipLoadingOnReload = false,
    bool skipLoadingOnRefresh = true,
    bool skipError = false,
    required NewT Function(ValueT data) data,
    required NewT Function(Object error, StackTrace stackTrace) error,
    required NewT Function() loading,
  }) {
    if (isLoading) {
      bool skip;
      if (isRefreshing) {
        skip = skipLoadingOnRefresh;
      } else if (isReloading) {
        skip = skipLoadingOnReload;
      } else {
        skip = false;
      }
      if (!skip) return loading();
    }

    if (hasError && (!hasValue || !skipError)) {
      return error(this.error!, stackTrace!);
    }

    return data(requireValue);
  }

  /// Perform actions conditionally based on the state of the [AsyncValue].
  ///
  /// Returns null if [AsyncValue] was in a state that was not handled.
  /// This is similar to [maybeWhen] where `orElse` returns null.
  ///
  /// {@macro async_value.skip_flags}
  NewT? whenOrNull<NewT>({
    bool skipLoadingOnReload = false,
    bool skipLoadingOnRefresh = true,
    bool skipError = false,
    NewT? Function(ValueT data)? data,
    NewT? Function(Object error, StackTrace stackTrace)? error,
    NewT? Function()? loading,
  }) {
    return when(
      skipError: skipError,
      skipLoadingOnRefresh: skipLoadingOnRefresh,
      skipLoadingOnReload: skipLoadingOnReload,
      data: data ?? (_) => null,
      error: error ?? (err, stack) => null,
      loading: loading ?? () => null,
    );
  }

  /// Perform some actions based on the state of the [AsyncValue], or call orElse
  /// if the current state was not tested.
  NewT maybeMap<NewT>({
    NewT Function(AsyncData<ValueT> data)? data,
    NewT Function(AsyncError<ValueT> error)? error,
    NewT Function(AsyncLoading<ValueT> loading)? loading,
    required NewT Function() orElse,
  }) {
    return map(
      data: (d) {
        if (data != null) return data(d);
        return orElse();
      },
      error: (d) {
        if (error != null) return error(d);
        return orElse();
      },
      loading: (d) {
        if (loading != null) return loading(d);
        return orElse();
      },
    );
  }

  /// Perform some actions based on the state of the [AsyncValue], or return null
  /// if the current state wasn't tested.
  NewT? mapOrNull<NewT>({
    NewT? Function(AsyncData<ValueT> data)? data,
    NewT? Function(AsyncError<ValueT> error)? error,
    NewT? Function(AsyncLoading<ValueT> loading)? loading,
  }) {
    return map(
      data: (d) => data?.call(d),
      error: (d) => error?.call(d),
      loading: (d) => loading?.call(d),
    );
  }

  /// The opposite of [copyWithPrevious], reverting to the raw [AsyncValue]
  /// with no information on the previous state.
  AsyncValue<ValueT> unwrapPrevious() {
    final that = this;
    return switch (that) {
      AsyncValue(isLoading: true) ||
      AsyncLoading() => AsyncLoading<ValueT>(progress: that.progress),
      AsyncData() => AsyncData<ValueT>(that.value),
      AsyncError() => AsyncError<ValueT>(that.error, that.stackTrace),
    };
  }
}

@internal
enum DataKind { cache, live }

@internal
enum DataSource { liveOrRefresh, reload }

typedef _DataRecord<ValueT> = (ValueT, {DataKind? kind, DataSource? source});

/// Not public
@internal
typedef DataFilledRecord<ValueT> =
    ({ValueT value, DataKind kind, DataSource? source});
typedef _ErrorRecord = ({Object err, StackTrace stack, bool? retrying});
typedef _ErrorFilledRecord =
    ({Object error, StackTrace stackTrace, bool retrying});
typedef _LoadingRecord = ({num? progress});

/// [AsyncValue.requireValue] was called on an [AsyncValue] with no error nor a value.
///
/// {@macro chaining_providers_synchronously}
class AsyncValueIsLoadingException implements Exception {
  AsyncValueIsLoadingException._(this.value);

  /// The [AsyncValue] that was in loading state when [AsyncValue.requireValue] was called.
  final AsyncValue<Object?> value;

  @override
  String toString() {
    return 'AsyncValueIsLoadingException: '
        '`requireValue` was called on the async value `$value`, yet it neither has an error nor a value.';
  }
}

/// A utility for safely manipulating asynchronous data.
///
/// By using [AsyncValue], you are guaranteed that you cannot forget to
/// handle the loading/error state of an asynchronous operation.
///
/// [AsyncValue] is a sealed class, and is designed to be used with
/// pattern matching to handle the different states:
///
/// ```dart
/// /// A provider that asynchronously exposes the current user
/// final userProvider = StreamProvider<User>((_) async* {
///   // fetch the user
/// });
///
/// class Example extends ConsumerWidget {
///   @override
///   Widget build(BuildContext context, WidgetRef ref) {
///     final AsyncValue<User> user = ref.watch(userProvider);
///
///     return switch (user) {
///       AsyncValue(hasError: true) => Text('Oops, something unexpected happened'),
///       AsyncValue(:final value, hasValue: true) => Text('Hello ${value.name}'),
///       _ => CircularProgressIndicator(),
///     );
///   }
/// }
/// ```
///
/// If a consumer of an [AsyncValue] does not care about the loading/error
/// state, consider using [requireValue] to read the state:
///
/// ```dart
/// Widget build(BuildContext context, WidgetRef ref) {
///   // Reading .requireValue will be thrown both on loading and error states.
///   final User user = ref.watch(userProvider).requireValue;
///
///   ...
/// }
/// ```
///
/// By using [requireValue], we get an immediate access to the value. At the same
/// time, if we made a mistake and the value is not available, we will get an
/// exception. This is a good thing because it will help us to spot problem.
///
/// {@macro chaining_providers_synchronously}
///
/// See also:
///
/// - [FutureProvider], [StreamProvider] which transforms a [Future] into
///   an [AsyncValue].
/// - [AsyncValue.guard], to simplify transforming a [Future] into an [AsyncValue].
/// {@category Core}
@sealed
@immutable
@publicInRiverpodAndCodegen
sealed class AsyncValue<ValueT> {
  const AsyncValue._();

  /// {@template async_value.data}
  /// Creates an [AsyncValue] with a data.
  /// {@endtemplate}
  // coverage:ignore-start
  const factory AsyncValue.data(ValueT value) = AsyncData<ValueT>;
  // coverage:ignore-end

  /// {@template async_value.loading}
  /// Creates an [AsyncValue] in loading state.
  ///
  /// Prefer always using this constructor with the `const` keyword.
  /// {@endtemplate}
  // coverage:ignore-start
  const factory AsyncValue.loading({num progress}) = AsyncLoading<ValueT>;
  // coverage:ignore-end

  /// {@template async_value.error_ctor}
  /// Creates an [AsyncValue] in the error state.
  ///
  /// _I don't have a [StackTrace], what can I do?_
  /// You can still construct an [AsyncError] by passing [StackTrace.current]:
  ///
  /// ```dart
  /// AsyncValue.error(error, StackTrace.current);
  /// ```
  /// {@endtemplate}
  // coverage:ignore-start
  const factory AsyncValue.error(Object error, StackTrace stackTrace) =
      AsyncError<ValueT>;
  // coverage:ignore-end

  /// Transforms a [Future] that may fail into something that is safe to read.
  ///
  /// This is useful to avoid having to do a tedious `try/catch`. Instead of
  /// writing:
  ///
  /// ```dart
  /// class MyNotifier extends AsyncNotifier<MyData> {
  ///   @override
  ///   Future<MyData> build() => Future.value(MyData());
  ///
  ///   Future<void> sideEffect() async {
  ///     state = const AsyncValue.loading();
  ///     try {
  ///       final response = await dio.get('my_api/data');
  ///       final data = MyData.fromJson(response);
  ///       state = AsyncValue.data(data);
  ///     } catch (err, stack) {
  ///       state = AsyncValue.error(err, stack);
  ///     }
  ///   }
  /// }
  /// ```
  ///
  /// We can use [guard] to simplify it:
  ///
  /// ```dart
  /// class MyNotifier extends AsyncNotifier<MyData> {
  ///   @override
  ///   Future<MyData> build() => Future.value(MyData());
  ///
  ///   Future<void> sideEffect() async {
  ///     state = const AsyncValue.loading();
  ///     // does the try/catch for us like previously
  ///     state = await AsyncValue.guard(() async {
  ///       final response = await dio.get('my_api/data');
  ///       return Data.fromJson(response);
  ///     });
  ///   }
  /// }
  /// ```
  ///
  /// An optional callback can be specified to catch errors only under a certain condition.
  /// In the following example, we catch all exceptions beside FormatExceptions.
  ///
  /// ```dart
  ///   AsyncValue.guard(
  ///    () async { /* ... */ },
  ///     // Catch all errors beside [FormatException]s.
  ///    (err) => err is! FormatException,
  ///   );
  /// }
  /// ```
  static Future<AsyncValue<ValueT>> guard<ValueT>(
    Future<ValueT> Function() future, [
    bool Function(Object)? test,
  ]) async {
    try {
      return AsyncValue.data(await future());
    } catch (err, stack) {
      if (test == null) {
        return AsyncValue.error(err, stack);
      }
      if (test(err)) {
        return AsyncValue.error(err, stack);
      }

      Error.throwWithStackTrace(err, stack);
    }
  }

  _LoadingRecord? get _loading;
  _DataRecord<ValueT>? get _value;
  _ErrorRecord? get _error;

  /// The value currently exposed.
  ///
  /// If currently in error/loading state, will return the previous value.
  /// If there is no previous value available, `null` will be returned.
  ///
  /// If you do not want to return previous value during loading/error states,
  /// consider using [unwrapPrevious]:
  ///
  /// ```dart
  /// ref.watch(provider).unwrapPrevious().value;
  /// ```
  ValueT? get value => _value?.$1;

  /// If [hasValue] is true, returns the value.
  /// Otherwise if [hasError], rethrows the error.
  /// Finally if in loading state, throws a [AsyncValueIsLoadingException].
  ///
  /// This has two main uses:
  /// - Inside widgets, it is used for when the UI assumes that [value] is always present
  ///   (thanks to loading/error states being handled at a different level).
  /// - Inside providers, this enables chaining asynchronous providers in a synchronous manner..
  ///
  /// {@template chaining_providers_synchronously}
  /// ## Chaining asynchronous providers synchronously.
  ///
  /// When [AsyncValueIsLoadingException] (thrown by [requireValue] during loading states)
  /// is thrown within a provider's initialization,
  /// Riverpod will silence it.
  /// Combined with the fact that [Ref.watch] rebuilds a provider when the dependency
  /// changes, this enables combining asynchronous providers in a synchronous manner.
  ///
  /// The following example adds two numbers obtained asynchronously,
  /// in a synchronous manner. This ensures that within the same frame where
  /// one of those asynchronous providers updates, the sum is immediately updated.
  ///
  /// ```dart
  /// // We use FutureProvider + AsyncValue to sycnhronously combine asynchronous providers.
  /// // Notice how the callback of FutureProvider is not marked as async.
  /// final sumProvider = FutureProvider<User>((ref) {
  ///   AsyncValue<int> value = ref.watch(someProvider);
  ///   AsyncValue<int> anotherValue = ref.watch(anotherProvider);
  ///
  ///   return value.requireValue + anotherValue.requireValue;
  /// });
  /// ```
  ///
  /// Note that this usage is only valid within providers that are expected
  /// to create a [FutureOr] (cf [FutureProvider]/[AsyncNotifierProvider]).
  /// {@endtemplate}
  ValueT get requireValue {
    if (hasValue) return value as ValueT;
    if (hasError) {
      assert(this is! AsyncData, 'Bad state');
      throwProviderException(error!, stackTrace!);
    }

    assert(this is! AsyncData, 'Bad state');
    throw AsyncValueIsLoadingException._(this);
  }

  /// The [error].
  Object? get error => _error?.err;

  /// The stacktrace of [error].
  StackTrace? get stackTrace => _error?.stack;

  String get _displayString;

  /// Casts the [AsyncValue] to a different type.
  AsyncValue<NewT> _cast<NewT>();

  /// Clone an [AsyncValue], merging it with [previous].
  ///
  /// When doing so, the resulting [AsyncValue] can contain the information
  /// about multiple state at once.
  /// For example, this allows an [AsyncError] to contain a [value], or even
  /// [AsyncLoading] to contain both a [value] and an [error].
  ///
  /// The optional [isRefresh] flag (true by default) represents whether the
  /// provider rebuilt by [Ref.refresh]/[Ref.invalidate] (if true)
  /// or instead by [Ref.watch] (if false).
  /// This changes the default behavior of [when] and sets the [isReloading]/
  /// [isRefreshing] flags accordingly.
  @internal
  AsyncValue<ValueT> copyWithPrevious(
    AsyncValue<ValueT> previous, {
    bool isRefresh = true,
  });

  @override
  String toString() {
    final content = [
      if (isLoading && this is! AsyncLoading) 'isLoading: $isLoading',
      if (progress case final progress?) 'progress: $progress',
      if (hasValue) 'value: $value',
      if (_error != null) ...[
        'error: $error',
        'stackTrace: $stackTrace',
        if (_errorFilled!.retrying) 'retrying',
      ],
      if (_value?.kind case final valueSource?)
        'valueSource: ${valueSource.name}',
    ].join(', ');

    return '$_displayString<$ValueT>($content)';
  }

  @override
  bool operator ==(Object other) {
    return runtimeType == other.runtimeType &&
        other is AsyncValue<ValueT> &&
        other._loading == _loading &&
        other.valueFilled == valueFilled &&
        other._errorFilled == _errorFilled;
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, _loading, valueFilled, _errorFilled);
}

/// A variant of [AsyncValue] that excludes [AsyncLoading].
///
/// This is useful when you want to represent only data|error states.
@publicInRiverpodAndCodegen
sealed class AsyncResult<ValueT> extends AsyncValue<ValueT> {
  const AsyncResult._() : super._();

  /// A variant of [AsyncValue.guard] that returns an [AsyncResult],
  /// but does not support returning a [Future].
  static AsyncResult<ValueT> guard<ValueT>(ValueT Function() fn) {
    try {
      return AsyncData(fn());
    } catch (err, stack) {
      return AsyncError(err, stack);
    }
  }
}

/// {@macro async_value.data}
/// {@category Core}
@publicInRiverpodAndCodegen
final class AsyncData<ValueT> extends AsyncResult<ValueT> {
  /// {@macro async_value.data}
  const AsyncData(
    ValueT value, {

    /// @nodoc
    @internal DataKind? kind,
  }) : this._((value, kind: kind, source: null), loading: null, error: null);

  const AsyncData._(
    this._value, {
    required _ErrorRecord? error,
    required _LoadingRecord? loading,
  }) : _loading = loading,
       _error = error,
       super._();

  @override
  final _LoadingRecord? _loading;

  @override
  String get _displayString => 'AsyncData';

  @override
  final _DataRecord<ValueT> _value;
  @override
  ValueT get value => _value.$1;

  @override
  final _ErrorRecord? _error;

  @internal
  @override
  AsyncData<ValueT> copyWithPrevious(
    AsyncValue<ValueT> previous, {
    bool isRefresh = true,
  }) {
    return this;
  }

  @override
  AsyncValue<NewT> _cast<NewT>() {
    if (ValueT == NewT) return this as AsyncValue<NewT>;
    return AsyncData<NewT>._(
      _value as _DataRecord<NewT>,
      error: _error,
      loading: _loading,
    );
  }
}

/// {@macro async_value.loading}
/// {@category Core}
@publicInRiverpodAndCodegen
final class AsyncLoading<ValueT> extends AsyncValue<ValueT> {
  /// {@macro async_value.loading}
  const AsyncLoading({num? progress})
    : _value = null,
      _loading = (progress: progress),
      _error = null,
      assert(
        progress == null || (progress >= 0 && progress <= 1),
        'progress must be between 0 and 1',
      ),
      super._();

  const AsyncLoading._(
    this._loading, {
    required _DataRecord<ValueT>? value,
    required _ErrorRecord? error,
  }) : _value = value,
       _error = error,
       super._();

  @override
  final _LoadingRecord _loading;

  @override
  String get _displayString => 'AsyncLoading';

  @override
  final _DataRecord<ValueT>? _value;

  @override
  final _ErrorRecord? _error;

  @override
  AsyncValue<NewT> _cast<NewT>() {
    if (ValueT == NewT) return this as AsyncValue<NewT>;
    return AsyncLoading<NewT>._(
      _loading,
      value: value as _DataRecord<NewT>?,
      error: _error,
    );
  }

  @internal
  @override
  AsyncValue<ValueT> copyWithPrevious(
    AsyncValue<ValueT> previous, {
    bool isRefresh = true,
  }) {
    final previousValue =
        isRefresh
            ? previous._value
            : previous._value?.copyWith(source: (DataSource.reload,));

    if (isRefresh) {
      return previous.map(
        data:
            (previous) => AsyncData._(
              previousValue!,
              error: previous._error,
              loading: _loading,
            ),
        error:
            (previous) => AsyncError._(
              previous._error,
              loading: _loading,
              value: previousValue,
            ),
        loading: (_) {
          return AsyncLoading<ValueT>._(
            _loading,
            value: previousValue,
            error: previous._error,
          );
        },
      );
    } else {
      return AsyncLoading._(
        _loading,
        value: previousValue,
        error: previous._error,
      );
    }
  }
}

/// {@macro async_value.error_ctor}
/// {@category Core}
@publicInRiverpodAndCodegen
final class AsyncError<ValueT> extends AsyncResult<ValueT> {
  /// {@macro async_value.error_ctor}
  const AsyncError(
    Object error,
    StackTrace stackTrace, {
    @internal bool? retrying,
  }) : this._(
         (err: error, stack: stackTrace, retrying: retrying),
         loading: null,
         value: null,
       );

  const AsyncError._(
    this._error, {
    required _DataRecord<ValueT>? value,
    required _LoadingRecord? loading,
  }) : _value = value,
       _loading = loading,
       super._();

  @override
  final _LoadingRecord? _loading;

  @override
  String get _displayString => 'AsyncError';

  @override
  final _DataRecord<ValueT>? _value;

  @override
  final _ErrorRecord _error;

  @override
  Object get error => _error.err;
  @override
  StackTrace get stackTrace => _error.stack;

  @override
  AsyncValue<NewT> _cast<NewT>() {
    if (ValueT == NewT) return this as AsyncValue<NewT>;
    return AsyncError<NewT>._(
      _error,
      loading: _loading,
      value: _value as _DataRecord<NewT>?,
    );
  }

  @internal
  @override
  AsyncError<ValueT> copyWithPrevious(
    AsyncValue<ValueT> previous, {
    bool isRefresh = true,
  }) {
    return AsyncError._(_error, loading: _loading, value: previous._value);
  }
}
```

// ============================================================
// 📦 Package: ref.dart
// 📁 /home/user/.pub-cache/hosted/pub.dev/riverpod-3.3.2/lib/src/core/ref.dart
// ============================================================

```dart
part of '../framework.dart';

@internal
@publicInCodegen
extension $RefArg on Ref {
  // Implementation detail, do not use
  Object? get $arg => _element.origin.argument;

  // Implementation detail, do not use
  ProviderElement get $element => _element;
}

@internal
class UnmountedRefException implements Exception {
  UnmountedRefException(this.origin);

  final ProviderBase<Object?> origin;

  @override
  String toString() {
    return '''
Cannot use the Ref of $origin after it has been disposed. This typically happens if:
- A provider rebuilt, but the previous "build" was still pending and is still performing operations.
  You should therefore either use `ref.onDispose` to cancel pending work, or
  check `ref.mounted` after async gaps or anything that could invalidate the provider.
- You tried to use Ref inside `onDispose` or other life-cycles.
  This is not supported, as the provider is already being disposed.
''';
  }
}

/// {@template riverpod.provider_ref_base}
/// An object used by providers to interact with other providers and the life-cycles
/// of the application.
///
/// See also:
///
/// - [read] and [watch], two methods that allow a provider to consume other providers.
/// - [onDispose], a method that allows performing a task when the provider is destroyed.
/// {@endtemplate}
/// {@category Core}
@publicInRiverpodAndCodegen
sealed class Ref implements BaseRef, MutationTarget {
  Ref._({required this.isFirstBuild, required this.isReload});

  ProviderElement<Object?, Object?> get _element;
  List<KeepAliveLink>? _keepAliveLinks;
  List<void Function()>? _onDisposeListeners;
  List<void Function()>? _onResumeListeners;
  List<void Function()>? _onCancelListeners;
  List<void Function()>? _onAddListeners;
  List<void Function()>? _onRemoveListeners;
  List<void Function()>? _onManualInvalidationListeners;
  bool _inManualInvalidationCallback = false;

  /// Whether we're initializing this provider for the first time.
  ///
  /// **Note**:
  /// When using [Provider.autoDispose], this flag will reset to `true` when the
  /// provider's state was destroyed and later recreated.
  final bool isFirstBuild;

  /// Whether the provider was recomputed without any dependency change.
  ///
  /// This is typically triggered when [refresh] or [invalidate] is called.
  bool get isRefresh => !isFirstBuild && !isReload;

  /// Whether the provider was recomputed after at least one dependency changed.
  ///
  /// This happens when using [watch] and the listened value changes.
  /// It can also trigger when using [invalidate] + `asReload: true`.
  final bool isReload;

  /// Whether this [Ref] is still active.
  ///
  /// All methods on a provider stop being usable once this becomes `false`.
  /// This happens on purpose, and happens to catch possible race conditions.
  ///
  /// The fix is to either use [onDispose] or [mounted] to cancel any pending work.
  ///
  /// Example using [onDispose]:
  ///
  /// ```dart
  /// import 'package:dio/dio.dart';
  /// final myProvider = FutureProvider((ref) async {
  ///   final cancelToken = CancelToken();
  ///   // Cancel pending network requests upon dispose
  ///   ref.onDispose(cancelToken.cancel);
  ///
  ///   return dio.get(..., cancelToken: cancelToken);
  /// });
  /// ```
  ///
  /// Example using [mounted]:
  ///
  /// ```dart
  /// import 'package:dio/dio.dart';
  /// final myProvider = FutureProvider((ref) async {
  ///   await dio.get(..., cancelToken: cancelToken);
  ///   if (!ref.mounted) throw Exception('cancelled');
  ///
  ///   return ...;
  /// });
  /// ```
  ///
  /// It is preferable to use [onDispose] when possible, as this will abort
  /// pending work earlier.
  ///
  /// In both of the examples above, [onDispose] will stop the network request
  /// while it is in progress. While [mounted] will let the network request
  /// complete, and stop its logic after it is done.
  bool get mounted => !_element._disposed && identical(_element.ref, this);

  /// Whether this [Ref] is currently **paused** (no active, non-paused listeners).
  ///
  /// A provider is paused when all of its listeners are removed or temporarily
  /// inactive. The state remains in memory but stops notifying listeners until
  /// it resumes (triggering [onResume]).
  ///
  /// This can happen, for example, when the provider’s listeners are inside a
  /// widget that is not visible due to **TickerMode** being disabled. Paused
  /// providers may later resume without being disposed, unless marked
  /// `autoDispose` without a [keepAlive] link.
  ///
  /// Note that during an asynchronous gap in `build`, a provider might become
  /// paused before the awaited code resumes. In such cases, [onCancel] may have
  /// already been called earlier in the build, so it will not trigger again.
  bool get isPaused => !_element.isActive && !_element._insideBuildFrame;

  /// The [ProviderContainer] that this provider is associated with.
  @override
  ProviderContainer get container => _element.container;

  void _debugAssertCanDependOn(ProviderListenableOrFamily listenable) {
    final dependency = switch (listenable) {
      ProviderOrFamily() => listenable,
      _ => listenable.debugListenedProvider,
    };

    if (dependency == null) return;

    final origin = _element.origin;
    final provider = _element.provider;

    assert(dependency != origin, 'A provider cannot depend on itself');

    final dependencies = origin.from?.dependencies ?? origin.dependencies ?? [];
    final targetDependencies =
        dependency.from?.dependencies ?? dependency.dependencies;

    if (
    // If the target has a null "dependencies", it should never be scoped.
    !(targetDependencies == null ||
        // Ignore dependency check if from an override
        provider != origin ||
        // Families are allowed to depend on themselves with different parameters.
        (origin.from != null && dependency.from == origin.from) ||
        dependencies.contains(dependency.from) ||
        dependencies.contains(dependency))) {
      throw StateError('''
The provider `$origin` depends on `$dependency`, which may be scoped.
Yet `$dependency` is not part of `$origin`'s `dependencies` list.

To fix, add $dependency to $origin's 'dependencies' parameter.
This can be done with either:

@Riverpod(dependencies: [<dependency>])
<your provider>

or:

final <yourProvider> = Provider(dependencies: [<dependency>]);
''');
    }

    final queue = Queue<ProviderElement>();
    _element.visitChildren(queue.add);

    while (queue.isNotEmpty) {
      final current = queue.removeFirst();
      current.visitChildren(queue.add);

      if (current.origin == dependency) {
        final dependencyLoop = _buildDependencyLoop(current, current.origin);
        throw CircularDependencyError._(dependencyLoop);
      }
    }
  }

  List<ProviderBase<Object?>> _buildDependencyLoop(
    ProviderElement from,
    ProviderBase<Object?> to,
  ) {
    final visited = <ProviderElement>{};
    final path = <ProviderBase<Object?>>[to];

    bool _findPath(ProviderElement current) {
      // Already visited, avoid infinite loops
      if (visited.contains(current)) return false;

      visited.add(current);
      path.add(current.origin);

      // If we found the target, return true
      if (current.origin == to) return true;

      // Search through all children
      var found = false;
      current.visitChildren((child) {
        if (!found && !visited.contains(child)) {
          if (_findPath(child)) found = true;
        }
      });

      if (found) return true;

      // Backtrack if this path doesn't lead to the target
      path.removeLast();
      return false;
    }

    from.visitChildren((child) {
      if (!visited.contains(child)) _findPath(child);
    });

    // Ensure the loop is closed by adding the target at the end if it's not already there
    if (path.isNotEmpty && path.last != to) path.add(to);

    return path;
  }

  void _throwIfInvalidUsage({bool skipAssert = false}) {
    if (!skipAssert) {
      assert(
        _debugCallbackStack == 0,
        'Cannot use Ref or modify other providers inside life-cycles/selectors.',
      );
    }
    if (!mounted) {
      throw UnmountedRefException(_element.origin);
    }
  }

  /// Requests for the state of a provider to not be disposed when all the
  /// listeners of the provider are removed.
  ///
  /// Returns an object which allows cancelling this operation, therefore
  /// allowing the provider to dispose itself when all listeners are removed.
  ///
  /// If [keepAlive] is invoked multiple times, all [KeepAliveLink] will have
  /// to be closed for the provider to dispose itself when all listeners are removed.
  @override
  KeepAliveLink keepAlive() {
    _throwIfInvalidUsage();

    final links = _keepAliveLinks ??= [];

    late KeepAliveLink link;
    link = KeepAliveLink._(() {
      if (links.remove(link)) {
        if (links.isEmpty) _element.mayNeedDispose();
      }
    });
    links.add(link);

    return link;
  }

  /// {@template riverpod.refresh}
  /// Forces a provider to re-evaluate its state immediately, and return the created value.
  ///
  /// Writing:
  ///
  /// ```dart
  /// final newValue = ref.refresh(provider);
  /// ```
  ///
  /// is strictly identical to doing:
  ///
  /// ```dart
  /// ref.invalidate(provider);
  /// final newValue = ref.read(provider);
  /// ```
  ///
  /// If you do not care about the return value of [refresh], use [invalidate] instead.
  /// Doing so has the benefit of:
  /// - making the invalidation logic more resilient by avoiding multiple
  ///   refreshes at once.
  /// - possibly avoids recomputing a provider if it isn't
  ///   needed immediately.
  ///
  /// This method is useful for features like "pull to refresh" or "retry on error",
  /// to restart a specific provider.
  /// {@endtemplate}
  @override
  @useResult
  StateT refresh<StateT>(Refreshable<StateT> refreshable) {
    _throwIfInvalidUsage();

    if (kDebugMode) _debugAssertCanDependOn(refreshable);

    return container.refresh(refreshable);
  }

  /// {@template riverpod.invalidate}
  /// Invalidates the state of the provider, destroying the state immediately
  /// and causing the provider to rebuild at some point in the future.
  ///
  /// As opposed to [refresh], the rebuild is not immediate and is instead
  /// delayed by an undefined amount of time.
  /// Typically, the rebuild happens at the next tick of the event loop.
  /// But if a provider is not listened to, the rebuild may be delayed until
  /// the provider is listened to again.
  ///
  /// Calling [invalidate] multiple times will refresh the provider only
  /// once.
  /// Calling [invalidate] will cause the provider to be disposed immediately.
  ///
  /// - [asReload] (false by default) can be optionally passed to tell
  ///   Riverpod to clear the state before refreshing it.
  ///   This is only useful for asynchronous providers, as by default,
  ///   [AsyncValue] keeps a reference on state during loading states.
  ///   Using [asReload] will disable this behavior and count as a
  ///   "hard refresh".
  ///
  /// If used on a provider which is not initialized or disposed, this method will have no effect.
  /// {@endtemplate}
  @override
  void invalidate(ProviderOrFamily providerOrFamily, {bool asReload = false}) {
    // Allow invalidate calls within onManualInvalidation callbacks
    _throwIfInvalidUsage(skipAssert: _inManualInvalidationCallback);

    if (kDebugMode) _debugAssertCanDependOn(providerOrFamily);

    container.invalidate(providerOrFamily, asReload: asReload);
  }

  /// Invokes [invalidate] on itself.
  ///
  /// {@macro riverpod.invalidate}
  @override
  void invalidateSelf({bool asReload = false}) {
    _invalidateSelf(asReload: asReload, manual: true);
  }

  void _invalidateSelf({required bool asReload, required bool manual}) {
    _throwIfInvalidUsage();

    _element.invalidateSelf(asReload: asReload, manual: manual);
  }

  /// {@template riverpod.onManualInvalidation}
  /// A life-cycle for whenever this provider is manually invalidated, as opposed
  /// to automatic invalidation caused by dependency changes.
  ///
  /// This callback is triggered when:
  /// - [invalidateSelf] is called
  /// - [invalidate] is called on this provider
  /// - [refresh] on this provider
  ///
  /// This callback is NOT triggered when:
  /// - A dependency watched with [watch] changes
  ///
  /// ## Common Use Cases
  ///
  /// **Invalidation forwarding**: Forward manual invalidations to upstream providers:
  /// ```dart
  /// final sourceProvider = Provider((ref) => 'source data');
  ///
  /// final derivedProvider = Provider((ref) {
  ///   final data = ref.watch(sourceProvider);
  ///
  ///   // Forward manual invalidations to the source
  ///   ref.onManualInvalidation(() {
  ///     ref.invalidate(sourceProvider);
  ///   });
  ///
  ///   return 'processed: $data';
  /// });
  /// ```
  ///
  /// Returns a function which can be called to remove the listener.
  ///
  /// See also:
  /// - [invalidateSelf], to manually invalidate this provider
  /// - [invalidate], to manually invalidate other providers
  /// - [refresh], to forcefully re-evaluate a provider
  /// {@endtemplate}
  @experimental
  RemoveListener onManualInvalidation(void Function() cb) {
    _throwIfInvalidUsage();

    final list = _onManualInvalidationListeners ??= [];
    list.add(cb);

    return () => list.remove(cb);
  }

  /// Notify dependents that this provider has changed.
  ///
  /// This is typically used for mutable state, such as to do:
  ///
  /// ```dart
  /// class TodoList extends Notifier<List<Todo>> {
  ///   @override
  ///   List<Todo>> build() => [];
  ///
  ///   void addTodo(Todo todo) {
  ///     state.add(todo);
  ///     ref.notifyListeners();
  ///   }
  /// }
  /// ```
  @override
  void notifyListeners() {
    _throwIfInvalidUsage();

    if (_element._didBuild) {
      final currentValue = _element.value;
      final currentValueResult = _element.resultForValue(currentValue);

      _element._notifyListeners(
        next: currentValueResult!,
        previous: currentValueResult,
        updateShouldNotifyResult: null,
      );
    }
  }

  /// A life-cycle for whenever a new listener is added to the provider.
  ///
  /// Returns a function which can be called to remove the listener.
  ///
  /// See also:
  /// - [onRemoveListener], for when a listener is removed
  @override
  RemoveListener onAddListener(void Function() cb) {
    _throwIfInvalidUsage();

    final list = _onAddListeners ??= [];
    list.add(cb);

    return () => list.remove(cb);
  }

  /// A life-cycle for whenever a listener is removed from the provider.
  ///
  /// Returns a function which can be called to remove the listener.
  ///
  /// See also:
  /// - [onAddListener], for when a listener is added
  @override
  RemoveListener onRemoveListener(void Function() cb) {
    _throwIfInvalidUsage();

    final list = _onRemoveListeners ??= [];
    list.add(cb);

    return () => list.remove(cb);
  }

  /// Add a listener to perform an operation when the last listener of the provider
  /// is removed.
  ///
  /// This typically means that the provider will be paused (or disposed if
  /// using [Provider.autoDispose]) unless a new listener is added.
  ///
  /// When the callback is invoked, there is no guarantee that the provider
  /// _will_ get paused/dispose. It is possible that after the last listener
  /// is removed, a new listener is immediately added.
  ///
  /// Returns a function which can be called to remove the listener.
  ///
  /// See also:
  /// - [keepAlive], which can be combined with [onCancel] for
  ///   advanced manipulation on when the provider should get disposed.
  /// - [Provider.autoDispose], a modifier which tell a provider that it should
  ///   destroy its state when no longer listened to.
  /// - [onDispose], a life-cycle for when a provider is disposed.
  /// - [onResume], a life-cycle for when the provider is listened to again.
  @override
  RemoveListener onCancel(void Function() cb) {
    _throwIfInvalidUsage();

    final list = _onCancelListeners ??= [];
    list.add(cb);

    return () => list.remove(cb);
  }

  /// A life-cycle for when a provider is listened again after it was paused
  /// (and [onCancel] was triggered).
  ///
  /// Returns a function which can be called to remove the listener.
  ///
  /// See also:
  /// - [keepAlive], which can be combined with [onCancel] for
  ///   advanced manipulation on when the provider should get disposed.
  /// - [Provider.autoDispose], a modifier which tell a provider that it should
  ///   destroy its state when no longer listened to.
  /// - [onDispose], a life-cycle for when a provider is disposed.
  /// - [onCancel], a life-cycle for when all listeners of a provider are removed.
  @override
  RemoveListener onResume(void Function() cb) {
    _throwIfInvalidUsage();

    final list = _onResumeListeners ??= [];
    list.add(cb);

    return () => list.remove(cb);
  }

  /// Adds a listener to perform an operation right before the provider is destroyed.
  ///
  /// This includes:
  /// - when the provider will rebuild (such as when using [watch] or [refresh]).
  /// - when an `autoDispose` provider is no longer used
  /// - when the associated [ProviderContainer]/`ProviderScope` is disposed`.
  ///
  /// **Prefer** having multiple [onDispose], for every disposable object created,
  /// instead of a single large [onDispose]:
  ///
  /// Good:
  /// ```dart
  /// final disposable1 = Disposable(...);
  /// ref.onDispose(disposable1.dispose);
  ///
  /// final disposable2 = Disposable(...);
  /// ref.onDispose(disposable2.dispose);
  /// ```
  ///
  /// Bad:
  /// ```dart
  /// final disposable1 = Disposable(...);
  /// final disposable2 = Disposable(...);
  ///
  /// ref.onDispose(() {
  ///   disposable1.dispose();
  ///   disposable2.dispose();
  /// });
  /// ```
  ///
  /// This is preferable for multiple reasons:
  /// - It is easier for readers to know if a "dispose" is missing for a given
  ///   object. That is because the `dispose` call is directly next to the
  ///   object creation.
  /// - It prevents memory leaks in cases of an exception.
  ///   If an exception happens inside a `dispose()` call, or
  ///   if an exception happens before [onDispose] is called, then
  ///   some of your objects may not be disposed.
  ///
  /// Returns a function which can be called to remove the listener.
  ///
  /// See also:
  ///
  /// - [Provider.autoDispose], a modifier which tell a provider that it should
  ///   destroy its state when no longer listened to.
  /// - [ProviderContainer.dispose], to destroy all providers associated with
  ///   a [ProviderContainer] at once.
  /// - [onCancel], a life-cycle for when all listeners of a provider are removed.
  @override
  RemoveListener onDispose(void Function() listener) {
    _throwIfInvalidUsage();

    final list = _onDisposeListeners ??= [];
    list.add(listener);

    return () => list.remove(listener);
  }

  /// Read the state associated with a provider, without listening to that provider.
  ///
  /// By calling [read] instead of [watch], this will not cause a provider's
  /// state to be recreated when the provider obtained changes.
  ///
  /// A typical use-case for this method is when passing it to the created
  /// object like so:
  ///
  /// ```dart
  /// final configsProvider = FutureProvider(...);
  /// final myServiceProvider = Provider(MyService.new);
  ///
  /// class MyService {
  ///   MyService(this.ref);
  ///
  ///   final Ref ref;
  ///
  ///   Future<User> fetchUser() {
  ///     // We read the current configurations, but do not care about
  ///     // rebuilding MyService when the configurations changes
  ///     final configs = ref.read(configsProvider.future);
  ///
  ///     return dio.get(configs.host);
  ///   }
  /// }
  /// ```
  ///
  /// By passing [Ref] to an object, this allows our object to read other providers.
  /// But we do not want to re-create our object if any of the provider
  /// obtained changes. We only want to read their current value without doing
  /// anything else.
  ///
  /// If possible, avoid using [read] and prefer [watch], which is generally
  /// safer to use.
  @override
  StateT read<StateT>(ProviderListenable<StateT> listenable) {
    _throwIfInvalidUsage();

    final result = container.read(listenable);

    if (kDebugMode) _debugAssertCanDependOn(listenable);

    return result;
  }

  /// {@template riverpod.exists}
  /// Determines whether a provider is initialized or not.
  ///
  /// Writing logic that conditionally depends on the existence of a provider
  /// is generally unsafe and should be avoided.
  /// The problem is that once the provider gets initialized, logic that
  /// depends on the existence or not of a provider won't be rerun; possibly
  /// causing your state to get out of date.
  ///
  /// But it can be useful in some cases, such as to avoid re-fetching an
  /// object if a different network request already obtained it:
  ///
  /// ```dart
  /// final fetchItemList = FutureProvider<List<Item>>(...);
  ///
  /// final fetchItem = FutureProvider.autoDispose.family<Item, String>((ref, id) async {
  ///   if (ref.exists(fetchItemList)) {
  ///     // If `fetchItemList` is initialized, we look into its state
  ///     // and return the already obtained item.
  ///     final itemFromItemList = await ref.watch(
  ///       fetchItemList.selectAsync((items) => items.firstWhereOrNull((item) => item.id == id)),
  ///     );
  ///     if (itemFromItemList != null) return itemFromItemList;
  ///   }
  ///
  ///   // If `fetchItemList` is not initialized, perform a network request for
  ///   // "id" separately
  ///
  ///   final json = await http.get('api/items/$id');
  ///   return Item.fromJson(json);
  /// });
  /// ```
  /// {@endtemplate}
  @override
  bool exists(ProviderBase<Object?> provider) {
    _throwIfInvalidUsage();

    final result = container.exists(provider);

    if (kDebugMode) _debugAssertCanDependOn(provider);

    return result;
  }

  /// Obtains the state of a provider and causes the state to be re-evaluated
  /// when that provider emits a new value.
  ///
  /// Using [watch] allows supporting the scenario where we want to re-create
  /// our state when one of the object we are listening to changed.
  ///
  /// This method should be your go-to way to make a provider read another
  /// provider – even if the value exposed by that other provider never changes.
  ///
  /// ## Use-case example: Sorting a todo-list
  ///
  /// Consider a todo-list application. We may want to implement a sort feature,
  /// to see the uncompleted todos first.\
  /// We will want to create a sorted list of todos based on the
  /// combination of the unsorted list and a sort method (ascendant, descendant, ...),
  /// both of which may change over time.
  ///
  /// In this situation, what we do not want to do is to sort our list
  /// directly inside the `build` method of our UI, as sorting a list can be
  /// expensive.
  /// But maintaining a cache manually is difficult and error prone.
  ///
  /// To solve this problem, we could create a separate [Provider] that will
  /// expose the sorted list, and use [watch] to automatically re-evaluate
  /// the list **only** when needed.
  ///
  /// In code, this may look like:
  ///
  /// ```dart
  /// final sortProvider = StateProvider((_) => Sort.byName);
  /// final unsortedTodosProvider = StateProvider((_) => <Todo>[]);
  ///
  /// final sortedTodosProvider = Provider((ref) {
  ///   // listen to both the sort enum and the unfiltered list of todos
  ///   final sort = ref.watch(sortProvider);
  ///   final todos = ref.watch(unsortedTodosProvider);
  ///
  ///   // Creates a new sorted list from the combination of the unfiltered
  ///   // list and the filter type.
  ///   return [...todos].sort((a, b) { ... });
  /// });
  /// ```
  ///
  /// In this code, by using [Provider] + [watch]:
  ///
  /// - if either `sortProvider` or `unsortedTodosProvider` changes, then
  ///   `sortedTodosProvider` will automatically be recomputed.
  /// - if multiple widgets depends on `sortedTodosProvider` the list will be
  ///   sorted only once.
  /// - if nothing is listening to `sortedTodosProvider`, then no sort is performed.
  ///
  ///
  /// **Note**:
  /// This can be considered as the combination of [listen] and [invalidateSelf] :
  /// ```dart
  /// T watch<T>(ProviderListenable<T> provider) {
  ///    final sub = listen(provider, (previous, next) {
  ///      invalidateSelf(asReload: true);
  ///    });
  ///    return sub.read();
  /// }
  /// ```
  @override
  StateT watch<StateT>(ProviderListenable<StateT> listenable) {
    _throwIfInvalidUsage();
    late ProviderSubscription<StateT> sub;
    sub = _element.listen<StateT>(
      listenable,
      (prev, value) => _invalidateSelf(asReload: true, manual: false),
      onError: (err, stack) => _invalidateSelf(asReload: true, manual: false),
      onDependencyMayHaveChanged: _element._markDependencyMayHaveChanged,
    );

    return sub.readSafe().valueOrProviderException;
  }

  /// {@template riverpod.listen}
  /// Listen to a provider and call [listener] whenever its value changes.
  ///
  /// Listeners will automatically be removed when the provider rebuilds (such
  /// as when a provider listened with [Ref.watch] changes).
  ///
  /// Returns an object that allows cancelling the subscription early.
  ///
  ///
  /// [fireImmediately] (false by default) can be optionally passed to tell
  /// Riverpod to immediately call the listener with the current value.
  ///
  /// [onError] can be specified to listen to uncaught errors in the provider.\
  /// **Note:**\
  /// [onError] will _not_ be triggered if the provider catches the exception
  /// and emit a valid value out of it. As such, if a
  /// [FutureProvider]/[StreamProvider] fail, [onError] will not be called.
  /// Instead the listener will receive an [AsyncError].
  ///
  /// - [weak] (false by default) can be optionally passed to have the listener
  ///   not cause the provider to be initialized and kept alive.
  ///   This enables listening to changes on a provider, without causing it to
  ///   perform any work if it currently isn't used.
  /// {@endtemplate}
  @override
  ProviderSubscription<StateT> listen<StateT>(
    ProviderListenable<StateT> provider,
    void Function(StateT? previous, StateT next) listener, {
    void Function(Object error, StackTrace stackTrace)? onError,
    bool weak = false,
    bool fireImmediately = false,
  }) {
    _throwIfInvalidUsage();
    final sub = _element.listen(
      provider,
      listener,
      weak: weak,
      onError: onError,
      fireImmediately: fireImmediately,
    );

    return sub;
  }
}

var _debugCallbackStack = 0;
void _runCallbacks(
  ProviderContainer container,
  List<void Function()>? callbacks,
) {
  if (callbacks == null) return;

  for (final cb in callbacks) {
    try {
      if (kDebugMode) {
        _debugCallbackStack++;
      }
      container.runGuarded(cb);
    } finally {
      if (kDebugMode) {
        _debugCallbackStack--;
      }
    }
  }
}

void _runManualInvalidationCallbacks(ProviderContainer container, Ref? ref) {
  // toList() protects against ConcurrentModificationError
  final callbacks = ref?._onManualInvalidationListeners?.toList();
  if (ref == null || callbacks == null) return;

  for (final cb in callbacks) {
    try {
      if (kDebugMode) {
        _debugCallbackStack++;
      }
      ref._inManualInvalidationCallback = true;
      container.runGuarded(cb);
    } finally {
      ref._inManualInvalidationCallback = false;
      if (kDebugMode) {
        _debugCallbackStack--;
      }
    }
  }
}

@internal
@publicInCodegen
class $Ref<StateT, ValueT> extends Ref {
  /// {@macro riverpod.provider_ref_base}
  $Ref(this._element, {required super.isFirstBuild, required super.isReload})
    : super._();

  ProviderElement<StateT, ValueT> get element => _element;

  @override
  final ProviderElement<StateT, ValueT> _element;

  List<void Function(StateT?, StateT)>? _onChangeSelfListeners;
  List<OnError>? _onErrorSelfListeners;

  /// Listens to changes on the value exposed by this provider.
  ///
  /// The listener will be called immediately after the provider completes building.
  ///
  /// As opposed to [listen], the listener will be called even if
  /// [ProviderElement.updateShouldNotify] returns false, meaning that the previous
  /// and new value can potentially be identical.
  RemoveListener listenSelf(
    void Function(StateT? previous, StateT next) listener, {
    void Function(Object error, StackTrace stackTrace)? onError,
  }) {
    _onChangeSelfListeners ??= [];
    _onChangeSelfListeners!.add(listener);

    if (onError != null) {
      _onErrorSelfListeners ??= [];
      _onErrorSelfListeners!.add(onError);
    }

    return () {
      _onChangeSelfListeners?.remove(listener);
      _onErrorSelfListeners?.remove(onError);
    };
  }
}

/// A object that maintains a provider alive.
@publicInMisc
class KeepAliveLink {
  KeepAliveLink._(this._close);

  final void Function() _close;

  /// Release this [KeepAliveLink], allowing the associated provider to
  /// be disposed if the provider is no-longer listener nor has any
  /// remaining [KeepAliveLink].
  void close() => _close();
}
```

// ============================================================
// 📦 Package: riverpod_annotation.dart
// 📁 /home/user/.pub-cache/hosted/pub.dev/riverpod_annotation-4.0.3/lib/src/riverpod_annotation.dart
// ============================================================

```dart
// DO NOT MOVE/RENAME

import 'package:meta/meta.dart';
import 'package:meta/meta_meta.dart';

import '../experimental/scope.dart';
import '../riverpod_annotation.dart';

/// {@template riverpod_annotation.provider}
/// An annotation placed on classes or functions.
///
/// This tells riverpod_generator to generate a provider out of the annotated.
///
/// By default, Riverpod will convert [Future]s and [Stream]s into [AsyncValue]s.
/// If this is undesired, you can use [Raw] to have Riverpod forcibly return
/// the raw [Future]/[Stream] instead.
/// element.
/// {@endtemplate}
@Target({TargetKind.classType, TargetKind.function})
@sealed
final class Riverpod {
  /// {@macro riverpod_annotation.provider}
  const Riverpod({
    this.keepAlive = false,
    this.dependencies,
    this.retry,
    this.name,
  });

  /// The name of the generated provider.
  ///
  /// If null, the name will be derived from the annotated element,
  /// after applying prefix/suffix transformations from the `build.yaml`
  /// configuration.
  ///
  /// If non-null, transformation from the `build.yaml` will not be applied,
  /// and the name will be used as-is.
  ///
  /// This name should be unique within the library.
  final String? name;

  /// The default retry logic used by providers associated to this container.
  ///
  /// The default implementation:
  /// - has unlimited retries
  /// - starts with a delay of 200ms
  /// - doubles the delay on each retry up to 6.4 seconds
  /// - retries all failures
  final Duration? Function(int retryCount, Object error)? retry;

  /// Whether the state of the provider should be maintained if it is no-longer used.
  ///
  /// Defaults to false.
  final bool keepAlive;

  /// The list of providers that this provider potentially depends on.
  ///
  /// This list must contains the classes/functions annotated with `@riverpod`,
  /// not the generated providers themselves.
  ///
  /// Specifying this list is strictly equivalent to saying "This provider may
  /// be scoped". If a provider is scoped, it should specify [dependencies].
  /// If it is never scoped, it should not specify [dependencies].
  ///
  /// The content of [dependencies] should be a list of all the providers that
  /// this provider may depend on which can be scoped.
  ///
  /// For example, consider the following providers:
  /// ```dart
  /// // By not specifying "dependencies", we are saying that this provider is never scoped
  /// @riverpod
  /// Foo root(Ref ref) => Foo();
  ///
  /// // By specifying "dependencies" (even if the list is empty),
  /// // we are saying that this provider is potentially scoped
  /// @Riverpod(dependencies: [])
  /// Foo scoped(Ref ref) => Foo();
  ///
  /// // Alternatively, notifiers with an abstract build method are also considered scoped
  /// @riverpod
  /// class MyNotifier extends _$MyNotifier {
  ///  @override
  ///  int build();
  /// }
  /// ```
  ///
  /// Then if we were to depend on `rootProvider` in a scoped provider, we
  /// could write any of:
  ///
  /// ```dart
  /// @riverpod
  /// Object? dependent(Ref ref) {
  ///   ref.watch(rootProvider);
  ///   // This provider does not depend on any scoped provider,
  ///   // as such "dependencies" is optional
  /// }
  ///
  /// @Riverpod(dependencies: [])
  /// Object? dependent(Ref ref) {
  ///   ref.watch(rootProvider);
  ///   // This provider decided to specify "dependencies" anyway, marking
  ///   // "dependentProvider" as possibly scoped.
  ///   // Since "rootProvider" is never scoped, it doesn't need to be included
  ///   // in "dependencies".
  /// }
  ///
  /// @Riverpod(dependencies: [root])
  /// Object? dependent(Ref ref) {
  ///   ref.watch(rootProvider);
  ///   // Including "rootProvider" in "dependencies" is fine too, even though
  ///   // it is not required. It is a no-op.
  /// }
  /// ```
  ///
  /// However, if we were to depend on `scopedProvider` then our only choice is:
  ///
  /// ```dart
  /// @Riverpod(dependencies: [scoped])
  /// Object? dependent(Ref ref) {
  ///   ref.watch(scopedProvider);
  ///   // Since "scopedProvider" specifies "dependencies", any provider that
  ///   // depends on it must also specify "dependencies" and include "scopedProvider".
  /// }
  /// ```
  ///
  /// In that scenario, the `dependencies` parameter is required and it must
  /// include `scopedProvider`.
  ///
  /// **Note**:
  /// It is not necessary to specify an empty "dependencies" on notifiers with
  /// an abstract build method:
  /// ```dart
  /// @riverpod
  /// class MyNotifier extends _$MyNotifier {
  ///   @override
  ///   int build(); // Valid, marks this notifier as scoped
  /// }
  /// ```
  ///
  /// See also:
  /// - [Dependencies], for specifying dependencies on non-providers.
  /// - [provider_dependencies](https://github.com/rrousselGit/riverpod/tree/master/packages/riverpod_lint#provider_dependencies-riverpod_generator-only)
  ///   and [scoped_providers_should_specify_dependencies](https://github.com/rrousselGit/riverpod/tree/master/packages/riverpod_lint#scoped_providers_should_specify_dependencies-generator-only).\
  ///   These are lint rules that will warn about incorrect `dependencies` usages.
  final List<Object>? dependencies;
}

/// {@macro riverpod_annotation.provider}
@Target({TargetKind.classType, TargetKind.function})
const riverpod = Riverpod();

/// An annotation used to help the linter find the user-defined element from
/// the generated provider.
///
/// DO NOT USE
class ProviderFor {
  /// An annotation used to help the linter find the user-defined element from
  /// the generated provider.
  // Put the annotation on the constructor to avoid the linter from complaining
  // about the annotation being exported; while preventing the user from using it.
  /// @nodoc
  @internal
  const ProviderFor(this.value)
    : assert(
        value is Function || value is Type,
        '$value is not a class/function',
      );

  /// The code annotated by `@riverpod`
  final Object value;
}

/// {@template riverpod_annotation.raw}
/// An annotation for marking a value type as "should not be handled
/// by Riverpod".
///
/// This is a type-alias to [WrappedT], and has no runtime effect. It is only used
/// as metadata for the code-generator/linter.
///
/// This serves two purposes:
/// - It enables a provider to return a [Future]/[Stream] without
///   having the provider converting it into an [AsyncValue].
///   ```dart
///   @riverpod
///   Raw<Future<int>> myProvider(...) async => ...;
///   ...
///   // returns a Future<int> instead of AsyncValue<int>
///   Future<int> value = ref.watch(myProvider);
///   ```
///
/// - It can silence the linter when a provider returns a value that
///   is otherwise not supported, such as Flutter's `ChangeNotifier`:
///   ```dart
///   // Will not trigger the "unsupported return type" lint
///   @riverpod
///   Raw<MyChangeNotifier> myProvider(...) => MyChangeNotifier();
///   ```
///
/// The typedef can be used at various places within the return type declaration.
///
/// For example, a valid return type is `Future<Raw<ChangeNotifier>>`.
/// This way, Riverpod will convert the [Future] into an [AsyncValue], and
/// the usage of `ChangeNotifier` will not trigger the linter:
///
/// ```dart
/// @riverpod
/// Future<Raw<ChangeNotifier>> myProvider(...) async => ...;
/// ...
/// AsyncValue<ChangeNotifier> value = ref.watch(myProvider);
/// ```
///
/// {@endtemplate}
typedef Raw<WrappedT> = WrappedT;

/// An exception thrown when a scoped provider is accessed when not yet overridden.
///
/// Do not use
class MissingScopeException implements Exception {
  /// An exception thrown when a scoped provider is accessed when not yet overridden.
  MissingScopeException(this.ref);

  /// The [Ref] that threw the exception
  final Ref ref;

  @override
  String toString() {
    final element = ref.$element;

    return 'MissingScopeException: The provider ${element.origin} is scoped, '
        'but was accessed in a place where it is not overridden. '
        'Either you forgot to override the provider, or you tried to read it outside of where it is defined';
  }
}
```
