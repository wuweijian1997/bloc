import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/single_child_widget.dart';

///
mixin BlocListenerSingleWidget on SingleChildWidget {}

/// Bloc widget listener.
typedef BlocWidgetListener<S> = void Function(BuildContext context, S state);

/// Bloc state 比较.
typedef BlocListenerCondition<S> = bool Function(
    S previousState, S currentState);

///BlocListener
class BlocListener<C extends Cubit<S>, S> extends BlocListenerBase<C, S>
    with BlocListenerSingleWidget {
  ///
  BlocListener({
    Widget child,
    C cubit,
    @required BlocWidgetListener<S> listener,
    BlocListenerCondition<S> listenerWhen,
  }) : super(
          child: child,
          cubit: cubit,
          listener: listener,
          listenerWhen: listenerWhen,
        );
}

/// BlocListenerBase
abstract class BlocListenerBase<C extends Cubit<S>, S>
    extends SingleChildStatefulWidget {
  /// BlocListener Base
  const BlocListenerBase({
    this.child,
    this.cubit,
    this.listener,
    this.listenerWhen,
  });

  /// 子组件
  final Widget child;

  /// Cubit,用于修改 state.
  final C cubit;

  /// state修改的监听.
  final BlocWidgetListener<S> listener;

  /// 比较之前和当前的state来判断是否需要触发listener.
  final BlocListenerCondition<S> listenerWhen;

  @override
  SingleChildState<BlocListenerBase> createState() =>
      _BlocListenerBaseState<C, S>();
}

class _BlocListenerBaseState<C extends Cubit<S>, S>
    extends SingleChildState<BlocListenerBase<C, S>> {
  ///Cubit 订阅
  StreamSubscription<S> _subscription;
  S _previousState;
  C _cubit;

  BlocListenerCondition<S> get listenerWhen => widget.listenerWhen;

  BlocWidgetListener<S> get listener => widget.listener;

  Widget get child => widget.child;

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
    final oldCubit = oldWidget.cubit ?? context.read<C>();
    final currentCubit = widget.cubit ?? oldCubit;

    /// 比较两个cubit是否相等
    if (oldCubit != currentCubit) {
      if (_subscription != null) {
        _unsubscribe();
        _cubit = currentCubit;
        _previousState = _cubit.state;
      }
      _subscribe();
    }
  }

  @override
  Widget buildWithChild(BuildContext context, Widget child) => child;

  void _subscribe() {
    if (_cubit != null) {
      _subscription = _cubit.listen((state) {
        if (listenerWhen?.call(_previousState, state) ?? true) {
          listener?.call(context, state);
        }
        _previousState = state;
      });
    }
  }

  void _unsubscribe() {
    if (_subscription != null) {
      _subscription.cancel();
      _subscription = null;
    }
  }

  @override
  void dispose() {
    _unsubscribe();
    super.dispose();
  }
}
