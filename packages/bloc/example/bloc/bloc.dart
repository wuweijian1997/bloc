import 'dart:async';

import 'package:meta/meta.dart';

import 'index.dart';

typedef TransitionFunction<Event, State> = Stream<Transition<Event, State>>
    Function(Event);

abstract class Bloc<Event, State> extends Cubit<State>
    implements EventSink<Event> {
  Bloc(State state) : super(state);

  ///bloc 观察者,回调 onCreate, onEvent, onChange,
  ///onTransition, onError, onClose事件.
  static BlocObserver observer = BlocObserver();

  ///事件 的 StreamController
  final StreamController _eventController = StreamController<Event>.broadcast();

  StreamSubscription<Transition<Event, State>> _transitionSubscription;

  bool _emitted = false;

  ///添加事件
  @override
  void add(Event event) {
    if (_eventController.isClosed) return;
    try {
      onEvent(event);
      _eventController.add(event);
    } catch (error, stackTrace) {
      onError(error, stackTrace);
    }
  }

  @protected
  @mustCallSuper
  void onEvent(Event event) {
    // ignore: invalid_use_of_protected_member
    observer.onEvent(this, event);
  }

  Stream<Transition<Event, State>> transformEvents(Stream<Event> events,
      TransitionFunction<Event, State> transitionFn) {
    return events.asyncExpand(transitionFn);
  }

  ///通过 event 改变 state.子类实现
  Stream<State> mapEventToState(Event event);

  Stream<Transition<Event, State>> transformTransitions(
      Stream<Transition<Event, State>> transitions
      ) {
    return transitions;
  }
}
