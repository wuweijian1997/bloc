import 'dart:async';

import 'package:meta/meta.dart';

///Cubit 未处理异常
class CubitUnhandledErrorException implements Exception {
  CubitUnhandledErrorException({this.cubit, this.error, this.stackTrace});

  ///未处理的cubit
  final Cubit cubit;

  ///异常
  final Object error;
  final StackTrace stackTrace;

  @override
  String toString() {
    return 'CubitUnhandledErrorException{cubit: '
        '$cubit, error: $error, stackTrace: $stackTrace}';
  }
}

class Cubit<State> extends Stream<State> {
  Cubit(this._state);

  State _state;

  State get state => _state;

  StreamController<State> _controller;

  bool _emitted = false;

  @protected
  @visibleForTesting
  void emit(State state) {
    _controller ??= StreamController.broadcast();
    if (_controller.isClosed) return;
    if (_state == state && _emitted) return;
    _state = state;
    _controller.add(state);
    _emitted = true;
  }

  @override
  StreamSubscription<State> listen(
    void Function(State event) onData, {
    Function onError,
    void Function() onDone,
    bool cancelOnError,
  }) {
    _controller ??= StreamController.broadcast();
    return _controller.stream.listen(onData,
        onDone: onDone, onError: onError, cancelOnError: cancelOnError);
  }

  @override
  bool get isBroadcast => true;

  Future<void> close() {
    return _controller?.close();
  }
}
