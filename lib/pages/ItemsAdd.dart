import 'package:flutter/material.dart';
import 'package:mark/pages/FlashSale.dart';
import 'package:mark/pages/SummerSale.dart';
import 'package:mark/pages/BestDeals.dart';

class Items extends StatefulWidget {
  const Items({super.key});

  @override
  State<Items> createState() => _ItemsState();
}

class _ItemsState extends State<Items> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title:
      Text("Add you items here"),
      centerTitle: true,),
      body: Padding(
        padding: const EdgeInsets.all(50.0),
        child: Center(
          child: Column(
            children: [
              ElevatedButton(onPressed: (){
                Navigator.push(context,MaterialPageRoute(builder: (context)=> FlashSale()));
                }, child: Text("Flash Sale")),
              SizedBox(height: 30,),
              ElevatedButton(onPressed: (){
                Navigator.push(context, MaterialPageRoute(builder: (context)=> SummerSale()));
              }, child: Text("Summer Sale")),
              SizedBox(height: 30,),
              ElevatedButton(onPressed: (){
                Navigator.push(context, MaterialPageRoute(builder: (context)=>BestDeals()));}, child: Text("Best Deals")),
            ],
          ),
        ),
      )
    );
  }
}
