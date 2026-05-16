// path: lib/shared/model/save_result_model.dart
// new file: Refactored from hasil_simpan_model.dart to use English naming conventions.

import 'package:wifi/shared/debug/log.dart';

/// A generic model to represent the result of a save or update operation.
class SaveResultModel<T> {
  /// Indicates whether the operation was successful.
  final bool success;

  /// A message providing more detail about the operation's result.
  final String message;

  /// Optional data that may be returned upon a successful operation.
  final T? data;

  /// Constructor for `SaveResultModel`.
  SaveResultModel({
    required this.success,
    required this.message,
    this.data,
  }) {
    Log.info('SaveResultModel created: success=$success, message=$message');
  }
}
