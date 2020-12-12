import 'dart:async';

import 'bloc/index.dart';

void main() {
  cubitMain();
  // blocMain();
}

void cubitMain() {
  print('----------CUBIT----------');

  ///常见一个CounterCubit
  final cubit = CounterCubit();

  print(cubit.state); // 0

  /// 调用 CounterCubit的increment事件
  cubit.increment();

  print(cubit.state); // 1

  /// 关闭cubit
  cubit.close();
}

void blocMain() async {
  print('----------BLOC----------');

  /// 创建一个 bloc
  final bloc = CounterBloc();
  print(bloc.state);

  /// 发送一个增加事件
  bloc.add(CounterEvent.increment);

  /// 事件循环
  await Future<void>.delayed(Duration.zero);

  print(bloc.state);

  /// 关闭 bloc
  await bloc.close();
}

/// 计数Cubit
class CounterCubit extends Cubit<int> {
  ///初始化cubit,默认值为0;
  CounterCubit() : super(0);

  ///增加事件,使用emit触发更新
  void increment() => emit(state + 1);
}

/// Bloc事件
enum CounterEvent { increment }

/// 计数bloc
class CounterBloc extends Bloc<CounterEvent, int> {
  /// 初始化,默认值为0.
  CounterBloc() : super(0);

  ///计数bloc事件处理
  @override
  Stream<int> mapEventToState(CounterEvent event) async* {
    switch (event) {
      case CounterEvent.increment:
        yield state + 1;
        break;
    }
  }
}
