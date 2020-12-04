import 'package:meta/meta.dart';

@immutable
class Change<State> {
  const Change({@required this.currentState, @required this.nextState});

  /// current state
  final State currentState;
  /// next state
  final State nextState;

  @override
  bool operator ==(Object other) {
    return identical(this, other) || other is Change<State>
        && other.runtimeType == runtimeType
        && other.currentState == currentState
        && other.nextState == nextState;
  }

  @override
  int get hashCode => currentState.hashCode ^ nextState.hashCode;

  @override
  String toString() {
    return 'Change { currentState: $currentState, nextState: $nextState }';
  }
}