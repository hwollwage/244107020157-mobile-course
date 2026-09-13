import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/counter_provider.dart';

class CounterPage extends ConsumerWidget {
  const CounterPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(counterProvider);

    return Scaffold(
      appBar: AppBar(title: Text("counter"),),

      body: Center(
        child: Text(
          "$count",
          style: const TextStyle(fontSize: 40),
        ),
      ),

      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () {
              ref
                .read(counterProvider.notifier)
                .increment();
            },
            child: const Icon(Icons.add),
          )
        ],
      ),
    );
  }
}