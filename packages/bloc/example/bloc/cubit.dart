import 'dart:async';

import 'package:meta/meta.dart';

import 'index.dart';

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
  Cubit(this._state) {
    // ignore: invalid_use_of_protected_member
    _observer.onCreate(this);
  }

  State _state;

  State get state => _state;

  BlocObserver get _observer => Bloc.observer;

  StreamController<State> _controller;

  bool _emitted = false;

  @protected
  @visibleForTesting
  void emit(State state) {
    _controller = StreamController.broadcast();
    if (_controller.isClosed) return;
    if (_state == state && _emitted) return;
    onChange(Change<State>(currentState: _state, nextState: state));
    _state = state;
    _controller.add(state);
    _emitted = true;
  }

  @mustCallSuper
  void onChange(Change<State> change) {
    _observer.onChange(this, change);
  }

  void addError(Object error, [StackTrace stackTrace]) {
    onError(error, stackTrace);
  }

  void onError(Object error, [StackTrace stackTrace]) {
    _observer.onError(this, error, stackTrace);
    assert(() {
      throw CubitUnhandledErrorException(
          cubit: this, error: error, stackTrace: stackTrace);
    }());
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

  Future<void> onClose() {
    _observer.onClose(this);
    return _controller?.close();
  }
}
