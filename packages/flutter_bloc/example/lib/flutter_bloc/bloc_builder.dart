import 'package:example/flutter_bloc/bloc_listener.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart' as flutter_bloc;

typedef BlocWidgetBuilder<S> = Widget Function(BuildContext context, S state);
typedef BlocWidgetCondition<S> = bool Function(S previous, S current);

///BlocBuilder
class BlocBuilder<C extends flutter_bloc.Cubit<S>, S>
    extends BlocBuilderBase<C, S> {
  ///BlocBuilder
  BlocBuilder({
    Key key,
    C cubit,
    @required this.builder,
    BlocWidgetCondition<S> buildWhen,
  }) : super(key: key, cubit: cubit, buildWhen: buildWhen);

  /// 暴露给外部的widget 构建方式
  final BlocWidgetBuilder<S> builder;

  @override
  Widget build(BuildContext context, S state) {
    return builder(context, state);
  }
}

///BlocBuilder base class
abstract class BlocBuilderBase<C extends flutter_bloc.Cubit<S>, S>
    extends StatefulWidget {
  ///BlocBuilderBase.
  const BlocBuilderBase({Key key, this.cubit, this.buildWhen})
      : super(key: key);

  ///Cubit.
  final C cubit;

  /// 子类重写这个build方法.
  Widget build(BuildContext context, S state);

  ///判断widget是否需要更新.
  final BlocWidgetCondition<S> buildWhen;

  @override
  State<BlocBuilderBase<C, S>> createState() => _BlocBuilderBaseState<C, S>();
}

class _BlocBuilderBaseState<C extends flutter_bloc.Cubit<S>, S>
    extends State<BlocBuilderBase<C, S>> {
  S _state;

  @override
  Widget build(BuildContext context) {
    return BlocListener<C, S>(
      listener: (BuildContext context, S state) =>
          setState(() => _state = state),
      child: widget.build(context, _state),
      cubit: widget.cubit ?? context.read<C>(),
      listenerWhen: widget.buildWhen,
    );
  }
}
