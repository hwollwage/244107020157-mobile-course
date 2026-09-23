import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rest_api/pages/post_list_page.dart';

void main() => runApp(const ProviderScope(child: MyApp()));

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "week 4 - REST API",
      theme: ThemeData(
        colorSchemeSeed: Colors.indigo, useMaterial3: true,
      ),
      home: const PostListPage(),
    );
  }
}