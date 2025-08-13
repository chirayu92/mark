import 'package:flutter/material.dart';

class kids extends StatefulWidget {
  const kids({super.key});

  @override
  State<kids> createState() => _kidsState();
}

class _kidsState extends State<kids> {
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
