import 'app_error.dart';

// Handler ka jawab: ya to Ok (value ke saath) ya Err (message ke saath)
sealed class Result<T> {
  const Result();

  // Action chalata hai, error aaye to Err banata hai. Har handler ye use karta hai.
  static Future<Result<R>> guard<R>(Future<R> Function() action) async {
    try {
      return Ok(await action());
    } catch (e) {
      return Err(friendlyMessage(e));
    }
  }
}

class Ok<T> extends Result<T> {
  final T value;
  const Ok(this.value);
}

class Err<T> extends Result<T> {
  final String message;
  const Err(this.message);
}
