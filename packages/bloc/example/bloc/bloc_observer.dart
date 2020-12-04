import 'package:meta/meta.dart';

import 'cubit.dart';
import 'index.dart';

class BlocObserver {
  @protected
  @mustCallSuper
  void onCreate(Cubit cubit) {}

  @protected
  @mustCallSuper
  void onEvent(Bloc bloc, Object event) {}

  @protected
  @mustCallSuper
  void onChange(Cubit cubit, Change change) {}

  @protected
  @mustCallSuper
  void onTransition(Bloc bloc, Transition transition) {}

  @protected
  @mustCallSuper
  void onError(Cubit cubit, Object error, StackTrace stackTrace) {}

  @protected
  @mustCallSuper
  void onClose(Cubit cubit) {}
}