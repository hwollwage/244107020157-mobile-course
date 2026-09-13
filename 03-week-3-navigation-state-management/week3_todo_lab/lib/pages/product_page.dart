import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:week3_todo_lab/providers/product_provider.dart';

class ProductPage extends ConsumerWidget {
  const ProductPage({super.key});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final prodcutAsync = ref.watch(productProvider);

    return Scaffold(
      appBar: AppBar(title: Text("prodcuts async notifier"),),

      body: prodcutAsync.when(
        loading: () => Center(child: CircularProgressIndicator(),),
        error: (error, stackTrace) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("failed to load: $error"),
              FilledButton(
                onPressed: () => ref.invalidate(productProvider),
                child: Text("retry"),
              ),
            ],
          ),
        ),
        data: (products) => ListView.builder(
          itemCount: products.length,
          itemBuilder: (context, index) => ListTile(title: Text(products[index]),),
        ),
      ),
    );
  }
}