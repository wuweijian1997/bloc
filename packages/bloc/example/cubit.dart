import 'dart:async';

class Cubit<State> extends Stream<State> {
  Cubit(this._state) {

  }
  State _state;
  State get state => _state;



  @override
  StreamSubscription<State> listen(
    void Function(State event) onData, {
    Function onError,
    void Function() onDone,
    bool cancelOnError,
  }) {

  }
}
