import 'package:bloc/bloc.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import 'bloc_listener.dart';
import 'bloc_provider.dart';

/// 通过BuildContext和State来返回widget.
/// 类似于 [StreamBuilder].
typedef BlocWidgetBuilder<S> = Widget Function(BuildContext context, S state);

/// 比较当前的state和之前的state,通过返回值来确认要不要重新builder.
typedef BlocBuilderCondition<S> = bool Function(S previous, S current);

/// 提供了构建widget方法,用户可以通过控制 buildWhen的返回值决定是否要rebuild
class BlocBuilder<C extends Cubit<S>, S> extends BlocBuilderBase<C, S> {
  /// {@macro bloc_builder}
  const BlocBuilder({
    Key key,
    @required this.builder,
    C cubit,
    BlocBuilderCondition<S> buildWhen,
  })  : super(key: key, cubit: cubit, buildWhen: buildWhen);

  /// 通过BuildContext和State来返回widget.
  final BlocWidgetBuilder<S> builder;

  @override
  Widget build(BuildContext context, S state) => builder(context, state);
}

/// BlocBuilder的基类.
abstract class BlocBuilderBase<C extends Cubit<S>, S> extends StatefulWidget {
  /// {@macro bloc_builder_base}
  const BlocBuilderBase({Key key, this.cubit, this.buildWhen})
      : super(key: key);

  /// 传入的 Cubit
  final C cubit;

  /// 重新build的时机
  final BlocBuilderCondition<S> buildWhen;

  /// Returns a widget based on the `BuildContext` and current [state].
  Widget build(BuildContext context, S state);

  @override
  State<BlocBuilderBase<C, S>> createState() => _BlocBuilderBaseState<C, S>();
}

class _BlocBuilderBaseState<C extends Cubit<S>, S>
    extends State<BlocBuilderBase<C, S>> {
  C _cubit;
  S _state;

  @override
  void initState() {
    super.initState();
    _cubit = widget.cubit ?? context.read<C>();
    _state = _cubit.state;
  }

  @override
  void didUpdateWidget(BlocBuilderBase<C, S> oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldCubit = oldWidget.cubit ?? context.read<C>();
    final currentCubit = widget.cubit ?? oldCubit;
    if (oldCubit != currentCubit) {
      _cubit = currentCubit;
      _state = _cubit.state;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<C, S>(
      cubit: _cubit,
      listenWhen: widget.buildWhen,
      listener: (context, state) {
        print('BlocBuilder build setState');
        setState(() => _state = state);
      },
      child: widget.build(context, _state),
    );
  }
}
