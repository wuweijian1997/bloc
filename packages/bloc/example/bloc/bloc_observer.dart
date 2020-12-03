import 'package:meta/meta.dart';

import 'cubit.dart';

class BlocObserver {
  @protected
  @mustCallSuper
  void onCreate() {}

  @protected
  @mustCallSuper
  void onEvent() {}

  @protected
  @mustCallSuper
  void onChange() {}

  @protected
  @mustCallSuper
  void onTransition() {}

  @protected
  @mustCallSuper
  void onError(Cubit cubit, Object error, StackTrace stackTrace) {

  }

  @protected
  @mustCallSuper
  void onClose(Cubit cubit) {}
}