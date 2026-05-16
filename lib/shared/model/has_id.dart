// path: lib/shared/model/has_id.dart
// new file: Refactored from memiliki_id.dart to use English naming conventions.

/// An interface for models that have an ID property.
///
/// All models in the application that require a unique identity
/// should implement this interface.
///
/// Example:
/// ```dart
/// class UserModel implements HasId {
///   @override
///   final String id;
///
///   UserModel({required this.id});
/// }
/// ```
abstract class HasId {
  /// The unique ID for each model.
  ///
  /// Typically uses a UUID v4 or an ID from the database.
  String get id;
}
