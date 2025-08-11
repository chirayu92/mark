import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';

class BestDeals extends StatefulWidget {
  const BestDeals({super.key});

  @override
  State<BestDeals> createState() => _BestDealsState();
}

class _BestDealsState extends State<BestDeals> {
  String? base64Image;
  Future<void> pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source, imageQuality: 70);

    if (pickedFile != null) {
      final compressed = await FlutterImageCompress.compressWithFile(
        pickedFile.path,
        quality: 70,
      );

      if (compressed != null) {
        setState(() {
          base64Image = base64Encode(compressed);
        });
      }
    }
  }

  TextEditingController Name = TextEditingController();
  TextEditingController Price = TextEditingController();
  TextEditingController Discription = TextEditingController();

  Future<void> Best() async {
    // Validate input fields
    if (Name.text.trim().isEmpty || Price.text.trim().isEmpty || Discription.text.trim().isEmpty)
    {
      Fluttertoast.showToast(msg: "Empty field please add items");
      return;  // Stop if validation fails
    }
    try {
      await FirebaseFirestore.instance.collection("Best").doc().set({
        "Name": Name.text,
        "Price": Price.text,
        "Discription": Discription.text,
        "image":base64Image
        //"timestamp": FieldValue.serverTimestamp(),  // Optional: to save timestamp
      });


      // Clear inputs on success
      // Name.clear();
      // Price.clear();
      // Discription.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Item added successfully!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to add item. ")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Best Deals",style:TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 30,
        color: Colors.blueGrey,
      ),),
        centerTitle: true,),
      body:
      Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          children: [
            if (base64Image != null)
              Column(
                children: [
                  const SizedBox(height: 10),
                  const Text("Preview:"),
                  Image.memory(base64Decode(base64Image!), height: 150),
                ],
              ),
            TextFormField(controller: Name,
              decoration: InputDecoration(
                  filled: true,
                  hintText: "Item Name"
              ),),
            SizedBox(height: 30),
            TextFormField(controller: Price,
              decoration: InputDecoration(
                  filled: true,
                  hintText: "Price of Item"
              ),),
            SizedBox(height: 30),

            TextFormField(controller: Discription,
              decoration: InputDecoration(
                  filled: true,
                  hintText: "Discription about item"
              ),),
            SizedBox(height: 30,),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(onPressed: ()=>pickImage(ImageSource.camera),
                    child: Text("Camera",style: TextStyle(
                      fontSize: 20,
                      color: Colors.black,
                    ),
                    )
                ),
                ElevatedButton(onPressed: ()=>pickImage(ImageSource.gallery),
                    child: Text("Gallery",style: TextStyle(
                      fontSize: 20,
                      color: Colors.black,
                    ),
                    )
                ),
              ],),
            SizedBox(height: 30),
            ElevatedButton(onPressed: (){Best();}, child: Text("Add",style: TextStyle(
              fontSize: 20,
              color: Colors.black,
            ),
            )
            ),

          ],
        ),
      ),

    );
  }
}
