import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import 'bloc_provider.dart';

/// 将多个[BlocProvider]小部件合并到一个小部件树中。
class MultiBlocProvider extends MultiProvider {
  /// {@macro multi_bloc_provider}
  MultiBlocProvider({
    Key key,
    @required List<BlocProviderSingleChildWidget> providers,
    @required Widget child,
  })  : assert(providers != null),
        assert(child != null),
        super(key: key, providers: providers, child: child);
}
