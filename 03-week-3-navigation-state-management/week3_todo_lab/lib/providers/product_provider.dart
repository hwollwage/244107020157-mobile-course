import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProductNotifier extends AsyncNotifier<List<String>> {
  @override
  Future<List<String>> build() async {
    await Future.delayed(const Duration(seconds: 2));
    return ['keyboard', 'mouse', 'monitor'];
    // throw Exception("failed to connect to serper");
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetch());
  }

  Future<List<String>> _fetch() async {
    await Future.delayed(Duration(seconds: 1));
    return ['keyboard', 'mouse', 'monitor', 'headset'];
  }
}

final productProvider = AsyncNotifierProvider<ProductNotifier, List<String>>(ProductNotifier.new);