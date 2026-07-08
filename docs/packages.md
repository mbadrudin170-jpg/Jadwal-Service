# 📚 Dokumentasi File Eksternal & Core

> **Tanggal dibuat:** 2026-07-08 17:56:45
> **Total file unik:** 5

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
