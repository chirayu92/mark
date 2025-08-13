import 'package:flutter/material.dart';

class Baby extends StatefulWidget {
  const Baby({super.key});

  @override
  State<Baby> createState() => _BabyState();
}

class _BabyState extends State<Baby> {
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
