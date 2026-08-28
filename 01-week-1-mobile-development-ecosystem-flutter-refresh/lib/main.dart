import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: Text("Student Profile"),
          centerTitle: true,
          backgroundColor: Colors.lightBlueAccent,
        ),

        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.school, size: 72,),

              SizedBox(height: 16,),

              Text(
                "Hanzel Putra Wollwage",
                style: TextStyle(fontSize: 24),
              ),
              Text("Mobile Programming - Week 1"),
              Text("NIM: 244107020157", ),
              Text(
                "i use arch btw...😹",
                style: TextStyle(fontSize: 26),
              ),

              SizedBox(height: 16,),

              ElevatedButton(
                onPressed: () => debugPrint("\$7000 from Israel"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightBlueAccent,
                ),
                child: const Text("click for \$7000 from big yahu", style: TextStyle(color: Colors.white),),
              ),
            ],
          ),
        ),
      ),
    );
  }
}