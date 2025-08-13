import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mark/login.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
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

  final _formkey = GlobalKey<FormState>();

  TextEditingController email = TextEditingController();
  TextEditingController name = TextEditingController();
  TextEditingController address = TextEditingController();
  TextEditingController phone = TextEditingController();
  TextEditingController password = TextEditingController();

  bool _obsecure =true;
  FirebaseAuth _auth = FirebaseAuth.instance;
  Future<void> _register()async{
    if (!_formkey.currentState!.validate()) {
      Fluttertoast.showToast(msg: "Please fix errors in the form");
      return;
    }

    if (base64Image == null) {
      Fluttertoast.showToast(msg: "Please pick an image");
      return;
    }
    try{
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
          email: email.text,
          password: password.text
      );
      final User user = userCredential.user!;

      if(user !=null) {
        FirebaseFirestore.instance.collection("users").doc(user.uid).set({
          "name": name.text,
          "email": email.text,
          "address": address.text,
          "phone": phone.text,
          "image" : base64Image,
        });
        Fluttertoast.showToast(msg: "Registration Successful");
        Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context)=>LoginPage()),
        );
      }
    } on FirebaseAuthException catch(e) {
      String message = "Registration Failed";
      if (e.code == 'email-already-in-use') {
        message = "This email is already registered";
      } else if (e.code == 'invalid-email') {
        message = 'Invalid email address';
      }
      Fluttertoast.showToast(msg: message);
    }
     catch (e) {
       Fluttertoast.showToast(msg: "unexpected error : ${e.toString()}");
     }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text("Haat Bazar",
            style:TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 30,
            color: Colors.brown
        )),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(40.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formkey,
            child: Column(children: [
              if (base64Image != null) ...[
                const SizedBox(height: 150),
                const Text("Image Preview:"),
                Image.memory(base64Decode(base64Image!), height: 150),
              ],
              Center(child: Text("Please fill the Form",style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  //color: Colors.red
              ),
              ),
              ),
              SizedBox(height: 50),
              TextFormField(controller: name,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.green,
                  hintText: "Enter your name",
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                if (value == null || value.trim().isEmpty){
                  return 'Name is required';
                }
                return null;
                },
              ),
              SizedBox(height: 10),
              TextFormField(controller: email,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.green,
                  hintText: "Enter your email",
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Email is required';
                  }
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value.trim())) {
                    return 'Enter a valid email';
                  }
                  return null;
                },
              ),
              SizedBox(height: 10),
              TextFormField(controller: address,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.green,
                  hintText: "Enter your address",
                  prefixIcon: Icon(Icons.home),
                ),
                validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Address is required';
                }
                return null;
                },
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: phone, // <-- Phone input field with validator
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  filled: true,
                  fillColor: Colors.green,
                  hintText: "Enter your phone number",
                  prefixIcon: Icon(Icons.phone),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Phone number is required';
                  }
                  final digitsOnly = RegExp(r'^\d+$');
                  if (!digitsOnly.hasMatch(value.trim())) {
                    return 'Phone number must contain digits only';
                  }
                  return null;
                },
              ),
              SizedBox(height: 10),
              TextFormField(
                obscureText: _obsecure,
                controller:password,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.green,
                  hintText: "Enter your Password",
                  prefixIcon: Icon(Icons.lock),
                  suffixIcon: GestureDetector(
                      onTap: (){
                        setState(() {
                          _obsecure=!_obsecure;
                        });
                      },
                      child: Icon(Icons.remove_red_eye)),
                ),
              ),
              SizedBox(height: 20,),
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

                ],
              ),
              ElevatedButton(onPressed: _register,
               child: Text("Register")),
            ]
            ),
          ),
        ),
      ),
      //backgroundColor: Colors.yellowAccent,

    );
  }
}
