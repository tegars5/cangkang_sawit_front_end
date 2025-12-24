/// Result type for handling success and failure cases
sealed class Result<T> {
  const Result();
}

/// Success result with data
class Success<T> extends Result<T> {
  final T data;
  const Success(this.data);
}

/// Failure result with error information
class Failure<T> extends Result<T> {
  final String message;
  final int? code;
  final dynamic cause;

  const Failure({required this.message, this.code, this.cause});

  @override
  String toString() => 'Failure(message: $message, code: $code)';
}

/// Extension methods for Result
extension ResultExtension<T> on Result<T> {
  /// Check if result is success
  bool get isSuccess => this is Success<T>;

  /// Check if result is failure
  bool get isFailure => this is Failure<T>;

  /// Get data if success, null otherwise
  T? get dataOrNull => this is Success<T> ? (this as Success<T>).data : null;

  /// Get failure if failure, null otherwise
  Failure<T>? get failureOrNull =>
      this is Failure<T> ? (this as Failure<T>) : null;

  /// Execute callback on success
  Result<T> onSuccess(void Function(T data) callback) {
    if (this is Success<T>) {
      callback((this as Success<T>).data);
    }
    return this;
  }

  /// Execute callback on failure
  Result<T> onFailure(void Function(Failure<T> failure) callback) {
    if (this is Failure<T>) {
      callback(this as Failure<T>);
    }
    return this;
  }

  /// Map success data to another type
  Result<R> map<R>(R Function(T data) transform) {
    if (this is Success<T>) {
      try {
        return Success(transform((this as Success<T>).data));
      } catch (e) {
        return Failure(message: 'Transform error: $e');
      }
    }
    return Failure(
      message: (this as Failure<T>).message,
      code: (this as Failure<T>).code,
      cause: (this as Failure<T>).cause,
    );
  }
}
