/// Har section ki loading state. UI isi se loading / error / empty / data decide karta hai.
sealed class LoadState<T> {
  const LoadState();
}

final class LoadIdle<T> extends LoadState<T> {
  const LoadIdle();
}

final class LoadLoading<T> extends LoadState<T> {
  const LoadLoading();
}

final class LoadError<T> extends LoadState<T> {
  final String message;
  const LoadError(this.message);
}

final class LoadData<T> extends LoadState<T> {
  final T value;
  const LoadData(this.value);
}
