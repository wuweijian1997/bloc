import 'package:example/flutter_bloc/bloc_builder.dart';
import 'package:example/flutter_bloc/bloc_listener.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart' as flutter_bloc;

///BlocBuilder和BlocListener二合一
class BlocConsumer<C extends flutter_bloc.Cubit<S>, S> extends StatefulWidget {
  ///BlocBuilder和BlocListener二合一
  BlocConsumer({
    this.builder,
    this.buildWhen,
    this.listener,
    this.listenWhen,
    this.cubit,
  });

  /// Cubit
  final C cubit;

  /// 构建方式
  final BlocWidgetBuilder<S> builder;

  /// 判断什么时候构建
  final BlocWidgetCondition<S> buildWhen;

  /// state改变监听
  final BlocWidgetListener<S> listener;

  /// 判断什么时候调用listener
  final BlocListenerCondition<S> listenWhen;

  @override
  State<BlocConsumer<C, S>> createState() => _BlocConsumerState<C, S>();
}

class _BlocConsumerState<C extends flutter_bloc.Cubit<S>, S>
    extends State<BlocConsumer<C, S>> {
  C _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = widget.cubit ?? context.read<C>();
  }

  @override
  void didUpdateWidget(BlocConsumer<C, S> oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldCubit = oldWidget.cubit ?? context.read<C>();
    final currentCubit = widget.cubit ?? oldCubit;
    if (oldCubit != currentCubit) {
      _cubit = oldCubit;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<C, S>(
      cubit: _cubit,
      builder: widget.builder,
      buildWhen: (S previous, S current) {
        if (widget.listenWhen.call(previous, current) ?? true) {
          widget.listener.call(context, current);
        }
        return widget.buildWhen.call(previous, current);
      },
    );
  }
}
