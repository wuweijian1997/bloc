import 'dart:async';

import 'package:meta/meta.dart';

import 'bloc.dart';
import 'bloc_observer.dart';
import 'change.dart';

/// Cubit 未处理的异常
class CubitUnhandledErrorException implements Exception {
  /// {@macro cubit_unhandled_error_exception}
  CubitUnhandledErrorException(this.cubit, this.error, [this.stackTrace]);

  /// The [cubit] in which the unhandled error occurred.
  final Cubit cubit;

  /// The unhandled [error] object.
  final Object error;

  /// An optional [stackTrace] which accompanied the error.
  final StackTrace stackTrace;

  @override
  String toString() {
    return 'Unhandled error $error occurred in $cubit.\n'
        '${stackTrace ?? ''}';
  }
}

/// [Cubit]是[Bloc]的子集，它没有事件
/// 并且依赖于[emit]新状态的方法。
/// 每个[Cubit]都需要一个初始状态，该初始状态将是// [emit]被调用之前[Cubit]的状态。
/// 可以通过[state] getter访问[Cubit]的当前状态
abstract class Cubit<State> extends Stream<State> {
  /// {@macro cubit}
  Cubit(this._state) {
    // ignore: invalid_use_of_protected_member
    _observer.onCreate(this);
  }

  /// 获取当前的状态
  State get state => _state;

  ///Bloc的观察者
  BlocObserver get _observer => Bloc.observer;

  ///Stream的controller
  StreamController<State> _controller;

  ///当前的状态
  State _state;

  bool _emitted = false;

  /// 改变state的事件
  /// 如果当前controller已关闭不处理
  /// 如果要修改的值和当前的值相同并且 _emitted = true
  @protected
  @visibleForTesting
  void emit(State state) {
    _controller ??= StreamController<State>.broadcast();
    if (_controller.isClosed) return;
    if (state == _state && _emitted) return;
    onChange(Change<State>(currentState: this.state, nextState: state));
    _state = state;
    _controller.add(_state);
    _emitted = true;
  }

  /// Notifies the [Cubit] of an [error] which triggers [onError].
  void addError(Object error, [StackTrace stackTrace]) {
    onError(error, stackTrace);
  }

  ///
  @mustCallSuper
  void onChange(Change<State> change) {
    // ignore: invalid_use_of_protected_member
    _observer.onChange(this, change);
  }

  ///
  @protected
  @mustCallSuper
  void onError(Object error, StackTrace stackTrace) {
    // ignore: invalid_use_of_protected_member
    _observer.onError(this, error, stackTrace);
    assert(() {
      throw CubitUnhandledErrorException(this, error, stackTrace);
    }());
  }

  /// Adds a subscription to the `Stream<State>`.
  /// Returns a [StreamSubscription] which handles events from
  /// the `Stream<State>` using the provided [onData], [onError] and [onDone]
  /// handlers.
  @override
  StreamSubscription<State> listen(
    void Function(State) onData, {
    Function onError,
    void Function() onDone,
    bool cancelOnError,
  }) {
    _controller ??= StreamController<State>.broadcast();
    return _controller.stream.listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }

  ///
  @override
  bool get isBroadcast => true;

  /// Closes the [Cubit].
  /// When close is called, new states can no longer be emitted.
  @mustCallSuper
  Future<void> close() {
    // ignore: invalid_use_of_protected_member
    _observer.onClose(this);
    return _controller?.close();
  }
}
