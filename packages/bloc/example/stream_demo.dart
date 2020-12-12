import 'dart:async';

class StreamDemo {
  StreamController<String> controller;
  void test() {
    controller = StreamController.broadcast();
    controller.sink.add('sink');
    controller.stream.listen((String event) {

    });
  }
}