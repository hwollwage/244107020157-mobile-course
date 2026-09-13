import 'package:flutter_riverpod/flutter_riverpod.dart';

class CounterProvider extends Notifier<int> {
  @override
  
  int build() {
    return 0;
  }

  void increment() {
    state++;
  }

  void decrement() {
    state--;
  }
}

final counterProvider = NotifierProvider<CounterProvider, int>(CounterProvider.new);