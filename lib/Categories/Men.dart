import 'package:flutter/material.dart';

class Men extends StatefulWidget {
  const Men({super.key});

  @override
  State<Men> createState() => _MenState();
}

class _MenState extends State<Men> {
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