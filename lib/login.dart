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
  FirebaseAuth _auth = FirebaseAuth.instance;
  Future<void> _login()async{
    if (!_formkey.currentState!.validate()) {
      return;
    }
    try{
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: email.text,
          password: password.text);
      final User user = userCredential.user!;

      if(user !=null){
     Navigator.push(context, MaterialPageRoute(builder: (context)=>HomePage()));
      }else{
        Fluttertoast.showToast(msg: "Failed to login");
      }

    }
     catch (e){
       Fluttertoast.showToast(msg: "Unexpected error: ${e.toString()}");
     }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        //backgroundColor: Colors.blue,
        title: Text("Haat Bazar",style:TextStyle(
          fontWeight: FontWeight.bold,
              fontSize: 30,
        )),
         //leading: Icon(Icons.people),
        // actions: [
        //   Padding(
        //     padding: const EdgeInsets.only(right: 8.0),
        //     child: Icon(Icons.bike_scooter),
        //   ),
        // ],
        // centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Form(
          key: _formkey,
          child: Column(children: [
              Center(child: Text("Welcome",style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                color: Colors.blueAccent
              ),
              ),
              ),
              SizedBox(height: 50),
              TextFormField(controller: email,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.green,
                hintText: "Enter your email",
                prefixIcon: Icon(Icons.email_outlined),
              ),
                validator: (value) {if (value == null || value.isEmpty) {
                  return "Please enter email";}
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
              validator: (value) {if (value == null || value.isEmpty) {
                return "Please enter Password";}
              return null;
              },
            ),
            SizedBox(height: 50,),
            ElevatedButton(onPressed: (){
              _login();
              }, child: Text("Log In")),
            SizedBox(height: 15,),
            // ElevatedButton(onPressed: (){
            //   Navigator.push(context, MaterialPageRoute(builder: (context)=>RegisterPage()));
            // }, child: Text("Register")),
            // Center(
            //   child: Text("Forget Password"),)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Dont have an account?"),
                GestureDetector(
                  onTap: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context)=>RegisterPage()));
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
      // backgroundColor: Colors.yellowAccent,

    );
  }
}
