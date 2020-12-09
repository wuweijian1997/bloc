import 'dart:async';

import 'index.dart';

typedef TransitionFunction<Event, State> = Stream<Transition<Event, State>>
    Function(Event);

abstract class Bloc<Event, State> extends Cubit<State>
    implements EventSink<Event> {
  Bloc(State state) : super(state) {
    _bindEventToState();
  }

  ///事件 的 StreamController
  final StreamController<Event> _eventController = StreamController.broadcast();

  StreamSubscription<Transition<Event, State>> _transitionSubscription;

  bool _emitted = false;

  ///添加事件
  @override
  void add(Event event) {
    if (_eventController.isClosed) return;
    _eventController.add(event);
  }

  Stream<Transition<Event, State>> transformEvents(
      Stream<Event> events, TransitionFunction<Event, State> transitionFn) {
    return events.asyncExpand(transitionFn);
  }

  ///通过 event 改变 state.子类实现
  Stream<State> mapEventToState(Event event);

  Stream<Transition<Event, State>> transformTransitions(
      Stream<Transition<Event, State>> transitions) {
    return transitions;
  }

  @override
  Future<void> close() async {
    await _eventController.close();
    await _transitionSubscription.cancel();
    return super.close();
  }

  @override
  void emit(State state) => super.emit(state);

  void _bindEventToState() {
    var _transformEvents = transformEvents(
      _eventController.stream,
      (event) => mapEventToState(event).map(
        (nextState) => Transition(
          currentState: state,
          event: event,
          nextState: nextState,
        ),
      ),
    );
    var _transformTransitions = transformTransitions(_transformEvents);
    _transitionSubscription = _transformTransitions.listen((event) {
      if (event.nextState == state && _emitted) return;
      emit(event.nextState);
      _emitted = true;
    });
  }

  @override
  void addError(Object error, [StackTrace stackTrace]) {
  }
}
