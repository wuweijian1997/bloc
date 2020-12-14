import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import 'bloc_provider.dart';

/// Mixin which allows `MultiBlocListener` to infer the types
/// of multiple [BlocListener]s.
mixin BlocListenerSingleChildWidget on SingleChildWidget {}

/// BlocWidget的listener
typedef BlocWidgetListener<S> = void Function(BuildContext context, S state);

/// 比较之前和现在的state,返回true 或 false.
typedef BlocListenerCondition<S> = bool Function(S previous, S current);

/// BlocListener
class BlocListener<C extends Cubit<S>, S> extends BlocListenerBase<C, S>
    with BlocListenerSingleChildWidget {
  /// {@macro bloc_listener}
  const BlocListener({
    Key key,
    @required BlocWidgetListener<S> listener,
    C cubit,
    BlocListenerCondition<S> listenWhen,
    Widget child,
  })  : super(
          key: key,
          child: child,
          listener: listener,
          cubit: cubit,
          listenWhen: listenWhen,
        );
}

/// BlocListener的基类
abstract class BlocListenerBase<C extends Cubit<S>, S>
    extends SingleChildStatefulWidget {
  /// {@macro bloc_listener_base}
  const BlocListenerBase({
    Key key,
    this.listener,
    this.cubit,
    this.child,
    this.listenWhen,
  }) : super(key: key, child: child);

  /// widget组件
  final Widget child;

  /// 修改state
  final C cubit;

  /// 调用listener会触发BlocBuilder的setState
  final BlocWidgetListener<S> listener;

  /// 是否需要调用listener
  final BlocListenerCondition<S> listenWhen;

  @override
  SingleChildState<BlocListenerBase<C, S>> createState() =>
      _BlocListenerBaseState<C, S>();
}

class _BlocListenerBaseState<C extends Cubit<S>, S>
    extends SingleChildState<BlocListenerBase<C, S>> {
  /// Cubit 的 subscription [订阅]
  StreamSubscription<S> _subscription;
  S _previousState;
  C _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = widget.cubit ?? context.read<C>();
    _previousState = _cubit.state;
    _subscribe();
  }

  @override
  void didUpdateWidget(BlocListenerBase<C, S> oldWidget) {
    super.didUpdateWidget(oldWidget);
    /// 这里拿到老的cubit,如果当前widget里有传入cubit则拿这个cubit,否则到InheritedWidget查询cubit.
    final oldCubit = oldWidget.cubit ?? context.read<C>();
    final currentCubit = widget.cubit ?? oldCubit;
    /// 如果两个cubit不相等
    if (oldCubit != currentCubit) {
      /// Cubit 的 subscription [订阅] 不等于 null
      if (_subscription != null) {
        /// 取消订阅.
        _unsubscribe();
        _cubit = currentCubit;
        _previousState = _cubit.state;
      }
      /// 订阅.
      _subscribe();
    }
  }

  @override
  Widget buildWithChild(BuildContext context, Widget child) => child;

  @override
  void dispose() {
    _unsubscribe();
    super.dispose();
  }

  ///订阅
  void _subscribe() {
    ///如果当前 _cubit 不为null
    if (_cubit != null) {
      _subscription = _cubit.listen((state) {
        ///如果BlocBuilder的listenWhen返回的是true,则调用listener也就是
        ///setState(() => _state = state) 更新state
        if (widget.listenWhen?.call(_previousState, state) ?? true) {
          widget.listener(context, state);
        }
        _previousState = state;
      });
    }
  }

  ///取消订阅
  void _unsubscribe() {
    if (_subscription != null) {
      _subscription.cancel();
      _subscription = null;
    }
  }
}
