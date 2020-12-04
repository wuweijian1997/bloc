import 'dart:async';

import 'index.dart';

abstract class Bloc<Event, State> extends Cubit<State>
    implements EventSink<Event> {
  Bloc(State state) : super(state);

  static BlocObserver observer = BlocObserver();

  final StreamController _eventController = StreamController<Event>.broadcast();

  StreamSubscription subscription;
}