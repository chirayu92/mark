import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';

class FlashSale extends StatefulWidget {
  const FlashSale({super.key});

  @override
  State<FlashSale> createState() => _FlashSaleState();
}

class _FlashSaleState extends State<FlashSale> {
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

  Future<void> Flash() async {
    // Validate input fields
    if (Name.text.trim().isEmpty ||
        Price.text.trim().isEmpty ||
        Discription.text.trim().isEmpty ||
        base64Image == null)
    {
      Fluttertoast.showToast(msg: "Empty field please fill up and add image");
      return;  // Stop if validation fails
    }
    try {
      await FirebaseFirestore.instance.collection("Flash").doc().set({
        "Name": Name.text,
        "Price": Price.text,
        "Discription": Discription.text,
        "image":base64Image
        //"timestamp": FieldValue.serverTimestamp(),  // Optional: to save timestamp
      });
      Name.clear();
      Price.clear();
      Discription.clear();
      setState(() {
        base64Image == null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Item added successfully!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to add item. ")),
      );
    }
  }
  Future<void> deleteItem(String id) async {
    await FirebaseFirestore.instance.collection("Flash").doc(id).delete();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Item deleted")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Flash Sale",style:TextStyle(
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
            ElevatedButton(onPressed: (){Flash();}, child: Text("Add",style: TextStyle(
              fontSize: 20,
              color: Colors.black,
            ),)
            ),
            Expanded(child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection("Flash").snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
                  final docs = snapshot.data!.docs;
                   if (docs.isEmpty) return Center(child: Text("No items yet"));
                   return ListView.builder(
                        itemCount: docs.length,
                        itemBuilder: (context, index) {
                        var doc = docs[index];
                      return Card(
                          child: ListTile(
                            leading: doc["image"] != null ? Image.memory(base64Decode(doc["image"]),
                            width: 50, height: 50, fit: BoxFit.cover)
                               : Icon(Icons.image),
                                  title: Text(doc["Name"]),subtitle: Text("Rs. ${doc["Price"]}\n${doc["Discription"]}"),
                                    isThreeLine: true,
                                    trailing: IconButton(
                                      icon: Icon(Icons.delete),
                                      onPressed: () => deleteItem(doc.id),
                                    ),
                          ),
                      );
                      },
                    );
                  },
                ),
              ),
            ],
        ),
      )
    );
  }
}
