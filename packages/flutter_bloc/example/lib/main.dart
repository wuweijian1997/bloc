import 'dart:async';

import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart' as flutter_bloc;

import 'flutter_bloc/index.dart';

void main() {
  runApp(App());
}

///
class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return flutter_bloc.MultiBlocProvider(
      providers: [
        flutter_bloc.BlocProvider<ThemeCubit>(
          create: (BuildContext context) => ThemeCubit(),
        ),
        flutter_bloc.BlocProvider<CounterBloc>(
          create: (BuildContext context) => CounterBloc(),
        ),
      ],
      child: BlocBuilder<ThemeCubit, ThemeData>(
        builder: (_, theme) {
          return MaterialApp(
            theme: theme,
            home: CounterPage(),
          );
        },
      ),
    );
  }
}

/// A [StatelessWidget] which demonstrates
/// how to consume and interact with a [CounterBloc].
class CounterPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Counter')),
      body: BlocConsumer<CounterBloc, int>(
        builder: (_, int count) {
          print('rebuild: count: $count');
          return Center(
            child: Text('$count', style: Theme.of(context).textTheme.headline1),
          );
        },
        listener: (_, int count) {
          print('listener count: $count');
        },
        buildWhen: (prev, current) {
          return prev != current && current % 2 == 0;
        },
        listenWhen: (prev, current) {
          return prev != current && current % 3 == 0;
        },
      ),
      floatingActionButton: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5.0),
            child: FloatingActionButton(
              child: const Icon(Icons.add),
              onPressed: () =>
                  context.read<CounterBloc>().add(CounterEvent.increment),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5.0),
            child: FloatingActionButton(
              child: const Icon(Icons.remove),
              onPressed: () =>
                  context.read<CounterBloc>().add(CounterEvent.decrement),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5.0),
            child: FloatingActionButton(
              child: const Icon(Icons.brightness_6),
              onPressed: () => context.read<ThemeCubit>().toggleTheme(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5.0),
            child: FloatingActionButton(
              backgroundColor: Colors.red,
              child: const Icon(Icons.error),
              onPressed: () => context.read<CounterBloc>().add(null),
            ),
          ),
        ],
      ),
    );
  }
}

/// Event being processed by [CounterBloc].
enum CounterEvent {
  /// Notifies bloc to increment state.
  increment,

  /// Notifies bloc to decrement state.
  decrement
}

/// {@template counter_bloc}
/// A simple [Bloc] which manages an `int` as its state.
/// {@endtemplate}
class CounterBloc extends flutter_bloc.Bloc<CounterEvent, int> {
  /// {@macro counter_bloc}
  CounterBloc() : super(0);

  @override
  Stream<int> mapEventToState(CounterEvent event) async* {
    switch (event) {
      case CounterEvent.decrement:
        yield state - 1;
        break;
      case CounterEvent.increment:
        yield state + 1;
        break;
      default:
        addError(Exception('unsupported event'));
    }
  }
}

/// {@template brightness_cubit}
/// A simple [Cubit] which manages the [ThemeData] as its state.
/// {@endtemplate}
class ThemeCubit extends flutter_bloc.Cubit<ThemeData> {
  /// {@macro brightness_cubit}
  ThemeCubit() : super(_lightTheme);

  static final _lightTheme = ThemeData(
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      foregroundColor: Colors.white,
    ),
    brightness: Brightness.light,
  );

  static final _darkTheme = ThemeData(
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      foregroundColor: Colors.black,
    ),
    brightness: Brightness.dark,
  );

  /// Toggles the current brightness between light and dark.
  void toggleTheme() {
    emit(state.brightness == Brightness.dark ? _lightTheme : _darkTheme);
  }
}
