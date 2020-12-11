import 'package:flutter/widgets.dart';

import 'package:bloc/bloc.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

/// Mixin which allows `MultiBlocProvider` to infer the types
/// of multiple [BlocProvider]s.
mixin BlocProviderSingleChildWidget on SingleChildWidget {}

/// Bloc提供者
class BlocProvider<T extends Cubit<Object>> extends SingleChildStatelessWidget
    with BlocProviderSingleChildWidget {
  /// Bloc提供者
  BlocProvider({
    Key key,
    @required Create<T> create,
    Widget child,
    bool lazy,
  }) : this._(
          key: key,
          create: create,
          dispose: (_, bloc) => bloc?.close(),
          child: child,
          lazy: lazy,
        );

  /// BlocProvider value构造方式
  BlocProvider.value({
    Key key,
    @required T value,
    Widget child,
  }) : this._(
          key: key,
          create: (_) => value,
          child: child,
        );

  /// 内部构建函数.
  BlocProvider._({
    Key key,
    @required Create<T> create,
    Dispose<T> dispose,
    this.child,
    this.lazy,
  })  : _create = create,
        _dispose = dispose,
        super(key: key, child: child);

  /// 子组件
  final Widget child;

  /// 是否延迟创建
  final bool lazy;

  final Dispose<T> _dispose;

  final Create<T> _create;

  /// 通过BuildContext查询Bloc.
  static T of<T extends Cubit<Object>>(
    BuildContext context, {
    bool listen = false,
  }) {
    try {
      return Provider.of<T>(context, listen: listen);
    } on ProviderNotFoundException catch (e) {
      if (e.valueType != T) rethrow;
      throw FlutterError(
        '''
        BlocProvider.of() called with a context that does not contain a Bloc/Cubit of type $T.
        ''',
      );
    }
  }

  @override
  Widget buildWithChild(BuildContext context, Widget child) {
    return InheritedProvider<T>(
      create: _create,
      dispose: _dispose,
      startListening: _startListening,
      child: child,
      lazy: lazy,
    );
  }

  static VoidCallback _startListening(
    InheritedContext<Cubit> e,
    Cubit value,
  ) {
    if (value == null) return () {};
    final subscription = value.listen(
      (Object _) {
        e.markNeedsNotifyDependents();
      },
    );
    if (subscription == null) return () {};
    return subscription.cancel;
  }
}
