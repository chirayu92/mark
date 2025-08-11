import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mark/login.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formkey = GlobalKey<FormState>();

  TextEditingController email = TextEditingController();
  TextEditingController name = TextEditingController();
  TextEditingController address = TextEditingController();
  TextEditingController password = TextEditingController();
  bool _obsecure =true;
  FirebaseAuth _auth = FirebaseAuth.instance;
  Future<void> _register()async{
    if (name.text.isEmpty || email.text.isEmpty || password.text.isEmpty)
      {
        Fluttertoast.showToast(msg: "Empty Fields please fill up the form");
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
        //leading: Icon(Icons.people),
        //actions: [
         // Padding(
           // padding: const EdgeInsets.only(right: 8.0),
           // child: Icon(Icons.bike_scooter),
          //),
        //],
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(40.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formkey,
            child: Column(children: [
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
              ),
              SizedBox(height: 10),
              TextFormField(controller: email,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.green,
                  hintText: "Enter your email",
                  prefixIcon: Icon(Icons.email_outlined),
                ),
              ),
              SizedBox(height: 10),
              TextFormField(controller: address,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.green,
                  hintText: "Enter your address",
                  prefixIcon: Icon(Icons.home),
                ),
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
