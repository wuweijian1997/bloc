import 'package:bloc/bloc.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import 'bloc_builder.dart';
import 'bloc_listener.dart';

/// 同时提供了 构建widget的方法和 监听事件方法.用户可以通过 buildWhen来控制是否
/// 需要rebuild,通过listenWhen来处理收到的通知事件.
/// 相当于 BlocBuilder 和 BlocListener的融合状态
class BlocConsumer<C extends Cubit<S>, S> extends StatefulWidget {
  /// Bloc Consumer
  const BlocConsumer({
    Key key,
    @required this.builder,
    @required this.listener,
    this.cubit,
    this.buildWhen,
    this.listenWhen,
  })  : assert(builder != null),
        assert(listener != null),
        super(key: key);

  /// Cubit
  final C cubit;

  /// Widget builder, 参数是 BuildContext和State
  final BlocWidgetBuilder<S> builder;

  /// BlocWidget的state改变 listener, 参数是 BuildContext和State,
  /// 可以通过listenWhen来控制调用的时机
  final BlocWidgetListener<S> listener;

  /// 比较当前的state和之前的state,通过返回值来确认要不要重新builder.
  final BlocBuilderCondition<S> buildWhen;

  /// 比较之前和现在的state,返回true 或 false.来确认是否需要调用listener
  final BlocListenerCondition<S> listenWhen;

  @override
  State<BlocConsumer<C, S>> createState() => _BlocConsumerState<C, S>();
}

class _BlocConsumerState<C extends Cubit<S>, S>
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
      _cubit = currentCubit;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<C, S>(
      cubit: _cubit,
      builder: widget.builder,
      buildWhen: (previous, current) {
        if (widget.listenWhen?.call(previous, current) ?? true) {
          widget.listener(context, current);
        }
        return widget.buildWhen?.call(previous, current) ?? true;
      },
    );
  }
}
