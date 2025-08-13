import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mark/HomePage.dart';
import 'Register.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});


  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  bool _obsecure=true;
  bool _rememberMe = false;

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  FirebaseAuth _auth = FirebaseAuth.instance;
  Future<void> _login()async{
    if (!_formkey.currentState!.validate())
      return;

    try{
      UserCredential userCredential =
      await _auth.signInWithEmailAndPassword(
          email: email.text.trim(),
          password: password.text.trim(),
      );
      final User? user = userCredential.user;

      if(user !=null){
     Navigator.pushReplacement(
         context,
       MaterialPageRoute(builder: (context)=>HomePage()),
     );
      }else{
        _showMessage ("Failed to login");
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        _showMessage( "No user found with this email");
      } else if (e.code == 'invalid-credential') {
        _showMessage("Please check your email or password!");
      } else {
        _showMessage("Error: ${e.message}");
      }
    }
     catch (e){
       _showMessage("Unexpected error: ${e.toString()}");
     }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        //backgroundColor: Colors.blue,
        title: Text(
          "Haat Bazar",
          style:TextStyle(
          fontWeight: FontWeight.bold,
              fontSize: 30,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(40.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formkey,
            child: Column(
                children: [
                  Center(
                    child: Text(
                      "Welcome",
                      style: TextStyle(
                          fontSize: 30,
                          fontWeight:
                          FontWeight.bold,
                          color: Colors.blueAccent
                      ),
                    ),
                  ),
                SizedBox(height: 50),
                TextFormField(
                  controller: email,
                  decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.green.shade100,
                  hintText: "Enter your email",
                  prefixIcon: Icon(Icons.email_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  validator: (value) {if (
                  value == null || value.isEmpty) {
                    return "Please enter email";
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
                  fillColor: Colors.green.shade100,
                  hintText: "Enter your Password",
                  prefixIcon: Icon(Icons.lock),
                  suffixIcon: GestureDetector(
                      onTap: (){
                        setState(() {
                          _obsecure=!_obsecure;
                        });
                      },
                    child: Icon(
                      _obsecure ? Icons.visibility_off : Icons.visibility)
                    ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                  return "Please enter Password";}
                return null;
                },
              ),
              SizedBox(height: 20,),
              Row( mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Checkbox(
                    value: _rememberMe,
                    onChanged: (bool? value) {
                      setState(() {
                      _rememberMe = value!;
                    });
                      },
                ),
                Text("Remember me")
              ],
              ),
              SizedBox(height: 20),
              ElevatedButton(
                  onPressed:_login,
               child: Text("Log In"),),
              SizedBox(height: 15,),
               Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Dont have an account?"),
                  GestureDetector(
                    onTap: (){
                      Navigator.push(context,
                          MaterialPageRoute(
                          builder: (context)=>RegisterPage())
                      );
                    },
                    child: Text(
                      "Register",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              )
               ]
            ),
          ),
        ),
      ),
      // backgroundColor: Colors.yellowAccent,
    );
  }
}
