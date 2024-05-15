class Logger {
  String tag;

  Logger(this.tag);

  void log(String message) {
    print("[FP-$tag]: $message"); // ignore: avoid_print
  }
}