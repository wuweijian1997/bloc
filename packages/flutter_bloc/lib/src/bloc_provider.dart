import 'package:flutter/widgets.dart';

import 'package:bloc/bloc.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

/// Mixin which allows `MultiBlocProvider` to infer the types
/// of multiple [BlocProvider]s.
mixin BlocProviderSingleChildWidget on SingleChildWidget {}

/// {@template bloc_provider}
/// Takes a [Create] function that is responsible for
/// creating the [Bloc] or [Cubit] and a [child] which will have access
/// to the instance via `BlocProvider.of(context)`.
/// It is used as a dependency injection (DI) widget so that a single instance
/// of a [Bloc] or [Cubit] can be provided to multiple widgets within a subtree.
///
/// ```dart
/// BlocProvider(
///   create: (BuildContext context) => BlocA(),
///   child: ChildA(),
/// );
/// ```
///
/// It automatically handles closing the instance when used with [Create].
/// By default, [Create] is called only when the instance is accessed.
/// To override this behavior, set [lazy] to `false`.
///
/// ```dart
/// BlocProvider(
///   lazy: false,
///   create: (BuildContext context) => BlocA(),
///   child: ChildA(),
/// );
/// ```
///
/// {@endtemplate}
class BlocProvider<T extends Cubit<Object>> extends SingleChildStatelessWidget
    with BlocProviderSingleChildWidget {
  /// {@macro bloc_provider}
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

  /// Takes a [value] and a [child] which will have access to the [value] via
  /// `BlocProvider.of(context)`.
  /// When `BlocProvider.value` is used, the [Bloc] or [Cubit]
  /// will not be automatically closed.
  /// As a result, `BlocProvider.value` should only be used for providing
  /// existing instances to new subtrees.
  ///
  /// A new [Bloc] or [Cubit] should not be created in `BlocProvider.value`.
  /// New instances should always be created using the
  /// default constructor within the [Create] function.
  ///
  /// ```dart
  /// BlocProvider.value(
  ///   value: BlocProvider.of<BlocA>(context),
  ///   child: ScreenA(),
  /// );
  /// ```
  BlocProvider.value({
    Key key,
    @required T value,
    Widget child,
  }) : this._(
          key: key,
          create: (_) => value,
          child: child,
        );

  /// Internal constructor responsible for creating the [BlocProvider].
  /// Used by the [BlocProvider] default and value constructors.
  BlocProvider._({
    Key key,
    @required Create<T> create,
    Dispose<T> dispose,
    this.child,
    this.lazy,
  })  : _create = create,
        _dispose = dispose,
        super(key: key, child: child);

  /// Widget which will have access to the [Bloc] or [Cubit].
  final Widget child;

  /// Whether the [Bloc] or [Cubit] should be created lazily.
  /// Defaults to `true`.
  final bool lazy;

  final Dispose<T> _dispose;

  final Create<T> _create;

  /// Method that allows widgets to access a [Bloc] or [Cubit] instance
  /// as long as their `BuildContext` contains a [BlocProvider] instance.
  ///
  /// If we want to access an instance of `BlocA` which was provided higher up
  /// in the widget tree we can do so via:
  ///
  /// ```dart
  /// BlocProvider.of<BlocA>(context);
  /// ```
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
        No ancestor could be found starting from the context that was passed to BlocProvider.of<$T>().

        This can happen if the context you used comes from a widget above the BlocProvider.

        The context used was: $context
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
      (Object _) => e.markNeedsNotifyDependents(),
    );
    if (subscription == null) return () {};
    return subscription.cancel;
  }
}
