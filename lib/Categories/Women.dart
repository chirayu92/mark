import 'package:flutter/material.dart';

class Women extends StatefulWidget {
  const Women({super.key});

  @override
  State<Women> createState() => _WomenState();
}

class _WomenState extends State<Women> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Sorry"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center( child:Image.asset("assets/wop.jpg"),
        ),
      ),
    );
  }
}