import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import 'bloc_listener.dart';

/// 将多个[BlocListener]小部件合并到一个Widget tree中。
class MultiBlocListener extends MultiProvider {
  /// {@macro multi_bloc_listener}
  MultiBlocListener({
    Key key,
    @required List<BlocListenerSingleChildWidget> listeners,
    @required Widget child,
  })  : assert(listeners != null),
        assert(child != null),
        super(key: key, providers: listeners, child: child);
}
