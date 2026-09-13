import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("home"),),
      body: ListView.builder(
        itemBuilder: (context, index) => ListTile(
          title: Text("item ${index+1}"),
          onTap: () => context.go('/detail/${index+1}'),
        ),
      ),
    );
  }
}