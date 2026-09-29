/// Coordinates screen-level loaders with the shared API activity overlay.
class ApiRequestVisibility {
  ApiRequestVisibility._();

  static int _suppressionCount = 0;
  static void Function()? _listener;

  static bool get isSuppressed => _suppressionCount > 0;

  static void listen(void Function() listener) {
    _listener = listener;
  }

  static void suppress() {
    _suppressionCount++;
    _listener?.call();
  }

  static void resume() {
    if (_suppressionCount == 0) return;
    _suppressionCount--;
    _listener?.call();
  }
}
