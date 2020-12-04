import 'package:meta/meta.dart';

import 'index.dart';

@immutable
class Transition<Event, State> extends Change<State> {
  Transition({this.event, State currentState, State nextState})
      : super(nextState: nextState, currentState: currentState);
  final Event event;
  @override
  bool operator ==(Object other) {
    return identical(this, other) || other is Transition<Event, State>
        && event == other.event && nextState == other.nextState
        && currentState == other.currentState;
  }

  @override
  int get hashCode =>
      currentState.hashCode ^ event.hashCode ^ nextState.hashCode;

  @override
  String toString() {
    return 'Transition{ event: $event, currentState: '
        '$currentState, nextState: $nextState }';
  }
}