import 'package:flutter/material.dart';

class DetailPage extends StatelessWidget {
  final String id;
  const DetailPage({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("detail $id"),),
      body: Center(child: Text("you opened item with id : $id"),),
    );
  }
}