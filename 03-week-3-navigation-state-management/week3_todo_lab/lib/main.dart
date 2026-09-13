import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:week3_todo_lab/providers/counter_page.dart';
// import 'package:week3_todo_lab/providers/product_page.dart';
// import 'package:week3_todo_lab/providers/todo_page.dart';
import 'package:flutter/material.dart';
import 'package:week3_todo_lab/pages/stats_page.dart';

void main() => runApp(const ProviderScope(child: MyApp()));

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "week 3 - TODO",
      theme: ThemeData(colorSchemeSeed: Colors.teal, useMaterial3: true),
      home: StatsPage(),
    );
  }
}