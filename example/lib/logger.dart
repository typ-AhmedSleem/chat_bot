class Logger {
  String tag;

  Logger(this.tag);

  void log(String message) {
    print("[FlutterPages-$tag]: $message"); // ignore: avoid_print
  }
}