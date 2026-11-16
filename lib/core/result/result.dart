/// Every repository call returns one of these, never throws.
/// The `sealed` keyword lets `switch` check that both cases are handled.
sealed class Result<T> {
  const Result();
}

final class Success<T> extends Result<T> {
  const Success(this.value);
  final T value;
}

final class Failure<T> extends Result<T> {
  const Failure(this.message, {this.cause});
  final String message;
  final Object? cause;
}
